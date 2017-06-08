//
//  Copyright (c) 2017 Open Whisper Systems. All rights reserved.
//

#import "SessionCipher.h"

#import <25519/Curve25519.h>
#import <25519/Ed25519.h>

#import "NSData+keyVersionByte.h"

#import "AxolotlExceptions.h"
#import "SessionBuilder.h"
#import "SessionStore.h"
#import "AES-CBC.h"
#import "AxolotlParameters.h"
#import "MessageKeys.h"
#import "SessionState.h"
#import "ChainKey.h"
#import "RootKey.h"
#import "WhisperMessage.h"

#import "SignedPreKeyStore.h"
#import "PreKeyStore.h"

#import <HKDFKit/HKDFKit.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(major, minor) \
    ([[NSProcessInfo processInfo] isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion){.majorVersion = major, .minorVersion = minor, .patchVersion = 0}])

static dispatch_queue_t _sessionCipherDispatchQueue;

@interface SessionCipher ()

@property (nonatomic, readonly) NSString *recipientId;
@property (nonatomic, readonly) int deviceId;

@property (nonatomic, readonly) id<IdentityKeyStore> identityKeyStore;
@property (nonatomic, readonly) id<SessionStore> sessionStore;
@property (nonatomic, readonly) SessionBuilder *sessionBuilder;
@property (nonatomic, readonly) id<PreKeyStore> prekeyStore;

@end


@implementation SessionCipher


- (instancetype)initWithAxolotlStore:(id<AxolotlStore>)sessionStore recipientId:(NSString*)recipientId deviceId:(int)deviceId{
    return [self initWithSessionStore:sessionStore
                          preKeyStore:sessionStore
                    signedPreKeyStore:sessionStore
                     identityKeyStore:sessionStore
                          recipientId:recipientId
                             deviceId:deviceId];
}

- (instancetype)initWithSessionStore:(id<SessionStore>)sessionStore
                         preKeyStore:(id<PreKeyStore>)preKeyStore
                   signedPreKeyStore:(id<SignedPreKeyStore>)signedPreKeyStore
                    identityKeyStore:(id<IdentityKeyStore>)identityKeyStore
                         recipientId:(NSString*)recipientId
                            deviceId:(int)deviceId{
    self = [super init];

    if (self){
        _recipientId = recipientId;
        _deviceId = deviceId;
        _sessionStore = sessionStore;
        _identityKeyStore = identityKeyStore;
        _sessionBuilder = [[SessionBuilder alloc] initWithSessionStore:sessionStore
                                                           preKeyStore:preKeyStore
                                                     signedPreKeyStore:signedPreKeyStore
                                                      identityKeyStore:identityKeyStore
                                                           recipientId:recipientId
                                                              deviceId:deviceId];
    }
    
    return self;
}

#pragma mark - dispatch queue 

+ (dispatch_queue_t)getSessionCipherDispatchQueue;
{
    if (_sessionCipherDispatchQueue) {
        return _sessionCipherDispatchQueue;
    } else {
        return dispatch_get_main_queue();
    }
}

+ (void)setSessionCipherDispatchQueue:(dispatch_queue_t)dispatchQueue
{
    _sessionCipherDispatchQueue = dispatchQueue;
}

- (void)assertOnSessionCipherDispatchQueue
{
#ifdef DEBUG
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(10, 0)) {
        dispatch_assert_queue([[self class] getSessionCipherDispatchQueue]);
    } // else, skip assert as it's a development convenience.
#endif
}

- (id<CipherMessage>)encryptMessage:(NSData*)paddedMessage{
    [self assertOnSessionCipherDispatchQueue];
    SessionRecord *sessionRecord = [self.sessionStore loadSession:self.recipientId deviceId:self.deviceId];
    SessionState *sessionState = sessionRecord.sessionState;
    ChainKey *chainKey = sessionState.senderChainKey;
    MessageKeys *messageKeys     = chainKey.messageKeys;
    NSData *senderRatchetKey = sessionState.senderRatchetKey;
    int previousCounter = sessionState.previousCounter;
    int sessionVersion = sessionState.version;

    if (![self.identityKeyStore isTrustedIdentityKey:sessionState.remoteIdentityKey
                                         recipientId:self.recipientId
                                           direction:TSMessageDirectionOutgoing]) {
        DDLogWarn(
            @"%@ Previously known identity key for while encrypting for recipient: %@", self.tag, self.recipientId);
        @throw [NSException exceptionWithName:UntrustedIdentityKeyException
                                       reason:@"There is a previously known identity key."
                                     userInfo:@{}];
    }

    if ([self.identityKeyStore saveRemoteIdentity:sessionState.remoteIdentityKey recipientId:self.recipientId]) {
        [sessionRecord removePreviousSessionStates];
    }

    NSData *ciphertextBody = [AES_CBC encryptCBCMode:paddedMessage withKey:messageKeys.cipherKey withIV:messageKeys.iv];

    id<CipherMessage> cipherMessage =
        [[WhisperMessage alloc] initWithVersion:sessionVersion
                                         macKey:messageKeys.macKey
                               senderRatchetKey:senderRatchetKey.prependKeyType
                                        counter:chainKey.index
                                previousCounter:previousCounter
                                     cipherText:ciphertextBody
                              senderIdentityKey:sessionState.localIdentityKey.prependKeyType
                            receiverIdentityKey:sessionState.remoteIdentityKey.prependKeyType];

    if ([sessionState hasUnacknowledgedPreKeyMessage]) {
        PendingPreKey *items = [sessionState unacknowledgedPreKeyMessageItems];
        int localRegistrationId = [sessionState localRegistrationId];

        DDLogInfo(@"Building PreKeyWhisperMessage for: %@ with preKeyId: %d", self.recipientId, items.preKeyId);

        cipherMessage =
            [[PreKeyWhisperMessage alloc] initWithWhisperMessage:cipherMessage
                                                  registrationId:localRegistrationId
                                                        prekeyId:items.preKeyId
                                                  signedPrekeyId:items.signedPreKeyId
                                                         baseKey:items.baseKey.prependKeyType
                                                     identityKey:sessionState.localIdentityKey.prependKeyType];
    }

    [sessionState setSenderChainKey:[chainKey nextChainKey]];
    [self.sessionStore storeSession:self.recipientId deviceId:self.deviceId session:sessionRecord];
    
    return cipherMessage;
}

- (NSData*)decrypt:(id<CipherMessage>)whisperMessage{
    [self assertOnSessionCipherDispatchQueue];
    if ([whisperMessage isKindOfClass:[PreKeyWhisperMessage class]]) {
        return [self decryptPreKeyWhisperMessage:(PreKeyWhisperMessage*)whisperMessage];
    } else{
        return [self decryptWhisperMessage:whisperMessage];
    }
}

- (NSData*)decryptPreKeyWhisperMessage:(PreKeyWhisperMessage*)preKeyWhisperMessage{
    [self assertOnSessionCipherDispatchQueue];
    SessionRecord *sessionRecord = [self.sessionStore loadSession:self.recipientId deviceId:self.deviceId];
    int unsignedPreKeyId         = [self.sessionBuilder processPrekeyWhisperMessage:preKeyWhisperMessage withSession:sessionRecord];
    NSData *plaintext            = [self decryptWithSessionRecord:sessionRecord whisperMessage:preKeyWhisperMessage.message];

    [self.sessionStore storeSession:self.recipientId deviceId:self.deviceId session:sessionRecord];

    // If there was an unsigned PreKey
    if (unsignedPreKeyId >= 0) {
        [self.prekeyStore removePreKey:unsignedPreKeyId];
    }
    
    return plaintext;
}

- (NSData*)decryptWhisperMessage:(WhisperMessage*)message{
    [self assertOnSessionCipherDispatchQueue];

    SessionRecord  *sessionRecord  = [self.sessionStore loadSession:self.recipientId deviceId:self.deviceId];
    NSData         *plaintext      = [self decryptWithSessionRecord:sessionRecord whisperMessage:message];

    if (![self.identityKeyStore isTrustedIdentityKey:sessionRecord.sessionState.remoteIdentityKey
                                         recipientId:self.recipientId
                                           direction:TSMessageDirectionIncoming]) {
        DDLogWarn(
            @"%@ Previously known identity key for while decrypting from recipient: %@", self.tag, self.recipientId);
        @throw [NSException exceptionWithName:UntrustedIdentityKeyException
                                       reason:@"There is a previously known identity key."
                                     userInfo:@{}];
    }

    if ([self.identityKeyStore saveRemoteIdentity:sessionRecord.sessionState.remoteIdentityKey
                                      recipientId:self.recipientId]) {
        [sessionRecord removePreviousSessionStates];
    }

    [self.sessionStore storeSession:self.recipientId deviceId:self.deviceId session:sessionRecord];
    
    return plaintext;
}


-(NSData*)decryptWithSessionRecord:(SessionRecord*)sessionRecord whisperMessage:(WhisperMessage*)message{
    [self assertOnSessionCipherDispatchQueue];
    SessionState   *sessionState   = [sessionRecord sessionState];
    NSMutableArray *exceptions     = [NSMutableArray array];
    
    @try {
        NSData *decryptedData = [self decryptWithSessionState:sessionState whisperMessage:message];
        DDLogDebug(@"%@ successfully decrypted with current session state: %@", self.tag, sessionState);
        return decryptedData;
    }
    @catch (NSException *exception) {
        if ([exception.name isEqualToString:InvalidMessageException]) {
            [exceptions addObject:exception];
        } else {
            @throw exception;
        }
    }

    // If we can decrypt the message with an "old" session state, that means the sender is using an "old" session.
    // In which case, we promote that session to "active" so as to converge on a single session for sending/receiving.
    __block NSUInteger stateToPromoteIdx;
    __block NSData *decryptedData;
    [[sessionRecord previousSessionStates]
        enumerateObjectsUsingBlock:^(SessionState *_Nonnull previousState, NSUInteger idx, BOOL *_Nonnull stop) {
            @try {
                decryptedData = [self decryptWithSessionState:previousState whisperMessage:message];
                DDLogInfo(@"%@ successfully decrypted with PREVIOUS session state: %@", self.tag, previousState);
                NSAssert(decryptedData != nil, @"Expected exception or non-nil data");
                stateToPromoteIdx = idx;
                *stop = YES;
            } @catch (NSException *exception) {
                [exceptions addObject:exception];
            }
        }];

    if (decryptedData) {
        SessionState *sessionStateToPromote = [sessionRecord previousSessionStates][stateToPromoteIdx];
        NSAssert(sessionStateToPromote != nil, @"the session state we just used is now missing");
        DDLogInfo(@"%@ promoting session: %@", self.tag, sessionStateToPromote);
        [[sessionRecord previousSessionStates] removeObjectAtIndex:stateToPromoteIdx];
        [sessionRecord promoteState:sessionStateToPromote];

        return decryptedData;
    }

    BOOL containsActiveSession = [self.sessionStore containsSession:self.recipientId deviceId:self.deviceId];
    DDLogError(@"%@ No valid session for recipient: %@ containsActiveSession: %@, previousStates: %lu",
        self.tag,
        self.recipientId,
        (containsActiveSession ? @"YES" : @"NO"),
        (unsigned long)sessionRecord.previousSessionStates.count);

    if (containsActiveSession) {
        @throw [NSException exceptionWithName:InvalidMessageException
                                       reason:@"No valid sessions"
                                     userInfo:@{
                                         @"Exceptions" : exceptions
                                     }];
    } else {
        @throw [NSException
            exceptionWithName:NoSessionException
                       reason:[NSString stringWithFormat:@"No session for: %@, %d", self.recipientId, self.deviceId]
                     userInfo:nil];
    }
}

-(NSData*)decryptWithSessionState:(SessionState*)sessionState whisperMessage:(WhisperMessage*)message{
    [self assertOnSessionCipherDispatchQueue];
    if (![sessionState hasSenderChain]) {
        @throw [NSException exceptionWithName:InvalidMessageException reason:@"Uninitialized session!" userInfo:nil];
    }
    
    if (message.version != sessionState.version) {
        @throw [NSException exceptionWithName:InvalidMessageException reason:[NSString stringWithFormat:@"Got message version %d but was expecting %d", message.version, sessionState.version] userInfo:nil];
    }

    int messageVersion       = message.version;
    NSData *theirEphemeral   = message.senderRatchetKey.removeKeyType;
    int counter              = message.counter;
    ChainKey *chainKey       = [self getOrCreateChainKeys:sessionState theirEphemeral:theirEphemeral];
    MessageKeys *messageKeys = [self getOrCreateMessageKeysForSession:sessionState theirEphemeral:theirEphemeral chainKey:chainKey counter:counter];
    
    [message verifyMacWithVersion:messageVersion senderIdentityKey:sessionState.remoteIdentityKey receiverIdentityKey:sessionState.localIdentityKey macKey:messageKeys.macKey];
    
    NSData *plaintext = [AES_CBC decryptCBCMode:message.cipherText withKey:messageKeys.cipherKey withIV:messageKeys.iv];
    
    [sessionState clearUnacknowledgedPreKeyMessage];
    
    return plaintext;
}

- (ChainKey*)getOrCreateChainKeys:(SessionState*)sessionState theirEphemeral:(NSData*)theirEphemeral{
    [self assertOnSessionCipherDispatchQueue];
    @try {
        if ([sessionState hasReceiverChain:theirEphemeral]) {
            return [sessionState receiverChainKey:theirEphemeral];
        } else{
            RootKey *rootKey = [sessionState rootKey];
            ECKeyPair *ourEphemeral = [sessionState senderRatchetKeyPair];
            RKCK *receiverChain = [rootKey createChainWithTheirEphemeral:theirEphemeral ourEphemeral:ourEphemeral];
            ECKeyPair *ourNewEphemeral = [Curve25519 generateKeyPair];
            RKCK *senderChain = [receiverChain.rootKey createChainWithTheirEphemeral:theirEphemeral ourEphemeral:ourNewEphemeral];
            
            [sessionState setRootKey:senderChain.rootKey];
            [sessionState addReceiverChain:theirEphemeral chainKey:receiverChain.chainKey];
            [sessionState setPreviousCounter:MAX(sessionState.senderChainKey.index-1 , 0)];
            [sessionState setSenderChain:ourNewEphemeral chainKey:senderChain.chainKey];
            
            return receiverChain.chainKey;
        }
    }
    @catch (NSException *exception) {
        @throw [NSException exceptionWithName:InvalidMessageException reason:@"Chainkeys couldn't be derived" userInfo:nil];
    }
}

- (MessageKeys*)getOrCreateMessageKeysForSession:(SessionState*)sessionState theirEphemeral:(NSData*)theirEphemeral chainKey:(ChainKey*)chainKey counter:(int)counter{
    [self assertOnSessionCipherDispatchQueue];
    if (chainKey.index > counter) {
        if ([sessionState hasMessageKeys:theirEphemeral counter:counter]) {
            return [sessionState removeMessageKeys:theirEphemeral counter:counter];
        }
        else{
            @throw [NSException exceptionWithName:DuplicateMessageException reason:@"Received message with old counter!" userInfo:@{}];
        }
    }
    
    if (chainKey.index - counter > 2000) {
        @throw [NSException exceptionWithName:@"Over 500 messages into the future!" reason:@"" userInfo:@{}];
    }
    
    while (chainKey.index < counter) {
        MessageKeys *messageKeys = [chainKey messageKeys];
        [sessionState setMessageKeys:theirEphemeral messageKeys:messageKeys];
        chainKey = chainKey.nextChainKey;
    }
    
    [sessionState setReceiverChainKey:theirEphemeral chainKey:[chainKey nextChainKey]];
    return [chainKey messageKeys];
}

/**
 *  The current version data. First 4 bits are the current version and the last 4 ones are the lowest version we support.
 *
 *  @return Current version data
 */

+ (NSData*)currentProtocolVersion{
    NSUInteger index = 0b00100010;
    NSData *versionByte = [NSData dataWithBytes:&index length:1];
    return versionByte;
}


- (int)remoteRegistrationId{
    [self assertOnSessionCipherDispatchQueue];
    SessionRecord *record = [self.sessionStore loadSession:self.recipientId deviceId:_deviceId];
    
    if (!record) {
        @throw [NSException exceptionWithName:NoSessionException reason:@"Trying to get registration Id of a non-existing session." userInfo:nil];
    }
    
    return record.sessionState.remoteRegistrationId;
}

- (int)sessionVersion{
    [self assertOnSessionCipherDispatchQueue];
    SessionRecord *record = [self.sessionStore loadSession:self.recipientId deviceId:_deviceId];
    
    if (!record) {
        @throw [NSException exceptionWithName:NoSessionException reason:@"Trying to get the version of a non-existing session." userInfo:nil];
    }
    
    return record.sessionState.version;
}

#pragma mark - Logging

+ (NSString *)tag
{
    return [NSString stringWithFormat:@"[%@]", self.class];
}

- (NSString *)tag
{
    return self.class.tag;
}

@end

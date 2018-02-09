//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
//

#import "SessionCipher.h"
#import "AES-CBC.h"
#import "AxolotlExceptions.h"
#import "AxolotlParameters.h"
#import "ChainKey.h"
#import "MessageKeys.h"
#import "NSData+keyVersionByte.h"
#import "PreKeyStore.h"
#import "RootKey.h"
#import "SessionBuilder.h"
#import "SessionState.h"
#import "SessionStore.h"
#import "SignedPreKeyStore.h"
#import "WhisperMessage.h"
#import <Curve25519Kit/Curve25519.h>
#import <Curve25519Kit/Ed25519.h>
#import <HKDFKit/HKDFKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SessionCipher ()

@property (nonatomic, readonly) NSString *recipientId;
@property (nonatomic, readonly) int deviceId;

@property (nonatomic, readonly) id<IdentityKeyStore> identityKeyStore;
@property (nonatomic, readonly) id<SessionStore> sessionStore;
@property (nonatomic, readonly) SessionBuilder *sessionBuilder;
@property (nonatomic, readonly) id<PreKeyStore> prekeyStore;

@end

#pragma mark -

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

- (id<CipherMessage>)encryptMessage:(NSData *)paddedMessage protocolContext:(nullable id)protocolContext
{
    SPKAssert(paddedMessage);

    SessionRecord *sessionRecord =
        [self.sessionStore loadSession:self.recipientId deviceId:self.deviceId protocolContext:protocolContext];
    SessionState *sessionState = sessionRecord.sessionState;
    ChainKey *chainKey = sessionState.senderChainKey;
    MessageKeys *messageKeys     = chainKey.messageKeys;
    NSData *senderRatchetKey = sessionState.senderRatchetKey;
    int previousCounter = sessionState.previousCounter;
    int sessionVersion = sessionState.version;

    if (![self.identityKeyStore isTrustedIdentityKey:sessionState.remoteIdentityKey
                                         recipientId:self.recipientId
                                           direction:TSMessageDirectionOutgoing
                                     protocolContext:protocolContext]) {
        DDLogWarn(
            @"%@ Previously known identity key for while encrypting for recipient: %@", self.tag, self.recipientId);
        @throw [NSException exceptionWithName:UntrustedIdentityKeyException
                                       reason:@"There is a previously known identity key."
                                     userInfo:@{}];
    }

    [self.identityKeyStore saveRemoteIdentity:sessionState.remoteIdentityKey
                                  recipientId:self.recipientId
                              protocolContext:protocolContext];

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
    [self.sessionStore storeSession:self.recipientId
                           deviceId:self.deviceId
                            session:sessionRecord
                    protocolContext:protocolContext];

    return cipherMessage;
}

- (NSData *)decrypt:(id<CipherMessage>)whisperMessage protocolContext:(nullable id)protocolContext
{
    SPKAssert(whisperMessage);

    if ([whisperMessage isKindOfClass:[PreKeyWhisperMessage class]]) {
        return
            [self decryptPreKeyWhisperMessage:(PreKeyWhisperMessage *)whisperMessage protocolContext:protocolContext];
    } else{
        return [self decryptWhisperMessage:whisperMessage protocolContext:protocolContext];
    }
}

- (NSData *)decryptPreKeyWhisperMessage:(PreKeyWhisperMessage *)preKeyWhisperMessage
                        protocolContext:(nullable id)protocolContext
{
    SPKAssert(preKeyWhisperMessage);

    SessionRecord *sessionRecord =
        [self.sessionStore loadSession:self.recipientId deviceId:self.deviceId protocolContext:protocolContext];
    int unsignedPreKeyId = [self.sessionBuilder processPrekeyWhisperMessage:preKeyWhisperMessage withSession:sessionRecord protocolContext:protocolContext];
    NSData *plaintext = [self decryptWithSessionRecord:sessionRecord
                                        whisperMessage:preKeyWhisperMessage.message
                                       protocolContext:protocolContext];

    [self.sessionStore storeSession:self.recipientId
                           deviceId:self.deviceId
                            session:sessionRecord
                    protocolContext:protocolContext];

    // If there was an unsigned PreKey
    if (unsignedPreKeyId >= 0) {
        [self.prekeyStore removePreKey:unsignedPreKeyId];
    }
    
    return plaintext;
}

- (NSData *)decryptWhisperMessage:(WhisperMessage *)whisperMessage protocolContext:(nullable id)protocolContext
{
    SPKAssert(whisperMessage);

    SessionRecord *sessionRecord =
        [self.sessionStore loadSession:self.recipientId deviceId:self.deviceId protocolContext:protocolContext];
    NSData *plaintext =
        [self decryptWithSessionRecord:sessionRecord whisperMessage:whisperMessage protocolContext:protocolContext];

    if (![self.identityKeyStore isTrustedIdentityKey:sessionRecord.sessionState.remoteIdentityKey
                                         recipientId:self.recipientId
                                           direction:TSMessageDirectionIncoming
                                     protocolContext:protocolContext]) {
        DDLogWarn(
            @"%@ Previously known identity key for while decrypting from recipient: %@", self.tag, self.recipientId);
        @throw [NSException exceptionWithName:UntrustedIdentityKeyException
                                       reason:@"There is a previously known identity key."
                                     userInfo:@{}];
    }

    [self.identityKeyStore saveRemoteIdentity:sessionRecord.sessionState.remoteIdentityKey
                                  recipientId:self.recipientId
                              protocolContext:protocolContext];
    [self.sessionStore storeSession:self.recipientId
                           deviceId:self.deviceId
                            session:sessionRecord
                    protocolContext:protocolContext];

    return plaintext;
}

- (NSData *)decryptWithSessionRecord:(SessionRecord *)sessionRecord
                      whisperMessage:(WhisperMessage *)whisperMessage
                     protocolContext:(nullable id)protocolContext
{
    SPKAssert(sessionRecord);
    SPKAssert(whisperMessage);

    SessionState   *sessionState   = [sessionRecord sessionState];
    NSMutableArray *exceptions     = [NSMutableArray array];
    
    @try {
        NSData *decryptedData =
            [self decryptWithSessionState:sessionState whisperMessage:whisperMessage protocolContext:protocolContext];
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
                decryptedData = [self decryptWithSessionState:previousState
                                               whisperMessage:whisperMessage
                                              protocolContext:protocolContext];
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

    BOOL containsActiveSession =
        [self.sessionStore containsSession:self.recipientId deviceId:self.deviceId protocolContext:protocolContext];
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

- (NSData *)decryptWithSessionState:(SessionState *)sessionState
                     whisperMessage:(WhisperMessage *)whisperMessage
                    protocolContext:(nullable id)protocolContext
{
    SPKAssert(sessionState);
    SPKAssert(whisperMessage);

    if (![sessionState hasSenderChain]) {
        @throw [NSException exceptionWithName:InvalidMessageException reason:@"Uninitialized session!" userInfo:nil];
    }

    if (whisperMessage.version != sessionState.version) {
        @throw [NSException exceptionWithName:InvalidMessageException
                                       reason:[NSString stringWithFormat:@"Got message version %d but was expecting %d",
                                                        whisperMessage.version,
                                                        sessionState.version]
                                     userInfo:nil];
    }

    int messageVersion = whisperMessage.version;
    NSData *theirEphemeral = whisperMessage.senderRatchetKey.removeKeyType;
    int counter = whisperMessage.counter;
    ChainKey *chainKey       = [self getOrCreateChainKeys:sessionState theirEphemeral:theirEphemeral];
    SPKAssert(chainKey);
    MessageKeys *messageKeys = [self getOrCreateMessageKeysForSession:sessionState theirEphemeral:theirEphemeral chainKey:chainKey counter:counter];
    SPKAssert(messageKeys);

    [whisperMessage verifyMacWithVersion:messageVersion
                       senderIdentityKey:sessionState.remoteIdentityKey
                     receiverIdentityKey:sessionState.localIdentityKey
                                  macKey:messageKeys.macKey];

    NSData *plaintext =
        [AES_CBC decryptCBCMode:whisperMessage.cipherText withKey:messageKeys.cipherKey withIV:messageKeys.iv];

    [sessionState clearUnacknowledgedPreKeyMessage];
    
    return plaintext;
}

- (ChainKey *)getOrCreateChainKeys:(SessionState *)sessionState
                    theirEphemeral:(NSData *)theirEphemeral
{
    SPKAssert(sessionState);
    SPKAssert(theirEphemeral);
    SPKAssert(theirEphemeral.length == ECCKeyLength);

    @try {
        if ([sessionState hasReceiverChain:theirEphemeral]) {
            DDLogInfo(@"%@ %@.%d has existing receiver chain.", self.tag, self.recipientId, self.deviceId);
            return [sessionState receiverChainKey:theirEphemeral];
        } else{
            DDLogInfo(@"%@ %@.%d creating new chains.", self.tag, self.recipientId, self.deviceId);
            RootKey *rootKey = [sessionState rootKey];
            SPKAssert(rootKey.keyData.length == ECCKeyLength);

            ECKeyPair *ourEphemeral = [sessionState senderRatchetKeyPair];
            SPKAssert(ourEphemeral.publicKey.length == ECCKeyLength);

            RKCK *receiverChain = [rootKey createChainWithTheirEphemeral:theirEphemeral ourEphemeral:ourEphemeral];

            ECKeyPair *ourNewEphemeral = [Curve25519 generateKeyPair];
            SPKAssert(ourNewEphemeral.publicKey.length == ECCKeyLength);

            RKCK *senderChain = [receiverChain.rootKey createChainWithTheirEphemeral:theirEphemeral ourEphemeral:ourNewEphemeral];

            SPKAssert(senderChain.rootKey.keyData.length == ECCKeyLength);
            [sessionState setRootKey:senderChain.rootKey];

            SPKAssert(receiverChain.chainKey.key.length == ECCKeyLength);
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

- (MessageKeys *)getOrCreateMessageKeysForSession:(SessionState *)sessionState
                                   theirEphemeral:(NSData *)theirEphemeral
                                         chainKey:(ChainKey *)chainKey
                                          counter:(int)counter
{
    SPKAssert(sessionState);
    SPKAssert(theirEphemeral);
    SPKAssert(chainKey);

    if (chainKey.index > counter) {
        if ([sessionState hasMessageKeys:theirEphemeral counter:counter]) {
            return [sessionState removeMessageKeys:theirEphemeral counter:counter];
        } else {
            DDLogInfo(
                @"%@ %@.%d Duplicate message for counter: %d", self.tag, self.recipientId, self.deviceId, counter);
            @throw [NSException exceptionWithName:DuplicateMessageException reason:@"Received message with old counter!" userInfo:@{}];
        }
    }

    NSUInteger kCounterLimit = 2000;
    if (counter - chainKey.index > kCounterLimit) {
        DDLogError(@"%@ %@.%d Exceeded future message limit: %lu, index: %d, counter: %d)",
            self.tag,
            self.recipientId,
            self.deviceId,
            (unsigned long)kCounterLimit,
            chainKey.index,
            counter);
        @throw [NSException exceptionWithName:InvalidMessageException
                                       reason:@"Exceeded message keys chain length limit"
                                     userInfo:@{}];
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

- (int)remoteRegistrationId:(nullable id)protocolContext
{
    SessionRecord *record =
        [self.sessionStore loadSession:self.recipientId deviceId:_deviceId protocolContext:protocolContext];

    if (!record) {
        @throw [NSException exceptionWithName:NoSessionException reason:@"Trying to get registration Id of a non-existing session." userInfo:nil];
    }
    
    return record.sessionState.remoteRegistrationId;
}

- (int)sessionVersion:(nullable id)protocolContext
{
    SessionRecord *record =
        [self.sessionStore loadSession:self.recipientId deviceId:_deviceId protocolContext:protocolContext];

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

NS_ASSUME_NONNULL_END

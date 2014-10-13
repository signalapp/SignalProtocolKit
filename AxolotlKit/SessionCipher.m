//
//  TSAxolotlRatchet.m
//  AxolotlKit
//
//  Created by Frederic Jacobs on 1/12/14.
//  Copyright (c) 2014 Open Whisper Systems. All rights reserved.
//

#import "SessionCipher.h"

#import <25519/Curve25519.h>
#import <25519/Ed25519.h>

#import "NSData+Base64.h"
#import "SessionBuilder.h"
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

@interface SessionCipher ()
@property long recipientId;
@property int deviceId;
@property (nonatomic, retain)   SessionBuilder *sessionBuilder;
@property (nonatomic, readonly) id<IdentityKeyStore>identityKeyStore;
@property (nonatomic, readonly) id<SessionStore> sessionStore;
@property (nonatomic, readonly) id<PreKeyStore> prekeyStore;
@property (nonatomic, readonly) id<SignedPreKeyStore> signedPreKeyStore;
@end


@implementation SessionCipher


- (instancetype)initWithAxolotlStore:(id<AxolotlStore>)sessionStore recipientId:(long)recipientId deviceId:(int)deviceId{
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
                         recipientId:(long)recipientId
                            deviceId:(int)deviceId{
    self = [super init];
    
    _sessionStore      = sessionStore;
    _prekeyStore       = preKeyStore;
    _signedPreKeyStore = signedPreKeyStore;
    _identityKeyStore  = identityKeyStore;
    _recipientId       = recipientId;
    _deviceId          = deviceId;
    
    return self;
}

- (WhisperMessage*)encryptMessage:(NSData*)paddedMessage{
    
    SessionRecord *sessionRecord = [self.sessionStore loadSession:_recipientId deviceId:_deviceId];
    SessionState  *session       = sessionRecord.sessionState;
    ChainKey *chainKey           = session.senderChainKey;
    MessageKeys *messageKeys     = chainKey.messageKeys;
    NSData *senderRatchetKey     = session.senderRatchetKey;
    int previousCounter          = session.previousCounter;
    int sessionVersion           = session.version;
    
    NSData *ciphertextBody = [AES_CBC encryptCBCMode:paddedMessage withKey:messageKeys.cipherKey withIV:messageKeys.iv];
    
    WhisperMessage *cipherMessage = [[WhisperMessage alloc] initWithVersion:sessionVersion macKey:messageKeys.macKey senderRatchetKey:senderRatchetKey previousCounter:previousCounter counter:chainKey.index cipherText:ciphertextBody];
    
    if ([session hasUnacknowledgedPreKeyMessage]){
        UnacknowledgedPreKeyMessageItems *items = [session unacknowledgedPreKeyMessageItems];
        int localRegistrationId = [session localRegistrationId];
        
        cipherMessage = [[PrekeyWhisperMessage alloc] initWithWhisperMessage:cipherMessage registrationId:localRegistrationId prekeyId:items.preKeyId signedPrekeyId:items.signedPreKeyId baseKey:items.baseKey identityKey:[session.localIdentityKey publicKey]];
    }
    
    [session setSenderChainKey:[chainKey nextChainKey]];
    [self.sessionStore storeSession:_recipientId deviceId:_deviceId session:sessionRecord];
    
    return cipherMessage;
}

- (NSData*)decryptPreKeyWhisperMessage:(PrekeyWhisperMessage*)preKeyWhisperMessage{
    SessionRecord *sessionRecord = [self.sessionStore loadSession:self.recipientId deviceId:self.deviceId];
    int unsignedPreKeyId         = [self.sessionBuilder processPrekeyWhisperMessage:preKeyWhisperMessage withSession:sessionRecord];
    NSData *plaintext            = [self decryptWithSessionRecord:sessionRecord whisperMessage:preKeyWhisperMessage.whisperMessage];

    [self.sessionStore storeSession:self.recipientId deviceId:self.deviceId session:sessionRecord];
    
    if (unsignedPreKeyId >= 0) {
        [_prekeyStore removePreKey:unsignedPreKeyId];
    }
    
    return plaintext;
}

- (NSData*)decryptWhisperMessage:(WhisperMessage*)message{
    if (![self.sessionStore containsSession:self.recipientId deviceId:self.deviceId]) {
        @throw [NSException exceptionWithName:NoSessionException reason:[NSString stringWithFormat:@"No session for: %ld, %d", self.recipientId, self.deviceId] userInfo:nil];
    }
    
    SessionRecord  *sessionRecord  = [self.sessionStore loadSession:self.recipientId deviceId:_deviceId];
    NSData         *plaintext      = [self decryptWithSessionRecord:sessionRecord whisperMessage:message];
    
    [self.sessionStore storeSession:self.recipientId deviceId:self.deviceId session:sessionRecord];
    
    return plaintext;
}


-(NSData*)decryptWithSessionRecord:(SessionRecord*)sessionRecord whisperMessage:(WhisperMessage*)message{
    SessionState   *sessionState   = [sessionRecord sessionState];
    NSArray        *previousStates = [sessionRecord previousSessionStates];
    NSMutableArray *exceptions     = [NSMutableArray array];
    
    @try {
        return [self decryptWithSessionState:sessionState whisperMessage:message];
    }
    @catch (NSException *exception) {
        [exceptions addObject:exception];
    }
    
    for (SessionState *previousState in previousStates) {
        @try {
            return [self decryptWithSessionState:previousState whisperMessage:message];
        }
        @catch (NSException *exception) {
            [exceptions addObject:exception];
        }
    }
    
    @throw [NSException exceptionWithName:InvalidMessageException reason:@"No valid sessions" userInfo:@{@"Exceptions":exceptions}];
}

-(NSData*)decryptWithSessionState:(SessionState*)sessionState whisperMessage:(WhisperMessage*)message{
    
    if (![sessionState hasSenderChain]) {
        @throw [NSException exceptionWithName:InvalidMessageException reason:@"Uninitialized session!" userInfo:nil];
    }
    
    if (message.version != sessionState.version) {
        @throw [NSException exceptionWithName:InvalidMessageException reason:[NSString stringWithFormat:@"Got message version %d but was expecting %d", message.version, sessionState.version] userInfo:nil];
    }
    
    int messageVersion = message.version;
    NSData *theirEphemeral = message.senderRatchetKey;
    int counter = message.counter;
    ChainKey *chainKey = [self getOrCreateChainKeys:sessionState theirEphemeral:theirEphemeral];
    MessageKeys *messageKeys = [self getOrCreateMessageKeysForSession:sessionState theirEphemeral:theirEphemeral chainKey:chainKey counter:counter];
    
    [message verifyMacWithVersion:messageVersion identityKey:sessionState.remoteIdentityKey receiverIdentityKey:sessionState.localIdentityKey macKey:messageKeys.macKey];
    
    NSData *plaintext = [AES_CBC decryptCBCMode:message.cipherText withKey:messageKeys.cipherKey withIV:messageKeys.iv];
    
    [sessionState clearUnacknowledgedPreKeyMessage];
    
    return plaintext;
}

- (ChainKey*)getOrCreateChainKeys:(SessionState*)sessionState theirEphemeral:(NSData*)theirEphemeral{
    
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
            [sessionState setPreviousCounter:MAX(sessionState.senderChainKey.index -1 , 0)];
            [sessionState setSenderChain:ourNewEphemeral chainKey:receiverChain.chainKey];
            
            return senderChain.chainKey;
        }
    }
    @catch (NSException *exception) {
        @throw [NSException exceptionWithName:InvalidMessageException reason:@"Chainkeys couldn't be derived" userInfo:nil];
    }
}

- (MessageKeys*)getOrCreateMessageKeysForSession:(SessionState*)sessionState theirEphemeral:(NSData*)theirEphemeral chainKey:(ChainKey*)chainKey counter:(int)counter{
    
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


@end
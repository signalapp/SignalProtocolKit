//
//  SessionBuilder.m
//  AxolotlKit
//
//  Created by Frederic Jacobs on 23/07/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import "AxolotlExceptions.h"
#import "AxolotlParameters.h"
#import "AliceAxolotlParameters.h"
#import "BobAxolotlParameters.h"

#import "NSData+keyVersionByte.h"

#import "AxolotlStore.h"
#import "SessionState.h"
#import "SessionBuilder.h"
#import "PreKeyWhisperMessage.h"
#import "RatchetingSession.h"

#import <25519/Curve25519.h>
#import <25519/Ed25519.h>

#import "PrekeyBundle.h"

#define CURRENT_VERSION 3
#define MINUMUM_VERSION 3

@interface SessionBuilder ()

@property (nonatomic, readonly)NSString* recipientId;
@property (nonatomic, readonly)int deviceId;

@property(nonatomic, readonly)id<SessionStore>      sessionStore;
@property(nonatomic, readonly)id<PreKeyStore>       prekeyStore ;
@property(nonatomic, readonly)id<SignedPreKeyStore> signedPreKeyStore;
@property(nonatomic, readonly)id<IdentityKeyStore>  identityStore;


@end

@implementation SessionBuilder

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
    
    if (self) {
        _sessionStore      = sessionStore;
        _prekeyStore       = preKeyStore;
        _signedPreKeyStore = signedPreKeyStore;
        _identityStore     = identityKeyStore;
        _recipientId       = recipientId;
        _deviceId          = deviceId;
    }
    
    return self;
}

- (void)processPrekeyBundle:(PreKeyBundle*)preKeyBundle{
    NSData *theirIdentityKey  = preKeyBundle.identityKey.removeKeyType;
    NSData *theirSignedPreKey = preKeyBundle.signedPreKeyPublic.removeKeyType;
    
    if (![self.identityStore isTrustedIdentityKey:theirIdentityKey recipientId:self.recipientId]) {
        @throw [NSException exceptionWithName:UntrustedIdentityKeyException reason:@"Identity key is not valid" userInfo:@{}];
    }

    if (![Ed25519 verifySignature:preKeyBundle.signedPreKeySignature publicKey:theirIdentityKey data:preKeyBundle.signedPreKeyPublic]) {
        @throw [NSException exceptionWithName:InvalidKeyException reason:@"KeyIsNotValidlySigned" userInfo:nil];
    }
    
    SessionRecord *sessionRecord       = [self.sessionStore loadSession:self.recipientId deviceId:preKeyBundle.deviceId];
    ECKeyPair     *ourBaseKey          = [Curve25519 generateKeyPair];
    NSData        *theirOneTimePreKey  = preKeyBundle.preKeyPublic.removeKeyType;
    int           theirOneTimePreKeyId = preKeyBundle.preKeyId;
    int           theirSignedPreKeyId  = preKeyBundle.signedPreKeyId;
    
    
    AliceAxolotlParameters *params = [[AliceAxolotlParameters alloc] initWithIdentityKey:[self.identityStore identityKeyPair]
                                                                        theirIdentityKey:theirIdentityKey
                                                                              ourBaseKey:ourBaseKey
                                                                       theirSignedPreKey:theirSignedPreKey
                                                                      theirOneTimePreKey:theirOneTimePreKey
                                                                         theirRatchetKey:theirSignedPreKey];
    
    if (!sessionRecord.isFresh) {
        [sessionRecord archiveCurrentState];
    }
    
    [RatchetingSession initializeSession:[sessionRecord sessionState] sessionVersion:CURRENT_VERSION AliceParameters:params];
    
    [sessionRecord.sessionState setUnacknowledgedPreKeyMessage:theirOneTimePreKeyId signedPreKey:theirSignedPreKeyId baseKey:ourBaseKey.publicKey];
    [sessionRecord.sessionState setLocalRegistrationId:self.identityStore.localRegistrationId];
    [sessionRecord.sessionState setRemoteRegistrationId:preKeyBundle.registrationId];
    [sessionRecord.sessionState setAliceBaseKey:ourBaseKey.publicKey];
    
    [self.sessionStore  storeSession:self.recipientId deviceId:self.deviceId session:sessionRecord];
    [self.identityStore saveRemoteIdentity:theirIdentityKey recipientId:self.recipientId];
}

- (int)processPrekeyWhisperMessage:(PreKeyWhisperMessage*)message withSession:(SessionRecord*)sessionRecord{

    int    messageVersion    = message.version;
    NSData *theirIdentityKey = message.identityKey.removeKeyType;

    if (![self.identityStore isTrustedIdentityKey:theirIdentityKey recipientId:self.recipientId]) {
        @throw [NSException exceptionWithName:UntrustedIdentityKeyException reason:@"There is a previously known identity key." userInfo:@{}];
    }
    
    int unSignedPrekeyId = -1;
    
    switch (messageVersion) {
        case 3:
            unSignedPrekeyId = [self processPrekeyV3:message withSession:sessionRecord];
            break;
        default:
            @throw [NSException exceptionWithName:InvalidVersionException reason:@"Trying to initialize with unknown version" userInfo:@{}];
            break;
    }
    
    [self.identityStore saveRemoteIdentity:theirIdentityKey recipientId:self.recipientId];
    return unSignedPrekeyId;
}

- (int)processPrekeyV3:(PreKeyWhisperMessage*)message withSession:(SessionRecord*)sessionRecord{
    
    NSData *baseKey = message.baseKey.removeKeyType;
    
    if ([sessionRecord hasSessionState:message.version baseKey:baseKey]) {
        return -1;
    }
    
    ECKeyPair *ourSignedPrekey = [self.signedPreKeyStore loadSignedPrekey:message.signedPrekeyId].keyPair;
    
    BobAxolotlParameters *params = [[BobAxolotlParameters alloc] initWithMyIdentityKeyPair:self.identityStore.identityKeyPair
                                                                          theirIdentityKey:message.identityKey.removeKeyType
                                                                           ourSignedPrekey:ourSignedPrekey
                                                                             ourRatchetKey:ourSignedPrekey
                                                                          ourOneTimePrekey:[self.prekeyStore loadPreKey:message.prekeyID].keyPair
                                                                              theirBaseKey:baseKey];
    
    if (!sessionRecord.isFresh) {
        [sessionRecord archiveCurrentState];
    }
    
    [RatchetingSession initializeSession:sessionRecord.sessionState sessionVersion:message.version BobParameters:params];
    
    [sessionRecord.sessionState setLocalRegistrationId:self.identityStore.localRegistrationId];
    [sessionRecord.sessionState setRemoteRegistrationId:message.registrationId];
    [sessionRecord.sessionState setAliceBaseKey:baseKey];
    
    if (message.prekeyID >= 0 && message.prekeyID != 0xFFFFFF) {
        return message.prekeyID;
    } else{
        return -1;
    }
}

@end

//
//  SessionBuilder.m
//  AxolotlKit
//
//  Created by Frederic Jacobs on 23/07/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import "AxolotlParameters.h"
#import "AliceAxolotlParameters.h"
#import "BobAxolotlParameters.h"

#import "SessionState.h"
#import "SessionBuilder.h"
#import "PrekeyWhisperMessage.h"
#import "RatchetingSession.h"

#import <25519/Curve25519.h>
#import <25519/Ed25519.h>

#import "PrekeyBundle.h"

#define CURRENT_VERSION 3
#define MINUMUM_VERSION 3

@interface SessionBuilder ()

@property (nonatomic, readonly)int recipientId;
@property (nonatomic, readonly)int deviceId;

@end

@implementation SessionBuilder

- (void)processPrekeyBundle:(PreKeyBundle*)preKeyBundle{
    
    if (![self.identityStore isTrustedIdentityKey:preKeyBundle.identityKey recipientId:self.recipientId]) {
        @throw [NSException exceptionWithName:UntrustedIdentityKeyException reason:@"Identity key is not valid" userInfo:@{}];
    }
    
    if ([Ed25519 verifySignature:preKeyBundle.signedPreKeySignature publicKey:preKeyBundle.identityKey data:preKeyBundle.signedPreKeyPublic]) {
        @throw [NSException exceptionWithName:InvalidKeyException reason:@"KeyIsNotValidlySigned" userInfo:nil];
    }
    
    SessionRecord *sessionRecord   = [self.sessionStore loadSession:preKeyBundle.contactIdentifier deviceId:preKeyBundle.deviceId];
    ECKeyPair *ourBaseKey          = [Curve25519 generateKeyPair];
    NSData    *theirSignedPreKey   = preKeyBundle.signedPreKeyPublic;
    NSData    *theirOneTimePreKey  = preKeyBundle.preKeyPublic;
    int       theirOneTimePreKeyId = preKeyBundle.preKeyId;
    int       theirSignedPreKeyId  = preKeyBundle.signedPreKeyId;
    
    AliceAxolotlParameters *params = [[AliceAxolotlParameters alloc] initWithIdentityKey:[self.identityStore identityKeyPair]
                                                                        theirIdentityKey:preKeyBundle.identityKey
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
    [self.identityStore saveRemoteIdentity:preKeyBundle.identityKey recipientId:self.recipientId];
}

- (int)processPrekeyWhisperMessage:(PrekeyWhisperMessage*)message withSession:(SessionRecord*)sessionRecord{
    if ([sessionRecord hasSessionState:message.version baseKey:[message baseKey]]) {
        return -1;
    }
    
    ECKeyPair *ourSignedPrekey = [self.signedPreKeyStore loadSignedPrekey:message.prekeyID].keyPair;
    
    BobAxolotlParameters *params = [[BobAxolotlParameters alloc] initWithMyIdentityKeyPair:self.identityStore.identityKeyPair
                                                                          theirIdentityKey:message.identityKey
                                                                           ourSignedPrekey:ourSignedPrekey
                                                                             ourRatchetKey:ourSignedPrekey
                                                                          ourOneTimePrekey:[self.prekeyStore loadPreKey:message.prekeyID].keyPair
                                                                              theirBaseKey:[message baseKey]];
    
    if (!sessionRecord.isFresh) {
        [sessionRecord archiveCurrentState];
    }
    
    [RatchetingSession initializeSession:sessionRecord.sessionState sessionVersion:message.version BobParameters:params];
    
    [sessionRecord.sessionState setLocalRegistrationId:self.identityStore.localRegistrationId];
    [sessionRecord.sessionState setRemoteRegistrationId:message.registrationId];
    [sessionRecord.sessionState setAliceBaseKey:message.baseKey];
    
    if (message.prekeyID >= 0 && message.prekeyID != 0xFFFFFF) {
        return message.prekeyID;
    } else{
        return -1;
    }
}

@end

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

@interface SessionBuilder ()

@property (nonatomic, readonly)int recipientId;
@property (nonatomic, readonly)int deviceId;

@end

@implementation SessionBuilder

-(void)verifyAndStoreIdentityKeys:(NSData*)identityKey contactIdentifier:(NSInteger)contactId{
    
    switch ([self.identityStore isTrustedIdentity:contactId identityKey:identityKey]) {
        case kIdentityKeyConflict:
            @throw [NSException exceptionWithName:UntrustedIdentityKeyException reason:@"Got new key, doesn't match the one stored" userInfo:nil];
            break;
        case kIdentityKeyNotFound:
            [self.identityStore saveIdentityKeyAsTrusted:contactId identityKey:identityKey];
            break;
        case kIdentityKeyMatching:
            break;
    }
}

- (void) processPrekeyBundle:(PreKeyBundle*)preKeyBundle{
    [self verifyAndStoreIdentityKeys:preKeyBundle.identityKey contactIdentifier:preKeyBundle.contactIdentifier];
    
    if ([Ed25519 verifySignature:preKeyBundle.signedPreKeySignature publicKey:preKeyBundle.identityKey data:preKeyBundle.signedPreKeyPublic]) {
        @throw [NSException exceptionWithName:InvalidKeyException reason:@"KeyIsNotValidlySigned" userInfo:nil];
    }
    
    SessionRecord *sessionRecord = [self.sessionStore loadSession:preKeyBundle.contactIdentifier deviceId:preKeyBundle.deviceId];
    ECKeyPair *ourBaseKey         = [Curve25519 generateKeyPair];
    NSData    *theirSignedPrekey  = preKeyBundle.signedPreKeyPublic;
    NSData    *theirOneTimePrekey = preKeyBundle.preKeyPublic;
    
    
    AliceAxolotlParameters *params = [[AliceAxolotlParameters alloc] initWithIdentityKey:[self.identityStore myIdentityKeyPair] theirIdentityKey:preKeyBundle.identityKey ourBaseKey:ourBaseKey theirSignedPreKey:theirSignedPrekey theirOneTimePreKey:theirOneTimePrekey theirRatchetKey:theirSignedPrekey];
    
    if ([[sessionRecord sessionState] needsRefresh]){
        [sessionRecord archiveCurrentState];
    } else{
        [sessionRecord reset];
    }
    
    [RatchetingSession initializeSession:[sessionRecord sessionState] sessionVersion:3 AliceParameters:params];
    [[sessionRecord sessionState] setUnacknowledgedPreKeyMessage:preKeyBundle.preKeyId signedPreKey:[preKeyBundle signedPreKeyId] baseKey:ourBaseKey.publicKey];
    [[sessionRecord sessionState] setLocalRegistrationId:[self.identityStore localRegistrationId]];
    [[sessionRecord sessionState] setRemoteRegistrationId:preKeyBundle.registrationId];
    
    [self.sessionStore  storeSession:self.recipientId deviceId:self.deviceId session:sessionRecord];
    [self.identityStore saveIdentityKeyAsTrusted:self.recipientId identityKey:preKeyBundle.identityKey];
}

- (int) processPrekeyWhisperMessage:(PrekeyWhisperMessage*)message withSession:(SessionRecord*)sessionRecord{
    
    if ([sessionRecord hasSessionState:message.version baseKey:[message baseKey]]) {
        return 0;
    }
    
    BOOL simultaneousInitiate  = [[sessionRecord sessionState] hasUnacknowledgedPreKeyMessage];
    ECKeyPair *ourSignedPrekey = [self.signedPreKeyStore loadSignedPrekey:message.prekeyID].keyPair;
    
    BobAxolotlParameters *params = [[BobAxolotlParameters alloc] initWithMyIdentityKeyPair:[[self identityStore] myIdentityKeyPair]
                                                                          theirIdentityKey:message.identityKey
                                                                           ourSignedPrekey:ourSignedPrekey
                                                                             ourRatchetKey:ourSignedPrekey
                                                                          ourOneTimePrekey:[self.prekeyStore loadPreKey:message.prekeyID].keyPair
                                                                              theirBaseKey:[message baseKey]];
    
    if (!sessionRecord.isFresh) {
        <#statements#>
    }
    
    
    [RatchetingSession initializeSession:[sessionRecord sessionState] sessionVersion:[message version] BobParameters:params];
    
    [[sessionRecord sessionState] setLocalRegistrationId:[[self identityStore] localRegistrationId]];
    [[sessionRecord sessionState] setRemoteRegistrationId:message.registrationId];
    [[sessionRecord sessionState] setAliceBaseKey:message.baseKey];
    
    if (simultaneousInitiate) {
        [[sessionRecord sessionState]setNeedsRefresh:YES];
    }
    
    if (message.prekeyID >= 0 && message.prekeyID != 0xFFFFFF) {
        [self.prekeyStore removePreKey:message.prekeyID];
    }
}

@end

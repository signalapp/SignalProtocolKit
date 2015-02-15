//
//  TSAxolotlRatchet.h
//  AxolotlKit
//
//  Created by Frederic Jacobs on 07/22/14.
//  Copyright (c) 2014 Open Whisper Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "AxolotlStore.h"
#import "SignedPreKeyStore.h"
#import "PreKeyStore.h"
#import "IdentityKeyStore.h"
#import "SessionStore.h"
#import "PreKeyWhisperMessage.h"
#import "SessionState.h"
#import "WhisperMessage.h"

@interface SessionCipher : NSObject

- (instancetype)initWithAxolotlStore:(id<AxolotlStore>)sessionStore recipientId:(NSString*)recipientId deviceId:(int)deviceId;

- (instancetype)initWithSessionStore:(id<SessionStore>)sessionStore preKeyStore:(id<PreKeyStore>)preKeyStore signedPreKeyStore:(id<SignedPreKeyStore>)signedPreKeyStore identityKeyStore:(id<IdentityKeyStore>)identityKeyStore recipientId:(NSString*)recipientId deviceId:(int)deviceId;

- (id<CipherMessage>)encryptMessage:(NSData*)paddedMessage;

- (NSData*)decrypt:(id<CipherMessage>)whisperMessage;

- (int)remoteRegistrationId;
- (int)sessionVersion;

@end
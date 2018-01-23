//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
//

#import "AxolotlStore.h"
#import "IdentityKeyStore.h"
#import "PreKeyStore.h"
#import "PreKeyWhisperMessage.h"
#import "SessionState.h"
#import "SessionStore.h"
#import "SignedPreKeyStore.h"
#import "WhisperMessage.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SessionCipher : NSObject

- (instancetype)initWithAxolotlStore:(id<AxolotlStore>)sessionStore recipientId:(NSString*)recipientId deviceId:(int)deviceId;

- (instancetype)initWithSessionStore:(id<SessionStore>)sessionStore preKeyStore:(id<PreKeyStore>)preKeyStore signedPreKeyStore:(id<SignedPreKeyStore>)signedPreKeyStore identityKeyStore:(id<IdentityKeyStore>)identityKeyStore recipientId:(NSString*)recipientId deviceId:(int)deviceId;

// protocolContext is an optional parameter that can be used to ensure that all
// identity and session store writes are coordinated and/or occur within a single
// transaction.
- (id<CipherMessage>)encryptMessage:(NSData *)paddedMessage protocolContext:(nullable id)protocolContext;

- (NSData *)decrypt:(id<CipherMessage>)whisperMessage protocolContext:(nullable id)protocolContext;

- (int)remoteRegistrationId:(nullable id)protocolContext;
- (int)sessionVersion:(nullable id)protocolContext;

@end

NS_ASSUME_NONNULL_END

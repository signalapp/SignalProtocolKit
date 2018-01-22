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

@interface SessionCipher : NSObject

/**
 * To keep Session state synchronized, encryption and decryption must happen on the same (serial) dispatch queue. If no
 * queue is specified, the main queue will be used by default. We only assert that this invariant is held. Dispatching 
 * to this thread is the responsibility of the caller.
 *
 * @param dispatchQueue    serial dispatch queue on which all encryption/decryption must be dispatched.
 */
+ (void)setSessionCipherDispatchQueue:(dispatch_queue_t)dispatchQueue;
+ (dispatch_queue_t)getSessionCipherDispatchQueue;

- (instancetype)initWithAxolotlStore:(id<AxolotlStore>)sessionStore recipientId:(NSString*)recipientId deviceId:(int)deviceId;

- (instancetype)initWithSessionStore:(id<SessionStore>)sessionStore preKeyStore:(id<PreKeyStore>)preKeyStore signedPreKeyStore:(id<SignedPreKeyStore>)signedPreKeyStore identityKeyStore:(id<IdentityKeyStore>)identityKeyStore recipientId:(NSString*)recipientId deviceId:(int)deviceId;

// protocolContext is an optional parameter that can be used to ensure that all
// identity and session store writes are coordinated and/or occur within a single
// transaction.
- (id<CipherMessage>)encryptMessage:(NSData *)paddedMessage protocolContext:(nullable id)protocolContext;

- (NSData *)decrypt:(id<CipherMessage>)whisperMessage protocolContext:(nullable id)protocolContext;

- (int)remoteRegistrationId:(nullable id)protocolContext;
- (int)sessionVersion;

@end

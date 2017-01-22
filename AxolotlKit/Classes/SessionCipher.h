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

- (id<CipherMessage>)encryptMessage:(NSData*)paddedMessage;

- (NSData*)decrypt:(id<CipherMessage>)whisperMessage;

- (int)remoteRegistrationId;
- (int)sessionVersion;

@end

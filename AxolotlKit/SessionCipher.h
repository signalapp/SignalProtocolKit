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
#import "PreKeyBundle.h"
#import "PreKeyWhisperMessage.h"
#import "SessionState.h"
#import "WhisperMessage.h"

#define currentVersion 3

#pragma mark Axolotl Processed Message Completion Block

typedef void (^AxolotlDecryptCompletionBlock) (NSError *error, NSData *decryptedMessage);
typedef void (^AxolotlEncryptCompletionBlock) (NSError *error, WhisperMessage *encryptedMessage);

#pragma mark Fetch Keying Material

typedef PreKeyBundle*(^AxolotlFetchKey)   (NSInteger contactIdentifier, NSInteger deviceId);

@interface SessionCipher : NSObject

- (instancetype)initWithAxolotlStore:(id<AxolotlStore>)sessionStore recipientId:(long)recipientId deviceId:(int)deviceId;

- (instancetype)initWithSessionStore:(id<SessionStore>)sessionStore preKeyStore:(id<PreKeyStore>)preKeyStore signedPreKeyStore:(id<SignedPreKeyStore>)signedPreKeyStore identityKeyStore:(id<IdentityKeyStore>)identityKeyStore recipientId:(long)recipientId deviceId:(int)deviceId;

- (WhisperMessage*)encryptMessage:(NSData*)paddedMessage;

- (NSData*)decrypt:(WhisperMessage*)whisperMessage;

@end
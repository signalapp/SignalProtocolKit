//
//  TSAxolotlRatchet.h
//  AxolotlKit
//
//  Created by Frederic Jacobs on 07/22/14.
//  Copyright (c) 2014 Open Whisper Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "IdentityStore.h"
#import "SessionStore.h"

#import "AxolotlPlainMessage.h"
#import "PreKeyBundle.h"
#import "PrekeyWhisperMessage.h"
#import "SessionState.h"
#import "WhisperMessage.h"

#define currentVersion 3

#pragma mark Axolotl Processed Message Completion Block

typedef void (^AxolotlDecryptCompletionBlock) (NSError *error, NSData *decryptedMessage);
typedef void (^AxolotlEncryptCompletionBlock) (NSError *error, WhisperMessage *encryptedMessage);

#pragma mark Fetch Keying Material

typedef PreKeyBundle*(^AxolotlFetchKey)   (NSInteger contactIdentifier, NSInteger deviceId);

@interface SessionCipher : NSObject



@end
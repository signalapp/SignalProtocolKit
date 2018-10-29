//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSDerivedSecrets : NSData

+ (instancetype)try_derivedInitialSecretsWithMasterKey:(NSData *)masterKey;
+ (instancetype)try_derivedRatchetedSecretsWithSharedSecret:(NSData *)masterKey rootKey:(NSData *)rootKey;
+ (instancetype)try_derivedMessageKeysWithData:(NSData *)data;

@property NSData *cipherKey;
@property NSData *macKey;
@property NSData *iv;

@end

//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSDerivedSecrets : NSData

+ (instancetype)try_derivedInitialSecretsWithMasterKey:(NSData *)masterKey NS_SWIFT_UNAVAILABLE("throws objc exceptions");
+ (instancetype)try_derivedRatchetedSecretsWithSharedSecret:(NSData *)masterKey rootKey:(NSData *)rootKey NS_SWIFT_UNAVAILABLE("throws objc exceptions");
+ (instancetype)try_derivedMessageKeysWithData:(NSData *)data NS_SWIFT_UNAVAILABLE("throws objc exceptions");

@property NSData *cipherKey;
@property NSData *macKey;
@property NSData *iv;

@end

//
//  TSDerivedSecrets.h
//  AxolotlKit
//
//  Created by Frederic Jacobs on 29/03/14.
//  Copyright (c) 2014 Open Whisper Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSDerivedSecrets : NSData

+ (instancetype)derivedInitialSecretsWithMasterKey:(NSData*)masterKey;
+ (instancetype)derivedRatchetedSecretsWithSharedSecret:(NSData*)masterKey rootKey:(NSData*)rootKey;
+ (instancetype)derivedMessageKeysWithData:(NSData*)data;

@property NSData *cipherKey;
@property NSData *macKey;
@property NSData *iv;

@end

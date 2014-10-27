//
//  TSDerivedSecrets.m
//  AxolotlKit
//
//  Created by Frederic Jacobs on 29/03/14.
//  Copyright (c) 2014 Open Whisper Systems. All rights reserved.
//

#import "TSDerivedSecrets.h"
#import "HKDFKit.h"

@implementation TSDerivedSecrets

+ (instancetype)derivedSecretsWithSeed:(NSData*)masterKey salt:(NSData*)salt info:(NSData*)info{
    TSDerivedSecrets *secrets = [[TSDerivedSecrets alloc] init];
    
    if (!salt) {
        const char *HKDFDefaultSalt[4] = {0};
        salt                           = [NSData dataWithBytes:HKDFDefaultSalt length:sizeof(HKDFDefaultSalt)];
    }
    
    @try {
        NSData *derivedMaterial = [HKDFKit deriveKey:masterKey info:info salt:salt outputSize:96];
        secrets.cipherKey       = [derivedMaterial subdataWithRange:NSMakeRange(0, 32)];
        secrets.macKey          = [derivedMaterial subdataWithRange:NSMakeRange(32, 32)];
        secrets.iv              = [derivedMaterial subdataWithRange:NSMakeRange(64, 16)];
    }
    @catch (NSException *exception) {
        @throw NSInvalidArgumentException;
    }
    
    return secrets;
}

+ (instancetype)derivedInitialSecretsWithMasterKey:(NSData*)masterKey{
    NSData *info = [@"WhisperText" dataUsingEncoding:NSUTF8StringEncoding];
    return [self derivedSecretsWithSeed:masterKey salt:nil info:info];
}

+ (instancetype)derivedRatchetedSecretsWithSharedSecret:(NSData*)masterKey rootKey:(NSData*)rootKey{
    NSData *info = [@"WhisperRatchet" dataUsingEncoding:NSUTF8StringEncoding];
    return [self derivedSecretsWithSeed:masterKey salt:rootKey info:info];
}

+ (instancetype)derivedMessageKeysWithData:(NSData*)data{
    NSData *info = [@"WhisperMessageKeys" dataUsingEncoding:NSUTF8StringEncoding];
    return [self derivedSecretsWithSeed:data salt:nil info:info];
}

@end

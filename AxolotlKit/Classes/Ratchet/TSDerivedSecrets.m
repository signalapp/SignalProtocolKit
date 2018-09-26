//
//  Copyright (c) 2017 Open Whisper Systems. All rights reserved.
//

#import "TSDerivedSecrets.h"
#import "HKDFKit.h"
#import <Curve25519Kit/Curve25519.h>

@implementation TSDerivedSecrets

+ (instancetype)derivedSecretsWithSeed:(NSData*)masterKey salt:(NSData*)salt info:(NSData*)info{
    OWSAssert(masterKey.length == 32);
    OWSAssert(info);

    TSDerivedSecrets *secrets = [[TSDerivedSecrets alloc] init];
    OWSAssert(secrets);

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

    OWSAssert(secrets.cipherKey.length == 32);
    OWSAssert(secrets.macKey.length == 32);
    OWSAssert(secrets.iv.length == 16);

    return secrets;
}

+ (instancetype)derivedInitialSecretsWithMasterKey:(NSData*)masterKey{
    OWSAssert(masterKey);

    NSData *info = [@"WhisperText" dataUsingEncoding:NSUTF8StringEncoding];
    return [self derivedSecretsWithSeed:masterKey salt:nil info:info];
}

+ (instancetype)derivedRatchetedSecretsWithSharedSecret:(NSData*)masterKey rootKey:(NSData*)rootKey{
    OWSAssert(masterKey);
    OWSAssert(rootKey);

    NSData *info = [@"WhisperRatchet" dataUsingEncoding:NSUTF8StringEncoding];
    return [self derivedSecretsWithSeed:masterKey salt:rootKey info:info];
}

+ (instancetype)derivedMessageKeysWithData:(NSData*)data{
    OWSAssert(data);

    NSData *info = [@"WhisperMessageKeys" dataUsingEncoding:NSUTF8StringEncoding];
    return [self derivedSecretsWithSeed:data salt:nil info:info];
}

@end

//
//  AES-CBC.m
//  AxolotlKit
//
//  Created by Frederic Jacobs on 22/07/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import "AES-CBC.h"
#import "AxolotlExceptions.h"
#import "MessageKeys.h"
#import <CommonCrypto/CommonCryptor.h>
#import <CommonCrypto/CommonHMAC.h>
#import <Security/Security.h>

NS_ASSUME_NONNULL_BEGIN

@implementation AES_CBC

#pragma mark AESCBC Mode

+ (NSData *)encryptCBCMode:(NSData *)data withKey:(NSData *)key withIV:(NSData *)iv
{
    OWSAssert(data);
    OWSAssert(data.length < SIZE_MAX - kCCBlockSizeAES128);
    OWSAssert(key.length == 32);
    OWSAssert(iv.length == 16);

    size_t bufferSize;
    ows_add_overflow(data.length, kCCBlockSizeAES128, &bufferSize);
    NSMutableData *_Nullable bufferData = [NSMutableData dataWithLength:bufferSize];
    OWSAssert(bufferData != nil);

    size_t bytesEncrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
        kCCAlgorithmAES128,
        kCCOptionPKCS7Padding,
        [key bytes],
        [key length],
        [iv bytes],
        [data bytes],
        [data length],
        bufferData.mutableBytes,
        bufferSize,
        &bytesEncrypted);

    if (cryptStatus == kCCSuccess) {
        return [bufferData subdataWithRange:NSMakeRange(0, bytesEncrypted)];
    } else {
        @throw [NSException exceptionWithName:CipherException
                                       reason:@"We encountered an issue while encrypting."
                                     userInfo:nil];
    }
}

+ (NSData *)decryptCBCMode:(NSData *)data withKey:(NSData *)key withIV:(NSData *)iv
{
    OWSAssert(data);
    OWSAssert(data.length < SIZE_MAX - kCCBlockSizeAES128);
    OWSAssert(key.length == 32);
    OWSAssert(iv.length == 16);

    size_t bufferSize;
    ows_add_overflow(data.length, kCCBlockSizeAES128, &bufferSize);
    NSMutableData *_Nullable bufferData = [NSMutableData dataWithLength:bufferSize];
    OWSAssert(bufferData != nil);

    size_t bytesDecrypted = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
        kCCAlgorithmAES128,
        kCCOptionPKCS7Padding,
        [key bytes],
        [key length],
        [iv bytes],
        [data bytes],
        [data length],
        bufferData.mutableBytes,
        bufferSize,
        &bytesDecrypted);

    if (cryptStatus == kCCSuccess) {
        return [bufferData subdataWithRange:NSMakeRange(0, bytesDecrypted)];
    } else {
        @throw [NSException exceptionWithName:CipherException
                                       reason:@"We encountered an issue while decrypting."
                                     userInfo:nil];
    }
}

@end

NS_ASSUME_NONNULL_END

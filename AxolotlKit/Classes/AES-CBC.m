//
//  AES-CBC.m
//  AxolotlKit
//
//  Created by Frederic Jacobs on 22/07/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import "MessageKeys.h"
#import "AES-CBC.h"
#import <Security/Security.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>

@implementation AES_CBC

#pragma mark AESCBC Mode

+(NSData*)encryptCBCMode:(NSData*)dataToEncrypt withKey:(NSData*)key withIV:(NSData*)iv{
    NSAssert(dataToEncrypt, @"Missing data to encrypt");
    NSAssert([key length] == 32, @"AES key should be 128 bits");
    NSAssert([iv  length] == 16, @"AE-CBC IV should be 128 bits");
    
    size_t bufferSize           = [dataToEncrypt length] + kCCBlockSizeAES128;
    void* buffer                = malloc(bufferSize);
    
    size_t bytesEncrypted    = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          [key bytes], [key length],
                                          [iv bytes],
                                          [dataToEncrypt bytes], [dataToEncrypt length],
                                          buffer, bufferSize,
                                          &bytesEncrypted);
    
    if (cryptStatus == kCCSuccess){
        return [NSData dataWithBytesNoCopy:buffer length:bytesEncrypted];
    } else{
        free(buffer);
        @throw [NSException exceptionWithName:CipherException reason:@"We encountered an issue while encrypting." userInfo:nil];
    }
}

+(NSData*) decryptCBCMode:(NSData*)dataToDecrypt withKey:(NSData*)key withIV:(NSData*)iv {

    size_t bufferSize           = [dataToDecrypt length] + kCCBlockSizeAES128;
    void* buffer                = malloc(bufferSize);
    
    size_t bytesDecrypted    = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          [key bytes], [key length],
                                          [iv bytes],
                                          [dataToDecrypt bytes], [dataToDecrypt length],
                                          buffer, bufferSize,
                                          &bytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:bytesDecrypted];
    } else{
        free(buffer);
        @throw [NSException exceptionWithName:CipherException reason:@"We encountered an issue while decrypting." userInfo:nil];
    }
}

@end

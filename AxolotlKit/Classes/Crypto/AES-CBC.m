//
//  AES-CBC.m
//  AxolotlKit
//
//  Created by Frederic Jacobs on 22/07/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import "AxolotlExceptions.h"
#import "MessageKeys.h"
#import "AES-CBC.h"
#import <Security/Security.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>

@implementation AES_CBC

#pragma mark AESCBC Mode

+(NSData*)encryptCBCMode:(NSData*)data withKey:(NSData*)key withIV:(NSData*)iv{
    NSAssert(data, @"Missing data to encrypt");
    NSAssert([key length] == 32, @"AES key should be 256 bits");
    NSAssert([iv  length] == 16, @"AES-CBC IV should be 128 bits");
    
    size_t bufferSize           = [data length] + kCCBlockSizeAES128;
    void* buffer                = malloc(bufferSize);
    
    size_t bytesEncrypted    = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          [key bytes], [key length],
                                          [iv bytes],
                                          [data bytes], [data length],
                                          buffer, bufferSize,
                                          &bytesEncrypted);
    
    if (cryptStatus == kCCSuccess){
        NSData *data = [NSData dataWithBytes:buffer length:bytesEncrypted];
        free(buffer);
        
        return data;
    } else{
        free(buffer);
        @throw [NSException exceptionWithName:CipherException reason:@"We encountered an issue while encrypting." userInfo:nil];
    }
}

+(NSData*) decryptCBCMode:(NSData*)data withKey:(NSData*)key withIV:(NSData*)iv {

    size_t bufferSize           = [data length] + kCCBlockSizeAES128;
    void* buffer                = malloc(bufferSize);
    
    size_t bytesDecrypted    = 0;
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding,
                                          [key bytes], [key length],
                                          [iv bytes],
                                          [data bytes], [data length],
                                          buffer, bufferSize,
                                          &bytesDecrypted);
    
    if (cryptStatus == kCCSuccess) {
        NSData *plaintext = [NSData dataWithBytes:buffer length:bytesDecrypted];
        free(buffer);

        return plaintext;
    } else{
        free(buffer);
        @throw [NSException exceptionWithName:CipherException reason:@"We encountered an issue while decrypting." userInfo:nil];
    }
}

@end

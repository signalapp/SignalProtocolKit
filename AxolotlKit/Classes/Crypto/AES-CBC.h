//
//  AES-CBC.h
//  AxolotlKit
//
//  Created by Frederic Jacobs on 22/07/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AES_CBC : NSObject

/**
 *  Encrypts with AES in CBC mode
 *
 *  @param data     data to encrypt
 *  @param key      AES key
 *  @param iv       Initialization vector for CBC
 *
 *  @return         ciphertext
 */

+(NSData*)encryptCBCMode:(NSData*)data withKey:(NSData*)key withIV:(NSData*)iv;

/**
 *  Decrypts with AES in CBC mode
 *
 *  @param data     data to decrypt
 *  @param key      AES key
 *  @param iv       Initialization vector for CBC
 *
 *  @return         plaintext
 */

+(NSData*)decryptCBCMode:(NSData*)data withKey:(NSData*)key withIV:(NSData*)iv;

@end

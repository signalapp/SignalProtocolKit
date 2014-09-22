//
//  AES-CBC.h
//  AxolotlKit
//
//  Created by Frederic Jacobs on 22/07/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AES_CBC : NSObject

+(NSData*)encryptCBCMode:(NSData*)dataToEncrypt withKey:(NSData*)key withIV:(NSData*)iv;
+(NSData*)decryptCBCMode:(NSData*)dataToDecrypt withKey:(NSData*)key withIV:(NSData*)iv;

@end

//
//  ECKeyPair+ECKeyPairTesting.m
//  AxolotlKit
//
//  Created by Frederic Jacobs on 26/10/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import "ECKeyPair+ECKeyPairTesting.h"
#import "NSData+keyVersionByte.h"

@implementation ECKeyPair (testing)

+(ECKeyPair*)keyPairWithPrivateKey:(NSData*)privateKey publicKey:(NSData*)publicKey{
    if (([publicKey length]  == 33)) {
        publicKey = [publicKey removeKeyType];
    }
    
    if ([privateKey length] != ECCKeyLength && [publicKey length] != ECCKeyLength) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Public or Private key is not required size" userInfo:@{@"PrivateKey":privateKey, @"Public Key":publicKey}];
    }
    
    ECKeyPair *keyPair  = [ECKeyPair new];
    memcpy(keyPair->publicKey,  [publicKey  bytes], ECCKeyLength);
    memcpy(keyPair->privateKey, [privateKey bytes], ECCKeyLength);
    
    return keyPair;
}

@end

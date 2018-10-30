//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
//

#import "ECKeyPair+ECKeyPairTesting.h"
#import "NSData+keyVersionByte.h"

NS_ASSUME_NONNULL_BEGIN

@interface ECKeyPair (ECKeyPairTestingPrivate)

- (nullable id)initWithPublicKey:(NSData *)publicKey privateKey:(NSData *)privateKey;

@end

#pragma mark -

@implementation ECKeyPair (testing)

+ (ECKeyPair *)throws_keyPairWithPrivateKey:(NSData *)privateKey publicKey:(NSData *)publicKey
{
    if (([publicKey length]  == 33)) {
        publicKey = [publicKey throws_removeKeyType];
    }
    
    if ([privateKey length] != ECCKeyLength && [publicKey length] != ECCKeyLength) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Public or Private key is not required size" userInfo:@{@"PrivateKey":privateKey, @"Public Key":publicKey}];
    }

    ECKeyPair *keyPairCopy = [[ECKeyPair alloc] initWithPublicKey:[publicKey copy] privateKey:[privateKey copy]];
    return keyPairCopy;
}

@end

NS_ASSUME_NONNULL_END

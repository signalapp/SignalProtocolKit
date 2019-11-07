//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
//

#import "ECKeyPair+ECKeyPairTesting.h"
#import "NSData+keyVersionByte.h"

NS_ASSUME_NONNULL_BEGIN

@implementation ECKeyPair (testing)

+ (ECKeyPair *)throws_keyPairWithPrivateKey:(NSData *)privateKey publicKey:(NSData *)publicKey
{
    if (([publicKey length]  == 33)) {
        publicKey = [publicKey throws_removeKeyType];
    }
    
    if ([privateKey length] != ECCKeyLength && [publicKey length] != ECCKeyLength) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Public or Private key is not required size" userInfo:@{@"PrivateKey":privateKey, @"Public Key":publicKey}];
    }

    NSError *error;
    ECKeyPair *_Nullable keyPairCopy = [[ECKeyPair alloc] initWithPublicKeyData:[publicKey copy] privateKeyData:[privateKey copy] error:&error];
    OWSAssertDebug(error == nil && keyPairCopy != nil);
    return keyPairCopy;
}

@end

NS_ASSUME_NONNULL_END

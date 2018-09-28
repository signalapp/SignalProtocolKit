//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
//

#import "Curve25519.h"

@interface ECKeyPair (ECKeyPairTesting)

+ (ECKeyPair *)keyPairWithPrivateKey:(NSData *)privateKey publicKey:(NSData *)publicKey;

@end

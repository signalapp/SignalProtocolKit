//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
//

#import "Curve25519.h"

NS_ASSUME_NONNULL_BEGIN

@interface ECKeyPair (ECKeyPairTesting)

+ (ECKeyPair *)throws_keyPairWithPrivateKey:(NSData *)privateKey
                                  publicKey:(NSData *)publicKey NS_SWIFT_UNAVAILABLE("throws objc exceptions");

@end

NS_ASSUME_NONNULL_END

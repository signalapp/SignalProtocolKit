//
//  ECKeyPair+ECKeyPairTesting.h
//  AxolotlKit
//
//  Created by Frederic Jacobs on 26/10/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import "Curve25519.h"

@interface ECKeyPair (ECKeyPairTesting)

+(ECKeyPair*)keyPairWithPrivateKey:(NSData*)privateKey publicKey:(NSData*)publicKey;

@end

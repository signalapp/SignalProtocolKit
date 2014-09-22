//
//  RKCK.m
//  AxolotlKit
//
//  Created by Frederic Jacobs on 1/15/14.
//  Copyright (c) 2014 Open Whisper Systems. All rights reserved.
//

#import "RKCK.h"
#import <25519/Curve25519.h>
#import "TSDerivedSecrets.h"

@implementation RKCK

+(instancetype) initWithRK:(RootKey*)rootKey CK:(ChainKey *)chainKey{
    RKCK *rkck = [[self alloc] init];
    rkck.rootKey = rootKey;
    rkck.chain = chainKey;
    return rkck;
}

- (instancetype)createChainWithEphemeral:(ECKeyPair*)myEphemeral fromTheirProvideEphemeral:(NSData*)theirPublicEphemeral{
    NSData *inputKeyMaterial = [Curve25519 generateSharedSecretFromPublicKey:theirPublicEphemeral andKeyPair:myEphemeral];
    //return [[self class]initWithRootKey:self.RK sharedSecret:inputKeyMaterial];
    return nil;
}


@end

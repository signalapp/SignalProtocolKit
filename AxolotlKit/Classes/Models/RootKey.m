//
//  RootKey.m
//  AxolotlKit
//
//  Created by Frederic Jacobs on 22/07/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import "RootKey.h"
#import "TSDerivedSecrets.h"
#import "RKCK.h"
#import <25519/Curve25519.h>
#import "ChainKey.h"

@implementation RootKey
- (RKCK*)createChainWithTheirEphemeral:(NSData*)theirEphemeral ourEphemeral:(ECKeyPair*)ourEphemeral{
    NSData *sharedSecret = [Curve25519 generateSharedSecretFromPublicKey:theirEphemeral andKeyPair:ourEphemeral];
    
    TSDerivedSecrets *secrets = [TSDerivedSecrets derivedRatchetedSecretsWithSharedSecret:sharedSecret rootKey:self];
    
    RKCK *newRKCK = [[RKCK alloc] initWithRK:[[RootKey alloc] initWithData:secrets.cipherKey]
                                          CK:[[ChainKey alloc] initWithData:secrets.macKey index:0]];
    
    return newRKCK;
}
@end

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

static NSString* const kCoderData      = @"kCoderData";

@implementation RootKey

+(BOOL)supportsSecureCoding{
    return YES;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_keyData forKey:kCoderData];
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    
    if (self) {
        _keyData = [aDecoder decodeObjectOfClass:[NSData class] forKey:kCoderData];
    }
    
    return self;
}

- (instancetype)initWithData:(NSData *)data{
    self = [super init];
    
    NSAssert([data length] == 32, @"Expected 32-byte RootKey Data");
    
    if (self) {
        _keyData = data;
    }
    
    return self;
}

- (RKCK*)createChainWithTheirEphemeral:(NSData*)theirEphemeral ourEphemeral:(ECKeyPair*)ourEphemeral{
    NSData *sharedSecret = [Curve25519 generateSharedSecretFromPublicKey:theirEphemeral andKeyPair:ourEphemeral];
    
    TSDerivedSecrets *secrets = [TSDerivedSecrets derivedRatchetedSecretsWithSharedSecret:sharedSecret rootKey:_keyData];
    
    RKCK *newRKCK = [[RKCK alloc] initWithRK:[[RootKey alloc]  initWithData:secrets.cipherKey]
                                          CK:[[ChainKey alloc] initWithData:secrets.macKey index:0]];
    
    return newRKCK;
}

@end

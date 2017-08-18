//
//  Copyright (c) 2017 Open Whisper Systems. All rights reserved.
//

#import "RootKey.h"
#import "TSDerivedSecrets.h"
#import "RKCK.h"
#import <Curve25519Kit/Curve25519.h>
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

    SPKAssert(data.length == ECCKeyLength);

    if (self) {
        _keyData = data;
    }
    
    return self;
}

- (RKCK*)createChainWithTheirEphemeral:(NSData*)theirEphemeral ourEphemeral:(ECKeyPair*)ourEphemeral{
    NSData *sharedSecret = [Curve25519 generateSharedSecretFromPublicKey:theirEphemeral andKeyPair:ourEphemeral];
    SPKAssert(sharedSecret.length == ECCKeyLength);

    TSDerivedSecrets *secrets = [TSDerivedSecrets derivedRatchetedSecretsWithSharedSecret:sharedSecret rootKey:_keyData];

    RKCK *newRKCK = [[RKCK alloc] initWithRK:[[RootKey alloc]  initWithData:secrets.cipherKey]
                                          CK:[[ChainKey alloc] initWithData:secrets.macKey index:0]];
    
    return newRKCK;
}

@end

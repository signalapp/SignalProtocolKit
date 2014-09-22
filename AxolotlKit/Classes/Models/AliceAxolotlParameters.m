//
//  AliceAxolotlParameters.m
//  AxolotlKit
//
//  Created by Frederic Jacobs on 26/07/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import "AliceAxolotlParameters.h"

@implementation AliceAxolotlParameters

@synthesize ourIdentityKeyPair=_ourIdentityKeyPair, theirIdentityKey=_theirIdentityKey;

- (instancetype)initWithIdentityKey:(ECKeyPair*)myIdentityKey theirIdentityKey:(NSData*)theirIdentityKey ourBaseKey:(ECKeyPair*)ourBaseKey theirSignedPreKey:(NSData*)theirSignedPreKey theirOneTimePreKey:(NSData*)theirOneTimePreKey{
    self = [super init];
    
    if (self) {
        self.ourIdentityKeyPair = myIdentityKey;
        self.theirIdentityKey   = theirIdentityKey;
        _ourBaseKey             = ourBaseKey;
        _theirSignedPreKey      = theirSignedPreKey;
        _theirOneTimePrekey     = theirOneTimePreKey;
    }
    
    return self;
}


@end

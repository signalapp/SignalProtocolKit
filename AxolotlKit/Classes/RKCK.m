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

- (instancetype)initWithRK:(RootKey*)rootKey CK:(ChainKey*)chainKey{
    self = [super init];
    self.rootKey = rootKey;
    self.chainKey   = chainKey;
    return self;
}

@end

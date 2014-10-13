//
//  SendingChain.m
//  AxolotlKit
//
//  Created by Frederic Jacobs on 02/09/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import "SendingChain.h"

@interface SendingChain ()

@property (nonatomic)ChainKey *chainKey;

@end

@implementation SendingChain

- (instancetype)initWithChainKey:(ChainKey *)chainKey senderRatchetKeyPair:(ECKeyPair *)keyPair{
    self = [super init];

    if (self) {
        _chainKey             = chainKey;
        _senderRatchetKeyPair = keyPair;
    }

    return self;
}

-(ChainKey *)chainKey{
    return _chainKey;
}

@end

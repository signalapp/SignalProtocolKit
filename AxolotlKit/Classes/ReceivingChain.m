//
//  ReceivingChain.m
//  AxolotlKit
//
//  Created by Frederic Jacobs on 02/09/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import "ReceivingChain.h"

@interface ReceivingChain ()

@property (nonatomic)ChainKey *chainKey;

@end

@implementation ReceivingChain

- (instancetype)initWithChainKey:(ChainKey *)chainKey senderRatchetKey:(NSData *)senderRatchet{
    self = [super init];

    self.chainKey         = chainKey;
    self.senderRatchetKey = senderRatchet;

    return self;
}

-(ChainKey *)chainKey{
    return self.chainKey;
}

-(void)setChainKey:(ChainKey*)nextChainKey{
    self.chainKey = nextChainKey;
}

@end

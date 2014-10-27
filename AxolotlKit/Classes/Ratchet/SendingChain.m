//
//  SendingChain.m
//  AxolotlKit
//
//  Created by Frederic Jacobs on 02/09/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import "SendingChain.h"
#import "ChainKey.h"

@interface SendingChain ()

@property (nonatomic)ChainKey *chainKey;

@end

@implementation SendingChain

static NSString* const kCoderChainKey      = @"kCoderChainKey";
static NSString* const kCoderSenderRatchet = @"kCoderSenderRatchet";

+ (BOOL)supportsSecureCoding{
    return YES;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [self initWithChainKey:[aDecoder decodeObjectOfClass:[ChainKey class] forKey:kCoderChainKey]
             senderRatchetKeyPair:[aDecoder decodeObjectOfClass:[ECKeyPair class] forKey:kCoderSenderRatchet]];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:self.chainKey forKey:kCoderChainKey];
    [aCoder encodeObject:self.senderRatchetKeyPair forKey:kCoderSenderRatchet];
}

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

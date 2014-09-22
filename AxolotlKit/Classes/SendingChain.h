//
//  SendingChain.h
//  AxolotlKit
//
//  Created by Frederic Jacobs on 02/09/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Chain.h"

@class ECKeyPair;

@interface SendingChain : NSObject<Chain>

-(instancetype)initWithChainKey:(ChainKey*)chainKey senderRatchetKeyPair:(ECKeyPair*)keyPair;

@property ECKeyPair *senderRatchetKeyPair;

@end

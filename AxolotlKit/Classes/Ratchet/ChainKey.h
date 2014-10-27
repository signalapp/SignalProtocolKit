//
//  ChainKey.h
//  AxolotlKit
//
//  Created by Frederic Jacobs on 26/08/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import "Chain.h"
#import "MessageKeys.h"
#import <Foundation/Foundation.h>

@interface ChainKey : NSObject <NSSecureCoding>

-(instancetype)initWithData:(NSData*)chainKey index:(int)index;

-(instancetype)nextChainKey;

-(MessageKeys*)messageKeys;

-(NSData*)baseMaterial:(NSData*)seed;

@property (readonly) int index;
@property (readonly) NSData *key;

@end

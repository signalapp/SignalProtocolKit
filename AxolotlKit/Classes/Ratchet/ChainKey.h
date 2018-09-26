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

NS_ASSUME_NONNULL_BEGIN

@interface ChainKey : NSObject <NSSecureCoding>

@property (nonatomic, readonly) int index;
@property (nonatomic, readonly) NSData *key;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithData:(NSData *)chainKey index:(int)index NS_DESIGNATED_INITIALIZER;

- (instancetype)nextChainKey;

- (MessageKeys *)messageKeys;

@end

NS_ASSUME_NONNULL_END

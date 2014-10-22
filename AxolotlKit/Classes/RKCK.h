//
//  RKCK.h
//  AxolotlKit
//
//  Created by Frederic Jacobs on 1/15/14.
//  Copyright (c) 2014 Open Whisper Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SessionState.h"
#import "Chain.h"
#import "RootKey.h"
@class ECKeyPair;

@interface RKCK : NSObject

@property (nonatomic,strong) RootKey  *rootKey;
@property (nonatomic,strong) ChainKey *chainKey;

-(instancetype) initWithRK:(RootKey*)rootKey CK:(ChainKey*)chainKey;

@end
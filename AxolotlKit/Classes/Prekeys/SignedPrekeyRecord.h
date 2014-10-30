//
//  SignedPrekeyRecord.h
//  AxolotlKit
//
//  Created by Frederic Jacobs on 26/07/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PreKeyRecord.h"
#import <25519/Curve25519.h>

@interface SignedPreKeyRecord : PreKeyRecord <NSSecureCoding>

@property (nonatomic, readonly) NSData *signature;
@property (nonatomic, readonly) NSDate *generatedAt;

- (instancetype)initWithId:(int)identifier keyPair:(ECKeyPair *)keyPair signature:(NSData*)signature generatedAt:(NSDate*)generatedAt;

@end

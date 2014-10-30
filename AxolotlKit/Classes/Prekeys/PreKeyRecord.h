//
//  PreKeyRecord.h
//  AxolotlKit
//
//  Created by Frederic Jacobs on 26/07/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import <25519/Curve25519.h>
#import <Foundation/Foundation.h>


@interface PreKeyRecord : NSObject <NSSecureCoding>

@property (nonatomic, readonly) int       Id;
@property (nonatomic, readonly) ECKeyPair *keyPair;

- (instancetype)initWithId:(int)identifier keyPair:(ECKeyPair*)keyPair;

@end

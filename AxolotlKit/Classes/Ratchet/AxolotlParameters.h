//
//  AxolotlParameters.h
//  AxolotlKit
//
//  Created by Frederic Jacobs on 22/07/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Curve25519Kit/Curve25519.h>

@protocol AxolotlParameters <NSObject>

@property (nonatomic) ECKeyPair *ourIdentityKeyPair;
@property (nonatomic) NSData    *theirIdentityKey;

@end

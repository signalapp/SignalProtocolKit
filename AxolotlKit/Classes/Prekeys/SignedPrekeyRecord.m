//
//  SignedPrekeyRecord.m
//  AxolotlKit
//
//  Created by Frederic Jacobs on 26/07/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import "SignedPreKeyRecord.h"



@implementation SignedPreKeyRecord

- (instancetype)initWithId:(int)identifier keyPair:(ECKeyPair *)keyPair signature:(NSData*)signature generatedAt:(NSDate *)generatedAt{
    self = [super initWithId:identifier keyPair:keyPair];
    
    if (self) {
        _signature = signature;
        _generatedAt = generatedAt;
    }
    
    return self;
}

- (instancetype)initWithId:(int)identifier keyPair:(ECKeyPair*)keyPair{
    NSAssert(FALSE, @"Signed PreKeys need a signature");
    return nil;
}

@end

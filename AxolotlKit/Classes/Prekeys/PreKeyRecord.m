//
//  PreKeyRecord.m
//  AxolotlKit
//
//  Created by Frederic Jacobs on 26/07/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import "PreKeyRecord.h"


@implementation PreKeyRecord

- (instancetype)initWithId:(int)identifier keyPair:(ECKeyPair*)keyPair{
    self = [super init];
    
    if (self) {
        _Id      = identifier;
        _keyPair = keyPair;
    }
    
    return self;
}

@end

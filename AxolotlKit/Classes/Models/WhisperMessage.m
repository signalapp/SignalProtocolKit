//
//  WhisperMessage.m
//  AxolotlKit
//
//  Created by Frederic Jacobs on 23/07/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import "WhisperMessage.h"

@implementation WhisperMessage

-(instancetype)initWithVersion:(int)version macKey:(NSData*)macKey senderRatchetKey:(NSData*)senderRatchetKey previousCounter:(NSInteger)previousCounter counter:(NSInteger)counter cipherText:(NSData*)cipherText{
    self = [super init];
    
    if (self) {
        _version          = version;
        _macKey           = macKey;
        _senderRatchetKey = senderRatchetKey;
        _previousCounter  = previousCounter;
        _counter          = counter;
        _cipherText       = cipherText;
    }
    return self;
}

@end

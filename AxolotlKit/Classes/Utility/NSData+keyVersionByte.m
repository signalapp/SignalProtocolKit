//
//  NSData+keyVersionByte.m
//  AxolotlKit
//
//  Created by Frederic Jacobs on 26/10/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import "AxolotlExceptions.h"
#import "NSData+keyVersionByte.h"

@implementation NSData (keyVersionByte)

const Byte DJB_TYPE = 0x05;

- (instancetype)prependKeyType {
    if (self.length == 32) {
        NSMutableData *data = [NSMutableData dataWithBytes:&DJB_TYPE length:1];
        [data appendData:self.copy];
        return data;
    }
    return self;
}

- (instancetype)removeKeyType {
    if (self.length == 33) {
        if ([[self subdataWithRange:NSMakeRange(0, 1)] isEqualToData:[NSData dataWithBytes:&DJB_TYPE length:1]]) {
            return [self subdataWithRange:NSMakeRange(1, 32)];
        } else{
            @throw [NSException exceptionWithName:InvalidKeyException reason:@"Key type is incorrect" userInfo:@{}];
        }
    } else{
        return self;
    }
}

@end

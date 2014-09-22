//
//  TSMessageKeys.m
//  AxolotlKit
//
//  Created by Frederic Jacobs on 09/03/14.
//  Copyright (c) 2014 Open Whisper Systems. All rights reserved.
//

#import "MessageKeys.h"

@implementation MessageKeys

- (instancetype)initWithCipherKey:(NSData*)cipherKey macKey:(NSData*)macKey iv:(NSData *)data{
    self = [super init];
    if (self) {
        _cipherKey = cipherKey;
        _macKey = macKey;
        _iv = data;
    }
    
    return self;
}
-(NSString*) debugDescription {
    return [NSString stringWithFormat:@"cipherKey: %@\n macKey %@\n",self.cipherKey,self.macKey];
}

@end

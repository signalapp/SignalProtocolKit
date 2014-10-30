//
//  SignedPrekeyRecord.m
//  AxolotlKit
//
//  Created by Frederic Jacobs on 26/07/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import "SignedPreKeyRecord.h"

static NSString* const kCoderPreKeyId        = @"kCoderPreKeyId";
static NSString* const kCoderPreKeyPair      = @"kCoderPreKeyPair";
static NSString* const kCoderPreKeyDate      = @"kCoderPreKeyDate";
static NSString* const kCoderPreKeySignature = @"kCoderPreKeySignature";

@implementation SignedPreKeyRecord

+ (BOOL)supportsSecureCoding{
    return YES;
}

- (instancetype)initWithId:(int)identifier keyPair:(ECKeyPair *)keyPair signature:(NSData*)signature generatedAt:(NSDate *)generatedAt{
    self = [super initWithId:identifier keyPair:keyPair];
    
    if (self) {
        _signature = signature;
        _generatedAt = generatedAt;
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
   return [self initWithId:[aDecoder decodeIntForKey:kCoderPreKeyId]
             keyPair:[aDecoder decodeObjectOfClass:[ECKeyPair class] forKey:kCoderPreKeyPair]
           signature:[aDecoder decodeObjectOfClass:[NSData class] forKey:kCoderPreKeySignature]
         generatedAt:[aDecoder decodeObjectOfClass:[NSDate class] forKey:kCoderPreKeyDate]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeInt:self.Id forKey:kCoderPreKeyId];
    [aCoder encodeObject:self.keyPair forKey:kCoderPreKeyPair];
    [aCoder encodeObject:self.signature forKey:kCoderPreKeySignature];
    [aCoder encodeObject:self.generatedAt forKey:kCoderPreKeyDate];
}

- (instancetype)initWithId:(int)identifier keyPair:(ECKeyPair*)keyPair{
    NSAssert(FALSE, @"Signed PreKeys need a signature");
    return nil;
}

@end

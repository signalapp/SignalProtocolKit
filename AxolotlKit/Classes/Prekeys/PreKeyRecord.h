//
//  Copyright (c) 2017 Open Whisper Systems. All rights reserved.
//

#import <Curve25519Kit/Curve25519.h>
#import <Foundation/Foundation.h>


@interface PreKeyRecord : NSObject <NSSecureCoding>

@property (nonatomic, readonly) int       Id;
@property (nonatomic, readonly) ECKeyPair *keyPair;
@property (nonatomic, readonly, nullable) NSDate *createdAt;

- (instancetype)initWithId:(int)identifier
                   keyPair:(ECKeyPair*)keyPair
                 createdAt:(NSDate *)createdAt;

- (void)setCreatedAtToNow;

@end

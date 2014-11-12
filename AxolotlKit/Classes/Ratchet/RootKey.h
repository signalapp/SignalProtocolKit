//
//  RootKey.h
//  AxolotlKit
//
//  Created by Frederic Jacobs on 22/07/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import <Foundation/Foundation.h>
@class RKCK;
@class ECKeyPair;

@interface RootKey : NSObject <NSSecureCoding>

- (instancetype)initWithData:(NSData *)data;
- (RKCK*)createChainWithTheirEphemeral:(NSData*)theirEphemeral ourEphemeral:(ECKeyPair*)ourEphemeral;

@property (nonatomic, readonly) NSData *keyData;

@end

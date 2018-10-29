//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ECKeyPair;
@class RKCK;

@interface RootKey : NSObject <NSSecureCoding>

- (instancetype)initWithData:(NSData *)data;
- (RKCK *)try_createChainWithTheirEphemeral:(NSData *)theirEphemeral ourEphemeral:(ECKeyPair *)ourEphemeral;

@property (nonatomic, readonly) NSData *keyData;

@end

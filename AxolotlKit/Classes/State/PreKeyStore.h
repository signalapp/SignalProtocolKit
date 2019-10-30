//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

#import "PreKeyRecord.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PreKeyStore <NSObject>

- (nullable PreKeyRecord *)loadPreKey:(int)preKeyId;

- (void)storePreKey:(int)preKeyId preKeyRecord:(PreKeyRecord *)record;

- (void)removePreKey:(int)preKeyId
     protocolContext:(nullable id<SPKProtocolWriteContext>)protocolContext;

@end

NS_ASSUME_NONNULL_END

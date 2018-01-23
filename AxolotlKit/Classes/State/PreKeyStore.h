//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
//

#import "PreKeyRecord.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol PreKeyStore <NSObject>

- (PreKeyRecord *)loadPreKey:(int)preKeyId;

- (void)storePreKey:(int)preKeyId preKeyRecord:(PreKeyRecord *)record;

- (BOOL)containsPreKey:(int)preKeyId;

- (void)removePreKey:(int)preKeyId;

@end

NS_ASSUME_NONNULL_END

//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

#import "SignedPrekeyRecord.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SignedPreKeyStore <NSObject>

- (nullable SignedPreKeyRecord *)loadSignedPreKey:(int)signedPreKeyId;

- (NSArray<SignedPreKeyRecord *> *)loadSignedPreKeys;

- (void)storeSignedPreKey:(int)signedPreKeyId signedPreKeyRecord:(SignedPreKeyRecord *)signedPreKeyRecord;

- (BOOL)containsSignedPreKey:(int)signedPreKeyId;

- (void)removeSignedPreKey:(int)signedPreKeyId;

@end

NS_ASSUME_NONNULL_END

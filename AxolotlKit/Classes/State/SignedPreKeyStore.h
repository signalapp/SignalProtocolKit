//
//  Copyright (c) 2017 Open Whisper Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SignedPrekeyRecord.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SignedPreKeyStore <NSObject>

- (SignedPreKeyRecord *)loadSignedPrekey:(int)signedPreKeyId;

- (nullable SignedPreKeyRecord *)loadSignedPrekeyOrNil:(int)signedPreKeyId;

- (NSArray<SignedPreKeyRecord *> *)loadSignedPreKeys;

- (void)storeSignedPreKey:(int)signedPreKeyId signedPreKeyRecord:(SignedPreKeyRecord *)signedPreKeyRecord;

- (BOOL)containsSignedPreKey:(int)signedPreKeyId;

- (void)removeSignedPreKey:(int)signedPrekeyId;

@end

NS_ASSUME_NONNULL_END

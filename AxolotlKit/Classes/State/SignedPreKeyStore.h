//
//  Copyright (c) 2017 Open Whisper Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SignedPrekeyRecord.h"

@protocol SignedPreKeyStore <NSObject>

- (SignedPreKeyRecord*)loadSignedPrekey:(int)signedPreKeyId;

- (nullable SignedPreKeyRecord *)loadSignedPrekeyOrNil:(int)signedPreKeyId;

- (NSArray*)loadSignedPreKeys;

- (void)storeSignedPreKey:(int)signedPreKeyId signedPreKeyRecord:(SignedPreKeyRecord*)signedPreKeyRecord;

- (BOOL)containsSignedPreKey:(int)signedPreKeyId;

- (void)removeSignedPreKey:(int)signedPrekeyId;


@end

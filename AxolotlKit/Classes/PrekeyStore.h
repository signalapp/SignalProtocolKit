//
//  PrekeyStore.h
//  AxolotlKit
//
//  Created by Frederic Jacobs on 23/07/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PreKeyRecord.h"
#import "SignedPreKeyRecord.h"

@protocol PrekeyStore <NSObject>

- (SignedPreKeyRecord*)loadSignedPrekey:(int)signedPreKeyId;

- (NSArray*)loadSignedPreKeys;

- (void)storeSignedPreKey:(int)signedPreKeyId signedPreKeyRecord:(SignedPreKeyRecord*)signedPreKeyRecord;

- (BOOL)containsSignedPreKey:(int)signedPreKeyId;

- (void)removeSignedPreKey:(int)signedPrekeyId;

- (PreKeyRecord*)loadPrekey:(int)preKeyId;

- (NSArray*)loadPreKeys;

- (void)storePreKey:(int)signedPreKeyId preKeyRecord:(PreKeyRecord*)preKeyRecord;

- (BOOL)containsPreKey:(int)signedPreKeyId;

- (void)removePreKey:(int)signedPrekeyId;

@end

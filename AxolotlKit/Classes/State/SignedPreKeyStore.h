//
//  SignedPrekeyStore.h
//  AxolotlKit
//
//  Created by Frederic Jacobs on 12/10/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SignedPrekeyRecord.h"

@protocol SignedPreKeyStore <NSObject>

- (SignedPreKeyRecord*)loadSignedPrekey:(int)signedPreKeyId;

- (NSArray*)loadSignedPreKeys;

- (void)storeSignedPreKey:(int)signedPreKeyId signedPreKeyRecord:(SignedPreKeyRecord*)signedPreKeyRecord;

- (BOOL)containsSignedPreKey:(int)signedPreKeyId;

- (void)removeSignedPreKey:(int)signedPrekeyId;


@end

//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

#import "SignedPrekeyRecord.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SignedPreKeyStore <NSObject>

- (nullable SignedPreKeyRecord *)loadSignedPreKey:(int)signedPreKeyId
                                  protocolContext:(nullable id<SPKProtocolReadContext>)protocolContext;

- (NSArray<SignedPreKeyRecord *> *)loadSignedPreKeysWithProtocolContext:(nullable id<SPKProtocolReadContext>)protocolContext;

- (void)storeSignedPreKey:(int)signedPreKeyId
       signedPreKeyRecord:(SignedPreKeyRecord *)signedPreKeyRecord
          protocolContext:(nullable id<SPKProtocolWriteContext>)protocolContext;

- (BOOL)containsSignedPreKey:(int)signedPreKeyId
             protocolContext:(nullable id<SPKProtocolReadContext>)protocolContext;

- (void)removeSignedPreKey:(int)signedPreKeyId
           protocolContext:(nullable id<SPKProtocolWriteContext>)protocolContext;

- (NSArray<NSString *> *)availableSignedPreKeyIdsWithProtocolContext:(nullable id<SPKProtocolReadContext>)protocolContext;

@end

NS_ASSUME_NONNULL_END

//
//  IdentityStore.h
//  AxolotlKit
//
//  Created by Frederic Jacobs on 23/07/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ECKeyPair;

typedef enum : NSUInteger {
    kIdentityKeyNotFound,
    kIdentityKeyMatching,
    kIdentityKeyConflict,
} IdentityKeyComparison;

@protocol IdentityStore <NSObject>

-(ECKeyPair*)myIdentityKeyPair;

-(int)localRegistrationId;

-(void)saveIdentityKeyAsTrusted:(NSInteger)recipientId identityKey:(NSData*)identityKey;

-(IdentityKeyComparison)isTrustedIdentity:(NSInteger)recipientId identityKey:(NSData*)identityKey;

@end

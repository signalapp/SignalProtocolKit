//
//  IdentityKeyStore.h
//  AxolotlKit
//
//  Created by Frederic Jacobs on 12/10/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IdentityKeyStore <NSObject>

- (NSData*)identityKeyPair;
- (int)localRegistrationId;
- (void)saveRemoteIdentity:(NSData*)identityKey recipientId:(long)recipientId;
- (BOOL)isTrustedIdentityKey:(NSData*)identityKey recipientId:(long)recipientId;

@end

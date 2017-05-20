//
//  Copyright (c) 2017 Open Whisper Systems. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ECKeyPair;

typedef NS_ENUM(NSInteger, TSMessageDirection) {
    TSMessageDirectionUnknown = 0,
    TSMessageDirectionIncoming,
    TSMessageDirectionOutgoing
};

@protocol IdentityKeyStore <NSObject>

- (ECKeyPair*)identityKeyPair;
- (int)localRegistrationId;
- (void)saveRemoteIdentity:(NSData*)identityKey recipientId:(NSString*)recipientId;
- (BOOL)isTrustedIdentityKey:(NSData*)identityKey recipientId:(NSString*)recipientId direction:(TSMessageDirection)direction;

@end

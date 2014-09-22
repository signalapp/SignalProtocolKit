//
//  AxolotlMessage.h
//  AxolotlKit
//
//  Created by Frederic Jacobs on 21/07/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    kDecryptedSuccessfully,
    kBadHMAC,
    kIdentityKeyMismatch,
} kDecryptionStatus;

@interface AxolotlPlainMessage : NSObject

@property NSData *body; // Protocol Buffer of the PushMessageContent
@property NSInteger kDecryptionStatus;

-(NSData*)hmacWithKey:(NSData*)data;


@end

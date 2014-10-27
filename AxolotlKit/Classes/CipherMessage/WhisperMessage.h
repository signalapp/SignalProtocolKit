//
//  WhisperMessage.h
//  AxolotlKit
//
//  Created by Frederic Jacobs on 23/07/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CipherMessage.h"

@class ECKeyPair;

@interface WhisperMessage : NSObject <CipherMessage>

@property (nonatomic, readonly) int       version;
@property (nonatomic, readonly) NSData    *senderRatchetKey;
@property (nonatomic, readonly) int       previousCounter;
@property (nonatomic, readonly) int       counter;
@property (nonatomic, readonly) NSData    *cipherText;
@property (nonatomic, readonly) NSData    *serialized;

- (instancetype)initWithData:(NSData*)serialized;

- (instancetype)initWithVersion:(int)version macKey:(NSData*)macKey senderRatchetKey:(NSData*)senderRatchetKey counter:(int)counter previousCounter:(int)previousCounter cipherText:(NSData*)cipherText senderIdentityKey:(NSData*)senderIdentityKey receiverIdentityKey:(NSData*)receiverIdentityKey;

- (void)verifyMacWithVersion:(int)messageVersion senderIdentityKey:(NSData *)senderIdentityKey receiverIdentityKey:(NSData*)receiverIdentityKey macKey:(NSData *)macKey;

@end

//
//  WhisperMessage.h
//  AxolotlKit
//
//  Created by Frederic Jacobs on 23/07/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ECKeyPair;

@interface WhisperMessage : NSObject

-(instancetype)initWithVersion:(int)version macKey:(NSData*)macKey senderRatchetKey:(NSData*)senderRatchetKey previousCounter:(NSInteger)previousCounter counter:(NSInteger)counter cipherText:(NSData*)cipherText;

@property (nonatomic, readonly) int       version;
@property (nonatomic, readonly) NSData*   macKey;
@property (nonatomic, readonly) NSData*   senderRatchetKey;
@property (nonatomic, readonly) int previousCounter;
@property (nonatomic, readonly) int counter;

@property (nonatomic, readonly) NSData *cipherText;

-(void)verifyMacWithVersion:(int)messageVersion identityKey:(NSData*)identityKey receiverIdentityKey:(ECKeyPair*)receiverKeyPair macKey:(NSData*)macKey;

@end

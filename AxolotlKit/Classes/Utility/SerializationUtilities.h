//
//  SerializationUtilities.h
//  AxolotlKit
//
//  Created by Frederic Jacobs on 26/10/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>

#define MAC_LENGTH 8

@interface SerializationUtilities : NSObject

+ (int)highBitsToIntFromByte:(Byte)byte;

+ (int)lowBitsToIntFromByte:(Byte)byte;

+ (Byte)intsToByteHigh:(int)highValue low:(int)lowValue;

+ (NSData*)macWithVersion:(int)version identityKey:(NSData*)senderIdentityKey receiverIdentityKey:(NSData*)receiverIdentityKey macKey:(NSData*)macKey serialized:(NSData*)serialized;

@end

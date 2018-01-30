//
//  Copyright (c) 2017 Open Whisper Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

#define MAC_LENGTH 8

@interface SerializationUtilities : NSObject

+ (int)highBitsToIntFromByte:(Byte)byte;

+ (int)lowBitsToIntFromByte:(Byte)byte;

+ (Byte)intsToByteHigh:(int)highValue low:(int)lowValue;

+ (NSData*)macWithVersion:(int)version identityKey:(NSData*)senderIdentityKey receiverIdentityKey:(NSData*)receiverIdentityKey macKey:(NSData*)macKey serialized:(NSData*)serialized;

@end

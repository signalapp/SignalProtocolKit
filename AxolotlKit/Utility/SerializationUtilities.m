//
//  SerializationUtilities.m
//  AxolotlKit
//
//  Created by Frederic Jacobs on 26/10/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import "SerializationUtilities.h"


@implementation SerializationUtilities

+ (int)highBitsToIntFromByte:(Byte)byte{
    return (byte & 0xFF) >> 4;
}

+ (int)lowBitsToIntFromByte:(Byte)byte{
    return (byte & 0xF);
}

+ (Byte)intsToByteHigh:(int)highValue low:(int)lowValue{
    return (Byte)((highValue << 4 | lowValue) & 0xFF);
}

+ (NSData*)macWithVersion:(int)version identityKey:(NSData*)senderIdentityKey receiverIdentityKey:(NSData*)receiverIdentityKey macKey:(NSData*)macKey serialized:(NSData*)serialized {
    
    uint8_t ourHmac[CC_SHA256_DIGEST_LENGTH] = {0};
    CCHmacContext context;
    CCHmacInit  (&context, kCCHmacAlgSHA256, [macKey bytes], [macKey length]);
    CCHmacUpdate(&context, [senderIdentityKey bytes], [senderIdentityKey length]);
    CCHmacUpdate(&context, [receiverIdentityKey bytes], [receiverIdentityKey length]);
    CCHmacUpdate(&context, [serialized bytes], [serialized length]);
    CCHmacFinal (&context, &ourHmac);
    
    return [NSData dataWithBytes:ourHmac length:MAC_LENGTH];
}



@end

//
//  Copyright (c) 2017 Open Whisper Systems. All rights reserved.
//

#import "SerializationUtilities.h"
#import <CommonCrypto/CommonCrypto.h>

NS_ASSUME_NONNULL_BEGIN

@implementation SerializationUtilities

+ (int)highBitsToIntFromByte:(Byte)byte
{
    return (byte & 0xFF) >> 4;
}

+ (int)lowBitsToIntFromByte:(Byte)byte
{
    return (byte & 0xF);
}

+ (Byte)intsToByteHigh:(int)highValue low:(int)lowValue
{
    return (Byte)((highValue << 4 | lowValue) & 0xFF);
}

+ (NSData *)macWithVersion:(int)version
               identityKey:(NSData *)senderIdentityKey
       receiverIdentityKey:(NSData *)receiverIdentityKey
                    macKey:(NSData *)macKey
                serialized:(NSData *)serialized
{
    OWSAssert(macKey);
    OWSAssert(macKey.length < SIZE_MAX);
    OWSAssert(senderIdentityKey);
    OWSAssert(senderIdentityKey.length < SIZE_MAX);
    OWSAssert(receiverIdentityKey);
    OWSAssert(receiverIdentityKey.length < SIZE_MAX);
    OWSAssert(serialized);
    OWSAssert(serialized.length < SIZE_MAX);

    NSMutableData *_Nullable bufferData = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    OWSAssert(bufferData);

    CCHmacContext context;
    CCHmacInit(&context, kCCHmacAlgSHA256, [macKey bytes], [macKey length]);
    CCHmacUpdate(&context, [senderIdentityKey bytes], [senderIdentityKey length]);
    CCHmacUpdate(&context, [receiverIdentityKey bytes], [receiverIdentityKey length]);
    CCHmacUpdate(&context, [serialized bytes], [serialized length]);
    CCHmacFinal(&context, bufferData.mutableBytes);

    return [bufferData subdataWithRange:NSMakeRange(0, MAC_LENGTH)];
}

@end

NS_ASSUME_NONNULL_END

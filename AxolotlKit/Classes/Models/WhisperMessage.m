//
//  WhisperMessage.m
//  AxolotlKit
//
//  Created by Frederic Jacobs on 23/07/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import "Constants.h"
#import "WhisperMessage.h"
#import "WhisperTextProtocol.pb.h"

#import <CommonCrypto/CommonCrypto.h>

#define MAC_LENGTH 8
#define VERSION_LENGTH 1

@implementation WhisperMessage

- (instancetype)initWithVersion:(int)version macKey:(NSData*)macKey senderRatchetKey:(NSData*)senderRatchetKey counter:(int)counter previousCounter:(int)previousCounter cipherText:(NSData*)cipherText senderIdentityKey:(NSData*)senderIdentityKey receiverIdentityKey:(NSData*)receiverIdentityKey{
    self = [super init];
    
    Byte versionByte = [self intsToByteHigh:version low:CURRENT_VERSION];
    NSData *versionData = [NSData dataWithBytes:&versionByte length:1];
    
    NSData *message = [[[[[[[TSProtoWhisperMessage builder] setRatchetKey:senderRatchetKey] setCounter:counter] setPreviousCounter:previousCounter] setCiphertext:cipherText] build] data];
    
    NSLog(@"messageData: %@", message);
    NSMutableData *versionAndMessage = [versionData mutableCopy];
    [versionAndMessage appendData:message];
    
    NSLog(@"MAKING MESSAGE WITH VERSION %d IDENTITY KEY %@ RECEIVER IDENTITY KEY %@  MAC KEY %@ SERIALIZED %@", version, senderIdentityKey, receiverIdentityKey, macKey,versionAndMessage);
    
    NSData *mac     = [self macWithVersion:version
                               identityKey:senderIdentityKey
                       receiverIdentityKey:receiverIdentityKey
                                    macKey:macKey
                                serialized:versionAndMessage];
    
    [versionAndMessage appendData:mac];
    
    if (self) {
        _version          = version;
        _senderRatchetKey = senderRatchetKey;
        _previousCounter  = previousCounter;
        _counter          = counter;
        _cipherText       = cipherText;
        _serialized       = versionAndMessage;
    }
    
    return self;
}

- (instancetype)initWithData:(NSData*)serialized{
    if (serialized.length <= (VERSION_LENGTH + MAC_LENGTH)) {
        @throw [NSException exceptionWithName:InvalidMessageException reason:@"Message size is too short to have content" userInfo:@{}];
    }
    
    Byte version;
    [serialized getBytes:&version length:1];
    
    NSData *messageAndMac = [serialized subdataWithRange:NSMakeRange(VERSION_LENGTH, serialized.length - VERSION_LENGTH)];
    
    NSData *message = [messageAndMac subdataWithRange:NSMakeRange(0, messageAndMac.length - MAC_LENGTH)];
    
    //NSData *mac     = [messageAndMac subdataWithRange:NSMakeRange(message.length,MAC_LENGTH)];
    
    if ([self highBitsToIntFromByte:version] < MINIMUM_SUPPORTED_VERSION) {
        @throw [NSException exceptionWithName:LegacyMessageException reason:@"Message was sent with an unsupported version of the TextSecure protocol." userInfo:@{}];
    }
    
    if ([self highBitsToIntFromByte:version] > CURRENT_VERSION) {
        @throw [NSException exceptionWithName:InvalidMessageException reason:@"Unknown Version" userInfo:@{@"Version": [NSNumber numberWithChar:[self highBitsToIntFromByte:version]]}];
    }
    
    TSProtoWhisperMessage *whisperMessage = [TSProtoWhisperMessage parseFromData:message];
    
    if (!whisperMessage.hasCiphertext || !whisperMessage.hasCounter || !whisperMessage.hasRatchetKey) {
        @throw [NSException exceptionWithName:InvalidMessageException reason:@"Incomplete Message" userInfo:@{}];
    }
    
    _serialized       = serialized;
    _senderRatchetKey = whisperMessage.ratchetKey;
    _version          = [self highBitsToIntFromByte:version];
    _counter          = whisperMessage.counter;
    _previousCounter  = whisperMessage.previousCounter;
    _cipherText       = whisperMessage.ciphertext;

    return self;
}

- (void)verifyMacWithVersion:(int)messageVersion senderIdentityKey:(NSData *)senderIdentityKey receiverIdentityKey:(NSData*)receiverIdentityKey macKey:(NSData *)macKey{
    
    NSData *data     = [self.serialized subdataWithRange:NSMakeRange(0, self.serialized.length - MAC_LENGTH)];
    NSData *theirMac = [self.serialized subdataWithRange:NSMakeRange(self.serialized.length - MAC_LENGTH, MAC_LENGTH)];
    NSData *ourMac   = [self macWithVersion:messageVersion
                                identityKey:senderIdentityKey
                        receiverIdentityKey:receiverIdentityKey
                                     macKey:macKey
                                 serialized:data];
    
    NSLog(@"Their Mac: %@", macKey);
    NSLog(@"Our Mac: %@", ourMac);
    
    NSLog(@"Receiving MESSAGE WITH VERSION %d IDENTITY KEY %@ RECEIVER IDENTITY KEY %@  MAC KEY %@ SERIALIZED %@", messageVersion, senderIdentityKey, receiverIdentityKey, macKey, data);
    
    if (![theirMac isEqualToData:ourMac]) {
        @throw [NSException exceptionWithName:InvalidMessageException reason:@"Bad Mac!" userInfo:@{}];
    }
}


# pragma mark Utility Methods

- (int)highBitsToIntFromByte:(Byte)byte{
    return (byte & 0xFF) >> 4;
}

- (int)lowBitsToIntFromByte:(Byte)byte{
    return (byte & 0xF);
}

- (Byte)intsToByteHigh:(int)highValue low:(int)lowValue{
    return (Byte)((highValue << 4 | lowValue) & 0xFF);
}

- (NSData*)macWithVersion:(int)version identityKey:(NSData*)senderIdentityKey receiverIdentityKey:(NSData*)receiverIdentityKey macKey:(NSData*)macKey serialized:(NSData*)serialized {
    
    uint8_t ourHmac[CC_SHA256_DIGEST_LENGTH] = {0};
    CCHmacContext context;
    CCHmacInit  (&context, kCCHmacAlgSHA256, [macKey bytes], [macKey length]);
    CCHmacUpdate(&context, [senderIdentityKey bytes], [senderIdentityKey length]);
    CCHmacUpdate(&context, [receiverIdentityKey bytes], [receiverIdentityKey length]);
    CCHmacUpdate(&context, [serialized bytes], [serialized length]);
    CCHmacFinal (&context, &ourHmac);
    
    return [NSData dataWithBytes:ourHmac length:CC_SHA256_DIGEST_LENGTH];
}

- (NSData*)computeSHA256HMAC:(NSData*)dataToHMAC withHMACKey:(NSData*)HMACKey{
    uint8_t ourHmac[CC_SHA256_DIGEST_LENGTH] = {0};
    CCHmac(kCCHmacAlgSHA256,
           [HMACKey bytes],
           [HMACKey length],
           [dataToHMAC bytes],
           [dataToHMAC  length],
           ourHmac);
    return [NSData dataWithBytes:ourHmac length:CC_SHA256_DIGEST_LENGTH];
}


@end

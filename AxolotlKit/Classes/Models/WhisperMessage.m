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
#import "NSData+keyVersionByte.h"

#import <CommonCrypto/CommonCrypto.h>

#define MAC_LENGTH 8
#define VERSION_LENGTH 1

@implementation WhisperMessage

- (instancetype)initWithVersion:(int)version macKey:(NSData*)macKey senderRatchetKey:(NSData*)senderRatchetKey counter:(int)counter previousCounter:(int)previousCounter cipherText:(NSData*)cipherText senderIdentityKey:(NSData*)senderIdentityKey receiverIdentityKey:(NSData*)receiverIdentityKey{
    self = [super init];
    
    Byte   versionByte    = [self intsToByteHigh:version low:CURRENT_VERSION];
    NSMutableData *serialized  = [NSMutableData dataWithBytes:&versionByte length:1];

    NSData *message       = [[[[[[[TSProtoWhisperMessage builder]
                                    setRatchetKey:senderRatchetKey]
                                    setCounter:counter]
                                    setPreviousCounter:previousCounter]
                                    setCiphertext:cipherText]
                                    build] data];
    [serialized appendData:message];
    
    NSData *mac = [self macWithVersion:version
                               identityKey:[senderIdentityKey prependKeyType]
                       receiverIdentityKey:[receiverIdentityKey prependKeyType]
                                    macKey:macKey
                                serialized:serialized];
    
    [serialized appendData:mac];
    
    if (self) {
        _version          = version;
        _senderRatchetKey = senderRatchetKey;
        _previousCounter  = previousCounter;
        _counter          = counter;
        _cipherText       = cipherText;
        _serialized       = serialized;
    }
    
    return self;
}

- (instancetype)initWithData:(NSData*)serialized{
    if (serialized.length <= (VERSION_LENGTH + MAC_LENGTH)) {
        @throw [NSException exceptionWithName:InvalidMessageException reason:@"Message size is too short to have content" userInfo:@{}];
    }
    
    Byte version;
    [serialized getBytes:&version length:VERSION_LENGTH];
    
    NSData *messageAndMac = [serialized subdataWithRange:NSMakeRange(VERSION_LENGTH, serialized.length - VERSION_LENGTH)];
    
    NSData *message = [messageAndMac subdataWithRange:NSMakeRange(0, messageAndMac.length - MAC_LENGTH)];
    
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
    _senderRatchetKey = [whisperMessage.ratchetKey removeKeyType];
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
                                identityKey:[senderIdentityKey prependKeyType]
                        receiverIdentityKey:[receiverIdentityKey prependKeyType]
                                     macKey:macKey
                                 serialized:data];
    
    NSLog(@"Their Mac: %@", macKey);
    NSLog(@"Our Mac: %@", ourMac);
    
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
    
    return [NSData dataWithBytes:ourHmac length:MAC_LENGTH];
}

@end

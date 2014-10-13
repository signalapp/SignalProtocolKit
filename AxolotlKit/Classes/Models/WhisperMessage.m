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

#define MAC_LENGTH 8
#define VERSION_LENGTH 1

@implementation WhisperMessage

- (instancetype)initWithVersion:(int)version macKey:(NSData*)macKey senderRatchetKey:(NSData*)senderRatchetKey previousCounter:(int)previousCounter counter:(int)counter cipherText:(NSData*)cipherText{
    self = [super init];
    
    if (self) {
        _version          = version;
        _macKey           = macKey;
        _senderRatchetKey = senderRatchetKey;
        _previousCounter  = previousCounter;
        _counter          = counter;
        _cipherText       = cipherText;
    }
    return self;
}

/// !! THROWS if not valid range!! CATCH IT

- (instancetype)initWithData:(NSData*)serialized{
    if (serialized.length <= (VERSION_LENGTH + MAC_LENGTH)) {
        @throw [NSException exceptionWithName:InvalidMessageException reason:@"Message size is too short to have content" userInfo:@{}];
    }
    
    Byte version;
    [serialized getBytes:&version length:1];
    
    NSData *messageAndMac = [serialized subdataWithRange:NSMakeRange(VERSION_LENGTH, serialized.length - VERSION_LENGTH)];
    
    NSData *message = [messageAndMac subdataWithRange:NSMakeRange(0, messageAndMac.length - MAC_LENGTH)];
    NSData *mac     = [messageAndMac subdataWithRange:NSMakeRange(message.length,MAC_LENGTH)];
    
    if ([self highBitsToIntFromByte:version] < MINIMUM_SUPPORTED_VERSION) {
        @throw [NSException exceptionWithName:LegacyMessageException reason:@"Message was sent with an unsupported version of the TextSecure protocol." userInfo:@{}];
    }
    
    if ([self highBitsToIntFromByte:version] > CURRENT_VERSION) {
        @throw [NSException exceptionWithName:InvalidMessageException reason:@"Unknown Version" userInfo:@{@"Version": [NSNumber numberWithChar:[self highBitsToIntFromByte:version]]}];
    }
    
    WhisperMessage *whisperMessage = [WhisperMessage par]
    
}

- (void)verifyMacWithVersion:(int)messageVersion identityKey:(NSData *)identityKey receiverIdentityKey:(ECKeyPair *)receiverKeyPair macKey:(NSData *)macKey{
    
    
}


# pragma mark Utility Methods

- (int)highBitsToIntFromByte:(Byte)byte{
    return (byte & 0xFF) >> 4;
}

- (int)lowBitsToIntFromByte:(Byte)byte{
    return (byte & 0xF);
}

@end

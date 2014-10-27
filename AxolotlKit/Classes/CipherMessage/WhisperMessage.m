//
//  WhisperMessage.m
//  AxolotlKit
//
//  Created by Frederic Jacobs on 23/07/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import "AxolotlExceptions.h"
#import "Constants.h"
#import "WhisperMessage.h"
#import "WhisperTextProtocol.pb.h"
#import "NSData+keyVersionByte.h"
#import "SerializationUtilities.h"

#define VERSION_LENGTH 1

@implementation WhisperMessage

- (instancetype)initWithVersion:(int)version macKey:(NSData*)macKey senderRatchetKey:(NSData*)senderRatchetKey counter:(int)counter previousCounter:(int)previousCounter cipherText:(NSData*)cipherText senderIdentityKey:(NSData*)senderIdentityKey receiverIdentityKey:(NSData*)receiverIdentityKey{
    self = [super init];
    
    Byte   versionByte    = [SerializationUtilities intsToByteHigh:version low:CURRENT_VERSION];
    NSMutableData *serialized  = [NSMutableData dataWithBytes:&versionByte length:1];

    NSData *message       = [[[[[[[TSProtoWhisperMessage builder]
                                    setRatchetKey:senderRatchetKey]
                                    setCounter:counter]
                                    setPreviousCounter:previousCounter]
                                    setCiphertext:cipherText]
                                    build] data];
    [serialized appendData:message];
    
    NSData *mac = [SerializationUtilities macWithVersion:version
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
    
    if ([SerializationUtilities highBitsToIntFromByte:version] < MINIMUM_SUPPORTED_VERSION) {
        @throw [NSException exceptionWithName:LegacyMessageException reason:@"Message was sent with an unsupported version of the TextSecure protocol." userInfo:@{}];
    }
    
    if ([SerializationUtilities highBitsToIntFromByte:version] > CURRENT_VERSION) {
        @throw [NSException exceptionWithName:InvalidMessageException reason:@"Unknown Version" userInfo:@{@"Version": [NSNumber numberWithChar:[SerializationUtilities highBitsToIntFromByte:version]]}];
    }
    
    TSProtoWhisperMessage *whisperMessage = [TSProtoWhisperMessage parseFromData:message];
    
    if (!whisperMessage.hasCiphertext || !whisperMessage.hasCounter || !whisperMessage.hasRatchetKey) {
        @throw [NSException exceptionWithName:InvalidMessageException reason:@"Incomplete Message" userInfo:@{}];
    }
    
    _serialized       = serialized;
    _senderRatchetKey = [whisperMessage.ratchetKey removeKeyType];
    _version          = [SerializationUtilities highBitsToIntFromByte:version];
    _counter          = whisperMessage.counter;
    _previousCounter  = whisperMessage.previousCounter;
    _cipherText       = whisperMessage.ciphertext;

    return self;
}

- (void)verifyMacWithVersion:(int)messageVersion senderIdentityKey:(NSData *)senderIdentityKey receiverIdentityKey:(NSData*)receiverIdentityKey macKey:(NSData *)macKey{
    
    NSData *data     = [self.serialized subdataWithRange:NSMakeRange(0, self.serialized.length - MAC_LENGTH)];
    NSData *theirMac = [self.serialized subdataWithRange:NSMakeRange(self.serialized.length - MAC_LENGTH, MAC_LENGTH)];
    NSData *ourMac   = [SerializationUtilities macWithVersion:messageVersion
                                identityKey:[senderIdentityKey prependKeyType]
                        receiverIdentityKey:[receiverIdentityKey prependKeyType]
                                     macKey:macKey
                                 serialized:data];
    
    if (![theirMac isEqualToData:ourMac]) {
        @throw [NSException exceptionWithName:InvalidMessageException reason:@"Bad Mac!" userInfo:@{}];
    }
}

@end

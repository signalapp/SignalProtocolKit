//
//  PrekeyWhisperMessage.m
//  AxolotlKit
//
//  Created by Frederic Jacobs on 23/07/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import "AxolotlExceptions.h"
#import "PreKeyWhisperMessage.h"
#import "Constants.h"
#import "WhisperTextProtocol.pb.h"
#import "SerializationUtilities.h"

@interface PreKeyWhisperMessage ()
@property (nonatomic, readwrite) NSData *identityKey;
@property (nonatomic, readwrite) NSData *baseKey;
@property (nonatomic, readwrite) NSData *serialized;
@end

@implementation PreKeyWhisperMessage

-(instancetype)initWithWhisperMessage:(WhisperMessage*)whisperMessage registrationId:(int)registrationId prekeyId:(int)prekeyId signedPrekeyId:(int)signedPrekeyId baseKey:(NSData*)baseKey identityKey:(NSData*)identityKey{
    
    self = [super init];
    
    if (self) {
        _registrationId      = registrationId;
        _version             = whisperMessage.version;
        _prekeyID            = prekeyId;
        _signedPrekeyId      = signedPrekeyId;
        _baseKey             = baseKey;
        _identityKey         = identityKey;
        _message             = whisperMessage;
    }
    
    TSProtoPreKeyWhisperMessageBuilder *builder = [TSProtoPreKeyWhisperMessage builder];
    [builder setSignedPreKeyId:signedPrekeyId];
    [builder setBaseKey:baseKey];
    [builder setIdentityKey:identityKey];
    [builder setMessage:whisperMessage.serialized];
    [builder setRegistrationId:registrationId];
    
    if (prekeyId != -1) {
        [builder setPreKeyId:prekeyId];
    }
    
    Byte versionByte          = [SerializationUtilities intsToByteHigh:_version low:CURRENT_VERSION];
    NSMutableData *serialized = [NSMutableData dataWithBytes:&versionByte length:1];
    NSData *messageBytes      = builder.build.data;
    [serialized appendData:messageBytes];
    
    _serialized          = [NSData dataWithData:serialized];
    
    return self;
}

- (instancetype)initWithData:(NSData*)serialized{
    self = [super init];
    
    if (self) {
        Byte version;
        [serialized getBytes:&version length:1];
        _version = [SerializationUtilities highBitsToIntFromByte:version];
        
        if (_version > CURRENT_VERSION && _version < MINIMUM_SUPPORTED_VERSION) {
            @throw [NSException exceptionWithName:InvalidVersionException reason:@"Unknown version" userInfo:@{@"version":[NSNumber numberWithInt:_version]}];
        }
        
        NSData *message = [serialized subdataWithRange:NSMakeRange(1, serialized.length-1)];
        
        TSProtoPreKeyWhisperMessage *preKeyWhisperMessage = [TSProtoPreKeyWhisperMessage parseFromData:message];
        
        if (!preKeyWhisperMessage.hasSignedPreKeyId || !preKeyWhisperMessage.hasBaseKey || !preKeyWhisperMessage.hasIdentityKey || !preKeyWhisperMessage.hasMessage) {
            @throw [NSException exceptionWithName:InvalidMessageException reason:@"Incomplete Message" userInfo:@{}];
        }
        
        _serialized     = serialized;
        _registrationId = preKeyWhisperMessage.registrationId;
        _prekeyID       = preKeyWhisperMessage.preKeyId;
        _signedPrekeyId = preKeyWhisperMessage.signedPreKeyId;
        _baseKey        = preKeyWhisperMessage.baseKey;
        _identityKey    = preKeyWhisperMessage.identityKey;
        _message        = [[WhisperMessage alloc] initWithData:preKeyWhisperMessage.message];
    }
    return self;
}

@end

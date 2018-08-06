//
//  PrekeyWhisperMessage.m
//  AxolotlKit
//
//  Created by Frederic Jacobs on 23/07/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import "PreKeyWhisperMessage.h"
#import "AxolotlExceptions.h"
#import "Constants.h"
#import "SerializationUtilities.h"
#import <AxolotlKit/AxolotlKit-Swift.h>

NS_ASSUME_NONNULL_BEGIN

@interface PreKeyWhisperMessage ()

@property (nonatomic, readwrite) NSData *identityKey;
@property (nonatomic, readwrite) NSData *baseKey;
@property (nonatomic, readwrite) NSData *serialized;

@end

#pragma mark -

@implementation PreKeyWhisperMessage

- (instancetype)initWithWhisperMessage:(WhisperMessage *)whisperMessage
                        registrationId:(int)registrationId
                              prekeyId:(int)prekeyId
                        signedPrekeyId:(int)signedPrekeyId
                               baseKey:(NSData *)baseKey
                           identityKey:(NSData *)identityKey
{
    if (self = [super init]) {
        _registrationId = registrationId;
        _version = whisperMessage.version;
        _prekeyID = prekeyId;
        _signedPrekeyId = signedPrekeyId;
        _baseKey = baseKey;
        _identityKey = identityKey;
        _message = whisperMessage;

        SPKProtoTSProtoPreKeyWhisperMessageBuilder *messageBuilder = [SPKProtoTSProtoPreKeyWhisperMessageBuilder new];
        [messageBuilder setSignedPreKeyID:signedPrekeyId];
        [messageBuilder setBaseKey:baseKey];
        [messageBuilder setIdentityKey:identityKey];
        [messageBuilder setMessage:whisperMessage.serialized];
        [messageBuilder setRegistrationID:registrationId];

        if (prekeyId != -1) {
            [messageBuilder setPreKeyID:prekeyId];
        }

        Byte versionByte = [SerializationUtilities intsToByteHigh:_version low:CURRENT_VERSION];
        NSMutableData *serialized = [NSMutableData dataWithBytes:&versionByte length:1];

        NSError *error;
        NSData *_Nullable messageData = [messageBuilder buildSerializedDataAndReturnError:&error];
        if (!messageData || error) {
            SPKFail(@"%@ Could not serialize proto: %@.", self.logTag, error);
            @throw [NSException exceptionWithName:InvalidMessageException
                                           reason:@"could not serialize proto"
                                         userInfo:@{}];
        }
        [serialized appendData:messageData];

        _serialized = [serialized copy];
    }

    return self;
}

- (instancetype)initWithData:(NSData *)serialized
{
    if (self = [super init]) {
        Byte version;
        [serialized getBytes:&version length:1];
        _version = [SerializationUtilities highBitsToIntFromByte:version];

        if (_version > CURRENT_VERSION && _version < MINIMUM_SUPPORTED_VERSION) {
            @throw [NSException exceptionWithName:InvalidVersionException
                                           reason:@"Unknown version"
                                         userInfo:@{ @"version" : [NSNumber numberWithInt:_version] }];
        }

        NSData *messageData = [serialized subdataWithRange:NSMakeRange(1, serialized.length - 1)];

        NSError *error;
        SPKProtoTSProtoPreKeyWhisperMessage *_Nullable preKeyWhisperMessage =
            [SPKProtoTSProtoPreKeyWhisperMessage parseData:messageData error:&error];
        if (!preKeyWhisperMessage || error) {
            SPKFail(@"%@ Could not parse proto: %@.", self.logTag, error);
            @throw [NSException exceptionWithName:InvalidMessageException reason:@"Could not parse proto" userInfo:@{}];
        }

        _serialized = serialized;
        _registrationId = preKeyWhisperMessage.registrationID;

        // This method is called when decrypting a received PreKeyMessage, but to be symmetrical with
        // encrypting a PreKeyWhisperMessage before sending, we use "-1" to indicate *no* unsignd prekey was
        // included.
        _prekeyID = preKeyWhisperMessage.hasPreKeyID ? preKeyWhisperMessage.preKeyID : -1;
        _signedPrekeyId = preKeyWhisperMessage.signedPreKeyID;
        _baseKey = preKeyWhisperMessage.baseKey;
        _identityKey = preKeyWhisperMessage.identityKey;
        _message = [[WhisperMessage alloc] initWithData:preKeyWhisperMessage.message];
    }

    return self;
}

#pragma mark - Logging

+ (NSString *)logTag
{
    return [NSString stringWithFormat:@"[%@]", self.class];
}

- (NSString *)logTag
{
    return self.class.logTag;
}

@end

NS_ASSUME_NONNULL_END

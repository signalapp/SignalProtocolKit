//
//  PrekeyWhisperMessage.m
//  AxolotlKit
//
//  Created by Frederic Jacobs on 23/07/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import "PreKeyWhisperMessage.h"

@implementation PreKeyWhisperMessage

@synthesize version=_version, senderRatchetKey=_senderRatchetKey, previousCounter=_previousCounter, counter=_counter, cipherText=_cipherText, serialized=_serialized;

-(instancetype)initWithWhisperMessage:(WhisperMessage*)whisperMessage registrationId:(long)registrationId prekeyId:(int)prekeyId signedPrekeyId:(int)signedPrekeyId baseKey:(NSData*)baseKey identityKey:(NSData*)identityKey{
    
    self = [super init];
    
    if (self) {
        _version             = whisperMessage.version;
        _senderRatchetKey    = whisperMessage.senderRatchetKey;
        _previousCounter     = whisperMessage.previousCounter;
        _counter             = whisperMessage.counter;
        _cipherText          = whisperMessage.cipherText;
        _serialized          = whisperMessage.serialized;
        _registrationId      = registrationId;
        _prekeyID            = prekeyId;
        _signedPrekeyId      = signedPrekeyId;
        _baseKey             = baseKey;
        _identityKey         = identityKey;
    }
    return self;
}

- (WhisperMessage*)whisperMessage{
    return (WhisperMessage*)self;
}

@end

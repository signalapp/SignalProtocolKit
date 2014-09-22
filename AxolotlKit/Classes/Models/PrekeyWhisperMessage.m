//
//  PrekeyWhisperMessage.m
//  AxolotlKit
//
//  Created by Frederic Jacobs on 23/07/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import "PrekeyWhisperMessage.h"

@implementation PrekeyWhisperMessage

-(instancetype)initWithWhisperMessage:(WhisperMessage*)whisperMessage registrationId:(int)registrationId prekeyId:(int)prekeyId signedPrekeyId:(int)signedPrekeyId baseKey:(NSData*)baseKey identityKey:(NSData*)identityKey{
    
    self = (PrekeyWhisperMessage*)whisperMessage;
    
    if (self) {
        _registrationId      = registrationId;
        _prekeyID            = prekeyId;
        _signedPrekeyId      = signedPrekeyId;
        _baseKey             = baseKey;
        _identityKey         = identityKey;
    }
    return self;
}

@end

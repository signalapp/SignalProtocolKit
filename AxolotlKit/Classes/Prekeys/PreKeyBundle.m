//
//  AxolotlKeyFetch.m
//  AxolotlKit
//
//  Created by Frederic Jacobs on 21/07/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import "PreKeyBundle.h"

@implementation PreKeyBundle

- (instancetype)initWithRegistrationId:(int)registrationId
                              deviceId:(int)deviceId
                              preKeyId:(int)preKeyId
                          preKeyPublic:(NSData*)preKeyPublic
                    signedPreKeyPublic:(NSData*)signedPreKeyPublic
                        signedPreKeyId:(int)signedPreKeyId
                 signedPreKeySignature:(NSData*)signedPreKeySignature
                           identityKey:(NSData*)identityKey{

    self = [super init];

    if (self) {
        _identityKey           = identityKey;
        _registrationId        = registrationId;
        _deviceId              = deviceId;
        _preKeyPublic          = preKeyPublic;
        _preKeyId              = preKeyId;
        _signedPreKeyPublic    = signedPreKeyPublic;
        _signedPreKeyId        = signedPreKeyId;
        _signedPreKeySignature = signedPreKeySignature;
    }

    return self;
}

@end

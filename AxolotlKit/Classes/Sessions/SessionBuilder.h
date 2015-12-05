//
//  SessionBuilder.h
//  AxolotlKit
//
//  Created by Frederic Jacobs on 23/07/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import "AxolotlStore.h"
#import "IdentityKeyStore.h"
#import "PreKeyBundle.h"
#import "PreKeyStore.h"
#import "SessionStore.h"
#import "SignedPreKeyStore.h"
#import <Foundation/Foundation.h>

@class PreKeyWhisperMessage;

@interface SessionBuilder : NSObject

- (instancetype)initWithAxolotlStore:(id<AxolotlStore>)sessionStore
                         recipientId:(NSString *)recipientId
                            deviceId:(int)deviceId;

- (instancetype)initWithSessionStore:(id<SessionStore>)sessionStore
                         preKeyStore:(id<PreKeyStore>)preKeyStore
                   signedPreKeyStore:(id<SignedPreKeyStore>)signedPreKeyStore
                    identityKeyStore:(id<IdentityKeyStore>)identityKeyStore
                         recipientId:(NSString *)recipientId
                            deviceId:(int)deviceId;

- (void)processPrekeyBundle:(PreKeyBundle *)preKeyBundle;
- (int)processPrekeyWhisperMessage:(PreKeyWhisperMessage *)message
                       withSession:(SessionRecord *)sessionRecord;

@end

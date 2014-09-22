//
//  SessionBuilder.h
//  AxolotlKit
//
//  Created by Frederic Jacobs on 23/07/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IdentityStore.h"
#import "SessionStore.h"
#import "PrekeyStore.h"
#import "PreKeyBundle.h"

@class PrekeyWhisperMessage;

@interface SessionBuilder : NSObject

typedef PreKeyBundle*(^AxolotlFetchKey)   (NSInteger contactIdentifier, NSInteger deviceId);

@property(nonatomic, readonly)id<SessionStore>  sessionStore;
@property(nonatomic, readonly)id<PrekeyStore>   prekeyStore ;
@property(nonatomic, readonly)id<IdentityStore> identityStore;

@property(nonatomic, readonly)AxolotlFetchKey fetchKeyBlock;

-(int)process:(SessionRecord*)sessionRecord prekeyWhisperMessage:(PrekeyWhisperMessage*)message;

@end

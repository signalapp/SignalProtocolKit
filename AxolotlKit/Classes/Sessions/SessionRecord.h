//
//  SessionRecord.h
//  AxolotlKit
//
//  Created by Frederic Jacobs on 25/07/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SessionState.h"

@interface SessionRecord : NSObject <NSSecureCoding>

- (instancetype)init;
- (instancetype)initWithSessionState:(SessionState*)sessionState;

- (BOOL)hasSessionState:(int)version baseKey:(NSData*)aliceBaseKey;
- (SessionState*)sessionState;
- (NSMutableArray*)previousSessionStates;

- (BOOL)isFresh;
- (void)archiveCurrentState;
- (void)promoteState:(SessionState*)promotedState;
- (void)setState:(SessionState*)sessionState;

@end

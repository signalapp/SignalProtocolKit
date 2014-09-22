//
//  RatchetingSession.h
//  AxolotlKit
//
//  Created by Frederic Jacobs on 26/07/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SessionState;
@class AliceAxolotlParameters;
@class BobAxolotlParameters;

@interface RatchetingSession : NSObject

+ (void)initializeSession:(SessionState*)session sessionVersion:(int)sessionVersion AliceParameters:(AliceAxolotlParameters*)parameters;

+ (void)initializeSession:(SessionState*)session sessionVersion:(int)sessionVersion BobParameters:(BobAxolotlParameters*)parameters;

@end

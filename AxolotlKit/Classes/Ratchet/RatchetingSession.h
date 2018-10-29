//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AliceAxolotlParameters;
@class BobAxolotlParameters;
@class ECKeyPair;
@class SessionState;

@interface RatchetingSession : NSObject

+ (void)try_initializeSession:(SessionState *)session
               sessionVersion:(int)sessionVersion
              AliceParameters:(AliceAxolotlParameters *)parameters;

+ (void)initializeSession:(SessionState*)session sessionVersion:(int)sessionVersion BobParameters:(BobAxolotlParameters*)parameters;

/**
 *  For testing purposes
 */

+ (void)try_initializeSession:(SessionState *)session
               sessionVersion:(int)sessionVersion
              AliceParameters:(AliceAxolotlParameters *)parameters
                senderRatchet:(ECKeyPair *)ratchet;

@end

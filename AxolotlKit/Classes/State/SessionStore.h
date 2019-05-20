//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
//

#import "SessionRecord.h"
#import <Foundation/Foundation.h>
#import "ProtocolContext.h"

NS_ASSUME_NONNULL_BEGIN

// See a discussion of the protocolContext in SessionCipher.h.
@protocol SessionStore <NSObject>

/**
 *  Returns a copy of the SessionRecord corresponding to the recipientId + deviceId tuple or a new SessionRecord if one does not currently exist.
 *
 *  @param contactIdentifier The recipientId of the remote client.
 *  @param deviceId          The deviceId of the remote client.
 *
 *  @return a copy of the SessionRecord corresponding to the recipientId + deviceId tuple.
 */
- (SessionRecord *)loadSession:(NSString *)contactIdentifier
                      deviceId:(int)deviceId
               protocolContext:(nullable id<ProtocolContext>)protocolContext;

- (NSArray *)subDevicesSessions:(NSString *)contactIdentifier protocolContext:(nullable id<ProtocolContext>)protocolContext __attribute__((deprecated));

- (void)storeSession:(NSString *)contactIdentifier
            deviceId:(int)deviceId
             session:(SessionRecord *)session
     protocolContext:(nullable id<ProtocolContext>)protocolContext;

- (BOOL)containsSession:(NSString *)contactIdentifier
               deviceId:(int)deviceId
        protocolContext:(nullable id<ProtocolContext>)protocolContext;

- (void)deleteSessionForContact:(NSString *)contactIdentifier
                       deviceId:(int)deviceId
                protocolContext:(nullable id<ProtocolContext>)protocolContext;

- (void)deleteAllSessionsForContact:(NSString *)contactIdentifier protocolContext:(nullable id<ProtocolContext>)protocolContext;

@end

NS_ASSUME_NONNULL_END

//
//  SessionBuilder.h
//  AxolotlKit
//
//  Created by Frederic Jacobs on 23/07/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SessionRecord.h"

/**
 *  The Session Store defines the interface of the storage of sesssions.
 */

@protocol SessionStore

-(SessionRecord*)loadSession:(int)contactIdentifier deviceId:(int)deviceId;

-(NSArray*)countSubDevicesSessions:(int)contactIdentifier;

-(void)storeSession:(int)contactIdentifier deviceId:(int)deviceId session:(SessionRecord*)session;

-(BOOL)containsSession:(int)contactIdentifier deviceId:(int)deviceId;

-(void)deleteSessionForContact:(int)contactIdentifier deviceId:(int)deviceId;

-(void)deleteAllSessionsForContact:(int)contactIdentifier;

@end

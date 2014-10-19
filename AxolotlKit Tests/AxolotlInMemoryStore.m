//
//  AxolotlInMemoryStore.m
//  AxolotlKit
//
//  Created by Frederic Jacobs on 17/10/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import "AxolotlInMemoryStore.h"

@interface AxolotlInMemoryStore ()

@property NSDictionary *sessionRecords;

@end

@implementation AxolotlInMemoryStore

# pragma mark Session Store

-(SessionRecord*)loadSession:(long)contactIdentifier deviceId:(int)deviceId{
    return [[self deviceSessionRecordsForContactIdentifier:contactIdentifier] objectForKey:[[NSNumber numberWithInt:deviceId] stringValue]];
}

- (NSArray*)subDevicesSessions:(long)contactIdentifier{
    return [[self deviceSessionRecordsForContactIdentifier:contactIdentifier] allKeys];
}

- (NSDictionary*)deviceSessionRecordsForContactIdentifier:(long)contactIdentifier{
    return [self.sessionRecords objectForKey:[[NSNumber numberWithLong:contactIdentifier] stringValue]];
}

- (void)storeSession:(long)contactIdentifier deviceId:(int)deviceId session:(SessionRecord *)session{
    [self.sessionRecords setValue:@{[NSNumber numberWithInt:deviceId]:session} forKey:[[NSNumber numberWithLong:contactIdentifier] stringValue]];
}

- (BOOL)containsSession:(long)contactIdentifier deviceId:(int)deviceId{
    
}

@end


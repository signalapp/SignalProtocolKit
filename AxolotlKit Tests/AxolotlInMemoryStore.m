//
//  AxolotlInMemoryStore.m
//  AxolotlKit
//
//  Created by Frederic Jacobs on 17/10/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import "AxolotlInMemoryStore.h"
#import "AxolotlExceptions.h"

@interface AxolotlInMemoryStore ()

@property NSMutableDictionary *sessionRecords;

// Signed PreKey Store

@property NSMutableDictionary *preKeyStore;
@property NSMutableDictionary *signedPreKeyStore;

@property NSMutableDictionary *trustedKeys;

@property ECKeyPair *_identityKeyPair;
@property int _localRegistrationId;

@end

@implementation AxolotlInMemoryStore


# pragma mark General

- (instancetype)init{
    self = [super init];
    
    if (self) {
        self._identityKeyPair     = [Curve25519 generateKeyPair];
        self._localRegistrationId = arc4random() % 16380;
        
        _preKeyStore = [NSMutableDictionary dictionary];
        _signedPreKeyStore = [NSMutableDictionary dictionary];
        _trustedKeys = [NSMutableDictionary dictionary];
        _sessionRecords = [NSMutableDictionary dictionary];
    }
    
    return self;
}

# pragma mark Signed PreKey Store

- (SignedPreKeyRecord *)loadSignedPrekey:(int)signedPreKeyId{
    if (![[self.signedPreKeyStore allKeys] containsObject:[NSNumber numberWithInt:signedPreKeyId]]) {
        @throw [NSException exceptionWithName:InvalidKeyIdException reason:@"No such signedprekeyrecord" userInfo:nil];
    }
    
    return [self.signedPreKeyStore objectForKey:[NSNumber numberWithInt:signedPreKeyId]];
}

- (NSArray *)loadSignedPreKeys{
    NSMutableArray *results = [NSMutableArray array];
    
    for (SignedPreKeyRecord *signedPrekey in [self.signedPreKeyStore allValues]) {
        [results addObject:signedPrekey];
    }
    
    return results;
}

- (void)storeSignedPreKey:(int)signedPreKeyId signedPreKeyRecord:(SignedPreKeyRecord *)signedPreKeyRecord{
    [self.signedPreKeyStore setObject:signedPreKeyRecord forKey:[NSNumber numberWithInteger:signedPreKeyId]];
}

- (BOOL)containsSignedPreKey:(int)signedPreKeyId{
    if ([[self.signedPreKeyStore allKeys] containsObject:[NSNumber numberWithInteger:signedPreKeyId]]) {
        return TRUE;
    }
    
    return FALSE;
}

- (void)removeSignedPreKey:(int)signedPrekeyId{
    [self.signedPreKeyStore removeObjectForKey:[NSNumber numberWithInteger:signedPrekeyId]];
}

# pragma mark PreKey Store

- (PreKeyRecord *)loadPreKey:(int)preKeyId{
    if (![[self.preKeyStore allKeys] containsObject:[NSNumber numberWithInt:preKeyId]]) {
        @throw [NSException exceptionWithName:InvalidKeyIdException reason:@"No such signedprekeyrecord" userInfo:nil];
    }
    
    return [self.preKeyStore objectForKey:[NSNumber numberWithInt:preKeyId]];
}

- (NSArray *)loadPreKeys{
    NSMutableArray *results = [NSMutableArray array];
    
    for (PreKeyRecord *prekey in [self.preKeyStore allValues]) {
        [results addObject:prekey];
    }
    
    return results;
}

- (void)storePreKey:(int)preKeyId preKeyRecord:(PreKeyRecord *)record{
    [self.preKeyStore setObject:record forKey:[NSNumber numberWithInt:preKeyId]];
}

- (BOOL)containsPreKey:(int)preKeyId{
    if ([[self.preKeyStore allKeys] containsObject:[NSNumber numberWithInteger:preKeyId]]) {
        return TRUE;
    }
    
    return FALSE;
}

- (void)removePreKey:(int)preKeyId{
    [self.preKeyStore removeObjectForKey:[NSNumber numberWithInt:preKeyId]];
}

# pragma mark IdentityKeyStore

- (ECKeyPair *)identityKeyPair{
    return __identityKeyPair;
}

- (int)localRegistrationId{
    return __localRegistrationId;
}

- (void)saveRemoteIdentity:(NSData *)identityKey recipientId:(NSString*)recipientId{
    [self.trustedKeys setObject:identityKey forKey:recipientId];
}

- (BOOL)isTrustedIdentityKey:(NSData *)identityKey recipientId:(NSString*)recipientId{
    NSData *data = [self.trustedKeys objectForKey:recipientId];
    
    if (data) {
        return [data isEqualToData:identityKey];
    }
    
    return YES; // Trust on first use
}

# pragma mark Session Store

-(SessionRecord*)loadSession:(NSString*)contactIdentifier deviceId:(int)deviceId{
    SessionRecord *sessionRecord = [[self deviceSessionRecordsForContactIdentifier:contactIdentifier] objectForKey:[NSNumber numberWithInteger:deviceId]];
    
    if (!sessionRecord) {
        sessionRecord = [SessionRecord new];
    }
    
    return sessionRecord;
}

- (NSArray*)subDevicesSessions:(NSString*)contactIdentifier{
    return [[self deviceSessionRecordsForContactIdentifier:contactIdentifier] allKeys];
}

- (NSDictionary*)deviceSessionRecordsForContactIdentifier:(NSString*)contactIdentifier{
    return [self.sessionRecords objectForKey:contactIdentifier];
}

- (void)storeSession:(NSString*)contactIdentifier deviceId:(int)deviceId session:(SessionRecord *)session{
    NSAssert(session, @"Session can't be nil");
    [self.sessionRecords setObject:@{[NSNumber numberWithInt:deviceId]:session} forKey:contactIdentifier];
}

- (BOOL)containsSession:(NSString*)contactIdentifier deviceId:(int)deviceId{
    
    if ([[self.sessionRecords objectForKey:contactIdentifier] objectForKey:[NSNumber numberWithInt:deviceId]]){
        return YES;
    }
    return NO;
}


@end


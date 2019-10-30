//
//  Copyright (c) 2019 Open Whisper Systems. All rights reserved.
//

#import "SPKMockProtocolStore.h"
#import "AxolotlExceptions.h"

NS_ASSUME_NONNULL_BEGIN

@interface SPKMockProtocolStore ()

@property NSMutableDictionary<NSString *, NSMutableDictionary *> *sessionRecords;

// Signed PreKey Store

@property NSMutableDictionary *preKeyStore;
@property NSMutableDictionary *signedPreKeyStore;

@property NSMutableDictionary *trustedKeys;

@property ECKeyPair *identityKeyPair;
@property int localRegistrationId;

@end

@implementation SPKMockProtocolStore


#pragma mark General

- (instancetype)init
{
    return [self initWithIdentityKeyPair:[Curve25519 generateKeyPair] localRegistrationId:arc4random() % 16380];
}

- (instancetype)initWithIdentityKeyPair:(ECKeyPair *)identityKeyPair localRegistrationId:(int)localRegistrationId
{
    self = [super init];

    if (self) {
        _identityKeyPair = identityKeyPair;
        _localRegistrationId = localRegistrationId;

        _preKeyStore = [NSMutableDictionary dictionary];
        _signedPreKeyStore = [NSMutableDictionary dictionary];
        _trustedKeys = [NSMutableDictionary dictionary];
        _sessionRecords = [NSMutableDictionary dictionary];
    }

    return self;
}

#pragma mark Signed PreKey Store

- (nullable SignedPreKeyRecord *)loadSignedPreKey:(int)signedPreKeyId
{
    return [self.signedPreKeyStore objectForKey:[NSNumber numberWithInt:signedPreKeyId]];
}

- (NSArray<SignedPreKeyRecord *> *)loadSignedPreKeys
{
    NSMutableArray *results = [NSMutableArray array];

    for (SignedPreKeyRecord *signedPrekey in [self.signedPreKeyStore allValues]) {
        [results addObject:signedPrekey];
    }

    return results;
}

- (void)storeSignedPreKey:(int)signedPreKeyId signedPreKeyRecord:(SignedPreKeyRecord *)signedPreKeyRecord
{
    [self.signedPreKeyStore setObject:signedPreKeyRecord forKey:[NSNumber numberWithInteger:signedPreKeyId]];
}

- (BOOL)containsSignedPreKey:(int)signedPreKeyId
{
    if ([[self.signedPreKeyStore allKeys] containsObject:[NSNumber numberWithInteger:signedPreKeyId]]) {
        return TRUE;
    }

    return FALSE;
}

- (void)removeSignedPreKey:(int)signedPreKeyId
{
    [self.signedPreKeyStore removeObjectForKey:[NSNumber numberWithInteger:signedPreKeyId]];
}

#pragma mark PreKey Store

- (nullable PreKeyRecord *)loadPreKey:(int)preKeyId
{
    return [self.preKeyStore objectForKey:[NSNumber numberWithInt:preKeyId]];
}

- (NSArray *)loadPreKeys
{
    NSMutableArray *results = [NSMutableArray array];

    for (PreKeyRecord *prekey in [self.preKeyStore allValues]) {
        [results addObject:prekey];
    }

    return results;
}

- (void)storePreKey:(int)preKeyId preKeyRecord:(PreKeyRecord *)record
{
    [self.preKeyStore setObject:record forKey:[NSNumber numberWithInt:preKeyId]];
}

- (void)removePreKey:(int)preKeyId
     protocolContext:(nullable id<SPKProtocolWriteContext>)protocolContext
{
    [self.preKeyStore removeObjectForKey:[NSNumber numberWithInt:preKeyId]];
}

#pragma mark IdentityKeyStore

- (nullable ECKeyPair *)identityKeyPair:(nullable id<SPKProtocolWriteContext>)protocolContext
{
    return self.identityKeyPair;
}

- (int)localRegistrationId:(nullable id<SPKProtocolWriteContext>)protocolContext
{
    return self.localRegistrationId;
}

- (BOOL)saveRemoteIdentity:(NSData *)identityKey
               recipientId:(NSString *)recipientId
           protocolContext:(nullable id<SPKProtocolWriteContext>)protocolContext
{
    NSData *existingKey = [self.trustedKeys objectForKey:recipientId];

    if ([existingKey isEqualToData:existingKey]) {
        return NO;
    }

    [self.trustedKeys setObject:identityKey forKey:recipientId];
    return YES;
}

- (BOOL)isTrustedIdentityKey:(NSData *)identityKey
                 recipientId:(NSString *)recipientId
                   direction:(TSMessageDirection)direction
             protocolContext:(nullable id<SPKProtocolWriteContext>)protocolContext
{
    NSData *data = [self.trustedKeys objectForKey:recipientId];
    if (!data) {
        // Trust on first use
        return YES;
    }

    switch (direction) {
        case TSMessageDirectionIncoming:
            return YES;
        case TSMessageDirectionOutgoing:
            // In a real implementation you may wish to ensure the use has been properly notified of any
            // recent identity change before sending outgoing messages.
            return [data isEqualToData:identityKey];
        case TSMessageDirectionUnknown:
            NSAssert(NO, @"unknown message direction");
            return NO;
    }
}

- (nullable NSData *)identityKeyForRecipientId:(NSString *)recipientId
{
    return [self identityKeyForRecipientId:recipientId protocolContext:nil];
}

- (nullable NSData *)identityKeyForRecipientId:(NSString *)recipientId
                               protocolContext:(nullable id<SPKProtocolReadContext>)protocolContext
{
    NSData *_Nullable data = [self.trustedKeys objectForKey:recipientId];
    return data;
}

#pragma mark Session Store

- (SessionRecord *)loadSession:(NSString *)contactIdentifier
                      deviceId:(int)deviceId
               protocolContext:(nullable id<SPKProtocolWriteContext>)protocolContext
{
    SessionRecord *sessionRecord = [[self deviceSessionRecordsForContactIdentifier:contactIdentifier]
        objectForKey:[NSNumber numberWithInteger:deviceId]];

    if (!sessionRecord) {
        sessionRecord = [SessionRecord new];
    }

    return sessionRecord;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-implementations"
- (NSArray *)subDevicesSessions:(NSString *)contactIdentifier protocolContext:(nullable id<SPKProtocolWriteContext>)protocolContext
{
    return [[self deviceSessionRecordsForContactIdentifier:contactIdentifier] allKeys];
}
#pragma clang diagnostic pop

- (NSMutableDictionary *)deviceSessionRecordsForContactIdentifier:(NSString *)contactIdentifier
{
    return [self.sessionRecords objectForKey:contactIdentifier];
}

- (void)storeSession:(NSString *)contactIdentifier
            deviceId:(int)deviceId
             session:(SessionRecord *)session
     protocolContext:(nullable id<SPKProtocolWriteContext>)protocolContext
{
    NSAssert(session, @"Session can't be nil");
    NSMutableDictionary *deviceSessions = self.sessionRecords[contactIdentifier];
    if (!deviceSessions) {
        deviceSessions = [NSMutableDictionary new];
    }
    deviceSessions[@(deviceId)] = session;

    self.sessionRecords[contactIdentifier] = deviceSessions;
}

- (BOOL)containsSession:(NSString *)contactIdentifier
               deviceId:(int)deviceId
        protocolContext:(nullable id<SPKProtocolWriteContext>)protocolContext
{

    if ([[self.sessionRecords objectForKey:contactIdentifier] objectForKey:[NSNumber numberWithInt:deviceId]]) {
        return YES;
    }
    return NO;
}

- (void)deleteSessionForContact:(NSString *)contactIdentifier
                       deviceId:(int)deviceId
                protocolContext:(nullable id<SPKProtocolWriteContext>)protocolContext
{
    NSMutableDictionary<NSNumber *, SessionRecord *> *sessions =
        [self deviceSessionRecordsForContactIdentifier:contactIdentifier];
    [sessions removeObjectForKey:@(deviceId)];
}

- (void)deleteAllSessionsForContact:(NSString *)contactIdentifier protocolContext:(nullable id<SPKProtocolWriteContext>)protocolContext
{
    [self.sessionRecords removeObjectForKey:contactIdentifier];
}

@end

NS_ASSUME_NONNULL_END

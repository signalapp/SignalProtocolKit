//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
//

#import <AxolotlKit/AliceAxolotlParameters.h>
#import <AxolotlKit/BobAxolotlParameters.h>
#import <AxolotlKit/ChainKey.h>
#import <AxolotlKit/RatchetingSession.h>
#import <AxolotlKit/SPKMockProtocolStore.h>
#import <AxolotlKit/SessionBuilder.h>
#import <AxolotlKit/SessionCipher.h>
#import <AxolotlKit/SessionState.h>
#import <Curve25519Kit/Curve25519.h>
#import <XCTest/XCTest.h>

@interface SessionCipherTest : XCTestCase

@property (nonatomic, readonly) NSString *aliceIdentifier;
@property (nonatomic, readonly) NSString *bobIdentifier;
@property (nonatomic, readonly) SPKMockProtocolStore *aliceStore;
@property (nonatomic, readonly) SPKMockProtocolStore *bobStore;

@end

@implementation SessionCipherTest

- (NSString *)aliceIdentifier
{
    return @"+3728378173821";
}

- (NSString *)bobIdentifier
{
    return @"bob@gmail.com";
}

- (void)setUp {
    [super setUp];
    _aliceStore = [SPKMockProtocolStore new];
    _bobStore = [SPKMockProtocolStore new];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testBasicSession{
    SessionRecord *aliceSessionRecord = [SessionRecord new];
    SessionRecord *bobSessionRecord   = [SessionRecord new];

    [self throws_sessionInitializationWithAliceSessionRecord:aliceSessionRecord bobSessionRecord:bobSessionRecord];
    [self runInteractionWithAliceRecord:aliceSessionRecord bobRecord:bobSessionRecord];
}

- (void)testPromotingOldSessionState
{
    SessionRecord *aliceSessionRecord = [SessionRecord new];
    SessionRecord *bobSessionRecord = [SessionRecord new];

    // 1.) Given Alice and Bob have initialized some session together
    SessionState *initialSessionState = bobSessionRecord.sessionState;
    [self throws_sessionInitializationWithAliceSessionRecord:aliceSessionRecord bobSessionRecord:bobSessionRecord];

    SessionRecord *activeSession = [self.bobStore loadSession:self.aliceIdentifier deviceId:1 protocolContext:nil];
    XCTAssertNotNil(activeSession);
    XCTAssertEqualObjects(initialSessionState, activeSession.sessionState);

    // 2.) If for some reason, bob has promoted a different session...
    SessionState *newSessionState = [SessionState new];
    [bobSessionRecord promoteState:newSessionState];
    XCTAssertEqual(1, bobSessionRecord.previousSessionStates.count);
    [self.bobStore storeSession:self.aliceIdentifier deviceId:1 session:bobSessionRecord protocolContext:nil];

    activeSession = [self.bobStore loadSession:self.aliceIdentifier deviceId:1 protocolContext:nil];
    XCTAssertNotNil(activeSession);
    XCTAssertNotEqualObjects(initialSessionState, activeSession.sessionState);
    XCTAssertEqualObjects(newSessionState, activeSession.sessionState);

    // 3.) Bob should promote back the initial session after receiving a message from that old session.
    [self runInteractionWithAliceRecord:aliceSessionRecord bobRecord:bobSessionRecord];
    XCTAssertNotEqualObjects(newSessionState, activeSession.sessionState);
    XCTAssertEqualObjects(initialSessionState, activeSession.sessionState);
    XCTAssertEqual(1, bobSessionRecord.previousSessionStates.count);
    XCTAssertEqual(0, aliceSessionRecord.previousSessionStates.count);
}

- (void)throws_sessionInitializationWithAliceSessionRecord:(SessionRecord *)aliceSessionRecord
                                          bobSessionRecord:(SessionRecord *)bobSessionRecord
{

    SessionState *aliceSessionState = aliceSessionRecord.sessionState;
    SessionState *bobSessionState = bobSessionRecord.sessionState;

    ECKeyPair *aliceIdentityKeyPair = [Curve25519 generateKeyPair];
    ECKeyPair *aliceBaseKey         = [Curve25519 generateKeyPair];
    
    ECKeyPair *bobIdentityKeyPair   = [Curve25519 generateKeyPair];
    ECKeyPair *bobBaseKey           = [Curve25519 generateKeyPair];
    ECKeyPair *bobOneTimePK         = [Curve25519 generateKeyPair];
    
    AliceAxolotlParameters *aliceParams = [[AliceAxolotlParameters alloc] initWithIdentityKey:aliceIdentityKeyPair theirIdentityKey:[bobIdentityKeyPair publicKey] ourBaseKey:aliceBaseKey theirSignedPreKey:[bobBaseKey publicKey] theirOneTimePreKey:[bobOneTimePK publicKey] theirRatchetKey:[bobBaseKey publicKey]];
    
    BobAxolotlParameters   *bobParams = [[BobAxolotlParameters alloc] initWithMyIdentityKeyPair:bobIdentityKeyPair theirIdentityKey:[aliceIdentityKeyPair publicKey] ourSignedPrekey:bobBaseKey ourRatchetKey:bobBaseKey ourOneTimePrekey:bobOneTimePK theirBaseKey:[aliceBaseKey publicKey]];

    [RatchetingSession throws_initializeSession:bobSessionState sessionVersion:3 BobParameters:bobParams];

    [RatchetingSession throws_initializeSession:aliceSessionState sessionVersion:3 AliceParameters:aliceParams];

    [self.aliceStore saveRemoteIdentity:bobIdentityKeyPair.publicKey recipientId:self.bobIdentifier protocolContext:nil];
    [self.aliceStore storeSession:self.bobIdentifier deviceId:1 session:aliceSessionRecord protocolContext:nil];

    [self.bobStore saveRemoteIdentity:aliceIdentityKeyPair.publicKey recipientId:self.aliceIdentifier protocolContext:nil];
    [self.bobStore storeSession:self.aliceIdentifier deviceId:1 session:bobSessionRecord protocolContext:nil];

    XCTAssert([aliceSessionState.remoteIdentityKey isEqualToData:bobSessionState.localIdentityKey]);
}

- (void)runInteractionWithAliceRecord:(SessionRecord*)aliceSessionRecord bobRecord:(SessionRecord*)bobSessionRecord {
    SessionCipher *aliceSessionCipher =
        [[SessionCipher alloc] initWithAxolotlStore:self.aliceStore recipientId:self.bobIdentifier deviceId:1];
    SessionCipher *bobSessionCipher =
        [[SessionCipher alloc] initWithAxolotlStore:self.bobStore recipientId:self.aliceIdentifier deviceId:1];

    NSData *alicePlainText     = [@"This is a plaintext message!" dataUsingEncoding:NSUTF8StringEncoding];
    WhisperMessage *cipherText = [aliceSessionCipher throws_encryptMessage:alicePlainText protocolContext:nil];

    NSData *bobPlaintext = [bobSessionCipher throws_decrypt:cipherText protocolContext:nil];

    XCTAssert([bobPlaintext isEqualToData:alicePlainText]);
}

@end

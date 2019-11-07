//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
//

#import <AxolotlKit/AxolotlExceptions.h>
#import <AxolotlKit/NSData+keyVersionByte.h>
#import <AxolotlKit/SPKMockProtocolStore.h>
#import <AxolotlKit/SessionBuilder.h>
#import <AxolotlKit/SessionCipher.h>
#import <Curve25519Kit/Ed25519.h>
#import <SignalCoreKit/NSData+OWS.h>
#import <XCTest/XCTest.h>

@interface PreKeyWhisperMessage ()

@property (nonatomic, readwrite) NSData         *identityKey;
@property (nonatomic, readwrite) NSData         *baseKey;

@end

#pragma mark -

@interface SessionBuilderTests : XCTestCase

@end

#pragma mark -

@implementation SessionBuilderTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

/**
 *  Testing session initialization with a basic PrekeyWhisperMessage
 */

- (void)testBasicPreKey {
    
    NSString *BOB_RECIPIENT_ID   = @"+3828923892";
    NSString *ALICE_RECIPIENT_ID = @"alice@gmail.com";

    SPKMockProtocolStore *aliceStore = [SPKMockProtocolStore new];
    SessionBuilder       *aliceSessionBuilder = [[SessionBuilder alloc] initWithAxolotlStore:aliceStore recipientId:BOB_RECIPIENT_ID deviceId:1];
    
    SPKMockProtocolStore *bobStore      = [SPKMockProtocolStore new];
    ECKeyPair *bobPreKeyPair            = [Curve25519 generateKeyPair];
    ECKeyPair *bobSignedPreKeyPair      = [Curve25519 generateKeyPair];
    NSData *bobSignedPreKeySignature =
        [Ed25519 throws_sign:bobSignedPreKeyPair.publicKey.prependKeyType withKeyPair:[bobStore identityKeyPair:nil]];

    PreKeyBundle *bobPreKey = [[PreKeyBundle alloc]initWithRegistrationId:[bobStore localRegistrationId:nil]
                                                                 deviceId:1
                                                                 preKeyId:31337
                                                             preKeyPublic:bobPreKeyPair.publicKey.prependKeyType
                                                       signedPreKeyPublic:bobSignedPreKeyPair.publicKey.prependKeyType
                                                           signedPreKeyId:22
                                                    signedPreKeySignature:bobSignedPreKeySignature
                                                              identityKey:[bobStore identityKeyPair:nil].publicKey.prependKeyType];

    [aliceSessionBuilder throws_processPrekeyBundle:bobPreKey protocolContext:nil];

    XCTAssert([aliceStore containsSession:BOB_RECIPIENT_ID deviceId:1 protocolContext:nil]);
    XCTAssert([aliceStore loadSession:BOB_RECIPIENT_ID deviceId:1 protocolContext:nil].sessionState.version == 3);
        
    NSString *originalMessage = @"Freedom is the right to tell people what they do not want to hear.";
    SessionCipher *aliceSessionCipher = [[SessionCipher alloc] initWithAxolotlStore:aliceStore recipientId:BOB_RECIPIENT_ID deviceId:1];

    WhisperMessage *outgoingMessage =
        [aliceSessionCipher throws_encryptMessage:[originalMessage dataUsingEncoding:NSUTF8StringEncoding]
                                  protocolContext:nil];

    XCTAssert([outgoingMessage isKindOfClass:[PreKeyWhisperMessage class]], @"Message should be PreKey type");
    
    PreKeyWhisperMessage *incomingMessage = (PreKeyWhisperMessage*)outgoingMessage;
    [bobStore storePreKey:31337 preKeyRecord:[[PreKeyRecord alloc] initWithId:bobPreKey.preKeyId
                                                                      keyPair:bobPreKeyPair
                                                                    createdAt:[NSDate date]]];
    [bobStore storeSignedPreKey:22 signedPreKeyRecord:[[SignedPreKeyRecord alloc] initWithId:22 keyPair:bobSignedPreKeyPair signature:bobSignedPreKeySignature generatedAt:[NSDate date]]];
    
    SessionCipher *bobSessionCipher = [[SessionCipher alloc] initWithAxolotlStore:bobStore recipientId:ALICE_RECIPIENT_ID deviceId:1];
    [bobSessionCipher throws_decrypt:incomingMessage protocolContext:nil];

    XCTAssert([bobStore containsSession:ALICE_RECIPIENT_ID deviceId:1 protocolContext:nil]);
    XCTAssert([bobStore loadSession:ALICE_RECIPIENT_ID deviceId:1 protocolContext:nil].sessionState.version == 3);
    XCTAssert([bobStore loadSession:ALICE_RECIPIENT_ID deviceId:1 protocolContext:nil].sessionState.aliceBaseKey != nil);
}

/**
 *  Tests the case where an attacker would send a new PreKeyWhisperMessage with another IdentityKey
 */

- (void)testBasicPreKeyMITM {
    
    NSString *BOB_RECIPIENT_ID   = @"+3828923892";
    
    SPKMockProtocolStore *aliceStore = [SPKMockProtocolStore new];
    SessionBuilder       *aliceSessionBuilder = [[SessionBuilder alloc] initWithAxolotlStore:aliceStore recipientId:BOB_RECIPIENT_ID deviceId:1];
    
    SPKMockProtocolStore *bobStore      = [SPKMockProtocolStore new];
    ECKeyPair *bobIdentityKeyPair1 = [Curve25519 generateKeyPair];
    ECKeyPair *bobPreKeyPair1 = [Curve25519 generateKeyPair];
    ECKeyPair *bobSignedPreKeyPair1 = [Curve25519 generateKeyPair];
    NSData *bobSignedPreKeySignature1 =
        [Ed25519 throws_sign:bobSignedPreKeyPair1.publicKey.prependKeyType withKeyPair:bobIdentityKeyPair1];

    PreKeyBundle *bobPreKey1 = [[PreKeyBundle alloc] initWithRegistrationId:[bobStore localRegistrationId:nil]
                                                                   deviceId:1
                                                                   preKeyId:31337
                                                               preKeyPublic:bobPreKeyPair1.publicKey.prependKeyType
                                                         signedPreKeyPublic:bobSignedPreKeyPair1.publicKey.prependKeyType
                                                             signedPreKeyId:22
                                                      signedPreKeySignature:bobSignedPreKeySignature1
                                                                identityKey:bobIdentityKeyPair1.publicKey.prependKeyType];

    [aliceSessionBuilder throws_processPrekeyBundle:bobPreKey1 protocolContext:nil];

    XCTAssert([aliceStore containsSession:BOB_RECIPIENT_ID deviceId:1 protocolContext:nil]);
    XCTAssert([aliceStore loadSession:BOB_RECIPIENT_ID deviceId:1 protocolContext:nil].sessionState.version == 3);

    NSString *messageText = @"Freedom is the right to tell people what they do not want to hear.";
    SessionCipher *aliceSessionCipher = [[SessionCipher alloc] initWithAxolotlStore:aliceStore recipientId:BOB_RECIPIENT_ID deviceId:1];

    WhisperMessage *outgoingMessage1 =
        [aliceSessionCipher throws_encryptMessage:[messageText dataUsingEncoding:NSUTF8StringEncoding]
                                  protocolContext:nil];

    XCTAssert([outgoingMessage1 isKindOfClass:[PreKeyWhisperMessage class]], @"Message should be PreKey type");

    ECKeyPair *bobIdentityKeyPair2 = [Curve25519 generateKeyPair];
    ECKeyPair *bobPreKeyPair2 = [Curve25519 generateKeyPair];
    ECKeyPair *bobSignedPreKeyPair2 = [Curve25519 generateKeyPair];
    NSData *bobSignedPreKeySignature2 =
        [Ed25519 throws_sign:bobSignedPreKeyPair2.publicKey.prependKeyType withKeyPair:bobIdentityKeyPair2];

    PreKeyBundle *bobPreKey2 = [[PreKeyBundle alloc] initWithRegistrationId:[bobStore localRegistrationId:nil]
                                                                   deviceId:1
                                                                   preKeyId:31337
                                                               preKeyPublic:bobPreKeyPair2.publicKey.prependKeyType
                                                         signedPreKeyPublic:bobSignedPreKeyPair2.publicKey.prependKeyType
                                                             signedPreKeyId:22
                                                      signedPreKeySignature:bobSignedPreKeySignature2
                                                                identityKey:bobIdentityKeyPair2.publicKey.prependKeyType];

    XCTAssertThrowsSpecificNamed([aliceSessionBuilder throws_processPrekeyBundle:bobPreKey2 protocolContext:nil],
        NSException,
        UntrustedIdentityKeyException);
}


@end

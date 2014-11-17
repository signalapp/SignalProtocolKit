//
//  SessionBuilder.m
//  AxolotlKit
//
//  Created by Frederic Jacobs on 22/10/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AxolotlInMemoryStore.h"
#import "SessionBuilder.h"
#import "SessionCipher.h"
#import "AxolotlExceptions.h"

#import <25519/Ed25519.h>


@interface PreKeyWhisperMessage ()
@property (nonatomic, readwrite) NSData         *identityKey;
@property (nonatomic, readwrite) NSData         *baseKey;
@end

@interface SessionBuilderTests : XCTestCase

@end


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

    AxolotlInMemoryStore *aliceStore = [AxolotlInMemoryStore new];
    SessionBuilder       *aliceSessionBuilder = [[SessionBuilder alloc] initWithAxolotlStore:aliceStore recipientId:BOB_RECIPIENT_ID deviceId:1];
    
    AxolotlInMemoryStore *bobStore      = [AxolotlInMemoryStore new];
    ECKeyPair *bobPreKeyPair            = [Curve25519 generateKeyPair];
    ECKeyPair *bobSignedPreKeyPair      = [Curve25519 generateKeyPair];
    NSData    *bobSignedPreKeySignature = [Ed25519 sign:bobSignedPreKeyPair.publicKey withKeyPair:bobStore.identityKeyPair];
    
    PreKeyBundle *bobPreKey = [[PreKeyBundle alloc]initWithRegistrationId:bobStore.localRegistrationId
                                                                 deviceId:1
                                                                 preKeyId:31337
                                                             preKeyPublic:bobPreKeyPair.publicKey
                                                       signedPreKeyPublic:bobSignedPreKeyPair.publicKey
                                                           signedPreKeyId:22
                                                    signedPreKeySignature:bobSignedPreKeySignature
                                                              identityKey:bobStore.identityKeyPair.publicKey];
    
    [aliceSessionBuilder processPrekeyBundle:bobPreKey];
    
    XCTAssert([aliceStore containsSession:BOB_RECIPIENT_ID deviceId:1]);
    XCTAssert([aliceStore loadSession:BOB_RECIPIENT_ID deviceId:1].sessionState.version == 3);
        
    NSString *originalMessage = @"Freedom is the right to tell people what they do not want to hear.";
    SessionCipher *aliceSessionCipher = [[SessionCipher alloc] initWithAxolotlStore:aliceStore recipientId:BOB_RECIPIENT_ID deviceId:1];
    
    WhisperMessage *outgoingMessage = [aliceSessionCipher encryptMessage:[originalMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    XCTAssert([outgoingMessage isKindOfClass:[PreKeyWhisperMessage class]], @"Message should be PreKey type");
    
    PreKeyWhisperMessage *incomingMessage = (PreKeyWhisperMessage*)outgoingMessage;
    [bobStore storePreKey:31337 preKeyRecord:[[PreKeyRecord alloc] initWithId:bobPreKey.preKeyId keyPair:bobPreKeyPair]];
    [bobStore storeSignedPreKey:22 signedPreKeyRecord:[[SignedPreKeyRecord alloc] initWithId:22 keyPair:bobSignedPreKeyPair signature:bobSignedPreKeySignature generatedAt:[NSDate date]]];
    
    SessionCipher *bobSessionCipher = [[SessionCipher alloc] initWithAxolotlStore:bobStore recipientId:ALICE_RECIPIENT_ID deviceId:1];
    [bobSessionCipher decrypt:incomingMessage];
    
    XCTAssert([bobStore containsSession:ALICE_RECIPIENT_ID deviceId:1]);
    XCTAssert([bobStore loadSession:ALICE_RECIPIENT_ID deviceId:1].sessionState.version == 3);
    XCTAssert([bobStore loadSession:ALICE_RECIPIENT_ID deviceId:1].sessionState.aliceBaseKey != nil);
}

/**
 *  Tests the case where an attacker would send a new PreKeyWhisperMessage with another IdentityKey
 */

- (void)testBasicPreKeyMITM {
    
    NSString *BOB_RECIPIENT_ID   = @"+3828923892";
    NSString *ALICE_RECIPIENT_ID = @"alice@gmail.com";
    
    AxolotlInMemoryStore *aliceStore = [AxolotlInMemoryStore new];
    SessionBuilder       *aliceSessionBuilder = [[SessionBuilder alloc] initWithAxolotlStore:aliceStore recipientId:BOB_RECIPIENT_ID deviceId:1];
    
    AxolotlInMemoryStore *bobStore      = [AxolotlInMemoryStore new];
    ECKeyPair *bobPreKeyPair            = [Curve25519 generateKeyPair];
    ECKeyPair *bobSignedPreKeyPair      = [Curve25519 generateKeyPair];
    NSData    *bobSignedPreKeySignature = [Ed25519 sign:bobSignedPreKeyPair.publicKey withKeyPair:bobStore.identityKeyPair];
    
    PreKeyBundle *bobPreKey = [[PreKeyBundle alloc]initWithRegistrationId:bobStore.localRegistrationId
                                                                 deviceId:1
                                                                 preKeyId:31337
                                                             preKeyPublic:bobPreKeyPair.publicKey
                                                       signedPreKeyPublic:bobSignedPreKeyPair.publicKey
                                                           signedPreKeyId:22
                                                    signedPreKeySignature:bobSignedPreKeySignature
                                                              identityKey:bobStore.identityKeyPair.publicKey];
    
    [aliceSessionBuilder processPrekeyBundle:bobPreKey];
    
    XCTAssert([aliceStore containsSession:BOB_RECIPIENT_ID deviceId:1]);
    XCTAssert([aliceStore loadSession:BOB_RECIPIENT_ID deviceId:1].sessionState.version == 3);
    
    NSString *originalMessage = @"Freedom is the right to tell people what they do not want to hear.";
    SessionCipher *aliceSessionCipher = [[SessionCipher alloc] initWithAxolotlStore:aliceStore recipientId:BOB_RECIPIENT_ID deviceId:1];
    
    WhisperMessage *outgoingMessage = [aliceSessionCipher encryptMessage:[originalMessage dataUsingEncoding:NSUTF8StringEncoding]];
    
    XCTAssert([outgoingMessage isKindOfClass:[PreKeyWhisperMessage class]], @"Message should be PreKey type");
    
    PreKeyWhisperMessage *incomingMessage = (PreKeyWhisperMessage*)outgoingMessage;
    [bobStore storePreKey:31337 preKeyRecord:[[PreKeyRecord alloc] initWithId:bobPreKey.preKeyId keyPair:bobPreKeyPair]];
    [bobStore storeSignedPreKey:22 signedPreKeyRecord:[[SignedPreKeyRecord alloc] initWithId:22 keyPair:bobSignedPreKeyPair signature:bobSignedPreKeySignature generatedAt:[NSDate date]]];
    
    SessionCipher *bobSessionCipher = [[SessionCipher alloc] initWithAxolotlStore:bobStore recipientId:ALICE_RECIPIENT_ID deviceId:1];
    [bobSessionCipher decrypt:incomingMessage];
    
    XCTAssert([bobStore containsSession:ALICE_RECIPIENT_ID deviceId:1]);
    XCTAssert([bobStore loadSession:ALICE_RECIPIENT_ID deviceId:1].sessionState.version == 3);
    XCTAssert([bobStore loadSession:ALICE_RECIPIENT_ID deviceId:1].sessionState.aliceBaseKey != nil);
    
    incomingMessage.identityKey = [Curve25519 generateKeyPair].publicKey;
    incomingMessage.baseKey     = [Curve25519 generateKeyPair].publicKey;
    XCTAssertThrowsSpecificNamed([bobSessionCipher decrypt:incomingMessage], NSException, UntrustedIdentityKeyException);
}


@end

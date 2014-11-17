//
//  SessionCipherTest.m
//  AxolotlKit
//
//  Created by Frederic Jacobs on 30/09/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import <25519/Curve25519.h>
#import "AxolotlInMemoryStore.h"
#import "AliceAxolotlParameters.h"
#import "BobAxolotlParameters.h"
#import "RatchetingSession.h"
#import "SessionBuilder.h"
#import "SessionCipher.h"
#import "Chainkey.h"

#import "SessionState.h"

@interface SessionCipherTest : XCTestCase

@end

@implementation SessionCipherTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testBasicSession{
    SessionRecord *aliceSessionRecord = [SessionRecord new];
    SessionRecord *bobSessionRecord   = [SessionRecord new];
    
    [self sessionInitialization:aliceSessionRecord.sessionState bobSessionState:bobSessionRecord.sessionState];
    
    [self runInteractionWithAliceRecord:aliceSessionRecord bobRecord:bobSessionRecord];
}

-(void)sessionInitialization:(SessionState*)aliceSessionState bobSessionState:(SessionState*)bobSessionState{
    
    ECKeyPair *aliceIdentityKeyPair = [Curve25519 generateKeyPair];
    ECKeyPair *aliceBaseKey         = [Curve25519 generateKeyPair];
    
    ECKeyPair *bobIdentityKeyPair   = [Curve25519 generateKeyPair];
    ECKeyPair *bobBaseKey           = [Curve25519 generateKeyPair];
    ECKeyPair *bobOneTimePK         = [Curve25519 generateKeyPair];
    
    AliceAxolotlParameters *aliceParams = [[AliceAxolotlParameters alloc] initWithIdentityKey:aliceIdentityKeyPair theirIdentityKey:[bobIdentityKeyPair publicKey] ourBaseKey:aliceBaseKey theirSignedPreKey:[bobBaseKey publicKey] theirOneTimePreKey:[bobOneTimePK publicKey] theirRatchetKey:[bobBaseKey publicKey]];
    
    BobAxolotlParameters   *bobParams = [[BobAxolotlParameters alloc] initWithMyIdentityKeyPair:bobIdentityKeyPair theirIdentityKey:[aliceIdentityKeyPair publicKey] ourSignedPrekey:bobBaseKey ourRatchetKey:bobBaseKey ourOneTimePrekey:bobOneTimePK theirBaseKey:[aliceBaseKey publicKey]];
    
    [RatchetingSession initializeSession:bobSessionState sessionVersion:3 BobParameters:bobParams];
    
    [RatchetingSession initializeSession:aliceSessionState sessionVersion:3 AliceParameters:aliceParams];
    
    
    XCTAssert([aliceSessionState.remoteIdentityKey isEqualToData:bobSessionState.localIdentityKey]);
}

- (void)runInteractionWithAliceRecord:(SessionRecord*)aliceSessionRecord bobRecord:(SessionRecord*)bobSessionRecord {
    
    NSString *aliceIdentifier = @"+3728378173821";
    NSString *bobIdentifier   = @"bob@gmail.com";
    
    AxolotlInMemoryStore *aliceStore  = [AxolotlInMemoryStore new];
    AxolotlInMemoryStore *bobStore    = [AxolotlInMemoryStore new];
    
    [aliceStore storeSession:bobIdentifier deviceId:1 session:aliceSessionRecord];
    [bobStore   storeSession:aliceIdentifier deviceId:1 session:bobSessionRecord];
    
    SessionCipher *aliceSessionCipher = [[SessionCipher alloc] initWithAxolotlStore:aliceStore recipientId:bobIdentifier deviceId:1];
    SessionCipher *bobSessionCipher   = [[SessionCipher alloc] initWithAxolotlStore:bobStore recipientId:aliceIdentifier deviceId:1];
    
    NSData *alicePlainText     = [@"This is a plaintext message!" dataUsingEncoding:NSUTF8StringEncoding];
    WhisperMessage *cipherText = [aliceSessionCipher encryptMessage:alicePlainText];
    
    NSData *bobPlaintext = [bobSessionCipher decrypt:cipherText];
    
    XCTAssert([bobPlaintext isEqualToData:alicePlainText]);
}

@end

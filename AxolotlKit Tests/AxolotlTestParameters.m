//
//  AxolotlTestParameters.m
//  AxolotlKit
//
//  Created by Frederic Jacobs on 22/10/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AliceAxolotlParameters.h"
#import "BobAxolotlParameters.h"

#import "RatchetingSession.h"
#import "SessionState.h"

@interface AxolotlTestParameters : XCTestCase

@end

@implementation AxolotlTestParameters

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testParameters {
    
    ECKeyPair *aliceIdentity = [Curve25519 generateKeyPair];
    ECKeyPair *bobIdentity   = [Curve25519 generateKeyPair];
    
    ECKeyPair *bobPrekey     = [Curve25519 generateKeyPair];
    ECKeyPair *bobSignedPrekey = [Curve25519 generateKeyPair];
    ECKeyPair *aliceEphemeral = [Curve25519 generateKeyPair];
    
    
    AliceAxolotlParameters *aliceParams = [[AliceAxolotlParameters alloc] initWithIdentityKey:aliceIdentity theirIdentityKey:bobIdentity.publicKey ourBaseKey:aliceEphemeral theirSignedPreKey:bobSignedPrekey.publicKey theirOneTimePreKey:bobPrekey.publicKey theirRatchetKey:bobSignedPrekey.publicKey];
    
    BobAxolotlParameters *bobParams     = [[BobAxolotlParameters alloc] initWithMyIdentityKeyPair:bobIdentity theirIdentityKey:aliceIdentity.publicKey ourSignedPrekey:bobSignedPrekey ourRatchetKey:bobSignedPrekey ourOneTimePrekey:bobPrekey theirBaseKey:aliceEphemeral.publicKey];
    
    SessionState *aliceSessionState = [SessionState new];
    SessionState *bobSessionState   = [SessionState new];
    
    [RatchetingSession initializeSession:aliceSessionState sessionVersion:3 AliceParameters:aliceParams];
    [RatchetingSession initializeSession:bobSessionState sessionVersion:3 BobParameters:bobParams];
    
    XCTAssert([aliceSessionState.rootKey.keyData isEqualToData:bobSessionState.rootKey.keyData], @"Root keys should be equal");
    
}

@end

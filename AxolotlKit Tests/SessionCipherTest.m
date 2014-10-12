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
#import "AliceAxolotlParameters.h"
#import "BobAxolotlParameters.h"
#import "RatchetingSession.h"
#import "SessionCipher.h"

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

-(void)testSessionInitialization:(SessionState*)aliceSessionState bobSessionState:(SessionState*)bobSessionState{
    
    ECKeyPair *aliceIdentityKeyPair = [Curve25519 generateKeyPair];
    ECKeyPair *aliceBaseKey         = [Curve25519 generateKeyPair];
    ECKeyPair *bobIdentityKeyPair   = [Curve25519 generateKeyPair];
    ECKeyPair *bobBaseKey           = [Curve25519 generateKeyPair];
    ECKeyPair *bobOneTimePK         = [Curve25519 generateKeyPair];
    
    AliceAxolotlParameters *aliceParams = [[AliceAxolotlParameters alloc] initWithIdentityKey:aliceIdentityKeyPair theirIdentityKey:[bobIdentityKeyPair publicKey] ourBaseKey:aliceBaseKey theirSignedPreKey:[bobBaseKey publicKey] theirOneTimePreKey:[bobOneTimePK publicKey] theirRatchetKey:[bobBaseKey publicKey]];
    
    BobAxolotlParameters   *bobParams = [[BobAxolotlParameters alloc] initWithMyIdentityKeyPair:bobIdentityKeyPair theirIdentityKey:[aliceIdentityKeyPair publicKey] ourSignedPrekey:bobBaseKey ourRatchetKey:bobBaseKey ourOneTimePrekey:bobOneTimePK theirBaseKey:[aliceBaseKey publicKey]];
    
    [RatchetingSession initializeSession:bobSessionState sessionVersion:3 BobParameters:bobParams];
    
    [RatchetingSession initializeSession:aliceSessionState sessionVersion:3 AliceParameters:aliceParams];
    
    [self runInteraction];
}

- (void)runInteraction{
    
    SessionCiper *sessionCipher = [[SessionCipher alloc] initWithSessionStore:<#(id<AxolotlStore>)#> recipientId:<#(long)#> deviceId:<#(int)#>]
    
}

@end

//
//  PreKeyBundleTests.m
//  AxolotlKit
//
//  Created by Frederic Jacobs on 15/02/15.
//  Copyright (c) 2015 Frederic Jacobs. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PreKeyBundle.h"
#import <25519/Curve25519.h>

@interface PreKeyBundleTests : XCTestCase

@end

@implementation PreKeyBundleTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testSerialization {
    PreKeyBundle *bundle = [[PreKeyBundle alloc] initWithRegistrationId:1
                                                               deviceId:2
                                                               preKeyId:3
                                                           preKeyPublic:[Curve25519 generateKeyPair].publicKey
                                                     signedPreKeyPublic:[Curve25519 generateKeyPair].publicKey
                                                         signedPreKeyId:4
                                                  signedPreKeySignature:[Curve25519 generateKeyPair].publicKey
                                                            identityKey:[Curve25519 generateKeyPair].publicKey];
    

    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:bundle];
    
    PreKeyBundle *bundle2 = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    XCTAssertEqual(bundle.registrationId, bundle2.registrationId);
    XCTAssertEqual(bundle.deviceId, bundle2.deviceId);
    XCTAssertEqual(bundle.preKeyId, bundle2.preKeyId);
    XCTAssertEqual(bundle.signedPreKeyId, bundle2.signedPreKeyId);
   
    
    XCTAssert([bundle.preKeyPublic isEqualToData:bundle2.preKeyPublic]);
    XCTAssert([bundle.signedPreKeyPublic isEqualToData:bundle2.signedPreKeyPublic]);
    XCTAssert([bundle.signedPreKeySignature isEqualToData:bundle2.signedPreKeySignature]);
    XCTAssert([bundle.identityKey isEqualToData:bundle2.identityKey]);
    
}


@end

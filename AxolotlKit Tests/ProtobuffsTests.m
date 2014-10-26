//
//  ProtobuffsTests.m
//  AxolotlKit
//
//  Created by Frederic Jacobs on 25/10/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "PreKeyWhisperMessage.h"
#import "WhisperMessage.h"
#import "WhisperTextProtocol.pb.h"

@interface ProtobuffsTests : XCTestCase

@end

@implementation ProtobuffsTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testProtoSerialization {
    NSData *ratchetKey = [@"RatchetKey" dataUsingEncoding:NSUTF8StringEncoding];
    NSData *cipherText = [@"CipherText" dataUsingEncoding:NSUTF8StringEncoding];
    int    counter = 2;
    int    previousCounter = 1;
    
    TSProtoWhisperMessage *helloMessage = [[[[[[[TSProtoWhisperMessage builder]
                                                setCounter:1]
                                               setRatchetKey:ratchetKey]
                                              setCiphertext:cipherText]
                                             setCounter:counter]
                                            setPreviousCounter:previousCounter] build];
    
    NSData *serializedMessage = [helloMessage data];
    
    TSProtoWhisperMessage *deserialized = [TSProtoWhisperMessage parseFromData:serializedMessage];
    
    XCTAssert(deserialized.counter == counter);
    XCTAssert(deserialized.previousCounter == previousCounter);
    XCTAssert([deserialized.ratchetKey isEqualToData:ratchetKey]);
    XCTAssert([deserialized.ciphertext isEqualToData:cipherText]);
}


@end

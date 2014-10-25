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

- (void)testExample {
    
    NSData *macKey =
    WhisperMessage *whisperMessage = [[WhisperMessage alloc]initWithVersion:3 macKey:<#(NSData *)#> senderRatchetKey:<#(NSData *)#> counter:<#(int)#> previousCounter:<#(int)#> cipherText:<#(NSData *)#> senderIdentityKey:<#(NSData *)#> receiverIdentityKey:<#(NSData *)#>]
    
    PreKeyWhisperMessage *preKeyMessage = [[PreKeyWhisperMessage alloc] initWithWhisperMessage:<#(WhisperMessage *)#> registrationId:<#(long)#> prekeyId:<#(int)#> signedPrekeyId:<#(int)#> baseKey:<#(NSData *)#> identityKey:<#(NSData *)#>]
    
}


@end

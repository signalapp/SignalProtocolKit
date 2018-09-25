//
//  Copyright (c) 2017 Open Whisper Systems. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <AxolotlKit/PreKeyWhisperMessage.h>
#import <AxolotlKit/WhisperMessage.h>
#import <AxolotlKit/AxolotlKit-Swift.h>

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
    
    SPKProtoTSProtoWhisperMessageBuilder *builder = [[SPKProtoTSProtoWhisperMessageBuilder alloc] initWithRatchetKey:ratchetKey
                                                                                                                    counter:counter
                                                                                                                 ciphertext:cipherText];
    [builder setPreviousCounter:previousCounter];
    SPKProtoTSProtoWhisperMessage *message = [builder buildIgnoringErrors];
    NSData *serializedMessage = [message serializedDataIgnoringErrors];
    
    NSError *error;
    SPKProtoTSProtoWhisperMessage *_Nullable deserialized = [SPKProtoTSProtoWhisperMessage parseData:serializedMessage
                                                             error:&error];
    XCTAssertNotNil(deserialized);
    XCTAssertNil(error);

    XCTAssert(deserialized.counter == counter);
    XCTAssert(deserialized.previousCounter == previousCounter);
    XCTAssert([deserialized.ratchetKey isEqualToData:ratchetKey]);
    XCTAssert([deserialized.ciphertext isEqualToData:cipherText]);
}


@end

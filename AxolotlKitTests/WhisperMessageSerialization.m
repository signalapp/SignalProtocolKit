//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
//

#import <AxolotlKit/WhisperMessage.h>
#import <Curve25519Kit/Curve25519.h>
#import <XCTest/XCTest.h>

@interface WhisperMessageSerialization : XCTestCase

@end

@implementation WhisperMessageSerialization

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testWhisperMessage {
    ECKeyPair *keyPair = [Curve25519 generateKeyPair];
    ECKeyPair *fakeMacKey = [Curve25519 generateKeyPair];
    int counter = 0;
    NSData *cipherText = [@"I'm not really ciphertext" dataUsingEncoding:NSUTF8StringEncoding];
    ECKeyPair *senderIdentityKey = [Curve25519 generateKeyPair];
    ECKeyPair *receiverIdentityKey = [Curve25519 generateKeyPair];

    WhisperMessage *message = [[WhisperMessage alloc] init_throws_withVersion:3
                                                                       macKey:fakeMacKey.publicKey
                                                             senderRatchetKey:keyPair.publicKey
                                                                      counter:counter
                                                              previousCounter:0
                                                                   cipherText:cipherText
                                                            senderIdentityKey:senderIdentityKey.publicKey
                                                          receiverIdentityKey:receiverIdentityKey.publicKey];

    WhisperMessage *deserializedMessage = [[WhisperMessage alloc] init_throws_withData:message.serialized];


    XCTAssert([[message.serialized subdataWithRange:NSMakeRange(0, message.serialized.length-8)] isEqualToData:[deserializedMessage.serialized subdataWithRange:NSMakeRange(0, deserializedMessage.serialized.length-8)]]);

    [message throws_verifyMacWithVersion:3
                       senderIdentityKey:senderIdentityKey.publicKey
                     receiverIdentityKey:receiverIdentityKey.publicKey
                                  macKey:fakeMacKey.publicKey];
    [deserializedMessage throws_verifyMacWithVersion:3
                                   senderIdentityKey:senderIdentityKey.publicKey
                                 receiverIdentityKey:receiverIdentityKey.publicKey
                                              macKey:fakeMacKey.publicKey];

    XCTAssert([message.cipherText isEqualToData:deserializedMessage.cipherText]);
    XCTAssert(message.version == deserializedMessage.version);
    XCTAssert([message.serialized isEqualToData:deserializedMessage.serialized]);
    
}

@end

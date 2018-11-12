//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
//

#import "ECKeyPair+ECKeyPairTesting.h"
#import <AxolotlKit/AliceAxolotlParameters.h>
#import <AxolotlKit/BobAxolotlParameters.h>
#import <AxolotlKit/ChainKey.h>
#import <AxolotlKit/RatchetingSession.h>
#import <AxolotlKit/SPKMockProtocolStore.h>
#import <AxolotlKit/SessionCipher.h>
#import <AxolotlKit/SessionRecord.h>
#import <AxolotlKit/SessionState.h>
#import <Curve25519Kit/Curve25519.h>
#import <Curve25519Kit/Ed25519.h>
#import <XCTest/XCTest.h>

@interface RatchetingSessionTest : XCTestCase

@end

@implementation RatchetingSessionTest

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

/**
 *  Test with Android Test Vectors
 */

- (void)testSessionInitializationAndRatcheting {
    
    Byte aliceIdentityPrivateKey [] = {(Byte) 0x58, (Byte) 0x20, (Byte) 0xD9, (Byte) 0x2B,
        (Byte) 0xBF, (Byte) 0x3E, (Byte) 0x74, (Byte) 0x80,
        (Byte) 0x68, (Byte) 0x01, (Byte) 0x94, (Byte) 0x90,
        (Byte) 0xC3, (Byte) 0xAA, (Byte) 0x94, (Byte) 0x50,
        (Byte) 0x21, (Byte) 0xFA, (Byte) 0xA6, (Byte) 0xD2,
        (Byte) 0x43, (Byte) 0xE4, (Byte) 0x86, (Byte) 0x49,
        (Byte) 0xF6, (Byte) 0x6B, (Byte) 0xD6, (Byte) 0xA4,
        (Byte) 0x45, (Byte) 0x99, (Byte) 0x17, (Byte) 0x63};
    NSData *aliceIdentityPrivateKeyData =  [NSData dataWithBytes:aliceIdentityPrivateKey length:32];
   
    Byte aliceIdentityPublicKey [] = {(Byte) 0x05, (Byte) 0x6F, (Byte) 0xEC, (Byte) 0xDE,
        (Byte) 0xE2, (Byte) 0x7F, (Byte) 0x67, (Byte) 0x36,
        (Byte) 0xA7, (Byte) 0xC6, (Byte) 0xA2, (Byte) 0x77,
        (Byte) 0x9C, (Byte) 0x5A, (Byte) 0xDC, (Byte) 0x26,
        (Byte) 0x35, (Byte) 0x22, (Byte) 0x2A, (Byte) 0xBB,
        (Byte) 0x26, (Byte) 0x01, (Byte) 0xCB, (Byte) 0x93,
        (Byte) 0x7B, (Byte) 0xA9, (Byte) 0x0F, (Byte) 0xD8,
        (Byte) 0x6E, (Byte) 0x56, (Byte) 0x2C, (Byte) 0x76,
        (Byte) 0x1C};
    NSData *aliceIdentityPublicKeyData =  [NSData dataWithBytes:aliceIdentityPublicKey length:33];
  
    Byte aliceBasePublicKey [] = {(Byte) 0x05, (Byte) 0x7B, (Byte) 0xB2, (Byte) 0x6A,
        (Byte) 0xAF, (Byte) 0x25, (Byte) 0x3C, (Byte) 0x7C,
        (Byte) 0x2F, (Byte) 0xFB, (Byte) 0x99, (Byte) 0x42,
        (Byte) 0xED, (Byte) 0x5F, (Byte) 0xDA, (Byte) 0x93,
        (Byte) 0x77, (Byte) 0xF5, (Byte) 0xD2, (Byte) 0x3E,
        (Byte) 0x25, (Byte) 0x95, (Byte) 0x67, (Byte) 0x5D,
        (Byte) 0x62, (Byte) 0x14, (Byte) 0xBB, (Byte) 0x3B,
        (Byte) 0x40, (Byte) 0xC7, (Byte) 0xBE, (Byte) 0xAC,
        (Byte) 0x56};
    NSData *aliceBasePublicKeyData =  [NSData dataWithBytes:aliceBasePublicKey length:33];
  
    Byte aliceBasePrivateKey [] = {(Byte) 0x28, (Byte) 0xD3, (Byte) 0x04, (Byte) 0xA2,
        (Byte) 0xEB, (Byte) 0x00, (Byte) 0xFB, (Byte) 0x63,
        (Byte) 0xF8, (Byte) 0x5E, (Byte) 0x6D, (Byte) 0x4C,
        (Byte) 0xEF, (Byte) 0xC6, (Byte) 0xBF, (Byte) 0x13,
        (Byte) 0x1B, (Byte) 0x5E, (Byte) 0xE5, (Byte) 0x62,
        (Byte) 0xB4, (Byte) 0x6B, (Byte) 0xD5, (Byte) 0x2C,
        (Byte) 0xCB, (Byte) 0x52, (Byte) 0x8A, (Byte) 0x84,
        (Byte) 0x61, (Byte) 0xDD, (Byte) 0xC3, (Byte) 0x65};
    NSData *aliceBasePrivateKeyData =  [NSData dataWithBytes:aliceBasePrivateKey length:32];
   
    Byte bobIdentityPublicKey [] = {(Byte) 0x05, (Byte) 0x01, (Byte) 0x6A, (Byte) 0x60,
        (Byte) 0xFC, (Byte) 0xCF, (Byte) 0x33, (Byte) 0xB6,
        (Byte) 0xF0, (Byte) 0x9A, (Byte) 0x1E, (Byte) 0x9B,
        (Byte) 0x54, (Byte) 0x77, (Byte) 0x78, (Byte) 0x42,
        (Byte) 0xDD, (Byte) 0xE6, (Byte) 0xC4, (Byte) 0xF6,
        (Byte) 0x30, (Byte) 0xAE, (Byte) 0x35, (Byte) 0x95,
        (Byte) 0x67, (Byte) 0xB3, (Byte) 0x74, (Byte) 0x20,
        (Byte) 0xCF, (Byte) 0x2D, (Byte) 0x93, (Byte) 0xF1,
        (Byte) 0x45};
    NSData *bobIdentityPublicKeyData =  [NSData dataWithBytes:bobIdentityPublicKey length:33];
    
    Byte bobIdentityPrivateKey [] = {(Byte) 0xC8, (Byte) 0xF3, (Byte) 0xA6, (Byte) 0x39,
        (Byte) 0x34, (Byte) 0xCE, (Byte) 0xDE, (Byte) 0xEE,
        (Byte) 0x37, (Byte) 0x07, (Byte) 0xFF, (Byte) 0x79,
        (Byte) 0x71, (Byte) 0x05, (Byte) 0x0D, (Byte) 0x58,
        (Byte) 0x3B, (Byte) 0x63, (Byte) 0x7D, (Byte) 0xD2,
        (Byte) 0x21, (Byte) 0x15, (Byte) 0xE3, (Byte) 0xFD,
        (Byte) 0x2B, (Byte) 0x1D, (Byte) 0x41, (Byte) 0x22,
        (Byte) 0x2C, (Byte) 0x29, (Byte) 0x24, (Byte) 0x65};
    NSData *bobIdentityPrivateKeyData =  [NSData dataWithBytes:bobIdentityPrivateKey length:32];
    
    Byte bobBasePrivateKey [] = {(Byte) 0x70, (Byte) 0xCC, (Byte) 0x77, (Byte) 0x0A,
        (Byte) 0x82, (Byte) 0x74, (Byte) 0x70, (Byte) 0x99,
        (Byte) 0xB7, (Byte) 0xCC, (Byte) 0x05, (Byte) 0xCC,
        (Byte) 0x69, (Byte) 0x73, (Byte) 0x58, (Byte) 0x78,
        (Byte) 0x41, (Byte) 0x3E, (Byte) 0xCF, (Byte) 0xEE,
        (Byte) 0xFE, (Byte) 0x85, (Byte) 0xB5, (Byte) 0xF7,
        (Byte) 0x14, (Byte) 0xFF, (Byte) 0x85, (Byte) 0x36,
        (Byte) 0x8C, (Byte) 0x98, (Byte) 0x70, (Byte) 0x52};
    NSData *bobBasePrivateKeyData =  [NSData dataWithBytes:bobBasePrivateKey length:32];
  
    Byte bobBasePublicKey [] = {(Byte) 0x05, (Byte) 0x18, (Byte) 0x3A, (Byte) 0x6E,
        (Byte) 0xC2, (Byte) 0xC7, (Byte) 0x4A, (Byte) 0x21,
        (Byte) 0xF3, (Byte) 0xDE, (Byte) 0xB3, (Byte) 0x70,
        (Byte) 0x4C, (Byte) 0x3D, (Byte) 0x32, (Byte) 0x45,
        (Byte) 0xE0, (Byte) 0xA5, (Byte) 0xD5, (Byte) 0x5F,
        (Byte) 0xDC, (Byte) 0xC9, (Byte) 0x9A, (Byte) 0x26,
        (Byte) 0x9D, (Byte) 0x64, (Byte) 0x68, (Byte) 0xA6,
        (Byte) 0x7C, (Byte) 0xAE, (Byte) 0xEF, (Byte) 0x59,
        (Byte) 0x12};
    NSData *bobBasePublicKeyData =  [NSData dataWithBytes:bobBasePublicKey length:33];

    Byte bobPreKeyPrivateKey [] = {(Byte) 0x78, (Byte) 0x0D, (Byte) 0x5D, (Byte) 0x26,
        (Byte) 0xF7, (Byte) 0x6A, (Byte) 0x24, (Byte) 0xAD,
        (Byte) 0x65, (Byte) 0x9C, (Byte) 0xF5, (Byte) 0xCE,
        (Byte) 0xD5, (Byte) 0x2B, (Byte) 0x0E, (Byte) 0x5C,
        (Byte) 0xEA, (Byte) 0x3D, (Byte) 0x42, (Byte) 0xA2,
        (Byte) 0x05, (Byte) 0x40, (Byte) 0xE0, (Byte) 0xD8,
        (Byte) 0x45, (Byte) 0xDF, (Byte) 0xA2, (Byte) 0xF0,
        (Byte) 0x78, (Byte) 0x1E, (Byte) 0xBA, (Byte) 0x42};
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    NSData *bobPreKeyPrivateKeyData =  [NSData dataWithBytes:bobPreKeyPrivateKey length:32];
#pragma clang diagnostic pop
   
    
    Byte bobPreKeyPublicKey [] = {(Byte) 0x05, (Byte) 0x52, (Byte) 0x02, (Byte) 0xA7,
        (Byte) 0xDE, (Byte) 0x5D, (Byte) 0x6C, (Byte) 0x23,
        (Byte) 0x87, (Byte) 0x6D, (Byte) 0x43, (Byte) 0x24,
        (Byte) 0x3D, (Byte) 0x75, (Byte) 0x68, (Byte) 0xAE,
        (Byte) 0x27, (Byte) 0x3B, (Byte) 0x27, (Byte) 0x76,
        (Byte) 0x4B, (Byte) 0x01, (Byte) 0xCE, (Byte) 0x15,
        (Byte) 0xDF, (Byte) 0x51, (Byte) 0x38, (Byte) 0xA5,
        (Byte) 0xFC, (Byte) 0xD9, (Byte) 0xB6, (Byte) 0xC8,
        (Byte) 0x44};
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    NSData *bobPreKeyPublicKeyData =  [NSData dataWithBytes:bobPreKeyPublicKey length:33];
#pragma clang diagnostic pop
 
    Byte aliceSendingRatchetPrivate [] = {(Byte) 0x98, (Byte) 0x04, (Byte) 0x0B, (Byte) 0xAE,
        (Byte) 0x6B, (Byte) 0x3D, (Byte) 0x02, (Byte) 0x9C,
        (Byte) 0xF1, (Byte) 0x25, (Byte) 0xDC, (Byte) 0x8E,
        (Byte) 0xD8, (Byte) 0x07, (Byte) 0xCE, (Byte) 0x33,
        (Byte) 0xFC, (Byte) 0xE0, (Byte) 0x07, (Byte) 0xD8,
        (Byte) 0x2F, (Byte) 0x67, (Byte) 0x6D, (Byte) 0x7B,
        (Byte) 0xC7, (Byte) 0x1A, (Byte) 0x5B, (Byte) 0x91,
        (Byte) 0x3B, (Byte) 0x60, (Byte) 0x3B, (Byte) 0x67};
    NSData *aliceSendingRatchetPrivateData =  [NSData dataWithBytes:aliceSendingRatchetPrivate length:32];
    
    Byte aliceSendingRatchetPublic [] = {(Byte) 0x05, (Byte) 0xB6, (Byte) 0x2A, (Byte) 0xE0,
        (Byte) 0x25, (Byte) 0xB8, (Byte) 0xFF, (Byte) 0xEE,
        (Byte) 0x3A, (Byte) 0xEB, (Byte) 0x01, (Byte) 0x1B,
        (Byte) 0xF7, (Byte) 0x78, (Byte) 0xE6, (Byte) 0x26,
        (Byte) 0x22, (Byte) 0x56, (Byte) 0x17, (Byte) 0x30,
        (Byte) 0x7A, (Byte) 0x95, (Byte) 0x87, (Byte) 0x91,
        (Byte) 0x31, (Byte) 0xD9, (Byte) 0x9D, (Byte) 0x27,
        (Byte) 0x49, (Byte) 0x06, (Byte) 0xEE, (Byte) 0x57,
        (Byte) 0x6A};
    NSData *aliceSendingRatchetPublicData =  [NSData dataWithBytes:aliceSendingRatchetPublic length:33];
   
    Byte aliceRootKey [] = {(Byte) 0xC3, (Byte) 0x5A, (Byte) 0xF1, (Byte) 0x81,
        (Byte) 0xB0, (Byte) 0xBF, (Byte) 0xEA, (Byte) 0xB5,
        (Byte) 0xD9, (Byte) 0x71, (Byte) 0x12, (Byte) 0x20,
        (Byte) 0xC1, (Byte) 0x60, (Byte) 0xD6, (Byte) 0x43,
        (Byte) 0xF6, (Byte) 0xE8, (Byte) 0x1C, (Byte) 0x00,
        (Byte) 0x11, (Byte) 0xBF, (Byte) 0xA1, (Byte) 0xAA,
        (Byte) 0x16, (Byte) 0xAE, (Byte) 0xF3, (Byte) 0x6A,
        (Byte) 0x91, (Byte) 0xCD, (Byte) 0x1A, (Byte) 0x9B};
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    NSData *aliceRootKeyData =  [NSData dataWithBytes:aliceRootKey length:32];
#pragma clang diagnostic pop
  
    Byte aliceSendingChainKey [] = {(Byte) 0x8A, (Byte) 0xA2, (Byte) 0x05, (Byte) 0xEA,
        (Byte) 0x17, (Byte) 0x00, (Byte) 0xC0, (Byte) 0x85,
        (Byte) 0xB6, (Byte) 0x43, (Byte) 0xE9, (Byte) 0x68,
        (Byte) 0x4F, (Byte) 0x6A, (Byte) 0x53, (Byte) 0x74,
        (Byte) 0x88, (Byte) 0xBD, (Byte) 0x9F, (Byte) 0x3E,
        (Byte) 0xA0, (Byte) 0x1D, (Byte) 0x00, (Byte) 0xF9,
        (Byte) 0x58, (Byte) 0x55, (Byte) 0xE1, (Byte) 0x8F,
        (Byte) 0xAB, (Byte) 0x9F, (Byte) 0xBE, (Byte) 0x51};
    NSData *aliceSendingChainKeyData =  [NSData dataWithBytes:aliceSendingChainKey length:32];
   
    Byte aliceSendingCipherKey [] = {(Byte) 0xDD, (Byte) 0x61, (Byte) 0x0E, (Byte) 0xEE,
        (Byte) 0x8F, (Byte) 0x33, (Byte) 0x02, (Byte) 0x25,
        (Byte) 0x63, (Byte) 0x48, (Byte) 0x8A, (Byte) 0xED,
        (Byte) 0xE0, (Byte) 0x94, (Byte) 0xAB, (Byte) 0x6C,
        (Byte) 0x72, (Byte) 0xAF, (Byte) 0x39, (Byte) 0x69,
        (Byte) 0xF7, (Byte) 0xCF, (Byte) 0xA6, (Byte) 0x5F,
        (Byte) 0x09, (Byte) 0x5F, (Byte) 0xEE, (Byte) 0x59,
        (Byte) 0xC4, (Byte) 0xEA, (Byte) 0xE7, (Byte) 0x3D};
    NSData *aliceSendingCipherKeyData =  [NSData dataWithBytes:aliceSendingCipherKey length:32];
    
    Byte aliceSendingIVKey [] = {(Byte) 0xF3, (Byte) 0xF0, (Byte) 0x25, (Byte) 0x58,
        (Byte) 0x43, (Byte) 0xDA, (Byte) 0x3A, (Byte) 0x81,
        (Byte) 0x6C, (Byte) 0x78, (Byte) 0xD7, (Byte) 0x65,
        (Byte) 0xCE, (Byte) 0xBD, (Byte) 0xBA, (Byte) 0x0B};
    NSData *aliceSendingIVKeyData =  [NSData dataWithBytes:aliceSendingIVKey length:16];
    
    Byte aliceSendingMacKey [] = {(Byte) 0xAC, (Byte) 0xC6, (Byte) 0x30, (Byte) 0x4D,
        (Byte) 0xC0, (Byte) 0xCC, (Byte) 0x20, (Byte) 0xE5,
        (Byte) 0x8F, (Byte) 0xCE, (Byte) 0xA4, (Byte) 0x60,
        (Byte) 0xDA, (Byte) 0xC1, (Byte) 0x67, (Byte) 0x55,
        (Byte) 0x4E, (Byte) 0x89, (Byte) 0xA9, (Byte) 0xB2,
        (Byte) 0x5E, (Byte) 0xBD, (Byte) 0xA5, (Byte) 0xA3,
        (Byte) 0xBA, (Byte) 0xBE, (Byte) 0x15, (Byte) 0xCF,
        (Byte) 0x8B, (Byte) 0x71, (Byte) 0xE7, (Byte) 0x9A};
    NSData *aliceSendingMacKeyData =  [NSData dataWithBytes:aliceSendingMacKey length:32];
   
    Byte bobRootKey [] = {(Byte) 0x89, (Byte) 0xF9, (Byte) 0x57, (Byte) 0x60,
        (Byte) 0x37, (Byte) 0xC1, (Byte) 0x07, (Byte) 0x6C,
        (Byte) 0x19, (Byte) 0x22, (Byte) 0x11, (Byte) 0xFB,
        (Byte) 0x22, (Byte) 0x61, (Byte) 0xE4, (Byte) 0xC4,
        (Byte) 0x44, (Byte) 0x58, (Byte) 0x51, (Byte) 0x44,
        (Byte) 0xC2, (Byte) 0x8C, (Byte) 0x1C, (Byte) 0x6E,
        (Byte) 0x7C, (Byte) 0x48, (Byte) 0xB6, (Byte) 0x91,
        (Byte) 0x26, (Byte) 0x9B, (Byte) 0xF2, (Byte) 0xE6};
    NSData *bobRootKeyData =  [NSData dataWithBytes:bobRootKey length:32];
  
    Byte aliceSessionRecordRootKey [] = {(Byte) 0xC3, (Byte) 0x5A, (Byte) 0xF1, (Byte) 0x81,
        (Byte) 0xB0, (Byte) 0xBF, (Byte) 0xEA, (Byte) 0xB5,
        (Byte) 0xD9, (Byte) 0x71, (Byte) 0x12, (Byte) 0x20,
        (Byte) 0xC1, (Byte) 0x60, (Byte) 0xD6, (Byte) 0x43,
        (Byte) 0xF6, (Byte) 0xE8, (Byte) 0x1C, (Byte) 0x00,
        (Byte) 0x11, (Byte) 0xBF, (Byte) 0xA1, (Byte) 0xAA,
        (Byte) 0x16, (Byte) 0xAE, (Byte) 0xF3, (Byte) 0x6A,
        (Byte) 0x91, (Byte) 0xCD, (Byte) 0x1A, (Byte) 0x9B};
    NSData *aliceSessionRecordRootKeyData =  [NSData dataWithBytes:aliceSessionRecordRootKey length:32];
  
    Byte bobSessionRecordRootKey [] = {(Byte) 0x89, (Byte) 0xF9, (Byte) 0x57, (Byte) 0x60,
        (Byte) 0x37, (Byte) 0xC1, (Byte) 0x07, (Byte) 0x6C,
        (Byte) 0x19, (Byte) 0x22, (Byte) 0x11, (Byte) 0xFB,
        (Byte) 0x22, (Byte) 0x61, (Byte) 0xE4, (Byte) 0xC4,
        (Byte) 0x44, (Byte) 0x58, (Byte) 0x51, (Byte) 0x44,
        (Byte) 0xC2, (Byte) 0x8C, (Byte) 0x1C, (Byte) 0x6E,
        (Byte) 0x7C, (Byte) 0x48, (Byte) 0xB6, (Byte) 0x91,
        (Byte) 0x26, (Byte) 0x9B, (Byte) 0xF2, (Byte) 0xE6};
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    NSData *bobSessionRecordRootKeyData =  [NSData dataWithBytes:bobSessionRecordRootKey length:32];
#pragma clang diagnostic pop

    Byte alicePlaintext [] = {(Byte) 0x54, (Byte) 0x68, (Byte) 0x69, (Byte) 0x73,
        (Byte) 0x20, (Byte) 0x69, (Byte) 0x73, (Byte) 0x20,
        (Byte) 0x61, (Byte) 0x20, (Byte) 0x70, (Byte) 0x6C,
        (Byte) 0x61, (Byte) 0x69, (Byte) 0x6E, (Byte) 0x74,
        (Byte) 0x65, (Byte) 0x78, (Byte) 0x74, (Byte) 0x20,
        (Byte) 0x6D, (Byte) 0x65, (Byte) 0x73, (Byte) 0x73,
        (Byte) 0x61, (Byte) 0x67, (Byte) 0x65, (Byte) 0x2E};
    NSData *alicePlaintextData =  [NSData dataWithBytes:alicePlaintext length:28];

    Byte AliceSerializedWhisperMessage [] = {(Byte) 0x33, (Byte) 0x0A, (Byte) 0x21, (Byte) 0x05,
        (Byte) 0xB6, (Byte) 0x2A, (Byte) 0xE0, (Byte) 0x25,
        (Byte) 0xB8, (Byte) 0xFF, (Byte) 0xEE, (Byte) 0x3A,
        (Byte) 0xEB, (Byte) 0x01, (Byte) 0x1B, (Byte) 0xF7,
        (Byte) 0x78, (Byte) 0xE6, (Byte) 0x26, (Byte) 0x22,
        (Byte) 0x56, (Byte) 0x17, (Byte) 0x30, (Byte) 0x7A,
        (Byte) 0x95, (Byte) 0x87, (Byte) 0x91, (Byte) 0x31,
        (Byte) 0xD9, (Byte) 0x9D, (Byte) 0x27, (Byte) 0x49,
        (Byte) 0x06, (Byte) 0xEE, (Byte) 0x57, (Byte) 0x6A,
        (Byte) 0x10, (Byte) 0x00, (Byte) 0x18, (Byte) 0x00,
        (Byte) 0x22, (Byte) 0x20, (Byte) 0x9E, (Byte) 0xF2,
        (Byte) 0xD0, (Byte) 0xE1, (Byte) 0x30, (Byte) 0x4C,
        (Byte) 0x01, (Byte) 0xE0, (Byte) 0x68, (Byte) 0x7B,
        (Byte) 0x44, (Byte) 0x5A, (Byte) 0x27, (Byte) 0x64,
        (Byte) 0x79, (Byte) 0x51, (Byte) 0xD4, (Byte) 0xC7,
        (Byte) 0x0B, (Byte) 0xF3, (Byte) 0xD3, (Byte) 0xAC,
        (Byte) 0x23, (Byte) 0xA5, (Byte) 0x8D, (Byte) 0xF7,
        (Byte) 0x22, (Byte) 0xDC, (Byte) 0x22, (Byte) 0x76,
        (Byte) 0xC3, (Byte) 0xA6, (Byte) 0x96, (Byte) 0x06,
        (Byte) 0xAB, (Byte) 0xBE, (Byte) 0x2E, (Byte) 0x31,
        (Byte) 0x63, (Byte) 0x88};
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    NSData *AliceSerializedWhisperMessageData =  [NSData dataWithBytes:AliceSerializedWhisperMessage length:82];
#pragma clang diagnostic pop
   
    Byte aliceCipherText [] = {(Byte) 0x9E, (Byte) 0xF2, (Byte) 0xD0, (Byte) 0xE1,
        (Byte) 0x30, (Byte) 0x4C, (Byte) 0x01, (Byte) 0xE0,
        (Byte) 0x68, (Byte) 0x7B, (Byte) 0x44, (Byte) 0x5A,
        (Byte) 0x27, (Byte) 0x64, (Byte) 0x79, (Byte) 0x51,
        (Byte) 0xD4, (Byte) 0xC7, (Byte) 0x0B, (Byte) 0xF3,
        (Byte) 0xD3, (Byte) 0xAC, (Byte) 0x23, (Byte) 0xA5,
        (Byte) 0x8D, (Byte) 0xF7, (Byte) 0x22, (Byte) 0xDC,
        (Byte) 0x22, (Byte) 0x76, (Byte) 0xC3, (Byte) 0xA6};
    NSData *aliceCipherTextData =  [NSData dataWithBytes:aliceCipherText length:32];


    ECKeyPair *aliceIdentityKey =
        [ECKeyPair throws_keyPairWithPrivateKey:aliceIdentityPrivateKeyData publicKey:aliceIdentityPublicKeyData];

    ECKeyPair *bobIdentityKey =
        [ECKeyPair throws_keyPairWithPrivateKey:bobIdentityPrivateKeyData publicKey:bobIdentityPublicKeyData];

    ECKeyPair *aliceBaseKey =
        [ECKeyPair throws_keyPairWithPrivateKey:aliceBasePrivateKeyData publicKey:aliceBasePublicKeyData];

    ECKeyPair *bobBaseKey =
        [ECKeyPair throws_keyPairWithPrivateKey:bobBasePrivateKeyData publicKey:bobBasePublicKeyData];

    ECKeyPair *aliceSendingRatchet =
        [ECKeyPair throws_keyPairWithPrivateKey:aliceSendingRatchetPrivateData publicKey:aliceSendingRatchetPublicData];

    // ---
    
    SPKMockProtocolStore *aliceStore = [SPKMockProtocolStore new];
    SPKMockProtocolStore *bobStore = [SPKMockProtocolStore new];
    
    SessionRecord *aliceSessionRecord = [SessionRecord new];
    SessionRecord *bobSessionRecord   = [SessionRecord new];
    
    AliceAxolotlParameters *aliceAxolotlParams = [[AliceAxolotlParameters alloc] initWithIdentityKey:aliceIdentityKey theirIdentityKey:bobIdentityKey.publicKey ourBaseKey:aliceBaseKey theirSignedPreKey:bobBaseKey.publicKey theirOneTimePreKey:nil theirRatchetKey:bobBaseKey.publicKey];
    
    BobAxolotlParameters   *bobAxolotlParams   = [[BobAxolotlParameters alloc] initWithMyIdentityKeyPair:bobIdentityKey theirIdentityKey:aliceIdentityKey.publicKey ourSignedPrekey:bobBaseKey ourRatchetKey:bobBaseKey ourOneTimePrekey:nil theirBaseKey:aliceBaseKey.publicKey];

    [RatchetingSession throws_initializeSession:aliceSessionRecord.sessionState
                                 sessionVersion:3
                                AliceParameters:aliceAxolotlParams
                                  senderRatchet:aliceSendingRatchet];

    [RatchetingSession throws_initializeSession:bobSessionRecord.sessionState
                                 sessionVersion:3
                                  BobParameters:bobAxolotlParams];

    NSString *aliceIdentifier = @"+483294823482";
    NSString *bobIdentifier = @"+389424728942";

    // Logging Alice's Session initialization and first message encryption
    XCTAssert([[@"This is a plaintext message." dataUsingEncoding:NSUTF8StringEncoding] isEqualToData:alicePlaintextData], @"Encoding is not correct");
    XCTAssert([aliceSessionRecord.sessionState.rootKey.keyData isEqualToData:aliceSessionRecordRootKeyData]);
    XCTAssert([aliceSessionRecord.sessionState.senderChainKey.key isEqualToData:aliceSendingChainKeyData]);
    XCTAssert([aliceSendingCipherKeyData
        isEqualToData:aliceSessionRecord.sessionState.senderChainKey.throws_messageKeys.cipherKey]);
    XCTAssert(
        [aliceSendingIVKeyData isEqualToData:aliceSessionRecord.sessionState.senderChainKey.throws_messageKeys.iv]);
    XCTAssert([aliceSendingMacKeyData
        isEqualToData:aliceSessionRecord.sessionState.senderChainKey.throws_messageKeys.macKey]);

    [aliceStore storeSession:bobIdentifier deviceId:1 session:aliceSessionRecord protocolContext:nil];
    SessionCipher *aliceSessionCipher = [[SessionCipher alloc] initWithAxolotlStore:aliceStore recipientId:bobIdentifier deviceId:1];

    WhisperMessage *message = [aliceSessionCipher throws_encryptMessage:alicePlaintextData protocolContext:nil];
    XCTAssert([aliceCipherTextData isEqualToData:message.cipherText]);
    
    // Logging's Bob's Session initialization and first message decryption
    
    XCTAssert([bobRootKeyData isEqualToData:bobSessionRecord.sessionState.rootKey.keyData]);
        
    [bobStore storeSession:aliceIdentifier deviceId:1 session:bobSessionRecord protocolContext:nil];
    
    SessionCipher *bobSessionCipher = [[SessionCipher alloc] initWithAxolotlStore:bobStore recipientId:aliceIdentifier deviceId:1];

    NSData *plainData = [bobSessionCipher throws_decrypt:message protocolContext:nil];

    XCTAssert([plainData isEqualToData:alicePlaintextData]);
    
    for (int i = 0; i<100; i++) {
        NSData *message = [[NSString stringWithFormat:@"Message: %i", i] dataUsingEncoding:NSUTF8StringEncoding];

        WhisperMessage *encrypted = [aliceSessionCipher throws_encryptMessage:message protocolContext:nil];

        XCTAssert([message isEqualToData:[bobSessionCipher throws_decrypt:encrypted protocolContext:nil]]);
    }
    
    for (int i = 0; i<100; i++) {
        NSData *message = [[NSString stringWithFormat:@"Message: %i", i] dataUsingEncoding:NSUTF8StringEncoding];

        WhisperMessage *encrypted = [bobSessionCipher throws_encryptMessage:message protocolContext:nil];

        XCTAssert([message isEqualToData:[aliceSessionCipher throws_decrypt:encrypted protocolContext:nil]]);
    }

    NSMutableArray *plainTexts      = [NSMutableArray new];
    NSMutableArray *cipherMessages = [NSMutableArray new];
    
    for (int i = 0 ; i < 100; i++) {
        NSData *message = [[NSString stringWithFormat:@"Message: %i", i] dataUsingEncoding:NSUTF8StringEncoding];
        [plainTexts addObject:message];
        [cipherMessages addObject:[bobSessionCipher throws_encryptMessage:message protocolContext:nil]];
    }
    
    for (int i = 0; i < plainTexts.count; i++) {
        XCTAssert([[aliceSessionCipher throws_decrypt:[cipherMessages objectAtIndex:i] protocolContext:nil]
            isEqualToData:[plainTexts objectAtIndex:i]]);
    }
    
}

- (void)testOutOfOrderReceives {
    
    Byte aliceIdentityPrivateKey [] = {(Byte) 0x58, (Byte) 0x20, (Byte) 0xD9, (Byte) 0x2B,
        (Byte) 0xBF, (Byte) 0x3E, (Byte) 0x74, (Byte) 0x80,
        (Byte) 0x68, (Byte) 0x01, (Byte) 0x94, (Byte) 0x90,
        (Byte) 0xC3, (Byte) 0xAA, (Byte) 0x94, (Byte) 0x50,
        (Byte) 0x21, (Byte) 0xFA, (Byte) 0xA6, (Byte) 0xD2,
        (Byte) 0x43, (Byte) 0xE4, (Byte) 0x86, (Byte) 0x49,
        (Byte) 0xF6, (Byte) 0x6B, (Byte) 0xD6, (Byte) 0xA4,
        (Byte) 0x45, (Byte) 0x99, (Byte) 0x17, (Byte) 0x63};
    NSData *aliceIdentityPrivateKeyData =  [NSData dataWithBytes:aliceIdentityPrivateKey length:32];
    
    Byte aliceIdentityPublicKey [] = {(Byte) 0x05, (Byte) 0x6F, (Byte) 0xEC, (Byte) 0xDE,
        (Byte) 0xE2, (Byte) 0x7F, (Byte) 0x67, (Byte) 0x36,
        (Byte) 0xA7, (Byte) 0xC6, (Byte) 0xA2, (Byte) 0x77,
        (Byte) 0x9C, (Byte) 0x5A, (Byte) 0xDC, (Byte) 0x26,
        (Byte) 0x35, (Byte) 0x22, (Byte) 0x2A, (Byte) 0xBB,
        (Byte) 0x26, (Byte) 0x01, (Byte) 0xCB, (Byte) 0x93,
        (Byte) 0x7B, (Byte) 0xA9, (Byte) 0x0F, (Byte) 0xD8,
        (Byte) 0x6E, (Byte) 0x56, (Byte) 0x2C, (Byte) 0x76,
        (Byte) 0x1C};
    NSData *aliceIdentityPublicKeyData =  [NSData dataWithBytes:aliceIdentityPublicKey length:33];
    
    Byte aliceBasePublicKey [] = {(Byte) 0x05, (Byte) 0x7B, (Byte) 0xB2, (Byte) 0x6A,
        (Byte) 0xAF, (Byte) 0x25, (Byte) 0x3C, (Byte) 0x7C,
        (Byte) 0x2F, (Byte) 0xFB, (Byte) 0x99, (Byte) 0x42,
        (Byte) 0xED, (Byte) 0x5F, (Byte) 0xDA, (Byte) 0x93,
        (Byte) 0x77, (Byte) 0xF5, (Byte) 0xD2, (Byte) 0x3E,
        (Byte) 0x25, (Byte) 0x95, (Byte) 0x67, (Byte) 0x5D,
        (Byte) 0x62, (Byte) 0x14, (Byte) 0xBB, (Byte) 0x3B,
        (Byte) 0x40, (Byte) 0xC7, (Byte) 0xBE, (Byte) 0xAC,
        (Byte) 0x56};
    NSData *aliceBasePublicKeyData =  [NSData dataWithBytes:aliceBasePublicKey length:33];
    
    Byte aliceBasePrivateKey [] = {(Byte) 0x28, (Byte) 0xD3, (Byte) 0x04, (Byte) 0xA2,
        (Byte) 0xEB, (Byte) 0x00, (Byte) 0xFB, (Byte) 0x63,
        (Byte) 0xF8, (Byte) 0x5E, (Byte) 0x6D, (Byte) 0x4C,
        (Byte) 0xEF, (Byte) 0xC6, (Byte) 0xBF, (Byte) 0x13,
        (Byte) 0x1B, (Byte) 0x5E, (Byte) 0xE5, (Byte) 0x62,
        (Byte) 0xB4, (Byte) 0x6B, (Byte) 0xD5, (Byte) 0x2C,
        (Byte) 0xCB, (Byte) 0x52, (Byte) 0x8A, (Byte) 0x84,
        (Byte) 0x61, (Byte) 0xDD, (Byte) 0xC3, (Byte) 0x65};
    NSData *aliceBasePrivateKeyData =  [NSData dataWithBytes:aliceBasePrivateKey length:32];
    
    Byte bobIdentityPublicKey [] = {(Byte) 0x05, (Byte) 0x01, (Byte) 0x6A, (Byte) 0x60,
        (Byte) 0xFC, (Byte) 0xCF, (Byte) 0x33, (Byte) 0xB6,
        (Byte) 0xF0, (Byte) 0x9A, (Byte) 0x1E, (Byte) 0x9B,
        (Byte) 0x54, (Byte) 0x77, (Byte) 0x78, (Byte) 0x42,
        (Byte) 0xDD, (Byte) 0xE6, (Byte) 0xC4, (Byte) 0xF6,
        (Byte) 0x30, (Byte) 0xAE, (Byte) 0x35, (Byte) 0x95,
        (Byte) 0x67, (Byte) 0xB3, (Byte) 0x74, (Byte) 0x20,
        (Byte) 0xCF, (Byte) 0x2D, (Byte) 0x93, (Byte) 0xF1,
        (Byte) 0x45};
    NSData *bobIdentityPublicKeyData =  [NSData dataWithBytes:bobIdentityPublicKey length:33];
    
    Byte bobIdentityPrivateKey [] = {(Byte) 0xC8, (Byte) 0xF3, (Byte) 0xA6, (Byte) 0x39,
        (Byte) 0x34, (Byte) 0xCE, (Byte) 0xDE, (Byte) 0xEE,
        (Byte) 0x37, (Byte) 0x07, (Byte) 0xFF, (Byte) 0x79,
        (Byte) 0x71, (Byte) 0x05, (Byte) 0x0D, (Byte) 0x58,
        (Byte) 0x3B, (Byte) 0x63, (Byte) 0x7D, (Byte) 0xD2,
        (Byte) 0x21, (Byte) 0x15, (Byte) 0xE3, (Byte) 0xFD,
        (Byte) 0x2B, (Byte) 0x1D, (Byte) 0x41, (Byte) 0x22,
        (Byte) 0x2C, (Byte) 0x29, (Byte) 0x24, (Byte) 0x65};
    NSData *bobIdentityPrivateKeyData =  [NSData dataWithBytes:bobIdentityPrivateKey length:32];
    
    Byte bobBasePrivateKey [] = {(Byte) 0x70, (Byte) 0xCC, (Byte) 0x77, (Byte) 0x0A,
        (Byte) 0x82, (Byte) 0x74, (Byte) 0x70, (Byte) 0x99,
        (Byte) 0xB7, (Byte) 0xCC, (Byte) 0x05, (Byte) 0xCC,
        (Byte) 0x69, (Byte) 0x73, (Byte) 0x58, (Byte) 0x78,
        (Byte) 0x41, (Byte) 0x3E, (Byte) 0xCF, (Byte) 0xEE,
        (Byte) 0xFE, (Byte) 0x85, (Byte) 0xB5, (Byte) 0xF7,
        (Byte) 0x14, (Byte) 0xFF, (Byte) 0x85, (Byte) 0x36,
        (Byte) 0x8C, (Byte) 0x98, (Byte) 0x70, (Byte) 0x52};
    NSData *bobBasePrivateKeyData =  [NSData dataWithBytes:bobBasePrivateKey length:32];
    
    Byte bobBasePublicKey [] = {(Byte) 0x05, (Byte) 0x18, (Byte) 0x3A, (Byte) 0x6E,
        (Byte) 0xC2, (Byte) 0xC7, (Byte) 0x4A, (Byte) 0x21,
        (Byte) 0xF3, (Byte) 0xDE, (Byte) 0xB3, (Byte) 0x70,
        (Byte) 0x4C, (Byte) 0x3D, (Byte) 0x32, (Byte) 0x45,
        (Byte) 0xE0, (Byte) 0xA5, (Byte) 0xD5, (Byte) 0x5F,
        (Byte) 0xDC, (Byte) 0xC9, (Byte) 0x9A, (Byte) 0x26,
        (Byte) 0x9D, (Byte) 0x64, (Byte) 0x68, (Byte) 0xA6,
        (Byte) 0x7C, (Byte) 0xAE, (Byte) 0xEF, (Byte) 0x59,
        (Byte) 0x12};
    NSData *bobBasePublicKeyData =  [NSData dataWithBytes:bobBasePublicKey length:33];
    
    Byte bobPreKeyPrivateKey [] = {(Byte) 0x78, (Byte) 0x0D, (Byte) 0x5D, (Byte) 0x26,
        (Byte) 0xF7, (Byte) 0x6A, (Byte) 0x24, (Byte) 0xAD,
        (Byte) 0x65, (Byte) 0x9C, (Byte) 0xF5, (Byte) 0xCE,
        (Byte) 0xD5, (Byte) 0x2B, (Byte) 0x0E, (Byte) 0x5C,
        (Byte) 0xEA, (Byte) 0x3D, (Byte) 0x42, (Byte) 0xA2,
        (Byte) 0x05, (Byte) 0x40, (Byte) 0xE0, (Byte) 0xD8,
        (Byte) 0x45, (Byte) 0xDF, (Byte) 0xA2, (Byte) 0xF0,
        (Byte) 0x78, (Byte) 0x1E, (Byte) 0xBA, (Byte) 0x42};
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    NSData *bobPreKeyPrivateKeyData =  [NSData dataWithBytes:bobPreKeyPrivateKey length:32];
#pragma clang diagnostic pop
    
    Byte bobPreKeyPublicKey [] = {(Byte) 0x05, (Byte) 0x52, (Byte) 0x02, (Byte) 0xA7,
        (Byte) 0xDE, (Byte) 0x5D, (Byte) 0x6C, (Byte) 0x23,
        (Byte) 0x87, (Byte) 0x6D, (Byte) 0x43, (Byte) 0x24,
        (Byte) 0x3D, (Byte) 0x75, (Byte) 0x68, (Byte) 0xAE,
        (Byte) 0x27, (Byte) 0x3B, (Byte) 0x27, (Byte) 0x76,
        (Byte) 0x4B, (Byte) 0x01, (Byte) 0xCE, (Byte) 0x15,
        (Byte) 0xDF, (Byte) 0x51, (Byte) 0x38, (Byte) 0xA5,
        (Byte) 0xFC, (Byte) 0xD9, (Byte) 0xB6, (Byte) 0xC8,
        (Byte) 0x44};
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    NSData *bobPreKeyPublicKeyData =  [NSData dataWithBytes:bobPreKeyPublicKey length:33];
#pragma clang diagnostic pop
    
    Byte aliceSendingRatchetPrivate [] = {(Byte) 0x98, (Byte) 0x04, (Byte) 0x0B, (Byte) 0xAE,
        (Byte) 0x6B, (Byte) 0x3D, (Byte) 0x02, (Byte) 0x9C,
        (Byte) 0xF1, (Byte) 0x25, (Byte) 0xDC, (Byte) 0x8E,
        (Byte) 0xD8, (Byte) 0x07, (Byte) 0xCE, (Byte) 0x33,
        (Byte) 0xFC, (Byte) 0xE0, (Byte) 0x07, (Byte) 0xD8,
        (Byte) 0x2F, (Byte) 0x67, (Byte) 0x6D, (Byte) 0x7B,
        (Byte) 0xC7, (Byte) 0x1A, (Byte) 0x5B, (Byte) 0x91,
        (Byte) 0x3B, (Byte) 0x60, (Byte) 0x3B, (Byte) 0x67};
    NSData *aliceSendingRatchetPrivateData =  [NSData dataWithBytes:aliceSendingRatchetPrivate length:32];
    
    Byte aliceSendingRatchetPublic [] = {(Byte) 0x05, (Byte) 0xB6, (Byte) 0x2A, (Byte) 0xE0,
        (Byte) 0x25, (Byte) 0xB8, (Byte) 0xFF, (Byte) 0xEE,
        (Byte) 0x3A, (Byte) 0xEB, (Byte) 0x01, (Byte) 0x1B,
        (Byte) 0xF7, (Byte) 0x78, (Byte) 0xE6, (Byte) 0x26,
        (Byte) 0x22, (Byte) 0x56, (Byte) 0x17, (Byte) 0x30,
        (Byte) 0x7A, (Byte) 0x95, (Byte) 0x87, (Byte) 0x91,
        (Byte) 0x31, (Byte) 0xD9, (Byte) 0x9D, (Byte) 0x27,
        (Byte) 0x49, (Byte) 0x06, (Byte) 0xEE, (Byte) 0x57,
        (Byte) 0x6A};
    NSData *aliceSendingRatchetPublicData =  [NSData dataWithBytes:aliceSendingRatchetPublic length:33];
    
    Byte aliceRootKey [] = {(Byte) 0xC3, (Byte) 0x5A, (Byte) 0xF1, (Byte) 0x81,
        (Byte) 0xB0, (Byte) 0xBF, (Byte) 0xEA, (Byte) 0xB5,
        (Byte) 0xD9, (Byte) 0x71, (Byte) 0x12, (Byte) 0x20,
        (Byte) 0xC1, (Byte) 0x60, (Byte) 0xD6, (Byte) 0x43,
        (Byte) 0xF6, (Byte) 0xE8, (Byte) 0x1C, (Byte) 0x00,
        (Byte) 0x11, (Byte) 0xBF, (Byte) 0xA1, (Byte) 0xAA,
        (Byte) 0x16, (Byte) 0xAE, (Byte) 0xF3, (Byte) 0x6A,
        (Byte) 0x91, (Byte) 0xCD, (Byte) 0x1A, (Byte) 0x9B};
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    NSData *aliceRootKeyData =  [NSData dataWithBytes:aliceRootKey length:32];
#pragma clang diagnostic pop
    
    Byte aliceSendingChainKey [] = {(Byte) 0x8A, (Byte) 0xA2, (Byte) 0x05, (Byte) 0xEA,
        (Byte) 0x17, (Byte) 0x00, (Byte) 0xC0, (Byte) 0x85,
        (Byte) 0xB6, (Byte) 0x43, (Byte) 0xE9, (Byte) 0x68,
        (Byte) 0x4F, (Byte) 0x6A, (Byte) 0x53, (Byte) 0x74,
        (Byte) 0x88, (Byte) 0xBD, (Byte) 0x9F, (Byte) 0x3E,
        (Byte) 0xA0, (Byte) 0x1D, (Byte) 0x00, (Byte) 0xF9,
        (Byte) 0x58, (Byte) 0x55, (Byte) 0xE1, (Byte) 0x8F,
        (Byte) 0xAB, (Byte) 0x9F, (Byte) 0xBE, (Byte) 0x51};
    NSData *aliceSendingChainKeyData =  [NSData dataWithBytes:aliceSendingChainKey length:32];
    
    Byte aliceSendingCipherKey [] = {(Byte) 0xDD, (Byte) 0x61, (Byte) 0x0E, (Byte) 0xEE,
        (Byte) 0x8F, (Byte) 0x33, (Byte) 0x02, (Byte) 0x25,
        (Byte) 0x63, (Byte) 0x48, (Byte) 0x8A, (Byte) 0xED,
        (Byte) 0xE0, (Byte) 0x94, (Byte) 0xAB, (Byte) 0x6C,
        (Byte) 0x72, (Byte) 0xAF, (Byte) 0x39, (Byte) 0x69,
        (Byte) 0xF7, (Byte) 0xCF, (Byte) 0xA6, (Byte) 0x5F,
        (Byte) 0x09, (Byte) 0x5F, (Byte) 0xEE, (Byte) 0x59,
        (Byte) 0xC4, (Byte) 0xEA, (Byte) 0xE7, (Byte) 0x3D};
    NSData *aliceSendingCipherKeyData =  [NSData dataWithBytes:aliceSendingCipherKey length:32];
    
    Byte aliceSendingIVKey [] = {(Byte) 0xF3, (Byte) 0xF0, (Byte) 0x25, (Byte) 0x58,
        (Byte) 0x43, (Byte) 0xDA, (Byte) 0x3A, (Byte) 0x81,
        (Byte) 0x6C, (Byte) 0x78, (Byte) 0xD7, (Byte) 0x65,
        (Byte) 0xCE, (Byte) 0xBD, (Byte) 0xBA, (Byte) 0x0B};
    NSData *aliceSendingIVKeyData =  [NSData dataWithBytes:aliceSendingIVKey length:16];
    
    Byte aliceSendingMacKey [] = {(Byte) 0xAC, (Byte) 0xC6, (Byte) 0x30, (Byte) 0x4D,
        (Byte) 0xC0, (Byte) 0xCC, (Byte) 0x20, (Byte) 0xE5,
        (Byte) 0x8F, (Byte) 0xCE, (Byte) 0xA4, (Byte) 0x60,
        (Byte) 0xDA, (Byte) 0xC1, (Byte) 0x67, (Byte) 0x55,
        (Byte) 0x4E, (Byte) 0x89, (Byte) 0xA9, (Byte) 0xB2,
        (Byte) 0x5E, (Byte) 0xBD, (Byte) 0xA5, (Byte) 0xA3,
        (Byte) 0xBA, (Byte) 0xBE, (Byte) 0x15, (Byte) 0xCF,
        (Byte) 0x8B, (Byte) 0x71, (Byte) 0xE7, (Byte) 0x9A};
    NSData *aliceSendingMacKeyData =  [NSData dataWithBytes:aliceSendingMacKey length:32];
    
    Byte bobRootKey [] = {(Byte) 0x89, (Byte) 0xF9, (Byte) 0x57, (Byte) 0x60,
        (Byte) 0x37, (Byte) 0xC1, (Byte) 0x07, (Byte) 0x6C,
        (Byte) 0x19, (Byte) 0x22, (Byte) 0x11, (Byte) 0xFB,
        (Byte) 0x22, (Byte) 0x61, (Byte) 0xE4, (Byte) 0xC4,
        (Byte) 0x44, (Byte) 0x58, (Byte) 0x51, (Byte) 0x44,
        (Byte) 0xC2, (Byte) 0x8C, (Byte) 0x1C, (Byte) 0x6E,
        (Byte) 0x7C, (Byte) 0x48, (Byte) 0xB6, (Byte) 0x91,
        (Byte) 0x26, (Byte) 0x9B, (Byte) 0xF2, (Byte) 0xE6};
    NSData *bobRootKeyData =  [NSData dataWithBytes:bobRootKey length:32];
    
    Byte aliceSessionRecordRootKey [] = {(Byte) 0xC3, (Byte) 0x5A, (Byte) 0xF1, (Byte) 0x81,
        (Byte) 0xB0, (Byte) 0xBF, (Byte) 0xEA, (Byte) 0xB5,
        (Byte) 0xD9, (Byte) 0x71, (Byte) 0x12, (Byte) 0x20,
        (Byte) 0xC1, (Byte) 0x60, (Byte) 0xD6, (Byte) 0x43,
        (Byte) 0xF6, (Byte) 0xE8, (Byte) 0x1C, (Byte) 0x00,
        (Byte) 0x11, (Byte) 0xBF, (Byte) 0xA1, (Byte) 0xAA,
        (Byte) 0x16, (Byte) 0xAE, (Byte) 0xF3, (Byte) 0x6A,
        (Byte) 0x91, (Byte) 0xCD, (Byte) 0x1A, (Byte) 0x9B};
    NSData *aliceSessionRecordRootKeyData =  [NSData dataWithBytes:aliceSessionRecordRootKey length:32];
    
    Byte bobSessionRecordRootKey [] = {(Byte) 0x89, (Byte) 0xF9, (Byte) 0x57, (Byte) 0x60,
        (Byte) 0x37, (Byte) 0xC1, (Byte) 0x07, (Byte) 0x6C,
        (Byte) 0x19, (Byte) 0x22, (Byte) 0x11, (Byte) 0xFB,
        (Byte) 0x22, (Byte) 0x61, (Byte) 0xE4, (Byte) 0xC4,
        (Byte) 0x44, (Byte) 0x58, (Byte) 0x51, (Byte) 0x44,
        (Byte) 0xC2, (Byte) 0x8C, (Byte) 0x1C, (Byte) 0x6E,
        (Byte) 0x7C, (Byte) 0x48, (Byte) 0xB6, (Byte) 0x91,
        (Byte) 0x26, (Byte) 0x9B, (Byte) 0xF2, (Byte) 0xE6};
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    NSData *bobSessionRecordRootKeyData =  [NSData dataWithBytes:bobSessionRecordRootKey length:32];
#pragma clang diagnostic pop
    
    Byte alicePlaintext [] = {(Byte) 0x54, (Byte) 0x68, (Byte) 0x69, (Byte) 0x73,
        (Byte) 0x20, (Byte) 0x69, (Byte) 0x73, (Byte) 0x20,
        (Byte) 0x61, (Byte) 0x20, (Byte) 0x70, (Byte) 0x6C,
        (Byte) 0x61, (Byte) 0x69, (Byte) 0x6E, (Byte) 0x74,
        (Byte) 0x65, (Byte) 0x78, (Byte) 0x74, (Byte) 0x20,
        (Byte) 0x6D, (Byte) 0x65, (Byte) 0x73, (Byte) 0x73,
        (Byte) 0x61, (Byte) 0x67, (Byte) 0x65, (Byte) 0x2E};
    NSData *alicePlaintextData =  [NSData dataWithBytes:alicePlaintext length:28];
    
    Byte AliceSerializedWhisperMessage [] = {(Byte) 0x33, (Byte) 0x0A, (Byte) 0x21, (Byte) 0x05,
        (Byte) 0xB6, (Byte) 0x2A, (Byte) 0xE0, (Byte) 0x25,
        (Byte) 0xB8, (Byte) 0xFF, (Byte) 0xEE, (Byte) 0x3A,
        (Byte) 0xEB, (Byte) 0x01, (Byte) 0x1B, (Byte) 0xF7,
        (Byte) 0x78, (Byte) 0xE6, (Byte) 0x26, (Byte) 0x22,
        (Byte) 0x56, (Byte) 0x17, (Byte) 0x30, (Byte) 0x7A,
        (Byte) 0x95, (Byte) 0x87, (Byte) 0x91, (Byte) 0x31,
        (Byte) 0xD9, (Byte) 0x9D, (Byte) 0x27, (Byte) 0x49,
        (Byte) 0x06, (Byte) 0xEE, (Byte) 0x57, (Byte) 0x6A,
        (Byte) 0x10, (Byte) 0x00, (Byte) 0x18, (Byte) 0x00,
        (Byte) 0x22, (Byte) 0x20, (Byte) 0x9E, (Byte) 0xF2,
        (Byte) 0xD0, (Byte) 0xE1, (Byte) 0x30, (Byte) 0x4C,
        (Byte) 0x01, (Byte) 0xE0, (Byte) 0x68, (Byte) 0x7B,
        (Byte) 0x44, (Byte) 0x5A, (Byte) 0x27, (Byte) 0x64,
        (Byte) 0x79, (Byte) 0x51, (Byte) 0xD4, (Byte) 0xC7,
        (Byte) 0x0B, (Byte) 0xF3, (Byte) 0xD3, (Byte) 0xAC,
        (Byte) 0x23, (Byte) 0xA5, (Byte) 0x8D, (Byte) 0xF7,
        (Byte) 0x22, (Byte) 0xDC, (Byte) 0x22, (Byte) 0x76,
        (Byte) 0xC3, (Byte) 0xA6, (Byte) 0x96, (Byte) 0x06,
        (Byte) 0xAB, (Byte) 0xBE, (Byte) 0x2E, (Byte) 0x31,
        (Byte) 0x63, (Byte) 0x88};
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wunused-variable"
    NSData *AliceSerializedWhisperMessageData =  [NSData dataWithBytes:AliceSerializedWhisperMessage length:82];
#pragma clang diagnostic pop
    
    Byte aliceCipherText [] = {(Byte) 0x9E, (Byte) 0xF2, (Byte) 0xD0, (Byte) 0xE1,
        (Byte) 0x30, (Byte) 0x4C, (Byte) 0x01, (Byte) 0xE0,
        (Byte) 0x68, (Byte) 0x7B, (Byte) 0x44, (Byte) 0x5A,
        (Byte) 0x27, (Byte) 0x64, (Byte) 0x79, (Byte) 0x51,
        (Byte) 0xD4, (Byte) 0xC7, (Byte) 0x0B, (Byte) 0xF3,
        (Byte) 0xD3, (Byte) 0xAC, (Byte) 0x23, (Byte) 0xA5,
        (Byte) 0x8D, (Byte) 0xF7, (Byte) 0x22, (Byte) 0xDC,
        (Byte) 0x22, (Byte) 0x76, (Byte) 0xC3, (Byte) 0xA6};
    NSData *aliceCipherTextData =  [NSData dataWithBytes:aliceCipherText length:32];


    ECKeyPair *aliceIdentityKey =
        [ECKeyPair throws_keyPairWithPrivateKey:aliceIdentityPrivateKeyData publicKey:aliceIdentityPublicKeyData];

    ECKeyPair *bobIdentityKey =
        [ECKeyPair throws_keyPairWithPrivateKey:bobIdentityPrivateKeyData publicKey:bobIdentityPublicKeyData];

    ECKeyPair *aliceBaseKey =
        [ECKeyPair throws_keyPairWithPrivateKey:aliceBasePrivateKeyData publicKey:aliceBasePublicKeyData];

    ECKeyPair *bobBaseKey =
        [ECKeyPair throws_keyPairWithPrivateKey:bobBasePrivateKeyData publicKey:bobBasePublicKeyData];

    ECKeyPair *aliceSendingRatchet =
        [ECKeyPair throws_keyPairWithPrivateKey:aliceSendingRatchetPrivateData publicKey:aliceSendingRatchetPublicData];

    // ---
    
    SPKMockProtocolStore *aliceStore = [SPKMockProtocolStore new];
    SPKMockProtocolStore *bobStore = [SPKMockProtocolStore new];
    
    SessionRecord *aliceSessionRecord = [SessionRecord new];
    SessionRecord *bobSessionRecord   = [SessionRecord new];
    
    AliceAxolotlParameters *aliceAxolotlParams = [[AliceAxolotlParameters alloc] initWithIdentityKey:aliceIdentityKey theirIdentityKey:bobIdentityKey.publicKey ourBaseKey:aliceBaseKey theirSignedPreKey:bobBaseKey.publicKey theirOneTimePreKey:nil theirRatchetKey:bobBaseKey.publicKey];
    
    BobAxolotlParameters   *bobAxolotlParams   = [[BobAxolotlParameters alloc] initWithMyIdentityKeyPair:bobIdentityKey theirIdentityKey:aliceIdentityKey.publicKey ourSignedPrekey:bobBaseKey ourRatchetKey:bobBaseKey ourOneTimePrekey:nil theirBaseKey:aliceBaseKey.publicKey];

    [RatchetingSession throws_initializeSession:aliceSessionRecord.sessionState
                                 sessionVersion:3
                                AliceParameters:aliceAxolotlParams
                                  senderRatchet:aliceSendingRatchet];

    [RatchetingSession throws_initializeSession:bobSessionRecord.sessionState
                                 sessionVersion:3
                                  BobParameters:bobAxolotlParams];

    NSString *aliceIdentifier = @"+483294823482";
    NSString *bobIdentifier = @"+389424728942";
    
    // Logging Alice's Session initialization and first message encryption
    XCTAssert([[@"This is a plaintext message." dataUsingEncoding:NSUTF8StringEncoding] isEqualToData:alicePlaintextData], @"Encoding is not correct");
    XCTAssert([aliceSessionRecord.sessionState.rootKey.keyData isEqualToData:aliceSessionRecordRootKeyData]);
    XCTAssert([aliceSessionRecord.sessionState.senderChainKey.key isEqualToData:aliceSendingChainKeyData]);
    XCTAssert([aliceSendingCipherKeyData
        isEqualToData:aliceSessionRecord.sessionState.senderChainKey.throws_messageKeys.cipherKey]);
    XCTAssert(
        [aliceSendingIVKeyData isEqualToData:aliceSessionRecord.sessionState.senderChainKey.throws_messageKeys.iv]);
    XCTAssert([aliceSendingMacKeyData
        isEqualToData:aliceSessionRecord.sessionState.senderChainKey.throws_messageKeys.macKey]);

    [aliceStore storeSession:bobIdentifier deviceId:1 session:aliceSessionRecord protocolContext:nil];
    SessionCipher *aliceSessionCipher = [[SessionCipher alloc] initWithAxolotlStore:aliceStore recipientId:bobIdentifier deviceId:1];

    WhisperMessage *message = [aliceSessionCipher throws_encryptMessage:alicePlaintextData protocolContext:nil];
    XCTAssert([aliceCipherTextData isEqualToData:message.cipherText]);
    
    // Logging's Bob's Session initialization and first message decryption
    
    XCTAssert([bobRootKeyData isEqualToData:bobSessionRecord.sessionState.rootKey.keyData]);
    
    [bobStore storeSession:aliceIdentifier deviceId:1 session:bobSessionRecord protocolContext:nil];
    
    SessionCipher *bobSessionCipher = [[SessionCipher alloc] initWithAxolotlStore:bobStore recipientId:aliceIdentifier deviceId:1];

    NSData *plainData = [bobSessionCipher throws_decrypt:message protocolContext:nil];

    XCTAssert([plainData isEqualToData:alicePlaintextData]);
    
    
    NSMutableArray *plainTexts      = [NSMutableArray new];
    NSMutableArray *cipherMessages = [NSMutableArray new];
    
    for (int i = 0 ; i < 30; i++) {
        NSData *message = [[NSString stringWithFormat:@"Message: %i", i] dataUsingEncoding:NSUTF8StringEncoding];
        [plainTexts addObject:message];
        [cipherMessages addObject:[bobSessionCipher throws_encryptMessage:message protocolContext:nil]];
    }
    
    for (NSUInteger i = plainTexts.count-1; i > 0; i--) {
        XCTAssert([[aliceSessionCipher throws_decrypt:[cipherMessages objectAtIndex:i] protocolContext:nil]
            isEqualToData:[plainTexts objectAtIndex:i]]);
    }
    
}

@end

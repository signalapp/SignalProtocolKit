//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
//

#import "ECKeyPair+ECKeyPairTesting.h"
#import <Curve25519Kit/Curve25519.h>
#import <Curve25519Kit/Ed25519.h>
#import <XCTest/XCTest.h>

@interface ECCTests : XCTestCase

@end

@implementation ECCTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testKeyAgreement{
    
    Byte alicePublicBytes[] = {(Byte) 0x05, (Byte) 0x1b, (Byte) 0xb7, (Byte) 0x59, (Byte) 0x66,
        (Byte) 0xf2, (Byte) 0xe9, (Byte) 0x3a, (Byte) 0x36, (Byte) 0x91,
        (Byte) 0xdf, (Byte) 0xff, (Byte) 0x94, (Byte) 0x2b, (Byte) 0xb2,
        (Byte) 0xa4, (Byte) 0x66, (Byte) 0xa1, (Byte) 0xc0, (Byte) 0x8b,
        (Byte) 0x8d, (Byte) 0x78, (Byte) 0xca, (Byte) 0x3f, (Byte) 0x4d,
        (Byte) 0x6d, (Byte) 0xf8, (Byte) 0xb8, (Byte) 0xbf, (Byte) 0xa2,
        (Byte) 0xe4, (Byte) 0xee, (Byte) 0x28};
    
    NSData *alicePublicKey = [NSData dataWithBytes:alicePublicBytes length:33];
    
    Byte alicePrivateBytes [] = {(Byte) 0xc8, (Byte) 0x06, (Byte) 0x43, (Byte) 0x9d, (Byte) 0xc9,
        (Byte) 0xd2, (Byte) 0xc4, (Byte) 0x76, (Byte) 0xff, (Byte) 0xed,
        (Byte) 0x8f, (Byte) 0x25, (Byte) 0x80, (Byte) 0xc0, (Byte) 0x88,
        (Byte) 0x8d, (Byte) 0x58, (Byte) 0xab, (Byte) 0x40, (Byte) 0x6b,
        (Byte) 0xf7, (Byte) 0xae, (Byte) 0x36, (Byte) 0x98, (Byte) 0x87,
        (Byte) 0x90, (Byte) 0x21, (Byte) 0xb9, (Byte) 0x6b, (Byte) 0xb4,
        (Byte) 0xbf, (Byte) 0x59};
    
    NSData *alicePrivateKey = [NSData dataWithBytes:alicePrivateBytes length:ECCKeyLength];
    
    Byte bobPublicBytes [] = {(Byte) 0x05, (Byte) 0x65, (Byte) 0x36, (Byte) 0x14, (Byte) 0x99,
        (Byte) 0x3d, (Byte) 0x2b, (Byte) 0x15, (Byte) 0xee, (Byte) 0x9e,
        (Byte) 0x5f, (Byte) 0xd3, (Byte) 0xd8, (Byte) 0x6c, (Byte) 0xe7,
        (Byte) 0x19, (Byte) 0xef, (Byte) 0x4e, (Byte) 0xc1, (Byte) 0xda,
        (Byte) 0xae, (Byte) 0x18, (Byte) 0x86, (Byte) 0xa8, (Byte) 0x7b,
        (Byte) 0x3f, (Byte) 0x5f, (Byte) 0xa9, (Byte) 0x56, (Byte) 0x5a,
        (Byte) 0x27, (Byte) 0xa2, (Byte) 0x2f};
    
    NSData *bobPublicKey = [NSData dataWithBytes:bobPublicBytes length:33];
    
    Byte bobPrivateBytes [] = {(Byte) 0xb0, (Byte) 0x3b, (Byte) 0x34, (Byte) 0xc3, (Byte) 0x3a,
        (Byte) 0x1c, (Byte) 0x44, (Byte) 0xf2, (Byte) 0x25, (Byte) 0xb6,
        (Byte) 0x62, (Byte) 0xd2, (Byte) 0xbf, (Byte) 0x48, (Byte) 0x59,
        (Byte) 0xb8, (Byte) 0x13, (Byte) 0x54, (Byte) 0x11, (Byte) 0xfa,
        (Byte) 0x7b, (Byte) 0x03, (Byte) 0x86, (Byte) 0xd4, (Byte) 0x5f,
        (Byte) 0xb7, (Byte) 0x5d, (Byte) 0xc5, (Byte) 0xb9, (Byte) 0x1b,
        (Byte) 0x44, (Byte) 0x66};
    
    NSData *bobPrivateKey = [NSData dataWithBytes:bobPrivateBytes length:ECCKeyLength];
    
    Byte sharedBytes []      = {(Byte) 0x32, (Byte) 0x5f, (Byte) 0x23, (Byte) 0x93, (Byte) 0x28,
        (Byte) 0x94, (Byte) 0x1c, (Byte) 0xed, (Byte) 0x6e, (Byte) 0x67,
        (Byte) 0x3b, (Byte) 0x86, (Byte) 0xba, (Byte) 0x41, (Byte) 0x01,
        (Byte) 0x74, (Byte) 0x48, (Byte) 0xe9, (Byte) 0x9b, (Byte) 0x64,
        (Byte) 0x9a, (Byte) 0x9c, (Byte) 0x38, (Byte) 0x06, (Byte) 0xc1,
        (Byte) 0xdd, (Byte) 0x7c, (Byte) 0xa4, (Byte) 0xc4, (Byte) 0x77,
        (Byte) 0xe6, (Byte) 0x29};
    
    NSData *sharedSecret = [NSData dataWithBytes:sharedBytes length:32];

    ECKeyPair *aliceKeyPair = [ECKeyPair throws_keyPairWithPrivateKey:alicePrivateKey publicKey:alicePublicKey];
    ECKeyPair *bobKeyPair = [ECKeyPair throws_keyPairWithPrivateKey:bobPrivateKey publicKey:bobPublicKey];

    NSData *aliceShared =
        [Curve25519 throws_generateSharedSecretFromPublicKey:[bobKeyPair publicKey] andKeyPair:aliceKeyPair];
    NSData *bobShared =
        [Curve25519 throws_generateSharedSecretFromPublicKey:[aliceKeyPair publicKey] andKeyPair:bobKeyPair];

    XCTAssert([aliceShared isEqualToData:sharedSecret], @"Alice's shared secret is equal to the expected one.");
    XCTAssert([bobShared   isEqualToData:sharedSecret], @"Bob's shared secret is equal to the expected one.");
}

- (void)testRandomKeyAgreements{
    for (int i=0;i<100;i++) {
        ECKeyPair *aliceKeyPair       = [Curve25519 generateKeyPair];
        ECKeyPair *bobKeyPair         = [Curve25519 generateKeyPair];

        XCTAssert([[Curve25519 throws_generateSharedSecretFromPublicKey:[aliceKeyPair publicKey] andKeyPair:bobKeyPair]
                      isEqualToData:[Curve25519 throws_generateSharedSecretFromPublicKey:[bobKeyPair publicKey]
                                                                              andKeyPair:aliceKeyPair]],
            @"Randomly generated keypairs produce same shared secret.");
    }
}

- (void)testSignatures{
    __unused Byte aliceIdentityPrivate [] = {(Byte)0xc0, (Byte)0x97, (Byte)0x24, (Byte)0x84, (Byte)0x12,
        (Byte)0xe5, (Byte)0x8b, (Byte)0xf0, (Byte)0x5d, (Byte)0xf4,
        (Byte)0x87, (Byte)0x96, (Byte)0x82, (Byte)0x05, (Byte)0x13,
        (Byte)0x27, (Byte)0x94, (Byte)0x17, (Byte)0x8e, (Byte)0x36,
        (Byte)0x76, (Byte)0x37, (Byte)0xf5, (Byte)0x81, (Byte)0x8f,
        (Byte)0x81, (Byte)0xe0, (Byte)0xe6, (Byte)0xce, (Byte)0x73,
        (Byte)0xe8, (Byte)0x65};
    
    Byte aliceIdentityPublic  [] = {(Byte)0x05, (Byte)0xab, (Byte)0x7e, (Byte)0x71, (Byte)0x7d,
        (Byte)0x4a, (Byte)0x16, (Byte)0x3b, (Byte)0x7d, (Byte)0x9a,
        (Byte)0x1d, (Byte)0x80, (Byte)0x71, (Byte)0xdf, (Byte)0xe9,
        (Byte)0xdc, (Byte)0xf8, (Byte)0xcd, (Byte)0xcd, (Byte)0x1c,
        (Byte)0xea, (Byte)0x33, (Byte)0x39, (Byte)0xb6, (Byte)0x35,
        (Byte)0x6b, (Byte)0xe8, (Byte)0x4d, (Byte)0x88, (Byte)0x7e,
        (Byte)0x32, (Byte)0x2c, (Byte)0x64};
    
    Byte aliceEphemeralPublic [] = {(Byte)0x05, (Byte)0xed, (Byte)0xce, (Byte)0x9d, (Byte)0x9c,
        (Byte)0x41, (Byte)0x5c, (Byte)0xa7, (Byte)0x8c, (Byte)0xb7,
        (Byte)0x25, (Byte)0x2e, (Byte)0x72, (Byte)0xc2, (Byte)0xc4,
        (Byte)0xa5, (Byte)0x54, (Byte)0xd3, (Byte)0xeb, (Byte)0x29,
        (Byte)0x48, (Byte)0x5a, (Byte)0x0e, (Byte)0x1d, (Byte)0x50,
        (Byte)0x31, (Byte)0x18, (Byte)0xd1, (Byte)0xa8, (Byte)0x2d,
        (Byte)0x99, (Byte)0xfb, (Byte)0x4a};
    
    Byte aliceSignature       [] = {(Byte)0x5d, (Byte)0xe8, (Byte)0x8c, (Byte)0xa9, (Byte)0xa8,
        (Byte)0x9b, (Byte)0x4a, (Byte)0x11, (Byte)0x5d, (Byte)0xa7,
        (Byte)0x91, (Byte)0x09, (Byte)0xc6, (Byte)0x7c, (Byte)0x9c,
        (Byte)0x74, (Byte)0x64, (Byte)0xa3, (Byte)0xe4, (Byte)0x18,
        (Byte)0x02, (Byte)0x74, (Byte)0xf1, (Byte)0xcb, (Byte)0x8c,
        (Byte)0x63, (Byte)0xc2, (Byte)0x98, (Byte)0x4e, (Byte)0x28,
        (Byte)0x6d, (Byte)0xfb, (Byte)0xed, (Byte)0xe8, (Byte)0x2d,
        (Byte)0xeb, (Byte)0x9d, (Byte)0xcd, (Byte)0x9f, (Byte)0xae,
        (Byte)0x0b, (Byte)0xfb, (Byte)0xb8, (Byte)0x21, (Byte)0x56,
        (Byte)0x9b, (Byte)0x3d, (Byte)0x90, (Byte)0x01, (Byte)0xbd,
        (Byte)0x81, (Byte)0x30, (Byte)0xcd, (Byte)0x11, (Byte)0xd4,
        (Byte)0x86, (Byte)0xce, (Byte)0xf0, (Byte)0x47, (Byte)0xbd,
        (Byte)0x60, (Byte)0xb8, (Byte)0x6e, (Byte)0x88};
    
    
    NSData *alicePublic  = [NSData dataWithBytes:aliceIdentityPublic length:33];
    alicePublic = [alicePublic subdataWithRange:NSMakeRange(1, 32)];
    NSData *ephemPublic  = [NSData dataWithBytes:aliceEphemeralPublic length:33];
    
    NSData *signature    = [NSData dataWithBytes:aliceSignature length:ECCSignatureLength];

    if (![Ed25519 throws_verifySignature:signature publicKey:alicePublic data:ephemPublic]) {
        XCTAssert(NO, @"Sig verification failed!");
    }

    for (int i=0;i<[signature length];i++) {
        
        NSMutableData *modifiedSignature = [signature mutableCopy];
        
        Byte replacedByte;
        
        [modifiedSignature getBytes:&replacedByte range:NSMakeRange(i, 1)];
        
        replacedByte ^= 0x01;
        
        [modifiedSignature replaceBytesInRange:NSMakeRange(i, 1) withBytes:&replacedByte length:1];

        if ([Ed25519 throws_verifySignature:modifiedSignature publicKey:alicePublic data:ephemPublic]) {
            XCTAssert(NO, @"Modified signature shouldn't be verified correctly");
        }
    }

}

@end

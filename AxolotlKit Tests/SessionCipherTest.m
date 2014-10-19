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
    
    [self runInteractionWithAliceRecord:aliceSess bobRecord:<#(SessionRecord *)#>];
}

- (void)runInteractionWithAliceRecord:(SessionRecord*)aliceSessionRecord bobRecord:(SessionRecord*)bobSessionRecord {
    
    AxolotlInMemoryStore *aliceStore  = [AxolotlInMemoryStore new];
    AxolotlInMemoryStore *bobStore    = [AxolotlInMemoryStore new];
    
    [aliceStore storeSession:2L deviceId:1 session:aliceSessionRecord];
    [bobStore   storeSession:3L deviceId:1 session:bobSessionRecord];
    
    SessionCipher *aliceSessionCipher = [[SessionCipher alloc] initWithAxolotlStore:aliceStore recipientId:2L deviceId:1];
    SessionCipher *bobSessionCipher   = [[SessionCipher alloc] initWithAxolotlStore:bobStore recipientId:3L deviceId:1];
    
    NSData *alicePlainText = @"";
    
    
    AxolotlStore aliceStore = new InMemoryAxolotlStore();
    AxolotlStore bobStore   = new InMemoryAxolotlStore();
    
    aliceStore.storeSession(2L, 1, aliceSessionRecord);
    bobStore.storeSession(3L, 1, bobSessionRecord);
    
    SessionCipher     aliceCipher    = new SessionCipher(aliceStore, 2L, 1);
    SessionCipher     bobCipher      = new SessionCipher(bobStore, 3L, 1);
    
    byte[]            alicePlaintext = "This is a plaintext message.".getBytes();
    CiphertextMessage message        = aliceCipher.encrypt(alicePlaintext);
    byte[]            bobPlaintext   = bobCipher.decrypt(new WhisperMessage(message.serialize()));
    
    assertTrue(Arrays.equals(alicePlaintext, bobPlaintext));
    
    byte[]            bobReply      = "This is a message from Bob.".getBytes();
    CiphertextMessage reply         = bobCipher.encrypt(bobReply);
    byte[]            receivedReply = aliceCipher.decrypt(new WhisperMessage(reply.serialize()));
    
    assertTrue(Arrays.equals(bobReply, receivedReply));
    
    List<CiphertextMessage> aliceCiphertextMessages = new ArrayList<>();
    List<byte[]>            alicePlaintextMessages  = new ArrayList<>();
    
    for (int i=0;i<50;i++) {
        alicePlaintextMessages.add(("смерть за смерть " + i).getBytes());
        aliceCiphertextMessages.add(aliceCipher.encrypt(("смерть за смерть " + i).getBytes()));
    }
    
    long seed = System.currentTimeMillis();
    
    Collections.shuffle(aliceCiphertextMessages, new Random(seed));
    Collections.shuffle(alicePlaintextMessages, new Random(seed));
    
    for (int i=0;i<aliceCiphertextMessages.size() / 2;i++) {
        byte[] receivedPlaintext = bobCipher.decrypt(new WhisperMessage(aliceCiphertextMessages.get(i).serialize()));
        assertTrue(Arrays.equals(receivedPlaintext, alicePlaintextMessages.get(i)));
    }
    
    List<CiphertextMessage> bobCiphertextMessages = new ArrayList<>();
    List<byte[]>            bobPlaintextMessages  = new ArrayList<>();
    
    for (int i=0;i<20;i++) {
        bobPlaintextMessages.add(("смерть за смерть " + i).getBytes());
        bobCiphertextMessages.add(bobCipher.encrypt(("смерть за смерть " + i).getBytes()));
    }
    
    seed = System.currentTimeMillis();
    
    Collections.shuffle(bobCiphertextMessages, new Random(seed));
    Collections.shuffle(bobPlaintextMessages, new Random(seed));
    
    for (int i=0;i<bobCiphertextMessages.size() / 2;i++) {
        byte[] receivedPlaintext = aliceCipher.decrypt(new WhisperMessage(bobCiphertextMessages.get(i).serialize()));
        assertTrue(Arrays.equals(receivedPlaintext, bobPlaintextMessages.get(i)));
    }
    
    for (int i=aliceCiphertextMessages.size()/2;i<aliceCiphertextMessages.size();i++) {
        byte[] receivedPlaintext = bobCipher.decrypt(new WhisperMessage(aliceCiphertextMessages.get(i).serialize()));
        assertTrue(Arrays.equals(receivedPlaintext, alicePlaintextMessages.get(i)));
    }
    
    for (int i=bobCiphertextMessages.size() / 2;i<bobCiphertextMessages.size();i++) {
        byte[] receivedPlaintext = aliceCipher.decrypt(new WhisperMessage(bobCiphertextMessages.get(i).serialize()));
        assertTrue(Arrays.equals(receivedPlaintext, bobPlaintextMessages.get(i)));
    }
    
    new SessionBuilder(sessionStore, preKeyStore, signedPreKeyStore,
                                                       identityStore, recipientId, deviceId);
    
    
    
    
    
}

@end

//
//  SessionState.m
//  AxolotlKit
//
//  Created by Frederic Jacobs on 01/03/14.
//  Copyright (c) 2014 Open Whisper Systems. All rights reserved.
//

#import <25519/Curve25519.h>
#import "SessionState.h"
#import "ReceivingChain.h"
#import "SendingChain.h"
#import "ChainAndIndex.h"


/**
 *  Pending PreKeys
 */

@interface PendingPreKey : NSObject

@property (readonly) int preKeyId;
@property (readonly) int signedPreKeyId;
@property (readonly) NSData *baseKey;

-(instancetype)initWithBaseKey:(NSData*)baseKey preKeyId:(int)preKeyId signedPreKeyId:(int)signedPrekeyId;

@end

@implementation PendingPreKey

-(instancetype)initWithBaseKey:(NSData*)baseKey preKeyId:(int)preKeyId signedPreKeyId:(int)signedPrekeyId{
    self = [super init];
    if (self) {
        _preKeyId       = preKeyId;
        _signedPreKeyId = signedPrekeyId;
        _baseKey        = baseKey;
    }
    return self;
}

@end

/**
 *  Pending Key Exchanges
 */

@interface PendingKeyExchange : NSObject

@property int sequence;
@property ECKeyPair *ourBaseKey;
#warning DO WE REALLY NEED A COPY OF THE IDENTITY KEY HERE?
@property ECKeyPair *ourIdentityKey;
@property ECKeyPair *ourRatchetKey;

-(instancetype)initWithBaseKey:(ECKeyPair*)baseKey ourIdentityKey:(ECKeyPair*)ourIdentityKey ratchetKey:(ECKeyPair*)ratchetKey sequence:(int)sequence;

@end

@implementation PendingKeyExchange

-(instancetype)initWithBaseKey:(ECKeyPair*)baseKey ourIdentityKey:(ECKeyPair*)ourIdentityKey ratchetKey:(ECKeyPair*)ratchetKey sequence:(int)sequence{
    self = [super init];
    if (self) {
        _ourBaseKey     = baseKey;
        _ourIdentityKey = ourIdentityKey;
        _ourRatchetKey  = ratchetKey;
        _sequence       = sequence;
    }
    return self;
}

@end

#pragma mark Keys for coder

static NSString* const kCoderPN               = @"kCoderPN";
static NSString* const kCoderRootKey          = @"kCoderRoot";
static NSString* const kCoderReceiverChains   = @"kCoderReceiverChains";
static NSString* const kCoderSendingChain     = @"kCoderSendingChain";
static NSString* const kCoderPendingPrekey    = @"kCoderPendingPrekey";
#warning missing serialization

@implementation UnacknowledgedPreKeyMessageItems

- (instancetype)initWithPreKeyId:(int)preKeyId signedPreKeyId:(int)signedPrekeyId baseKey:(NSData*)baseKey{
    self = [super init];
    if (self) {
        self.preKeyId       = preKeyId;
        self.signedPreKeyId = signedPrekeyId;
        self.baseKey        = baseKey;
    }
    return self;
}

@end

@interface SessionState ()

@property SendingChain       *sendingChain;               // The outgoing sending chain
@property NSMutableArray     *receivingChains;            // NSArray of ReceivingChains
@property PendingKeyExchange *pendingKeyExchange;
@property PendingPreKey      *pendingPreKey;

@end

@implementation SessionState

- (instancetype)init{
    self = [super init];
    
    if (self) {
        self.receivingChains = [NSMutableArray array];
    }
    
    return self;
}

- (NSData*)senderRatchetKey{
    return [[self senderRatchetKeyPair] publicKey];
}

- (ECKeyPair*)senderRatchetKeyPair{
    return [[self sendingChain] senderRatchetKeyPair];
}

- (BOOL)hasReceiverChain:(NSData*)senderRatchet{
    NSLog(@"Receiver chains: %@", _receivingChains);
    return [self receiverChainKey:senderRatchet] != nil;
}

- (BOOL)hasSenderChain{
    return self.sendingChain != nil;
}

- (ChainAndIndex*)receiverChain:(NSData*)senderRatchetKey{
    int index = 0;
    
    for (ReceivingChain *receiverChain in self.receivingChains) {
        NSData *chainSenderRatchetKey = receiverChain.senderRatchetKey;
        
        if ([chainSenderRatchetKey isEqualToData:senderRatchetKey]) {
            ChainAndIndex *cai = [[ChainAndIndex alloc] init];
            cai.chain   = receiverChain;
            cai.index   = index;
            return cai;
        }
        index++;
    }
    
    return nil;
}

- (ChainKey*)receiverChainKey:(NSData*)senderRatchetKey{
    ChainAndIndex  *receiverChainAndIndex = [self receiverChain:senderRatchetKey];
    ReceivingChain *receiverChain         = receiverChainAndIndex.chain;
    
    if (receiverChain == nil) {
        return nil;
    } else{
        return [[ChainKey alloc] initWithData:receiverChain.chainKey.key index:receiverChain.chainKey.index];
    }
}

- (void)setReceiverChainKey:(NSData*)senderEphemeral chainKey:(ChainKey*)nextChainKey{
    ChainAndIndex *chainAndIndex = [self receiverChain:senderEphemeral];
    ReceivingChain *chain        = (ReceivingChain*)chainAndIndex.chain;
    
    ReceivingChain *newChain     = [[ReceivingChain alloc] initWithChainKey:[[ChainKey alloc] initWithData:[chain.chainKey.key copy] index:chain.chainKey.index] senderRatchetKey:chain.senderRatchetKey];
    newChain.chainKey            = nextChainKey;
    
    [self.receivingChains insertObject:newChain atIndex:chainAndIndex.index];
}

- (void)addReceiverChain:(NSData*)senderRatchetKey chainKey:(ChainKey*)chainKey{
    
    ReceivingChain *receivingChain =  [[ReceivingChain alloc] initWithChainKey:chainKey senderRatchetKey:senderRatchetKey];
    
    [self.receivingChains addObject:receivingChain];
    
    if ([self.receivingChains count] > 5) {
        // We keep 5 receiving chains to be able to decrypt out of order messages.
        [self.receivingChains removeObjectAtIndex:0];
    }
}

- (void)setSenderChain:(ECKeyPair*)senderRatchetKeyPair chainKey:(ChainKey*)chainKey{
    self.sendingChain = [[SendingChain alloc]initWithChainKey:chainKey senderRatchetKeyPair:senderRatchetKeyPair];
}

- (ChainKey*)senderChainKey{
    return self.sendingChain.chainKey;
}

- (void)setSenderChainKey:(ChainKey*)nextChainKey{
    SendingChain *sendingChain = self.sendingChain;
    sendingChain.chainKey = nextChainKey;
    
    self.sendingChain = sendingChain;
}

- (BOOL)hasMessageKeys:(NSData*)senderRatchetKey counter:(int)counter{
    ChainAndIndex *chainAndIndex = [self receiverChain:senderRatchetKey];
    ReceivingChain *receivingChain = (ReceivingChain*)chainAndIndex.chain;
    
    if (!receivingChain) {
        return false;
    }
    
    NSArray *messageKeyArray = receivingChain.messageKeys;
    
    for (MessageKeys *keys in messageKeyArray) {
        if (keys.index == counter) {
            return YES;
        }
    }
    
    return NO;
}

- (MessageKeys*)removeMessageKeys:(NSData*)senderRatcherKey counter:(int)counter{
    ChainAndIndex *chainAndIndex = [self receiverChain:senderRatcherKey];
    ReceivingChain *receivingChain = (ReceivingChain*)chainAndIndex.chain;
    
    if (!receivingChain) {
        return nil;
    }
    
    NSMutableArray *messageList = receivingChain.messageKeys;
    
    MessageKeys *result;
    
    for(MessageKeys *messageKeys in messageList){
        if (messageKeys.index == counter) {
            result = messageKeys;
            break;
        }
    }
    
    [messageList removeObject:result];
    
    return result;
}

-(void)setReceiverChain:(int)index updatedChain:(ReceivingChain*)recvchain{
    for(ReceivingChain *chain in self.receivingChains){
        if(recvchain.chainKey.index == index){
            [self.receivingChains removeObject:chain];
            break;
        }
    }
    
    [self.receivingChains addObject:self];
}

- (void)setMessageKeys:(NSData*)senderRatchetKey messageKeys:(MessageKeys*)messageKeys{
    ChainAndIndex  *chainAndIndex = [self receiverChain:senderRatchetKey];
    ReceivingChain *chain         = chainAndIndex.chain;
    [chain.messageKeys addObject:messageKeys];
}

- (void)setPendingKeyExchange:(int)sequence ourBaseKey:(ECKeyPair*)ourBaseKey ourRatchetKey:(ECKeyPair*)ourRatchetKey identityKeyPair:(NSData*)ourIdentityKeyPair{
    PendingKeyExchange *pendingKeyExchange = [[PendingKeyExchange alloc] initWithBaseKey:ourBaseKey ourIdentityKey:ourRatchetKey ratchetKey:ourRatchetKey sequence:sequence];
    self.pendingKeyExchange = pendingKeyExchange;
}

- (int)pendingKeyExchangeSequence{
    return self.pendingKeyExchange.sequence;
}

- (ECKeyPair*)pendingKeyExchangeBaseKey{
    return self.pendingKeyExchange.ourBaseKey;
}

- (ECKeyPair*)pendingKeyExchangeRatchetKey{
    return self.pendingKeyExchange.ourRatchetKey;
}

- (ECKeyPair*)pendingKeyExchangeIdentityKey{
    return self.pendingKeyExchange.ourIdentityKey;
}

- (BOOL) hasPendingKeyExchange{
    return self.pendingKeyExchange?YES:NO;
}

- (void)setUnacknowledgedPreKeyMessage:(int)preKeyId signedPreKey:(int)signedPreKeyId baseKey:(NSData*)baseKey{
    PendingPreKey *pendingPreKey = [[PendingPreKey alloc] initWithBaseKey:baseKey preKeyId:preKeyId signedPreKeyId:signedPreKeyId];
    
    self.pendingPreKey = pendingPreKey;
}

- (BOOL)hasUnacknowledgedPreKeyMessage{
    return self.pendingPreKey?YES:NO;
}

- (PendingPreKey*)unacknowledgedPreKeyMessageItems{
    return self.pendingPreKey;
}
- (void)clearUnacknowledgedPreKeyMessage{
    self.pendingPreKey = nil;
}

@end

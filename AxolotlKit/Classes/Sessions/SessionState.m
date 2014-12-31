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


@implementation PendingPreKey

static NSString* const kCoderPreKeyId       = @"kCoderPreKeyId";
static NSString* const kCoderSignedPreKeyId = @"kCoderSignedPreKeyId";
static NSString* const kCoderBaseKey        = @"kCoderBaseKey";


+ (BOOL)supportsSecureCoding{
    return YES;
}

-(instancetype)initWithBaseKey:(NSData*)baseKey preKeyId:(int)preKeyId signedPreKeyId:(int)signedPrekeyId{
    self = [super init];
    if (self) {
        _preKeyId       = preKeyId;
        _signedPreKeyId = signedPrekeyId;
        _baseKey        = baseKey;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [self initWithBaseKey:[aDecoder decodeObjectOfClass:[NSData class] forKey:kCoderBaseKey]
                        preKeyId:[aDecoder decodeIntForKey:kCoderPreKeyId]
                  signedPreKeyId:[aDecoder decodeIntForKey:kCoderSignedPreKeyId]];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_baseKey forKey:kCoderBaseKey];
    [aCoder encodeInt:_preKeyId forKey:kCoderPreKeyId];
    [aCoder encodeInt:_signedPreKeyId forKey:kCoderSignedPreKeyId];
}

@end

@interface SessionState ()

@property SendingChain       *sendingChain;               // The outgoing sending chain
@property NSMutableArray     *receivingChains;            // NSArray of ReceivingChains
@property PendingPreKey      *pendingPreKey;

@end

#pragma mark Keys for coder

static NSString* const kCoderVersion          = @"kCoderVersion";
static NSString* const kCoderAliceBaseKey     = @"kCoderAliceBaseKey";
static NSString* const kCoderRemoteIDKey      = @"kCoderRemoteIDKey";
static NSString* const kCoderLocalIDKey       = @"kCoderLocalIDKey";
static NSString* const kCoderPreviousCounter  = @"kCoderPreviousCounter";
static NSString* const kCoderRootKey          = @"kCoderRoot";
static NSString* const kCoderLocalRegID       = @"kCoderLocalRegID";
static NSString* const kCoderRemoteRegID      = @"kCoderRemoteRegID";
static NSString* const kCoderReceiverChains   = @"kCoderReceiverChains";
static NSString* const kCoderSendingChain     = @"kCoderSendingChain";
static NSString* const kCoderPendingPrekey    = @"kCoderPendingPrekey";

@implementation SessionState

+ (BOOL)supportsSecureCoding{
    return YES;
}

- (instancetype)init{
    self = [super init];
    
    if (self) {
        self.receivingChains = [NSMutableArray array];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [self init];
    
    if (self) {
        self.version              = [aDecoder decodeIntForKey:kCoderVersion];
        self.aliceBaseKey         = [aDecoder decodeObjectOfClass:[NSData class] forKey:kCoderAliceBaseKey];
        self.remoteIdentityKey    = [aDecoder decodeObjectOfClass:[NSData class] forKey:kCoderRemoteIDKey];
        self.localIdentityKey     = [aDecoder decodeObjectOfClass:[NSData class] forKey:kCoderLocalIDKey];
        self.previousCounter      = [aDecoder decodeIntForKey:kCoderPreviousCounter];
        self.rootKey              = [aDecoder decodeObjectOfClass:[NSData class] forKey:kCoderRootKey];
        self.remoteRegistrationId = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:kCoderRemoteRegID] intValue];
        self.localRegistrationId  = [[aDecoder decodeObjectOfClass:[NSNumber class] forKey:kCoderLocalRegID] intValue];
        self.sendingChain         = [aDecoder decodeObjectOfClass:[SendingChain class] forKey:kCoderSendingChain];
        self.receivingChains      = [aDecoder decodeObjectOfClass:[NSArray class] forKey:kCoderReceiverChains];
        self.pendingPreKey        = [aDecoder decodeObjectOfClass:[PendingPreKey class] forKey:kCoderPendingPrekey];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeInt:self.version forKey:kCoderVersion];
    [aCoder encodeObject:self.aliceBaseKey forKey:kCoderAliceBaseKey];
    [aCoder encodeObject:self.remoteIdentityKey forKey:kCoderRemoteIDKey];
    [aCoder encodeObject:self.localIdentityKey forKey:kCoderLocalIDKey];
    [aCoder encodeInt:self.previousCounter forKey:kCoderPreviousCounter];
    [aCoder encodeObject:self.rootKey forKey:kCoderRootKey];
    [aCoder encodeObject:[NSNumber numberWithInt:self.remoteRegistrationId] forKey:kCoderRemoteRegID];
    [aCoder encodeObject:[NSNumber numberWithInt:self.localRegistrationId] forKey:kCoderLocalRegID];
    [aCoder encodeObject:self.sendingChain forKey:kCoderSendingChain];
    [aCoder encodeObject:self.receivingChains forKey:kCoderReceiverChains];
    [aCoder encodeObject:self.pendingPreKey forKey:kCoderPendingPrekey];
}

- (NSData*)senderRatchetKey{
    return [[self senderRatchetKeyPair] publicKey];
}

- (ECKeyPair*)senderRatchetKeyPair{
    return [[self sendingChain] senderRatchetKeyPair];
}

- (BOOL)hasReceiverChain:(NSData*)senderRatchet{
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
    ReceivingChain *receiverChain         = (ReceivingChain*)receiverChainAndIndex.chain;
    
    if (receiverChain == nil) {
        return nil;
    } else{
        return [[ChainKey alloc] initWithData:receiverChain.chainKey.key index:receiverChain.chainKey.index];
    }
}

- (void)setReceiverChainKey:(NSData*)senderEphemeral chainKey:(ChainKey*)nextChainKey{
    ChainAndIndex *chainAndIndex = [self receiverChain:senderEphemeral];
    ReceivingChain *chain        = (ReceivingChain*)chainAndIndex.chain;
    
    ReceivingChain *newChain     = chain;
    newChain.chainKey            = nextChainKey;
    
    [self.receivingChains replaceObjectAtIndex:chainAndIndex.index withObject:newChain];
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

    NSArray *messageKeyArray = receivingChain.messageKeysList;
    
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
    
    NSMutableArray *messageList = receivingChain.messageKeysList;
    
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
    [self.receivingChains replaceObjectAtIndex:index withObject:recvchain];
}

- (void)setMessageKeys:(NSData*)senderRatchetKey messageKeys:(MessageKeys*)messageKeys{
    ChainAndIndex  *chainAndIndex = [self receiverChain:senderRatchetKey];
    ReceivingChain *chain         = (ReceivingChain*)chainAndIndex.chain;
    [chain.messageKeysList addObject:messageKeys];
    
    [self setReceiverChain:chainAndIndex.index updatedChain:chain];
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

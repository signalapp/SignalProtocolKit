//
//  ChainKey.m
//  AxolotlKit
//
//  Created by Frederic Jacobs on 26/08/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import "ChainKey.h"
#import "TSDerivedSecrets.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation ChainKey


#define keySerializationKey @"keyKey"
#define indexSerializationKey @"indexKey"

#define kTSKeySeedLength 1
static uint8_t kMessageKeySeed[kTSKeySeedLength]    = {01};
static uint8_t kChainKeySeed[kTSKeySeedLength]      = {02};


#pragma mark Serialization

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super init];
    
    _key = [aDecoder decodeObjectOfClass:[NSData class] forKey:keySerializationKey];
    _index = [aDecoder decodeIntForKey:indexSerializationKey];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_key forKey:keySerializationKey];
    [aCoder encodeInt:_index forKey:indexSerializationKey];
}

+ (BOOL)supportsSecureCoding{
    return YES;
}



-(instancetype)initWithData:(NSData *)chainKey index:(int)index{
    
    self = [super init];
    if (self) {
        _key   = chainKey;
        _index = index;
    }
    return self;
}

- (instancetype) nextChainKey{
    NSData* nextCK = [self baseMaterial:[NSData dataWithBytes:kChainKeySeed length:kTSKeySeedLength]];
    
    return [[ChainKey alloc] initWithData:nextCK index:self.index+1];
}

- (MessageKeys*)messageKeys{
    NSData *inputKeyMaterial = [self baseMaterial:[NSData dataWithBytes:kMessageKeySeed length:kTSKeySeedLength]];
    TSDerivedSecrets *derivedSecrets = [TSDerivedSecrets derivedMessageKeysWithData:inputKeyMaterial];
    return [[MessageKeys alloc] initWithCipherKey:derivedSecrets.cipherKey macKey:derivedSecrets.macKey iv:derivedSecrets.iv index:self.index];
}

- (NSData*)baseMaterial:(NSData*)seed{
    uint8_t result[CC_SHA256_DIGEST_LENGTH] = {0};
    CCHmacContext ctx;
    CCHmacInit(&ctx, kCCHmacAlgSHA256, [self.key bytes], [self.key length]);
    CCHmacUpdate(&ctx, [seed bytes], [seed length]);
    CCHmacFinal(&ctx, result);
    return [NSData dataWithBytes:result length:sizeof(result)];
}

@end

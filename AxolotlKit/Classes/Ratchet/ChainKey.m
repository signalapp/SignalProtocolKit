//
//  Copyright (c) 2017 Open Whisper Systems. All rights reserved.
//

#import "ChainKey.h"
#import "TSDerivedSecrets.h"
#import <CommonCrypto/CommonCrypto.h>
#import <Curve25519Kit/Curve25519.h>

NS_ASSUME_NONNULL_BEGIN

@implementation ChainKey

static NSString *const kCoderKey = @"kCoderKey";
static NSString *const kCoderIndex = @"kCoderIndex";

#define kTSKeySeedLength 1

static uint8_t kMessageKeySeed[kTSKeySeedLength] = { 01 };
static uint8_t kChainKeySeed[kTSKeySeedLength] = { 02 };

+ (BOOL)supportsSecureCoding
{
    return YES;
}

- (nullable id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    if (self) {
        _key = [aDecoder decodeObjectOfClass:[NSData class] forKey:kCoderKey];
        _index = [aDecoder decodeIntForKey:kCoderIndex];
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_key forKey:kCoderKey];
    [aCoder encodeInt:_index forKey:kCoderIndex];
}

- (instancetype)initWithData:(NSData *)chainKey index:(int)index
{
    SPKAssert(chainKey.length == ECCKeyLength);

    self = [super init];

    if (self) {
        _key = chainKey;
        _index = index;
    }

    return self;
}

- (instancetype)nextChainKey
{
    NSData *nextCK = [self baseMaterial:[NSData dataWithBytes:kChainKeySeed length:kTSKeySeedLength]];

    return [[ChainKey alloc] initWithData:nextCK index:self.index + 1];
}

- (MessageKeys *)messageKeys
{
    NSData *inputKeyMaterial = [self baseMaterial:[NSData dataWithBytes:kMessageKeySeed length:kTSKeySeedLength]];
    TSDerivedSecrets *derivedSecrets = [TSDerivedSecrets derivedMessageKeysWithData:inputKeyMaterial];
    return [[MessageKeys alloc] initWithCipherKey:derivedSecrets.cipherKey
                                           macKey:derivedSecrets.macKey
                                               iv:derivedSecrets.iv
                                            index:self.index];
}

- (NSData *)baseMaterial:(NSData *)seed
{
    if (!self.key) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Missing key." userInfo:nil];
    }
    if (self.key.length >= SIZE_MAX) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Oversize key." userInfo:nil];
    }
    if (!seed) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Missing seed." userInfo:nil];
    }
    if (seed.length >= SIZE_MAX) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Oversize seed." userInfo:nil];
    }

    NSMutableData *_Nullable bufferData = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    if (!bufferData) {
        @throw [NSException exceptionWithName:NSGenericException reason:@"Couldn't allocate buffer." userInfo:nil];
    }

    CCHmacContext ctx;
    CCHmacInit(&ctx, kCCHmacAlgSHA256, [self.key bytes], [self.key length]);
    CCHmacUpdate(&ctx, [seed bytes], [seed length]);
    CCHmacFinal(&ctx, bufferData.mutableBytes);
    return [bufferData copy];
}

@end

NS_ASSUME_NONNULL_END

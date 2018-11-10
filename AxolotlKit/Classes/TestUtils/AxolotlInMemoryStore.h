//
//  Copyright (c) 2018 Open Whisper Systems. All rights reserved.
//

#import "AxolotlStore.h"
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AxolotlInMemoryStore : NSObject <AxolotlStore>

- (instancetype)initWithIdentityKeyPair:(ECKeyPair *)identityKeyPair
                    localRegistrationId:(int)localRegistrationId NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END

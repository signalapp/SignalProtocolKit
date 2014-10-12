//
//  PreKeyStore.h
//  AxolotlKit
//
//  Created by Frederic Jacobs on 12/10/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PreKeyRecord.h"

@protocol PreKeyStore <NSObject>

- (PreKeyRecord*)loadPreKey:(int)preKeyId;

- (void)storePreKey:(int)preKeyId preKeyRecord:(PreKeyRecord*)record;

- (BOOL)containsPreKey:(int)preKeyId;

- (void)removePreKey:(int)preKeyId;

@end

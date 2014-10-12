//
//  SessionBuilder.h
//  AxolotlKit
//
//  Created by Frederic Jacobs on 23/07/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IdentityKeyStore.h"
#import "PreKeyStore.h"
#import "SessionStore.h"
#import "SignedPreKeyStore.h"

/**
 *  The Session Store defines the interface of the storage of sesssions.
 */

@protocol AxolotlStore <SessionStore, IdentityKeyStore, PreKeyStore, SessionStore, SignedPreKeyStore>

@end

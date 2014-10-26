//
//  AxolotlExceptions.h
//  AxolotlKit
//
//  Created by Frederic Jacobs on 23/07/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#ifndef AxolotlKit_AxolotlExceptions_h
#define AxolotlKit_AxolotlExceptions_h

static NSString *UntrustedIdentityKeyException = @"AxolotlUnstrustedIdentityKeyException";

static NSString *InvalidKeyIdException         = @"AxolotlInvalidKeyIdException";

static NSString *InvalidKeyException           = @"AxolotlInvalidKeyException";

static NSString *NoSessionException            = @"AxolotlNoSessionException";

static NSString *InvalidMessageException       = @"AxolotlInvalidMessageException";

static NSString *CipherException               = @"AxolotlCipherIssue";

static NSString *DuplicateMessageException     = @"AxolotlDuplicateMessage";

static NSString *LegacyMessageException        = @"AxolotlLegacyMessageException";

static NSString *InvalidVersionException       = @"AxolotlInvalidVersionException";

#endif

//
//  CipherMessage.h
//  AxolotlKit
//
//  Created by Frederic Jacobs on 26/10/14.
//  Copyright (c) 2014 Frederic Jacobs. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CipherMessage <NSObject>

- (NSData*)serialized;

@end

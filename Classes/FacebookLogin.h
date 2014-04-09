//
//  FacebookLogin.h
//  DitoSDK
//
//  Created by Joao Pedro Melo on 3/11/14.
//  Copyright (c) 2014 Jota. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DitoSDK.h"

@interface FacebookLogin : NSObject

+ (void)openSessionWithCallback:(FacebookCompletionBlock)block
                    permissions:(NSArray *)permissions;

+ (BOOL)handleFacebookURL:(NSURL *)url;

@end

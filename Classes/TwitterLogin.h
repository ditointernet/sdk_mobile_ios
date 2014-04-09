//
//  TwitterLogin.h
//  DitoSDK
//
//  Created by Joao Pedro Melo on 3/12/14.
//  Copyright (c) 2014 Jota. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RSTwitterEngine.h"
#import "DitoSDK.h"

@interface TwitterLogin : NSObject <UIActionSheetDelegate, RSTwitterEngineDelegate>

+ (id)initWithCompletionHandler:(TwitterCompletionBlock)block;

@end

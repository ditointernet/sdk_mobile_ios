//
//  GooglePlusLogin.h
//  testapp
//
//  Created by Joao Pedro Melo on 3/25/14.
//  Copyright (c) 2014 Jota. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GooglePlus/GooglePlus.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import "DitoSDK.h"

@interface GooglePlusLogin : NSObject <GPPSignInDelegate>

@property (strong, nonatomic) NSString *hue;

+ (id)sharedManager;
- (void)beginAuthenticationWithCompletion:(GooglePlusCompletionBlock)block;

@end

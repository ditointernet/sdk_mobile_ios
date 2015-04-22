//
//  AppDelegate.h
//  DitoSDKSample
//
//  Created by Marcos Lacerda on 07/04/15.
//  Copyright (c) 2015 Dito. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DitoSDK/DitoCredentials.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) DitoCredentials *credentials;
@property (strong, nonatomic) UIWindow *window;

@end
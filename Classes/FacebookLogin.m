//
//  FacebookLogin.m
//  DitoSDK
//
//  Created by Joao Pedro Melo on 3/11/14.
//  Copyright (c) 2014 Jota. All rights reserved.
//

#import "FacebookLogin.h"
#import <FacebookSDK/FacebookSDK.h>

@implementation FacebookLogin

+ (void)openSessionWithCallback:(FacebookCompletionBlock)block
                    permissions:(NSArray *)permissions
{
    [FBSession openActiveSessionWithPublishPermissions:[permissions arrayByAddingObject:@"publish_actions"]
                                    defaultAudience:FBSessionDefaultAudienceEveryone
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session,
       FBSessionState state, NSError *error) {
         [self sessionStateChanged:session state:state error:error callback:block];
     }];
}

+ (void)sessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error callback:(FacebookCompletionBlock)block
{
    if (state == FBSessionStateOpen)
        [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error){
            if (error != nil)
                block(nil, nil, error);
            else
                block([[[FBSession activeSession] accessTokenData] accessToken], [result objectForKey:@"id"], nil);
        }];
    
    if (error)
        block(nil, nil, error);
}

+ (BOOL)handleFacebookURL:(NSURL *)url
{
    return [FBSession.activeSession handleOpenURL:url];
}

@end

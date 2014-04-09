//
//  TwitterLogin.m
//  DitoSDK
//
//  Created by Joao Pedro Melo on 3/12/14.
//  Copyright (c) 2014 Jota. All rights reserved.
//

#import "TwitterLogin.h"
#import "TWAPIManager.h"
#import "UIActionSheet+Blocks.h"
#import <Accounts/Accounts.h>

@interface TwitterLogin ()

@property (strong, nonatomic) ACAccountStore *accountStore;
@property (strong, nonatomic) NSArray *accounts;
@property (strong, nonatomic) TWAPIManager *apiManager;
@property (strong, nonatomic) RSTwitterEngine *twitterEngine;
@property (strong, nonatomic) void(^completionHandler)(NSString *userId, NSString *token, NSString *tokenSecret, NSError *error);

@end

@implementation TwitterLogin

+ (id)initWithCompletionHandler:(TwitterCompletionBlock)block
{
    return [[self alloc] initWithCompletionHandler:block];
}

- (id)initWithCompletionHandler:(TwitterCompletionBlock)block
{
    self = [super init];
    if (self) {
        if ([TWAPIManager isLocalTwitterAccountAvailable]) {
            self.accountStore = [[ACAccountStore alloc] init];
            self.apiManager = [[TWAPIManager alloc] init];
            self.completionHandler = block;
            
            [self refreshAccountsWithBlock:^(BOOL granted, NSError *error) {
                if (granted) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Escolha a conta" delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
                        
                        for (ACAccount *acct in self.accounts)
                            [sheet addButtonWithTitle:acct.username];
                        
                        sheet.tapBlock = ^(UIActionSheet *actionSheet, NSInteger buttonIndex) {
                            if (buttonIndex != actionSheet.cancelButtonIndex) {
                                [self.apiManager performReverseAuthForAccount:self.accounts[buttonIndex] withHandler:^(NSData *responseData, NSError *error) {
                                    if (responseData) {
                                        NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                                        
                                        NSArray *parts = [responseStr componentsSeparatedByString:@"&"];
                                        NSMutableDictionary *dict = [NSMutableDictionary new];
                                        
                                        for (NSString *part in parts)
                                            [dict setObject:[part componentsSeparatedByString:@"="][1] forKey:[part componentsSeparatedByString:@"="][0]];
                                        
                                        block([dict objectForKey:@"user_id"], [dict objectForKey:@"oauth_token"], [dict objectForKey:@"oauth_token_secret"], nil);
                                    }
                                    else {
                                        
                                    }
                                }];
                            }
                        };
                        
                        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                        
                        sheet.cancelButtonIndex = [sheet addButtonWithTitle:@"Cancelar"];
                        [sheet showInView:window.rootViewController.view];
                    });
                } else {
                    block(nil, nil, nil, error);
                }
            }];
        } else
            [self doManualAuthWithCompletionHandler:block];
    }
    
    return self;
}

- (void)doManualAuthWithCompletionHandler:(void(^)(NSString *userId, NSString *token, NSString *tokenSecret, NSError *error))block
{
    self.twitterEngine = [[RSTwitterEngine alloc] initWithDelegate:self];
    [self.twitterEngine authenticateWithCompletionBlock:^(NSError *err) {
        if (err == nil)
            block(self.twitterEngine.user_id, self.twitterEngine.token, self.twitterEngine.tokenSecret, nil);
        else
            block(nil, nil, nil, err);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTwitterURL:) name:@"TwitterAuthURLOpened" object:nil];
    /*[[NSNotificationCenter defaultCenter] addObserverForName:@"TwitterAuthURLOpened" object:nil queue:nil usingBlock:^(NSNotification *notification) {
        NSURL *url = notification.userInfo[@"url"];
        if ([url.query hasPrefix:@"denied"]) {
            if (self.twitterEngine) [self.twitterEngine cancelAuthentication];
        } else {
            if (self.twitterEngine) [self.twitterEngine resumeAuthenticationFlowWithURL:url];
        }
    }];*/
}

- (void)handleTwitterURL:(NSNotification *)notification
{
    NSURL *url = notification.userInfo[@"url"];
    if ([url.query hasPrefix:@"denied"]) {
        if (self.twitterEngine) [self.twitterEngine cancelAuthentication];
    } else {
        if (self.twitterEngine) [self.twitterEngine resumeAuthenticationFlowWithURL:url];
    }
}

- (void)refreshAccountsWithBlock:(void(^)(BOOL granted, NSError *error))block
{
    ACAccountType *twitterType = [_accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    ACAccountStoreRequestAccessCompletionHandler handler = ^(BOOL granted, NSError *error) {
        if (granted) {
            self.accounts = [_accountStore accountsWithAccountType:twitterType];
            block(granted, error);
        } else {
            block(granted, error);
        }
    };
    [self.accountStore requestAccessToAccountsWithType:twitterType options:NULL completion:handler];
}

#pragma mark - RSTWitterEngine Delegate

- (void)twitterEngine:(RSTwitterEngine *)engine needsToOpenURL:(NSURL *)url
{
    [[UIApplication sharedApplication] openURL:url];
}

- (void)twitterEngine:(RSTwitterEngine *)engine statusUpdate:(NSString *)message
{
    //self.statusLabel.text = message;
}


#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        [self.apiManager performReverseAuthForAccount:self.accounts[buttonIndex] withHandler:^(NSData *responseData, NSError *error) {
            if (responseData) {
                NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                
                NSArray *parts = [responseStr componentsSeparatedByString:@"&"];
                NSString *lined = [parts componentsJoinedByString:@"\n"];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success!" message:lined delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                    [alert show];
                });
            }
            else {
                
            }
        }];
    }
}

@end

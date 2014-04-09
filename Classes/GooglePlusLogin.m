//
//  GooglePlusLogin.m
//  testapp
//
//  Created by Joao Pedro Melo on 3/25/14.
//  Copyright (c) 2014 Jota. All rights reserved.
//

#import "GooglePlusLogin.h"

@interface GooglePlusLogin ()

@property (assign, nonatomic) GooglePlusCompletionBlock block;
@property (strong, nonatomic) NSDictionary *blockDict;

@end

@implementation GooglePlusLogin

#define kClientId @"311813557407-i71qhrtbadoidul5geld68qggulvv269.apps.googleusercontent.com"

+ (id)sharedManager
{
    static GooglePlusLogin *sharedGLogin = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedGLogin = [[self alloc] init];
    });
    
    return sharedGLogin;
}

- (void)beginAuthenticationWithCompletion:(GooglePlusCompletionBlock)block
{
    self.blockDict = @{@"block": block};
    [self beginSignin];
}

- (void)beginSignin
{
    GPPSignIn *signIn = [GPPSignIn sharedInstance];
    signIn.shouldFetchGooglePlusUser = YES;
    signIn.shouldFetchGoogleUserEmail = YES;
    signIn.clientID = kClientId;
    signIn.scopes = @[kGTLAuthScopePlusLogin];
    signIn.delegate = self;
    [signIn authenticate];
}

- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error
{
    GooglePlusCompletionBlock block = self.blockDict[@"block"];
    NSString *accessToken = auth.accessToken;
    GTLServicePlus* plusService = [[GTLServicePlus alloc] init];
    [plusService setAuthorizer:auth];
    GTLQueryPlus *query = [GTLQueryPlus queryForPeopleGetWithUserId:@"me"];
    
    [plusService executeQuery:query
            completionHandler:^(GTLServiceTicket *ticket,
                                GTLPlusPerson *person,
                                NSError *error) {
                if (error) {
                    block(nil, nil, error);
                } else {
                    block(accessToken, person.identifier, nil);
                }
            }];
}

@end

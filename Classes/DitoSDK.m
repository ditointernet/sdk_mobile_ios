//
//  DitoSDK.m
//  DitoSDK
//
//  Created by Joao Pedro Melo on 3/11/14.
//  Copyright (c) 2014 Jota. All rights reserved.
//

#import "DitoSDK.h"
#import "FacebookLogin.h"
#import "TwitterLogin.h"
#import "GooglePlusLogin.h"
#import "MKNetworkKit.h"
#import "rsa.h"
#import "pem.h"
#import <Security/Security.h>
#import <GooglePlus/GooglePlus.h>

@interface DitoSDK ()

@property (strong, nonatomic) TwitterLogin *twitterLogin;

@end

@implementation DitoSDK

+ (BOOL)handleURL:(NSURL *)url
sourceApplication:(NSString *)sourceApplication
     annotation:(id)annotation
{
    if ([[url.scheme substringToIndex:2] isEqualToString:@"tw"])
        return [DitoSDK handleTwitterURL:url];
    else if ([[url.scheme substringFromIndex:2] isEqualToString:@"fb"])
        return [DitoSDK handleFacebookURL:url];
    else {
        BOOL result = [GPPURLHandler handleURL:url sourceApplication:sourceApplication annotation:annotation];
        return result;
    }
}

#pragma mark - HTTP
static NSString *urlEncode(NSString *string) {
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                        NULL,
                                        (__bridge CFStringRef) string,
                                        NULL,
                                        CFSTR("!*'();:@&=+$,/?%#[]\" "),
                                        kCFStringEncodingUTF8));
}

- (NSString *)userAgent
{
    NSBundle *bundle = [NSBundle bundleForClass:[self class]];
    
    NSString *appName = [bundle objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    if (!appName) {
        appName = [bundle objectForInfoDictionaryKey:@"CFBundleName"];
    }
    
    NSData *latin1Data = [appName dataUsingEncoding:NSUTF8StringEncoding];
    appName = [[NSString alloc] initWithData:latin1Data encoding:NSISOLatin1StringEncoding];
    
    if (!appName) {
        return nil;
    }
    
    NSString *appVersion = nil;
    NSString *marketingVersionNumber = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *developmentVersionNumber = [bundle objectForInfoDictionaryKey:@"CFBundleVersion"];
    if (marketingVersionNumber && developmentVersionNumber) {
        if ([marketingVersionNumber isEqualToString:developmentVersionNumber]) {
            appVersion = marketingVersionNumber;
        } else {
            appVersion = [NSString stringWithFormat:@"%@ rv:%@",marketingVersionNumber,developmentVersionNumber];
        }
    } else {
        appVersion = (marketingVersionNumber ? marketingVersionNumber : developmentVersionNumber);
    }
    
    NSString *deviceName;
    NSString *OSName;
    NSString *OSVersion;
    NSString *locale = [[NSLocale currentLocale] localeIdentifier];
    
    UIDevice *device = [UIDevice currentDevice];
    deviceName = [device model];
    OSName = [device systemName];
    OSVersion = [device systemVersion];
    
    return [NSString stringWithFormat:@"%@ %@ (%@; %@ %@; %@)", appName, appVersion, deviceName, OSName, OSVersion, locale];
}

- (NSString *)addParams:(NSDictionary *)params toURL:(NSString *)url
{
    NSMutableString *finalUrl = [NSMutableString stringWithFormat:@"%@?", url];
    
    for (NSString *key in params.allKeys)
        [finalUrl appendFormat:@"%@=%@&", key, urlEncode([params objectForKey:key])];
    
    return finalUrl;
}

- (void)makeRequest:(NSString *)method
            baseURL:(NSString *)baseURL
               path:(NSString *)path
             params:(NSMutableDictionary *)params
         completion:(void(^)(id response, NSError *error))completion
{
    MKNetworkEngine *engine = [[MKNetworkEngine alloc] initWithHostName:baseURL customHeaderFields:@{@"Origin": ORIGIN_DOMAIN, @"User-Agent": [self userAgent]}];
    
    if (params == nil)
        params = [NSMutableDictionary dictionaryWithDictionary:@{@"platform_api_key": API_KEY}];
    else
        [params setObject:API_KEY forKey:@"platform_api_key"];
    
    NSString *signatureb64 = [self EncryptMessage:API_SECRET];
    [params setObject:signatureb64 forKey:@"signature"];
    [params setObject:@"base64" forKey:@"encoding"];
    
    MKNetworkOperation *op = [engine operationWithPath:path params:params httpMethod:method];
    [op addCompletionHandler:^(MKNetworkOperation *operation) {
        completion(operation.responseJSON, nil);
    } errorHandler:^(MKNetworkOperation *op, NSError *err) {
        if (op.responseJSON == nil)
            completion(op.responseString, err);
        else
            completion(op.responseJSON, err);
    }];
    op.freezable = YES;
    
    [engine enqueueOperation:op];
}

#pragma mark - Social login
#pragma mark Facebook
- (void)doFacebookLoginWithPermissions:(NSArray *)permissions
                     completionHandler:(RequestBlock)completion
{
    [FacebookLogin openSessionWithCallback:^(NSString *accessToken, NSString *userId, NSError *error) {
        if (error)
            completion(nil, error);
        else {
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            [params setObject:accessToken forKey:@"access_token"];
            [params setObject:kDitoSocialNetworkFacebook forKey:@"network_name"];
            
            [self makeRequest:@"POST" baseURL:kLoginBaseURL path:[NSString stringWithFormat:@"users/facebook/%@/signup", userId] params:params completion:completion];
        }
    } permissions:permissions];
}

+ (BOOL)handleFacebookURL:(NSURL *)url
{
    return [FacebookLogin handleFacebookURL:url];
}

#pragma mark Twitter

- (void)doTwitterLoginWithCompletionHandler:(RequestBlock)completion
{
    self.twitterLogin = [TwitterLogin initWithCompletionHandler:^(NSString *userId, NSString *token, NSString *tokenSecret, NSError *error) {
        if (error)
            completion(nil, error);
        else {
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            [params setObject:token forKey:@"access_token"];
            [params setObject:kDitoSocialNetworkTwitter forKey:@"network_name"];
            
            [self makeRequest:@"POST" baseURL:kLoginBaseURL path:[NSString stringWithFormat:@"users/twitter/%@/signup", userId] params:params completion:completion];
        }
    }];
}

+ (BOOL)handleTwitterURL:(NSURL *)url
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TwitterAuthURLOpened" object:nil userInfo:@{@"url": url}];
    return YES;
}

#pragma mark Google+

- (void)doGooglePlusLoginWithCompletionHandler:(RequestBlock)completion
{
    GooglePlusLogin *gpLogin = [GooglePlusLogin sharedManager];
    gpLogin.hue = @"HuE";
    [gpLogin beginAuthenticationWithCompletion:^(NSString *accessToken, NSString *userID, NSError *error) {
        if (error)
            completion(nil, error);
        else {
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            [params setObject:accessToken forKey:@"access_token"];
            [params setObject:kDitoSocialNetworkGooglePlus forKey:@"network_name"];
            
            [self makeRequest:@"POST" baseURL:kLoginBaseURL path:[NSString stringWithFormat:@"users/plus/%@/signup", userID] params:params completion:completion];
        }
    }];
}

#pragma mark Portal

- (void)doPortalLoginWithSocialID:(NSString *)socialID
                         userData:(NSDictionary *)userData
                       completion:(RequestBlock)block
{
    NSString *path = [NSString stringWithFormat:@"users/pt/%@/signup", socialID];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:userData forKey:@"user_data"];
    
    [self makeRequest:@"POST" baseURL:kLoginBaseURL path:path params:params completion:block];
}

#pragma mark - User

- (void)getDataForUserReference:(NSString *)reference
                     completion:(RequestBlock)block
{
    NSString *path = [NSString stringWithFormat:@"users/%@", reference];
    
    [self makeRequest:@"GET" baseURL:kLoginBaseURL path:path params:nil completion:block];
}

- (void)putData:(NSDictionary *)data
inUserReference:(NSString *)reference
     completion:(RequestBlock)block
{
    NSString *path = [NSString stringWithFormat:@"users/%@", reference];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:data forKey:@"user_data"];
    
    [self makeRequest:@"PUT" baseURL:kLoginBaseURL path:path params:params completion:block];
}

#pragma mark - Events

- (void)createEventWithData:(NSDictionary *)eventData
           forUserReference:(NSString *)reference
                    network:(NSString *)network
                 completion:(RequestBlock)block
{
    NSString *path = [NSString stringWithFormat:@"users/%@", reference];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:[self objectToJSONString:eventData] forKey:@"event"];
    [params setObject:network forKey:@"network_name"];
    [params setObject:@"" forKey:@"signature"];
    
    [self makeRequest:@"POST" baseURL:kEventsBaseURL path:path params:params completion:block];
}

- (void)friendsWhoDidEvents:(NSArray *)events
              userReference:(NSString *)reference
                 completion:(RequestBlock)block
{
    NSString *path = [NSString stringWithFormat:@"users/%@/friends/did", reference];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:[self objectToJSONString:events] forKey:@"events"];
    
    [self makeRequest:@"POST" baseURL:kEventsBaseURL path:path params:params completion:block];
}

- (void)eventsFeedWithLimit:(NSNumber *)limit
                       page:(NSNumber *)page
              userReference:(NSString *)reference
                      order:(DitoSDKSorting)_sorting
                 completion:(RequestBlock)block
{
    NSString *path = [NSString stringWithFormat:@"users/%@/friends", reference];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    if (limit != nil)
        [params setObject:limit forKey:@"limit"];
    if (page != nil)
        [params setObject:page forKey:@"page"];
    [params setObject:(_sorting == 0) ? @"asc" : @"desc" forKey:@"order"];
    
    [self makeRequest:@"POST" baseURL:kEventsBaseURL path:path params:params completion:block];
}

#pragma mark - Push

- (void)registerDeviceWithToken:(NSData *)tokenData
                  userReference:(NSString *)reference
                     completion:(RequestBlock)block
{
    NSString *path = [NSString stringWithFormat:@"/users/%@/mobile-tokens", reference];
    NSString *tokenString = [[[[tokenData description]
                     stringByReplacingOccurrencesOfString: @"<" withString: @""]
                    stringByReplacingOccurrencesOfString: @">" withString: @""]
                   stringByReplacingOccurrencesOfString: @" " withString: @""];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:tokenString forKey:@"token"];
    
    [[NSUserDefaults standardUserDefaults] setObject:tokenString forKey:@"__ditosdk__pushToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self makeRequest:@"POST" baseURL:kNotificationBaseURL path:path params:params completion:block];
}

- (void)disableDeviceWithUserReference:(NSString *)reference
                            completion:(RequestBlock)block
{
    NSString *path = [NSString stringWithFormat:@"/users/%@/mobile-tokens/disable", reference];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"___ditosdk__pushToken"] forKey:@"token"];
    
    [self makeRequest:@"POST" baseURL:kNotificationBaseURL path:path params:params completion:block];
}

- (NSDictionary *)checkAppLaunchForNotification:(NSDictionary *)launchOptions
{
    NSDictionary *notification = [launchOptions objectForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
    if (notification == nil)
        return nil;
    else {
        NSString *path = [NSString stringWithFormat:@"/notifications/%@/open", notification[@"id"]];
        
        NSMutableDictionary *params = [NSMutableDictionary new];
        [params setObject:[self objectToJSONString:notification] forKey:@"data"];
        
        [self makeRequest:@"POST" baseURL:kNotificationBaseURL path:path params:params completion:nil];
        
        return notification;
    }
}

#pragma mark - Encryption

- (NSString *)EncryptMessage:(NSString *)message {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"plataforma_social" ofType:@"pem"];
    FILE *pubkey = fopen([path cStringUsingEncoding:1], "r");
    if (pubkey == NULL) {
        NSLog(@"duh: %@", [path stringByAppendingString:@" not found"]);
        return NULL;
    }
    
    RSA *rsa = PEM_read_RSAPublicKey(pubkey, NULL, NULL, NULL);
    //pem_read_rsa
    if (rsa == NULL) {
        NSLog(@"Error reading RSA public key.");
        return NULL;
    }
    
    const char *msgInChar = [message UTF8String];
    const unsigned char *plaintext = (unsigned char *)[message UTF8String];
    unsigned char encrypted[RSA_size(rsa)];
    //unsigned char *encrypted = (unsigned char *) malloc(128); //I'm not so sure about this size
    const int bufferSize = RSA_public_encrypt((int)strlen(msgInChar), plaintext, encrypted, rsa, RSA_PKCS1_PADDING);
    if (bufferSize == -1) {
        NSLog(@"Encryption failed");
        return NULL;
    }
    
    BIO *base64 = BIO_new(BIO_s_mem());
    base64 = BIO_push(BIO_new(BIO_f_base64()), base64);
    BIO_write(base64, encrypted, bufferSize);
    BIO_flush(base64);
    char *base64Data;
    const long base64Length = BIO_get_mem_data(base64, &base64Data);
    NSMutableString *base64String = [NSMutableString new];
    for (int i = 0; i < base64Length; ++i)
        [base64String appendFormat:@"%c", base64Data[i]];
    
    return base64String;
}

#pragma mark - General

- (NSString *)objectToJSONString:(id)object
{
    NSData *JSONData = [NSJSONSerialization dataWithJSONObject:([object isKindOfClass:[NSDictionary class]]) ? ((object[@"event"] == nil) ? object : object[@"event"]) : object
                        options:0
                             error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:JSONData encoding:NSUTF8StringEncoding];
    return jsonString;
}


@end

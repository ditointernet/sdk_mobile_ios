//
//  DitoAPI.m
//  DitoSDK
//
//  Created by Marcos Lacerda on 31/03/15.
//
//

#import "DitoAPI.h"
#import "DitoConstants.h"
#import "DitoUtils.h"
#import "DitoReachability.h"

@implementation DitoAPI

static DitoReachability *reachability;
static BOOL internetDown;
static NSMutableArray *eventsOffLine;
static DitoCredentials *credentialsOffLine;

+(void)configureEnvironment:(EnvironmentType)environment {
    kEnvironment = environment;
}

+(void)configure:(NSString *)apiKey secret:(NSString *)secret {
    kApiKey = apiKey;
    kSecret = secret;
    kSignature = [DitoUtils encriptCredentials];
    internetDown = NO;
    
    // Start monitor networking connection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChanged:) name:kDitoReachabilityChangedNotification object:nil];
    
    reachability = [DitoReachability reachabilityForInternetConnection];
    [reachability startNotifier];
}

+(void)identify:(DitoCredentials *)credentials accessToken:(NSString *)accessToken data:(NSDictionary *)data completion:(void (^)(id, NSError *))block {
    if (![self validateData:block]) {
        return;
    } else if (![self validateUseReference:block method:@"identify" credentials:credentials]) {
        return;
    }
    
    NSString *baseURL = @"";
    
    if (kEnvironment == PRODUCTION) {
        baseURL = [NSString stringWithFormat:kIdentifyURL, @"s", @""];
    } else {
        baseURL = [NSString stringWithFormat:kIdentifyURL, @"", @"dev."];
    }
    
    NSString *url = [NSString stringWithFormat:@"%@%@/%@/signup", baseURL, [self getNetwork:credentials], [self getSocialID:credentials]];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    if ([[self getNetwork:credentials] isEqualToString:@"portal"]) {
        [params setValue:credentials._id forKey:[self getIdentifyKey:credentials]];
    } else {
        [params setValue:[self getSocialID:credentials] forKey:[self getIdentifyKey:credentials]];
        [params setValue:accessToken forKey:kAccessToken];
    }
    
    [params setValue:data forKey:kUserData];
    
    [self peformRequest:POST url:url params:params completion:block];
}

+(void)track:(DitoCredentials *)credentials event:(NSDictionary *)event completion:(void (^)(id, NSError *))block {
    if (![self validateData:block]) {
        return;
    } else if (![self validateUseReference:block method:@"track" credentials:credentials]) {
        return;
    }
    
    if (!eventsOffLine) {
        eventsOffLine = [[NSMutableArray alloc] initWithArray:[self loadEventsOffline] copyItems:YES];
        
        if (!eventsOffLine) {
            eventsOffLine = [[NSMutableArray alloc] init];
        }
    }
    
    if (internetDown) {
        if (!credentialsOffLine) {
            credentialsOffLine = credentials;
        }
        
        [eventsOffLine addObject:event];
        [self saveEventsOffline:eventsOffLine];
        
        if (block) {
            block(@"{\"message\" : \"O evento foi armazenado para ser enviado mais tarde, devido a falta de conexão com a internet.\", \"success\" : \"true\"}", nil);
        }
        
        return;
    }
    
    NSString *baseURL = @"";
    
    if (kEnvironment == PRODUCTION) {
        baseURL = [NSString stringWithFormat:kTrackURL, @"s", @""];
    } else {
        baseURL = [NSString stringWithFormat:kTrackURL, @"", @"dev."];
    }
    
    NSString *url = [NSString stringWithFormat:@"%@%@", baseURL, [self getSocialID:credentials]];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    if (![[self getIdentifyKey:credentials] isEqualToString:@"reference"]) {
        [params setValue:[self getIdentifyKey:credentials] forKey:kIdType];
    }
    
    NSData *eventData = [NSJSONSerialization dataWithJSONObject:event options:0 error:nil];
    NSString *jsonEvent = @"";
    
    if (!eventData) {
        jsonEvent = @"{}";
    } else {
        jsonEvent = [[NSString alloc] initWithData:eventData encoding:NSUTF8StringEncoding];
    }
    
    [params setValue:jsonEvent forKey:kEvent];
    
    [self peformRequest:POST url:url params:params completion:block];
}

+(void)alias:(DitoCredentials *)credentials accounts:(NSArray *)accounts completion:(void(^)(id response, NSError *error))block {
    if (![self validateData:block]) {
        return;
    } else if (![self validateUseReference:block method:@"alias" credentials:credentials]) {
        return;
    }
    
    NSString *url = @"";
    
    if (kEnvironment == PRODUCTION) {
        url = [NSString stringWithFormat:kAliasURL, @"s", @"", [self getSocialID:credentials]];
    } else {
        url = [NSString stringWithFormat:kAliasURL, @"", @"dev.", [self getSocialID:credentials]];
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *accountsData = [[NSMutableDictionary alloc] init];
    
    [params setValue:[self getIdentifyKey:credentials] forKey:kIdType];

    for (DitoAccount *account in accounts) {
        if (account) {
            if (account.type != PORTAL && !account.data) {
                [accountsData setValue:@{@"id" : account._id, @"access_token" : account.accessToken} forKey:[self getAccountType:account.type]];
            } else if (account.data && account.type == PORTAL) {
                NSMutableDictionary *userData = [account.data mutableCopy];
                
                [userData setValue:account._id forKey:@"id"];
                
                [accountsData setValue:userData forKey:[self getAccountType:account.type]];
            } else {
                if (block) {
                    NSError *error = [[NSError alloc] initWithDomain:@"" code:-1 userInfo:@{@"message" : @"O parâmetro \"data\" só pode ser utilizado para contas do tipo \"PORTAL\"."}];
                    
                    block(nil, error);
                } else {
                    [NSException raise:@"O parâmetro \"data\" só pode ser utilizado para contas do tipo \"PORTA\"." format:nil, nil];
                }
            }
        }
    }

    [params setValue:accountsData forKey:@"accounts"];
    
    [self peformRequest:POST url:url params:params completion:block];
}

+(void)unalias:(DitoCredentials *)credentials accounts:(NSArray *)accounts completion:(void (^)(id, NSError *))block {
    if (![self validateData:block]) {
        return;
    } else if (![self validateUseReference:block method:@"unalias" credentials:credentials]) {
        return;
    }
    
    NSString *url = @"";
    
    if (kEnvironment == PRODUCTION) {
        url = [NSString stringWithFormat:kUnaliasURL, @"s", @"", [self getSocialID:credentials]];
    } else {
        url = [NSString stringWithFormat:kUnaliasURL, @"", @"dev.", [self getSocialID:credentials]];
    }
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *accountsData = [[NSMutableDictionary alloc] init];
    
    [params setValue:[self getIdentifyKey:credentials] forKey:kIdType];
    
    for (DitoAccount *account in accounts) {
        if (account) {
            [accountsData setValue:@{@"id" : account._id} forKey:[self getAccountType:account.type]];
        }
    }
    
    [params setValue:accountsData forKey:@"accounts"];
    
    [self peformRequest:POST url:url params:params completion:block];
}

+(void)registerDevice:(DitoCredentials *)credentials deviceToken:(NSString *)deviceToken completion:(void (^)(id, NSError *))block {
    if (![self validateData:block]) {
        return;
    } else if (![self validateUseReference:block method:@"registerDevice" credentials:credentials]) {
        return;
    }
    
    NSString *baseURL = @"";
    
    if (kEnvironment == PRODUCTION) {
        baseURL = [NSString stringWithFormat:kRegisterDeviceURL, @"s", @""];
    } else {
        baseURL = [NSString stringWithFormat:kRegisterDeviceURL, @"", @"dev."];
    }
    
    NSString *url = [NSString stringWithFormat:@"%@%@/mobile-tokens", baseURL, [self getSocialID:credentials]];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setValue:deviceToken forKey:kToken];
    [params setValue:kAppleiPhone forKey:kPlatform];
    [params setValue:[self getIdentifyKey:credentials] forKey:kIdType];

    [self peformRequest:POST url:url params:params completion:block];
}

+(void)unregisterDevice:(DitoCredentials *)credentials deviceToken:(NSString *)deviceToken completion:(void (^)(id, NSError *))block {
    if (![self validateData:block]) {
        return;
    } else if (![self validateUseReference:block method:@"unregisterDevice" credentials:credentials]) {
        return;
    }
    
    NSString *baseURL = @"";
    
    if (kEnvironment == PRODUCTION) {
        baseURL = [NSString stringWithFormat:kUnregisterDeviceURL, @"s", @""];
    } else {
        baseURL = [NSString stringWithFormat:kUnregisterDeviceURL, @"", @"dev."];
    }
    
    NSString *url = [NSString stringWithFormat:@"%@%@/mobile-tokens/disable", baseURL, [self getSocialID:credentials]];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setValue:deviceToken forKey:kToken];
    [params setValue:kAppleiPhone forKey:kPlatform];
    [params setValue:[self getIdentifyKey:credentials] forKey:kIdType];
    
    [self peformRequest:POST url:url params:params completion:block];
}

+(void)request:(NSString *)module path:(NSString *)path params:(NSMutableDictionary *)params requestType:(HttpTypes)requestType completion:(void (^)(id, NSError *))block {
    if ([[DitoUtils trimmingString:module] isEqualToString:@""]) {
        if (block) {
            NSError *error = [[NSError alloc] initWithDomain:@"" code:-1 userInfo:@{@"message" : @"É obrigatório informar o módulo para continuar."}];
            
            block(nil, error);
        } else {
            [NSException raise:@"É obrigatório informar o módulo para continuar." format:nil, nil];
        }
        
        return;
    }
    
    NSString *baseURL = @"http%@://%@%@.plataformasocial.com.br%@";
    NSString *url = @"";
    
    if (![[DitoUtils trimmingString:path] isEqualToString:@""]) {
        if (![[path substringToIndex:1] isEqualToString:@"/"]) {
            path = [@"/" stringByAppendingString:path];
        }
        
        if (kEnvironment == PRODUCTION) {
            url = [NSString stringWithFormat:baseURL, @"s", module, @"", path];
        } else {
            url = [NSString stringWithFormat:baseURL, @"", module, @".dev", path];
        }
    } else {
        if (kEnvironment == PRODUCTION) {
            url = [NSString stringWithFormat:baseURL, @"s", module, @"", @""];
        } else {
            url = [NSString stringWithFormat:baseURL, @"", module, @".dev", @""];
        }
    }
    
    NSString *method = [self getMethod:requestType];
    
    // Create a request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    // Configure request parameters fixed
    [request setHTTPMethod:method];
    [request setCachePolicy:(NSURLRequestReloadIgnoringCacheData)];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    if (![method isEqualToString:@"GET"]) {
        [params setValue:kApiKey forKey:kPlataformApiKey];
        [params setValue:kSignature forKey:kSHA1Signature];
        
        NSString *json;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
        
        if (!jsonData) {
            json = @"{}";
        } else {
            json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
        
        if (![[DitoUtils trimmingString:json] isEqualToString:@""]) {
            NSData *requestData = [json dataUsingEncoding:NSUTF8StringEncoding];
            [request setHTTPBody:requestData];
        }
    } else {
        // Verificar como tratar esse caso
        if (![[url substringFromIndex:[url length] - 1] isEqualToString:@"?"]) {
            url = [url stringByAppendingString:@"?"];
        } else {
            url = [url stringByAppendingString:@"&"];
        }
        
        url = [NSString stringWithFormat:@"%@%@=%@", url, kPlataformApiKey, [kApiKey stringByAppendingString:@"&"]];
        
        if (params && [params count] == 0) {
            url = [NSString stringWithFormat:@"%@%@=%@", url, kSHA1Signature, kSignature];
        } else {
            url = [NSString stringWithFormat:@"%@%@=%@", url, kSHA1Signature, [kSignature stringByAppendingString:@"&"]];
        }
        
        // Adicionando demais parâmetros via query String
        for (NSString *key in [params allKeys]) {
            url = [NSString stringWithFormat:@"%@%@=%@", url, key, [[params objectForKey:key] stringByAppendingString:@"&"]];
        }
        
        // Removendo o último "&" se houver
        if ([[url substringFromIndex:[url length] - 1] isEqualToString:@"&"]) {
            url = [url substringToIndex:[url length] - 1];
        }
    }
    
    [request setURL:[NSURL URLWithString:url]];
    
    // Create handle variables
    NSHTTPURLResponse *urlResponse = nil;
    NSError *error = nil;
    
    // Executing request and retrieve response
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    
    NSString *jsonResponse = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    
    if (block) {
        block(jsonResponse, error);
    }
}

+(void)notificationRead:(DitoCredentials *)credentials message:(NSString *)message completion:(void (^)(id, NSError *))block {
    if (![self validateData:block]) {
        return;
    } else if (!message || [[DitoUtils trimmingString:message] isEqualToString:@""]) {
        if (block) {
            NSError *error = [[NSError alloc] initWithDomain:@"" code:-1 userInfo:@{@"message" : @"O parâmetro \"message\" é obrigatório."}];
            
            block(nil, error);
        } else {
            [NSException raise:@"O parâmetro \"message\" é obrigatório." format:nil, nil];
        }
        
        return;
    }
    
    NSData *messageData = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSString *identifier = @"";
    NSError *error;
    NSDictionary *jsonMessage = [NSJSONSerialization JSONObjectWithData:messageData options:kNilOptions error:&error];
    
    if (error) {
        NSLog(@"Erro ao efetuar o parse do json: %@", [error localizedDescription]);
        
        if (block) {
            block(nil, error);
        }
        
        return;
    }
    
    if (!jsonMessage || !jsonMessage[@"notification"]) {
        NSLog(@"O json fornecido não está no formato esperado.");
        
        if (block) {
            block(nil, [[NSError alloc] initWithDomain:@"" code:-1 userInfo:@{@"message" : @"O json fornecido não está no formato esperado."}]);
        }
        
        return;
    }
    
    identifier = jsonMessage[@"notification"];
    
    NSString *baseURL = @"";
    
    if (kEnvironment == PRODUCTION) {
        baseURL = [NSString stringWithFormat:kNotificationReadURL, @"s", @""];
    } else {
        baseURL = [NSString stringWithFormat:kNotificationReadURL, @"", @"dev."];
    }
    
    NSString *url = [NSString stringWithFormat:@"%@%@/open", baseURL, identifier];

    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    
    [params setValue:kMobile forKey:kChannelType];
    [params setValue:[self getIdentifyKey:credentials] forKey:kIdType];
    [params setValue:[self getSocialID:credentials] forKey:@"id"];
    
    if(jsonMessage[@"notification_log_id"]){
      NSString *notificationLogId = @"";
      notificationLogId = jsonMessage[@"notification_log_id"]
      [params setValue:notificationLogId forKey:@"notification_log_id"];
    }
    
    [self peformRequest:POST url:url params:params completion:block];
}

+(void)trackBatch:(DitoCredentials *)credentials events:(NSArray *)events completion:(void (^)(id, NSError *))block {
    [NSException raise:@"Not implemented yet." format:@""];
}

#pragma mark -
#pragma mark - Private methods

+(NSString *)getNetwork:(DitoCredentials *)credentials {
    if (!credentials) {
        return nil;
    }
    
    if ([DitoUtils trimmingString:credentials._id] && ![[DitoUtils trimmingString:credentials._id] isEqualToString:@""]) {
        return @"portal";
    } else if ([DitoUtils trimmingString:credentials.facebookID] && ![[DitoUtils trimmingString:credentials.facebookID] isEqualToString:@""]) {
        return @"facebook";
    } else if ([DitoUtils trimmingString:credentials.twitterID] && ![[DitoUtils trimmingString:credentials.twitterID] isEqualToString:@""]) {
        return @"twitter";
    } else if ([DitoUtils trimmingString:credentials.googlePlusID] && ![[DitoUtils trimmingString:credentials.googlePlusID] isEqualToString:@""]) {
        return @"plus";
    }
    
    return nil;
}

+(NSString *)getIdentifyKey:(DitoCredentials *)credentials {
    if (!credentials) {
        return nil;
    }
    
    if ([DitoUtils trimmingString:credentials._id] && ![[DitoUtils trimmingString:credentials._id] isEqualToString:@""]) {
        return @"id";
    } else if ([DitoUtils trimmingString:credentials.facebookID] && ![[DitoUtils trimmingString:credentials.facebookID] isEqualToString:@""]) {
        return @"facebook_id";
    } else if ([DitoUtils trimmingString:credentials.twitterID] && ![[DitoUtils trimmingString:credentials.twitterID] isEqualToString:@""]) {
        return @"twitter_id";
    } else if ([DitoUtils trimmingString:credentials.googlePlusID] && ![[DitoUtils trimmingString:credentials.googlePlusID] isEqualToString:@""]) {
        return @"google_plus_id";
    } else if ([DitoUtils trimmingString:credentials.reference] && ![[DitoUtils trimmingString:credentials.reference] isEqualToString:@""]) {
        return @"reference";
    }
    
    return nil;
}

+(NSString *)getSocialID:(DitoCredentials *)credentials {
    if (!credentials) {
        return nil;
    }
    
    if ([DitoUtils trimmingString:credentials._id] && ![[DitoUtils trimmingString:credentials._id] isEqualToString:@""]) {
        return credentials._id;
    } else if ([DitoUtils trimmingString:credentials.facebookID] && ![[DitoUtils trimmingString:credentials.facebookID] isEqualToString:@""]) {
        return credentials.facebookID;
    } else if ([DitoUtils trimmingString:credentials.twitterID] && ![[DitoUtils trimmingString:credentials.twitterID] isEqualToString:@""]) {
        return credentials.twitterID;
    } else if ([DitoUtils trimmingString:credentials.googlePlusID] && ![[DitoUtils trimmingString:credentials.googlePlusID] isEqualToString:@""]) {
        return credentials.googlePlusID;
    } else if ([DitoUtils trimmingString:credentials.reference] && ![[DitoUtils trimmingString:credentials.reference] isEqualToString:@""]) {
        return credentials.reference;
    }
    
    return nil;
}

+(BOOL)validateData:(void (^)(id, NSError *))block {
    if (!kApiKey || !kSecret) {
        if (block) {
            NSError *error = [[NSError alloc] initWithDomain:@"" code:-1 userInfo:@{@"message" : @"Para continuar é necessário fornecer \"SUA_API_KEY\" e/ou \"SUA_SECRET\""}];
            
            block(nil, error);
            
            return NO;
        } else {
            [NSException raise:@"Para continuar é necessário fornecer \"SUA_API_KEY\" e/ou \"SUA_SECRET\"" format:nil, nil];
            
            return NO;
        }
    }
    
    return YES;
}

+(BOOL)validateUseReference:(void (^)(id, NSError *))block method:(NSString *)methodName credentials:(DitoCredentials *)credentials {
    if (([methodName isEqualToString:@"identify"] || [methodName isEqualToString:@"alias"] || [methodName isEqualToString:@"unalias"]) && ([DitoUtils trimmingString:credentials.reference] && ![[DitoUtils trimmingString:credentials.reference] isEqualToString:@""])) {
        if (block) {
            NSError *error = [[NSError alloc] initWithDomain:@"" code:-1 userInfo:@{@"message" : @"Não é possível utilizar o atributo \"reference\" para esta requisição."}];
            
            block(nil, error);
            
            return NO;
        } else {
            [NSException raise:@"Não é possível utilizar o atributo \"reference\" para esta requisição." format:nil, nil];
            
            return NO;
        }
    }
    
    return YES;
}

+(NSString *)getAccountType:(AccountsType)type {
    switch (type) {
        case FACEBOOK: return @"facebook";
        case TWITTER: return @"twitter";
        case GOOGLE_PLUS: return @"plus";
        case PORTAL: return @"portal";
            
        default: return @"";
    }
}

+(NSString *)getMethod:(HttpTypes)requestType {
    switch (requestType) {
        case GET: return @"GET";
        case PUT: return @"PUT";
        case POST: return @"POST";
        case DELETE: return @"DELETE";
        default: return @"";
    }
}

+(void)peformRequest:(HttpTypes)requestType url:(NSString *)url params:(NSMutableDictionary *)params completion:(void (^)(id, NSError *))block {
    // Create a request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    NSString *method = [self getMethod:requestType];
    
    // Configure request parameters fixed
    [request setHTTPMethod:method];
    [request setURL:[NSURL URLWithString:url]];
    [request setCachePolicy:(NSURLRequestReloadIgnoringCacheData)];
    [request setValue:kAppicationJson forHTTPHeaderField:kContentType];
    [request setValue:@"iPhone" forHTTPHeaderField:@"User-Agent"];
    
    [params setValue:kApiKey forKey:kPlataformApiKey];
    [params setValue:kSignature forKey:kSHA1Signature];
    
    NSString *json = @"";
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:params options:0 error:nil];
    
    if (!jsonData) {
        json = @"{}";
    } else {
        json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    if (![[DitoUtils trimmingString:json] isEqualToString:@""]) {
        NSData *requestData = [json dataUsingEncoding:NSUTF8StringEncoding];
        [request setHTTPBody:requestData];
    }
    
    // Create handle variables
    NSHTTPURLResponse *urlResponse = nil;
    NSError *error = nil;
    
    // Executing request and retrieve response
    NSData *response = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    
    NSString *jsonResponse = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    
    if (block) {
        block(jsonResponse, error);
    }
}

#pragma mark -
#pragma mark - Internet connections

+(void)networkChanged:(NSNotification *)notification {
    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
    internetDown = (remoteHostStatus == NotReachable);
    
    if (!internetDown) {
        NSArray *events = [self loadEventsOffline];
        
        if (events && [events count] > 0) {
            for (NSDictionary *event in events) {
                [self track:credentialsOffLine event:event completion:nil];
            }
            
            credentialsOffLine = nil;
            eventsOffLine = nil;
            
            [self removeEventsOffline];
        }
    }
}

#pragma mark -
#pragma mark - Preference methods

+(void)saveEventsOffline:(NSArray *)events {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:events];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    [prefs setObject:data forKey:@"events_offline"];
    [prefs synchronize];
}

+(NSArray *)loadEventsOffline {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSData *data = [prefs objectForKey:@"events_offline"];
    return [NSKeyedUnarchiver unarchiveObjectWithData:data];
}

+(void)removeEventsOffline {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs removeObjectForKey:@"events_offline"];
    [prefs synchronize];
}

@end
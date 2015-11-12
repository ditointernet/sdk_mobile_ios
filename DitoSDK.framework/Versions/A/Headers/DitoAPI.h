//
//  DitoAPI.h
//  DitoSDK
//
//  Created by Marcos Lacerda on 31/03/15.
//
//

#import <Foundation/Foundation.h>
#import "DitoCredentials.h"
#import "DitoAccount.h"
#import "DitoEnums.h"


static EnvironmentType kEnvironment = PRODUCTION;

@interface DitoAPI : NSObject

+(void)configureEnvironment:(EnvironmentType)environment;

+(void)configure:(NSString *)apiKey secret:(NSString *)secret;

+(void)identify:(DitoCredentials *)credentials accessToken:(NSString *)accessToken data:(NSDictionary *)data completion:(void(^)(id response, NSError *error))block;

+(void)track:(DitoCredentials *)credentials event:(NSDictionary *)event completion:(void(^)(id response, NSError *error))block;

+(void)alias:(DitoCredentials *)credentials accounts:(NSArray *)accounts completion:(void(^)(id response, NSError *error))block;

+(void)unalias:(DitoCredentials *)credentials accounts:(NSArray *)accounts completion:(void(^)(id response, NSError *error))block;

+(void)registerDevice:(DitoCredentials *)credentials deviceToken:(NSString *)deviceToken completion:(void(^)(id response, NSError *error))block;

+(void)unregisterDevice:(DitoCredentials *)credentials deviceToken:(NSString *)deviceToken completion:(void(^)(id response, NSError *error))block;

+(void)request:(NSString *)module path:(NSString *)path params:(NSMutableDictionary *)params requestType:(HttpTypes)requestType completion:(void(^)(id response, NSError *error))block;

+(void)notificationRead:(DitoCredentials *)credentials message:(NSString *)message completion:(void(^)(id response, NSError *error))block;

@end
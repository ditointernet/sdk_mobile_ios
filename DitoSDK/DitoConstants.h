//
//  DitoConstants.h
//  DitoSDK
//
//  Created by Marcos Lacerda on 31/03/15.
//
//

#import <Foundation/Foundation.h>
#import "DitoEnums.h"


NSString *kApiKey;
NSString *kSecret;
NSString *kSignature;

#pragma mark - Headers Values

static NSString *const kAppleiPhone = @"Apple iPhone";
static NSString *const kMobile = @"mobile";
static NSString *const kAppicationJson = @"application/json";

#pragma mark - Headers Identifiers

static NSString *const kPlataformApiKey = @"platform_api_key";
static NSString *const kSHA1Signature = @"sha1_signature";
static NSString *const kAccessToken = @"access_token";
static NSString *const kUserData = @"user_data";
static NSString *const kEvent = @"event";
static NSString *const kIdType = @"id_type";
static NSString *const kToken = @"token";
static NSString *const kPlatform = @"platform";
static NSString *const kChannelType = @"channel_type";
static NSString *const kContentType = @"Content-Type";

#pragma mark - URLs Definitions

static NSString *const kIdentifyURL = @"http%@://login.%@plataformasocial.com.br/users/";
static NSString *const kTrackURL = @"http%@://events.%@plataformasocial.com.br/users/";
static NSString *const kAliasURL = @"http%@://login.%@plataformasocial.com.br/users/%@/link";
static NSString *const kUnaliasURL = @"http%@://login.%@plataformasocial.com.br/users/%@/unlink";
static NSString *const kRegisterDeviceURL = @"http%@://notification.%@plataformasocial.com.br/users/";
static NSString *const kUnregisterDeviceURL = @"http%@://notification.%@plataformasocial.com.br/users/";
static NSString *const kNotificationReadURL = @"http%@://notification.%@plataformasocial.com.br/notifications/";

@interface DitoConstants : NSObject

@end
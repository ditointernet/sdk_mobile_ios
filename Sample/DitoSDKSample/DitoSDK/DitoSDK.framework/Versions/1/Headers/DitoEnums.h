//
//  DitoEnums.h
//  DitoSDK
//
//  Created by Marcos Lacerda on 08/04/15.
//
//

#import <Foundation/Foundation.h>

typedef enum {
    PUT,
    GET,
    DELETE,
    POST
} HttpTypes;

typedef enum {
    PRODUCTION,
    DEVELOPMENT
} EnvironmentType;

typedef enum {
    FACEBOOK,
    TWITTER,
    GOOGLE_PLUS,
    PORTAL
} AccountsType;

@interface DitoEnums : NSObject

@end
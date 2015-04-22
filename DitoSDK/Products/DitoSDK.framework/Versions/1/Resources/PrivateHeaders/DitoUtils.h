//
//  DitoUtils.h
//  DitoSDK
//
//  Created by Marcos Lacerda on 31/03/15.
//
//

#import <Foundation/Foundation.h>

@interface DitoUtils : NSObject

+(NSString *)encriptCredentials;
+(NSString *)trimmingString:valueToTrimming;
+(NSString *)getUserAgentString;

@end
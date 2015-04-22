//
//  DitoUtils.m
//  DitoSDK
//
//  Created by Marcos Lacerda on 31/03/15.
//
//

#import "DitoUtils.h"
#import "DitoConstants.h"
#import <CommonCrypto/CommonDigest.h>

@implementation DitoUtils

+(NSString *)encriptCredentials {
 
    const char *cstr = [kSecret cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:kSecret.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (CC_LONG) data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

+(NSString *)trimmingString:(id)valueToTrimming {
    if (!valueToTrimming) {
        return nil;
    }
    
    return [valueToTrimming stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+(NSString *)getUserAgentString {
    return @"(Mobile)";
}

@end
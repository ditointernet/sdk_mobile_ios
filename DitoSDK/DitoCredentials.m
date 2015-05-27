//
//  DitoCredentials.m
//  DitoSDK
//
//  Created by Marcos Lacerda on 31/03/15.
//
//

#import "DitoCredentials.h"

@implementation DitoCredentials

-(DitoCredentials *)initWithID:(NSString *)identifier facebookID:(NSString *)fbID googlePlusID:(NSString *)gpID twitterID:(NSString *)twID reference:(NSString *)userReference {
    self._id = identifier;
    self.facebookID = fbID;
    self.googlePlusID = gpID;
    self.twitterID = twID;
    self.reference = userReference;
    
    return self;
}

@end
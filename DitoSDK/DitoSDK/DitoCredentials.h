//
//  DitoCredentials.h
//  DitoSDK
//
//  Created by Marcos Lacerda on 31/03/15.
//
//

#import <Foundation/Foundation.h>

@interface DitoCredentials : NSObject

@property (strong, nonatomic) NSString *_id;
@property (strong, nonatomic) NSString *facebookID;
@property (strong, nonatomic) NSString *googlePlusID;
@property (strong, nonatomic) NSString *twitterID;
@property (strong, nonatomic) NSString *reference;

-(DitoCredentials *)initWithID:(NSString *)identifier facebookID:(NSString *)fbID googlePlusID:(NSString *)gpID twitterID:(NSString *)twID reference:(NSString *)userReference;

@end
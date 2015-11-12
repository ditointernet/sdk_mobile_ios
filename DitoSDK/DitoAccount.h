//
//  DitoAccount.h
//  DitoSDK
//
//  Created by Marcos Lacerda on 02/04/15.
//
//

#import <Foundation/Foundation.h>
#import "DitoEnums.h"


@interface DitoAccount : NSObject

@property (strong, nonatomic) NSString *_id;
@property (strong, nonatomic) NSString *accessToken;
@property (assign, nonatomic) AccountsType type;
@property (assign, nonatomic) NSDictionary *data;

-(DitoAccount *)initWithID:(NSString *)identifier accessToken:(NSString *)token type:(AccountsType)accountType;

-(DitoAccount *)initWithID:(NSString *)identifier type:(AccountsType)accountType;

-(DitoAccount *)initWithID:(NSString *)identifier data:(NSDictionary *)data type:(AccountsType)accountType;

@end
//
//  DitoAccount.m
//  DitoSDK
//
//  Created by Marcos Lacerda on 02/04/15.
//
//

#import "DitoAccount.h"

@implementation DitoAccount

-(DitoAccount *)initWithID:(NSString *)identifier accessToken:(NSString *)token type:(AccountsType)accountType {
    self._id = identifier;
    self.accessToken = token;
    self.type = accountType;
    
    return self;
}

-(DitoAccount *)initWithID:(NSString *)identifier type:(AccountsType)accountType {
    self._id = identifier;
    self.type = accountType;
    
    return self;
}

-(DitoAccount *)initWithID:(NSString *)identifier data:(NSDictionary *)data type:(AccountsType)accountType {
    self._id = identifier;
    self.type = accountType;
    self.data = data;
    
    return self;
}

@end
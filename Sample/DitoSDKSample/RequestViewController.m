//
//  RequestViewController.m
//  DitoSDKSample
//
//  Created by Marcos Lacerda on 08/04/15.
//  Copyright (c) 2015 Dito. All rights reserved.
//

#import "RequestViewController.h"
#import "MBProgressHUD.h"
#import <DitoSDK/DitoAPI.h>
#import "AppDelegate.h"

@interface RequestViewController ()

@end

@implementation RequestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    labelTitle.text = _methodName;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self callSDK];
}

-(IBAction)backAView:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
-(void)setText:(id)sender
{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    labelJsonResponse.text = [NSString stringWithFormat:@"%@", sender];

}
-(void)callSDK {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    switch (_tag) {
        case 0: {
            NSString *jsonRequest = @"{\"sha1_signature\":\"29feaa6fd8a6ba7ca745f9083e3d3e07c2107137\",\"platform_api_key\":\"MjAxNS0wMy0zMSAxMToxOToyNCAtMDMwME1vYmlsZSBTREtzMTI4\",\"facebook_id\":\"10205082116146301\",\"access_token\":\"CAAWC8vPa5uEBAFs59ouBWCkkA0cZCy8i8yaVFPZBni77N818DJhRTW8HLGBVGGqlXRsIigQldtbl2EAMGgPp5TjUg0AkIeNCyZCkC8mVAQnynUjWlktHIK2v9BrDjS4fIDASIMZBjCCdjucAtfJkSCxvjHhIa0AQ5Xqx2kjhK4ZBRpHQI2r8BZBmpZC4WnZCZA7YFn1zmI6VB2JRmuya8cg77Vi9xUhPIomZCxsu0nvQL3ygZDZD\"}";
            
            labelJsonRequest.text = jsonRequest;
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            NSString *kAccessToken = @"CAAV9fG4JUfcBAH6KfAL3cbJx5Sq0CuKLWXaZCo3gLxneGPd3OZC5wxpvaLN2hL4reuRfLfkji4EzSYB8XxXHaXae5I5ZAH6BHZBAZB7VtyqPTJLRQ2yQoTDXgCbPHTvLZCWYYOPDgSjKBs4wssenZB8P8aqBFwAZAKlilfaj4y6zHDO2tdcWafkirQibT7ajMGrx3S2tJEOzTa2XhOq5mybS02xptJ0W8cPolov4XBVOtauTfGTlovMKss4SOjJdGtUBxBTAPG61NAZDZD";
            
            NSDictionary *kUser = @{@"name" : @"Sample Teste", @"email" : @"sample@teste.com.br", @"data_nascimento" : @"1900-01-01"};
            
            [DitoAPI identify:delegate.credentials accessToken:kAccessToken data:kUser completion:^(id response, NSError *error) {
                
                
                if (error) {
                    [self performSelectorOnMainThread:@selector(setText:) withObject:error waitUntilDone:YES];
                } else if (response) {
                    [self performSelectorOnMainThread:@selector(setText:) withObject:response waitUntilDone:YES];

                }
            }];
        }
            
            break;
            
        case 1: {
            NSString *jsonRequest = @"{\"id_type\":\"facebook_id\",\"sha1_signature\":\"29feaa6fd8a6ba7ca745f9083e3d3e07c2107137\",\"platform_api_key\":\"MjAxNS0wMy0zMSAxMToxOToyNCAtMDMwME1vYmlsZSBTREtzMTI4\",\"event\":\"{\"revenue\":\"0.00\",\"action\":\"Evento Sample\",\"data\":{\"name\":\"Track Sample\"}}\"}";
            
            labelJsonRequest.text = jsonRequest;
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            NSDictionary *kEvent = @{@"action" : @"Evento Sample", @"revenue" : @"0.00", @"data" : @{@"name" : @"Track Sample"}};
            
            [DitoAPI track:delegate.credentials event:kEvent completion:^(id response, NSError *error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                if (error) {
                    labelJsonResponse.text = [NSString stringWithFormat:@"%@", error];
                } else if (response) {
                    labelJsonResponse.text = [NSString stringWithFormat:@"%@", response];
                }
            }];
        }
            break;
            
        case 2: {
            NSString *jsonRequest = @"{\"id_type\":\"facebook_id\",\"sha1_signature\":\"29feaa6fd8a6ba7ca745f9083e3d3e07c2107137\",\"platform_api_key\":\"MjAxNS0wMy0zMSAxMToxOToyNCAtMDMwME1vYmlsZSBTREtzMTI4\",\"accounts\":{\"facebook\":{\"id\":\"1574730112774792\",\"access_token\":\"CAAWC8vPa5uEBAFs59ouBWCkkA0cZCy8i8yaVFPZBni77N818DJhRTW8HLGBVGGqlXRsIigQldtbl2EAMGgPp5TjUg0AkIeNCyZCkC8mVAQnynUjWlktHIK2v9BrDjS4fIDASIMZBjCCdjucAtfJkSCxvjHhIa0AQ5Xqx2kjhK4ZBRpHQI2r8BZBmpZC4WnZCZA7YFn1zmI6VB2JRmuya8cg77Vi9xUhPIomZCxsu0nvQL3ygZDZD\"}}}";
            
            labelJsonRequest.text = jsonRequest;
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            DitoAccount *account = [[DitoAccount alloc] initWithID:@"1574730112774792" accessToken:@"CAAWC8vPa5uEBAFs59ouBWCkkA0cZCy8i8yaVFPZBni77N818DJhRTW8HLGBVGGqlXRsIigQldtbl2EAMGgPp5TjUg0AkIeNCyZCkC8mVAQnynUjWlktHIK2v9BrDjS4fIDASIMZBjCCdjucAtfJkSCxvjHhIa0AQ5Xqx2kjhK4ZBRpHQI2r8BZBmpZC4WnZCZA7YFn1zmI6VB2JRmuya8cg77Vi9xUhPIomZCxsu0nvQL3ygZDZD" type:FACEBOOK];
            
            [DitoAPI alias:delegate.credentials accounts:@[account] completion:^(id response, NSError *error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                if (error) {
                    labelJsonResponse.text = [NSString stringWithFormat:@"%@", error];
                } else if (response) {
                    labelJsonResponse.text = [NSString stringWithFormat:@"%@", response];
                }
            }];
        }
            
            break;
            
        case 3: {
            NSString *jsonRequest = @"{\"id_type\":\"facebook_id\",\"sha1_signature\":\"29feaa6fd8a6ba7ca745f9083e3d3e07c2107137\",\"platform_api_key\":\"MjAxNS0wMy0zMSAxMToxOToyNCAtMDMwME1vYmlsZSBTREtzMTI4\",\"accounts\":{\"facebook\":{\"id\":\"1574730112774792\"}}}";
            
            labelJsonRequest.text = jsonRequest;
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            DitoAccount *account = [[DitoAccount alloc] initWithID:@"1574730112774792" type:FACEBOOK];
            
            [DitoAPI unalias:delegate.credentials accounts:@[account] completion:^(id response, NSError *error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                if (error) {
                    labelJsonResponse.text = [NSString stringWithFormat:@"%@", error];
                } else if (response) {
                    labelJsonResponse.text = [NSString stringWithFormat:@"%@", response];
                }
            }];
        }
            
            break;
            
        case 4: {
            NSString *jsonRequest = @"{\"id_type\":\"facebook_id\",\"sha1_signature\":\"29feaa6fd8a6ba7ca745f9083e3d3e07c2107137\",\"platform_api_key\":\"MjAxNS0wMy0zMSAxMToxOToyNCAtMDMwME1vYmlsZSBTREtzMTI4\",\"token\":\"123456\",\"platform\":\"Apple iPhone\"}";
            
            labelJsonRequest.text = jsonRequest;
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            [DitoAPI registerDevice:delegate.credentials deviceToken:@"123456" completion:^(id response, NSError *error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                if (error) {
                    labelJsonResponse.text = [NSString stringWithFormat:@"%@", error];
                } else if (response) {
                    labelJsonResponse.text = [NSString stringWithFormat:@"%@", response];
                }
            }];
        }
            
            break;
            
        case 5: {
            NSString *jsonRequest = @"{\"id_type\":\"facebook_id\",\"sha1_signature\":\"29feaa6fd8a6ba7ca745f9083e3d3e07c2107137\",\"platform_api_key\":\"MjAxNS0wMy0zMSAxMToxOToyNCAtMDMwME1vYmlsZSBTREtzMTI4\",\"token\":\"123456\",\"platform\":\"Apple iPhone\"}";
            
            labelJsonRequest.text = jsonRequest;
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            [DitoAPI unregisterDevice:delegate.credentials deviceToken:@"123456" completion:^(id response, NSError *error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                if (error) {
                    labelJsonResponse.text = [NSString stringWithFormat:@"%@", error];
                } else if (response) {
                    labelJsonResponse.text = [NSString stringWithFormat:@"%@", response];
                }
            }];
        }
            
            break;
            
        case 6: {
            labelJsonRequest.text = @"Simulando uma chamada GET, na qual não haverá json a ser enviado.";
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            NSString *const kModule = @"login";
            NSString *const kPath = @"/app";
            
            [DitoAPI request:kModule path:kPath params:nil requestType:GET completion:^(id response, NSError *error) {
                if (error) {
                    labelJsonResponse.text = [NSString stringWithFormat:@"%@", error];
                } else if (response) {
                    labelJsonResponse.text = [NSString stringWithFormat:@"%@", response];
                }
            }];
        }
            
            break;
            
        case 7: {
            NSString *jsonRequest = @"{\"id_type\":\"facebook_id\",\"id\":\"10205082116146301\",\"sha1_signature\":\"29feaa6fd8a6ba7ca745f9083e3d3e07c2107137\",\"platform_api_key\":\"MjAxNS0wMy0zMSAxMToxOToyNCAtMDMwME1vYmlsZSBTREtzMTI4\",\"channel_type\":\"mobile\"}";
            
            labelJsonRequest.text = jsonRequest;
            
            [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            
            NSString *const kMessage = @"{\"notification\":\"526\",\"link\":\"\"}";
            
            [DitoAPI notificationRead:delegate.credentials message:kMessage completion:^(id response, NSError *error) {
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                
                if (error) {
                    labelJsonResponse.text = [NSString stringWithFormat:@"%@", error];
                } else if (response) {
                    labelJsonResponse.text = [NSString stringWithFormat:@"%@", response];
                }
            }];
        }
            
            break;
            
        default:
            break;
    }
}

@end
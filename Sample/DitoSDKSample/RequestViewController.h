//
//  RequestViewController.h
//  DitoSDKSample
//
//  Created by Marcos Lacerda on 08/04/15.
//  Copyright (c) 2015 Dito. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RequestViewController : UIViewController {
    IBOutlet UILabel *labelTitle;
    IBOutlet UITextView *labelJsonRequest;
    IBOutlet UITextView *labelJsonResponse;
}

@property (strong, nonatomic) NSString *methodName;
@property (assign) int tag;

@end
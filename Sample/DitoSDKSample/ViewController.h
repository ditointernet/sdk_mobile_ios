//
//  ViewController.h
//  DitoSDKSample
//
//  Created by Marcos Lacerda on 07/04/15.
//  Copyright (c) 2015 Dito. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UITableViewDataSource, UITableViewDelegate> {
    IBOutlet UITableView *tableOptions;
    NSArray *items;
}


@end


//
//  ViewController.m
//  DitoSDKSample
//
//  Created by Marcos Lacerda on 07/04/15.
//  Copyright (c) 2015 Dito. All rights reserved.
//

#import "ViewController.h"
#import "SampleTableViewCell.h"
#import "RequestViewController.h"

@interface ViewController ()

@end

@implementation ViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    items = @[@"Identify", @"Track", @"Alias", @"Unalias", @"Register Device", @"Unregister Device", @"Request", @"Notification Read"];
    
    tableOptions.delegate = self;
    tableOptions.dataSource = self;
    
    [tableOptions reloadData];
}

#pragma mark - TableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SampleTableViewCell *cell = (SampleTableViewCell *) [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SampleTableViewCell" owner:self options:nil] objectAtIndex:0];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.tag = indexPath.row;
    [cell initWithOptionName:items[indexPath.row]];
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [items count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    SampleTableViewCell *cell = (SampleTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    RequestViewController *requestController = [[RequestViewController alloc] init];

    requestController.methodName = items[indexPath.row];
    requestController.tag = cell.tag;
    
    [self presentViewController:requestController animated:YES completion:nil];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

@end

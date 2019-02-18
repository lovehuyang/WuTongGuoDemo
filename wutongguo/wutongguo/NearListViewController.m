//
//  NearListViewController.m
//  wutongguo
//
//  Created by Lucifer on 15-5-14.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "NearListViewController.h"
#import "SwitchCampusListViewController.h"
#import "SCNavTabBarController.h"

@interface NearListViewController ()

@end

@implementation NearListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    SwitchCampusListViewController *campusCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"switchCampusListView"];
    campusCtrl.title = @"宣讲会";
    campusCtrl.searchType = 3;
    SwitchCampusListViewController *recruitmentCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"switchCampusListView"];
    recruitmentCtrl.title = @"招聘会";
    recruitmentCtrl.searchType = 4;
    SCNavTabBarController *navTabCtrl = [[SCNavTabBarController alloc] init];
    navTabCtrl.subViewControllers = @[campusCtrl, recruitmentCtrl];
    navTabCtrl.scrollEnabled = YES;
    [navTabCtrl addParentController:self];
    self.title = @"周边";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

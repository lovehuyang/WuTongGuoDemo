//
//  ApplyLogViewController.m
//  wutongguo
//
//  Created by Lucifer on 15-5-9.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "ApplyLogViewController.h"
#import "SCNavTabBarController.h"
#import "EmailApplyLogViewController.h"
#import "IntelligentApplyLogController.h"

@interface ApplyLogViewController ()

@end

@implementation ApplyLogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"网申记录";
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UIViewController *applyWebCtrl = [storyBoard instantiateViewControllerWithIdentifier:@"applyWebView"];
    applyWebCtrl.title = @"梧桐果记录";
    EmailApplyLogViewController *emailApplyLogCtrl = [[EmailApplyLogViewController alloc] init];
    emailApplyLogCtrl.title = @"简历转发记录";
    //UIViewController *applyOtherCtrl = [storyBoard instantiateViewControllerWithIdentifier:@"applyOtherView"];
    //applyOtherCtrl.title = @"第三方网申记录";
    IntelligentApplyLogController *ivc = [IntelligentApplyLogController new];
    ivc.title = @"智能网申记录";
    

    SCNavTabBarController *navTabCtrl = [[SCNavTabBarController alloc] init];
    navTabCtrl.subViewControllers = @[applyWebCtrl, emailApplyLogCtrl,ivc];
    navTabCtrl.scrollEnabled = YES;
    [navTabCtrl addParentController:self];
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

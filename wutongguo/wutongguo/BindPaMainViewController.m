//
//  BindPaMainViewController.m
//  wutongguo
//
//  Created by Lucifer on 15/6/4.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "BindPaMainViewController.h"
#import "SCNavTabBarController.h"
#import "EmailRegViewController.h"
#import "MobileRegViewController.h"
#import "BindLoginViewController.h"

@interface BindPaMainViewController ()

@end

@implementation BindPaMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    BindLoginViewController *bindLoginCtrl = [storyBoard instantiateViewControllerWithIdentifier:@"bindLoginView"];
    bindLoginCtrl.title = @"现有账号绑定";
    bindLoginCtrl.openId = self.openId;
    bindLoginCtrl.unionId = self.unionId;
    bindLoginCtrl.contactType = self.contactType;
    bindLoginCtrl.fromJobApply = self.fromJobApply;
    EmailRegViewController *bindRegCtrl = [storyBoard instantiateViewControllerWithIdentifier:@"emailRegView"];
    bindRegCtrl.title = @"邮箱注册绑定";
    bindRegCtrl.openId = self.openId;
    bindRegCtrl.unionId = self.unionId;
    bindRegCtrl.fromJobApply = self.fromJobApply;
    MobileRegViewController *bindMobileRegCtrl = [storyBoard instantiateViewControllerWithIdentifier:@"mobileRegView"];
    bindMobileRegCtrl.title = @"手机注册绑定";
    bindMobileRegCtrl.openId = self.openId;
    bindMobileRegCtrl.unionId = self.unionId;
    bindMobileRegCtrl.contactType = self.contactType;
    bindMobileRegCtrl.fromJobApply = self.fromJobApply;
    SCNavTabBarController *navTabCtrl = [[SCNavTabBarController alloc] init];
    navTabCtrl.subViewControllers = @[bindLoginCtrl, bindRegCtrl, bindMobileRegCtrl];
    navTabCtrl.scrollEnabled = YES;
    [navTabCtrl addParentController:self];
    self.title = @"绑定账号";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

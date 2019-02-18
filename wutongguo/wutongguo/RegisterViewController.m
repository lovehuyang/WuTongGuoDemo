//
//  RegisterViewController.m
//  wutongguo
//
//  Created by Lucifer on 15-5-6.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "RegisterViewController.h"
#import "SCNavTabBarController.h"
#import "EmailRegViewController.h"
#import "MobileRegViewController.h"
#import "WeChatRegViewController.h"
#import "LoginViewController.h"
#import "WXApi.h"

@interface RegisterViewController () <SCNavTabBarControllerDelegate>

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
        WeChatRegViewController *weChatRegCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"weChatRegView"];
        weChatRegCtrl.title = @"微信注册";
        MobileRegViewController *mobileRegCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"mobileRegView"];
        mobileRegCtrl.title = @"手机号注册";
        mobileRegCtrl.fromJobApply = self.fromJobApply;
        EmailRegViewController *emailRegCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"emailRegView"];
        emailRegCtrl.title = @"邮箱注册";
        emailRegCtrl.fromJobApply = self.fromJobApply;
        SCNavTabBarController *navTabCtrl = [[SCNavTabBarController alloc] init];
        navTabCtrl.delegate = self;
        navTabCtrl.subViewControllers = @[weChatRegCtrl, mobileRegCtrl, emailRegCtrl];
        [navTabCtrl addParentController:self];
        navTabCtrl.navTabBarIndex = 1;
    }
    else {
        MobileRegViewController *mobileRegCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"mobileRegView"];
        mobileRegCtrl.title = @"手机号注册";
        mobileRegCtrl.fromJobApply = self.fromJobApply;
        EmailRegViewController *emailRegCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"emailRegView"];
        emailRegCtrl.title = @"邮箱注册";
        emailRegCtrl.fromJobApply = self.fromJobApply;
        SCNavTabBarController *navTabCtrl = [[SCNavTabBarController alloc] init];
        navTabCtrl.subViewControllers = @[mobileRegCtrl, emailRegCtrl];
        [navTabCtrl addParentController:self];
    }
    self.title = @"注册";
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

- (void) anotherTabPressed:(UIButton *)button {
    if (button.tag == 0) {
        LoginViewController *loginCtrl = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
        loginCtrl.fromWechatRegister = YES;
        loginCtrl.fromJobApply = self.fromJobApply;
        [self.navigationController popToViewController:loginCtrl animated:YES];
    }
}

@end

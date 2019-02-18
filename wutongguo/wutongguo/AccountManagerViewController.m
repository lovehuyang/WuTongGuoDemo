//
//  AccountManagerViewController.m
//  wutongguo
//
//  Created by Lucifer on 15-5-10.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "AccountManagerViewController.h"
#import "SCNavTabBarController.h"

@interface AccountManagerViewController ()

@end

@implementation AccountManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"账户管理";
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UIViewController *passwordModifyCtrl = [storyBoard instantiateViewControllerWithIdentifier:@"passwordModifyView"];
    passwordModifyCtrl.title = @"修改密码";
    UIViewController *mobileModifyCtrl = [storyBoard instantiateViewControllerWithIdentifier:@"mobileModifyView"];
    mobileModifyCtrl.title = @"修改手机号";
    UIViewController *emailModifyCtrl = [storyBoard instantiateViewControllerWithIdentifier:@"emailModifyView"];
    emailModifyCtrl.title = @"修改邮箱";
    SCNavTabBarController *navTabCtrl = [[SCNavTabBarController alloc] init];
    navTabCtrl.subViewControllers = @[passwordModifyCtrl, mobileModifyCtrl, emailModifyCtrl];
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

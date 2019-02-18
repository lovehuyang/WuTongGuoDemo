//
//  CompanyNoticeViewController.m
//  wutongguo
//
//  Created by Lucifer on 2017/3/14.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "CompanyNoticeViewController.h"
#import "NoticeListViewController.h"
#import "InvitationViewController.h"
#import "SCNavTabBarController.h"

@interface CompanyNoticeViewController ()

@end

@implementation CompanyNoticeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"企业通知";
    
    NoticeListViewController *noticeListCtrl = [[NoticeListViewController alloc] init];
    noticeListCtrl.title = @"企业通知";
    InvitationViewController *invitationCtrl = [[InvitationViewController alloc] init];
    invitationCtrl.title = @"收到的应聘邀请";
    SCNavTabBarController *navTabCtrl = [[SCNavTabBarController alloc] init];
    navTabCtrl.subViewControllers = @[noticeListCtrl, invitationCtrl];
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

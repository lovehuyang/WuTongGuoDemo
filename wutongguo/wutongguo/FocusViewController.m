//
//  FocusViewController.m
//  wutongguo
//
//  Created by Lucifer on 15/5/31.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "FocusViewController.h"
#import "SCNavTabBarController.h"
#import "FocusCompanyViewController.h"
#import "FocusJobViewController.h"
#import "FocusSchoolViewController.h"
#import "FocusCampusViewController.h"
#import "FocusRecruitmentViewController.h"
#import "CommonMacro.h"

@interface FocusViewController ()

@end

@implementation FocusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"我的关注";
    FocusCompanyViewController *focusCompanyCtrl = [[FocusCompanyViewController alloc] init];
    focusCompanyCtrl.title = @"企业";
    FocusJobViewController *focusJobCtrl = [[FocusJobViewController alloc] init];
    focusJobCtrl.title = @"职位";
    FocusSchoolViewController *focusSchoolCtrl = [[FocusSchoolViewController alloc] init];
    focusSchoolCtrl.title = @"学校";
    FocusCampusViewController *focusCampusCtrl = [[FocusCampusViewController alloc] init];
    focusCampusCtrl.title = @"宣讲会";
    FocusRecruitmentViewController *focusRecruitmentCtrl = [[FocusRecruitmentViewController alloc] init];
    focusRecruitmentCtrl.title = @"招聘会";
    SCNavTabBarController *navTabCtrl = [[SCNavTabBarController alloc] init];
    navTabCtrl.subViewControllers = @[focusCompanyCtrl, focusJobCtrl, focusSchoolCtrl, focusCampusCtrl, focusRecruitmentCtrl];
    navTabCtrl.scrollEnabled = YES;
    [navTabCtrl addParentController:self];
    if (self.navTabBarIndex > 0) {
        navTabCtrl.navTabBarIndex = self.navTabBarIndex;
    }
    else {
        NSInteger attentionType = [[USER_DEFAULT objectForKey:@"attentionType"] integerValue];
        if (attentionType == 5) {
            attentionType = 4;
        }
        navTabCtrl.navTabBarIndex = attentionType;
    }
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

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

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    NSUserDefaults*pushJudge = [NSUserDefaults standardUserDefaults];
    if([[pushJudge objectForKey:@"push"]isEqualToString:@"push"]) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"menu-back"] style:UIBarButtonItemStylePlain target:self action:@selector(rebackToRootViewAction)];
    }else{
        self.navigationItem.leftBarButtonItem=nil;
    }
}
- (void)rebackToRootViewAction {
    NSUserDefaults * pushJudge = [NSUserDefaults standardUserDefaults];
    [pushJudge setObject:@""forKey:@"push"];
    [pushJudge synchronize];//记得立即同步
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end

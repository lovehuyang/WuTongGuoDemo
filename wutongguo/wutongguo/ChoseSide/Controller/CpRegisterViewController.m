//
//  RegisterViewController.m
//  wutongguo
//
//  Created by Lucifer on 2019/2/26.
//  Copyright © 2019年 Lucifer. All rights reserved.
//

#import "CpRegisterViewController.h"
#import "CommonMacro.h"

@interface CpRegisterViewController ()

@end

@implementation CpRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"注册";
    UILabel *tipLab = [UILabel new];
    tipLab.frame = CGRectMake(0, 0, SCREEN_WIDTH, 40);
    tipLab.text = @"一键注册，开启校园招聘之旅";
    [self.view addSubview:tipLab];
    tipLab.font = [UIFont systemFontOfSize:14];
    tipLab.backgroundColor =  BGCOLOR;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

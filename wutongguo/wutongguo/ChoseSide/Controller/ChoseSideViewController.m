//
//  ChoseSideViewController.m
//  wutongguo
//
//  Created by Lucifer on 2019/2/25.
//  Copyright © 2019年 Lucifer. All rights reserved.
//

#import "ChoseSideViewController.h"
#import "CpLoginViewController.h"
#import "RoleView.h"
#import "CommonMacro.h"
#import "LoginViewController.h"

@interface ChoseSideViewController ()
@property (nonatomic , strong) UIImageView *backView;
@end

@implementation ChoseSideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"选择身份";
    [self.view addSubview:self.backView];
    
    [self setupRoleUI];
}

- (UIImageView *)backView{
    if (!_backView) {
        _backView = [UIImageView new];
        _backView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        _backView.image = [UIImage imageNamed:@"ChoseRoleBackImg"];
        _backView.userInteractionEnabled = YES;
    }
    return _backView;
}

- (void)setupRoleUI{
    RoleView *companyView = [[RoleView alloc]initWithFrame:CGRectMake(0, 64, 100, 175) title:@"我是企业" img:@"company_role"];
    companyView.center = CGPointMake(SCREEN_WIDTH/2, (SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT)/4);
    [self.backView addSubview:companyView];
    companyView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(companyClick)];
    [companyView addGestureRecognizer:tap1];
    
    
    RoleView *personView = [[RoleView alloc]initWithFrame:CGRectMake(0, 64, 100, 175) title:@"我是学生" img:@"person_role"];
    personView.center = CGPointMake(SCREEN_WIDTH/2, (SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT)/4*2.8);
    [self.backView addSubview:personView];
    personView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(personClick)];
    [personView addGestureRecognizer:tap2];
}

- (void)companyClick{
    CpLoginViewController *lvc = [CpLoginViewController new];
    [self.navigationController pushViewController:lvc animated:YES];
}

- (void)personClick{
    
    UIStoryboard *sb=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    [self.navigationController pushViewController:[sb instantiateViewControllerWithIdentifier:@"loginView"] animated:YES];

}
@end

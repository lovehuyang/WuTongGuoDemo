//
//  ExchangeRoleViewController.m
//  wutongguo
//
//  Created by Lucifer on 2019/3/1.
//  Copyright © 2019年 Lucifer. All rights reserved.
//

#import "ExchangeRoleViewController.h"
#import "CpLoginViewController.h"

@interface ExchangeRoleViewController ()
@property (nonatomic, strong) LoadingAnimationView *loadingView;

@end

@implementation ExchangeRoleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColorFromRGB(0xFFFFFF);
    
    UIButton *returnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    returnBtn.frame = CGRectMake(10, STATUS_BAR_HEIGHT, 44, 44);
    [returnBtn setImage:[UIImage imageNamed:@"nav_return"] forState:UIControlStateNormal];
    [returnBtn addTarget:self action:@selector(returnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:returnBtn];
    
    // 当前身份
    UILabel *currentRoleLab = [[UILabel  alloc]initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT + 50, SCREEN_WIDTH, 30)];
    [self.view addSubview:currentRoleLab];
    currentRoleLab.text = [NSString stringWithFormat:@"当前身份：%@",self.status];
    currentRoleLab.textAlignment = NSTextAlignmentCenter;
    
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, VIEW_BY(currentRoleLab) , SCREEN_WIDTH - 20, SCREEN_WIDTH - 20) ];
    imgView.center = CGPointMake(SCREEN_WIDTH/2, imgView.center.y);
    [self.view addSubview:imgView];
    imgView.image = [UIImage imageNamed:@"exchange_role"];
    imgView.userInteractionEnabled = YES;
    
    
    UIButton *exchageBtn = [UIButton new];
    exchageBtn.frame = CGRectMake(0, 0, VIEW_W(imgView) - VIEW_W(imgView) * 0.29 *2, 40);
    exchageBtn.center = CGPointMake(VIEW_W(imgView)/2, VIEW_H(imgView)*0.652);
    [imgView addSubview:exchageBtn];
    exchageBtn.backgroundColor = NAVBARCOLOR;
    exchageBtn.layer.cornerRadius = 20;
    exchageBtn.layer.masksToBounds = YES;
    NSString *btnTitle  = [self.status isEqualToString:@"学生"]?@"切换至企业身份":@"切换至学生身份";
    [exchageBtn setTitle:btnTitle forState:UIControlStateNormal];
    exchageBtn.titleLabel.font = [UIFont boldSystemFontOfSize:DEFAULTFONTSIZE];
    [exchageBtn addTarget:self action:@selector(exchageBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    //等待动画
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.view addSubview:self.loadingView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)returnClick{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)exchageBtnClick{
    
    if([self.status isEqualToString:@"学生"]){
        [CommonToos saveData:APP_STATUS value:@"1"];
        CpLoginViewController *cvc = [CpLoginViewController new];
        [self.navigationController pushViewController:cvc animated:YES];
    
    }else{
        [self.loadingView startAnimating];
        [CommonToos saveData:APP_STATUS value:@"0"];
        // GCD延时执行
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            UIWindow * window = [[UIApplication sharedApplication] keyWindow];
            UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
            window.rootViewController = [storyBoard instantiateViewControllerWithIdentifier:@"person"];
        });
    }
}
@end

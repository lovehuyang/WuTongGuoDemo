//
//  ApplySpeedUpIntroduceController.m
//  wutongguo
//
//  Created by Lucifer on 2019/3/19.
//  Copyright © 2019年 Lucifer. All rights reserved.
//

#import "ApplySpeedUpIntroduceController.h"
#import "ApplySpeedUpTipLab.h"
#import "IntelligentApplyController.h"
#import "CommonFunc.h"

@interface ApplySpeedUpIntroduceController ()
@property (nonatomic , strong) UIScrollView *scrollView;
@property (nonatomic , strong) UIView *bgView1;
@property (nonatomic , strong) UIView *bgView2;

@end

@implementation ApplySpeedUpIntroduceController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"求职加速";
    [self setupUI];
    
    //分享
//    UIButton *btnShare = [[UIButton alloc] initWithFrame:CGRectMake(31, 0, 25, 25)];
//    [btnShare setBackgroundImage:[UIImage imageNamed:@"coShare.png"] forState:UIControlStateNormal];
//    [btnShare addTarget:self action:@selector(shareClick) forControlEvents:UIControlEventTouchUpInside];
//    UIView *viewRightItem = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 21, 25)];
//    [viewRightItem setFrame:CGRectMake(0, 0, 60, 25)];
//    [viewRightItem addSubview:btnShare];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:viewRightItem];
}

- (void)setupUI{
    self.scrollView = [UIScrollView new];
    [self.view addSubview:self.scrollView];
    self.scrollView.sd_layout
    .leftSpaceToView(self.view, 0)
    .topSpaceToView(self.view, 0)
    .rightSpaceToView(self.view, 0)
    .bottomSpaceToView(self.view, 0);
    self.scrollView.backgroundColor = [UIColor colorWithHex:0x5142CC];
    
    CGFloat img_H = 0.3156 * SCREEN_WIDTH;// 图片高度

    self.bgView1 = [UIView new];
    [self.scrollView addSubview:self.bgView1];
    self.bgView1.sd_layout
    .leftSpaceToView(self.scrollView, 15)
    .rightSpaceToView(self.scrollView, 15)
    .topSpaceToView(self.scrollView, img_H - 10)
    .heightIs(300);
    self.bgView1.backgroundColor = [UIColor whiteColor];
    self.bgView1.sd_cornerRadius = @(5);
    [self createView1SubViews];
    
    self.bgView2 = [UIView new];
    [self.scrollView addSubview:self.bgView2];
    self.bgView2.sd_layout
    .leftEqualToView(self.bgView1)
    .rightEqualToView(self.bgView1)
    .topSpaceToView(self.bgView1, 15)
    .heightIs(300);
    self.bgView2.backgroundColor = [UIColor whiteColor];
    self.bgView2.sd_cornerRadius = @(5);
    [self createView1SubViews2];
    
    [self.scrollView setupAutoContentSizeWithBottomView:self.bgView2 bottomMargin:10];
    
    
    UIImageView *imgView = [UIImageView new];
    [self.scrollView addSubview:imgView];
    imgView.sd_layout
    .leftSpaceToView(self.scrollView, 0)
    .topSpaceToView(self.scrollView, 0)
    .rightSpaceToView(self.scrollView, 0)
    .autoHeightRatio(0.3156);
    imgView.image = [UIImage imageNamed:@"apply_speedup_BG"];
}

- (void)createView1SubViews{
    //
    UILabel *titleLab = [UILabel new];
    [self.bgView1 addSubview:titleLab];
    titleLab.sd_layout
    .topSpaceToView(self.bgView1, 10)
    .autoHeightRatio(0)
    .centerXEqualToView(self.bgView1);
    [titleLab setSingleLineAutoResizeWithMaxWidth:SCREEN_WIDTH];
    titleLab.text = @"智能网申";
    titleLab.font = [UIFont boldSystemFontOfSize:BIGGERFONTSIZE];
    titleLab.textColor = [UIColor colorWithHex:0xFF821A];
    
    UILabel *line1 = [UILabel new];
    [self.bgView1 addSubview:line1];
    line1.sd_layout
    .leftSpaceToView(self.bgView1, 20)
    .rightSpaceToView(titleLab, 20)
    .heightIs(1)
    .centerYEqualToView(titleLab);
    line1.backgroundColor = titleLab.textColor;
    
    UILabel *line2 = [UILabel new];
    [self.bgView1 addSubview:line2];
    line2.sd_layout
    .leftSpaceToView(titleLab, 20)
    .rightSpaceToView(self.bgView1, 20)
    .heightIs(1)
    .centerYEqualToView(titleLab);
    line2.backgroundColor = titleLab.textColor;
    
    
    NSArray *labArr = @[@"抢占先机",@"Offer任你挑",@"省时省力"];
    for (int i = 0; i < labArr.count; i ++) {
        ApplySpeedUpTipLab *lab = [ApplySpeedUpTipLab new];
        [self.bgView1 addSubview:lab];
        lab.sd_layout
        .leftSpaceToView(self.bgView1,94 * i + 20)
        .heightIs(25)
        .widthIs(82)
        .topSpaceToView(titleLab, 15);
        lab.text = labArr[i];
        lab.sd_cornerRadius = @(12.5);
        lab.textAlignment = NSTextAlignmentCenter;
    }
    
    UILabel *introductionLab = [UILabel new];
    [self.bgView1 addSubview:introductionLab];
    introductionLab.sd_layout
    .rightSpaceToView(self.bgView1, 15)
    .topSpaceToView(titleLab, 60)
    .leftSpaceToView(self.bgView1, 120)
    .autoHeightRatio(0);
    introductionLab.text = @"您意向的企业发布校招信息后，网站立即为您投递申请表。当您的同学在悔恨错过了网申时间时，您已经在赶往笔试的途中。同样的毕业季，不同的求职经历。";
    introductionLab.font = DEFAULTFONT;
    
    UIImageView *imgView = [UIImageView new];
    [self.bgView1 addSubview:imgView];
    imgView.sd_layout
    .leftSpaceToView(self.bgView1, 20)
    .centerYEqualToView(introductionLab)
    .rightSpaceToView(introductionLab, 20)
    .heightEqualToWidth();
    imgView.image =[UIImage imageNamed:@"智能网申"];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    
    NSArray *tipArr = @[@"·早先申请，提早获得入场券",@"·平均网申10个职位，可以换来1次面试机会",@"·毕业季可以节省出更多的时间准备笔试面试"];
    
    for (int i = 0; i < tipArr.count ; i ++) {
        UILabel *lab = [UILabel new];
        [self.bgView1  addSubview:lab];
        lab.sd_layout
        .leftEqualToView(imgView)
        .topSpaceToView(introductionLab, 15 + 20*i)
        .rightEqualToView(introductionLab)
        .heightIs(20);
        lab.text = tipArr[i];
        lab.font = DEFAULTFONT;
        lab.textColor = [UIColor colorWithHex:0xFF8117];
    }
    
    UIButton *button  = [UIButton new];
    [self.bgView1 addSubview:button];
    button.sd_layout
    .leftSpaceToView(self.bgView1, 20)
    .rightSpaceToView(self.bgView1, 20)
    .topSpaceToView(introductionLab, 90)
    .heightIs(35);
    [button setTitle:@"获取特权，加速求职" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor colorWithHex:0xFF8117];
    button.sd_cornerRadius = @(5);
    [self.bgView1 setupAutoHeightWithBottomView:button bottomMargin:20];
    button.tag = 100;
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)createView1SubViews2{
    UILabel *titleLab = [UILabel new];
    [self.bgView2 addSubview:titleLab];
    titleLab.sd_layout
    .topSpaceToView(self.bgView2, 10)
    .autoHeightRatio(0)
    .centerXEqualToView(self.bgView2);
    [titleLab setSingleLineAutoResizeWithMaxWidth:SCREEN_WIDTH];
    titleLab.text = @"应聘优先";
    titleLab.font = [UIFont boldSystemFontOfSize:BIGGERFONTSIZE];
    titleLab.textColor = [UIColor colorWithHex:0xFF821A];
    
    UILabel *line1 = [UILabel new];
    [self.bgView2 addSubview:line1];
    line1.sd_layout
    .leftSpaceToView(self.bgView2, 20)
    .rightSpaceToView(titleLab, 20)
    .heightIs(1)
    .centerYEqualToView(titleLab);
    line1.backgroundColor = titleLab.textColor;
    
    UILabel *line2 = [UILabel new];
    [self.bgView2 addSubview:line2];
    line2.sd_layout
    .leftSpaceToView(titleLab, 20)
    .rightSpaceToView(self.bgView2, 20)
    .heightIs(1)
    .centerYEqualToView(titleLab);
    line2.backgroundColor = titleLab.textColor;
    
    
    NSArray *labArr = @[@"置顶显示",@"答复率高",@"安全放心"];
    for (int i = 0; i < labArr.count; i ++) {
        ApplySpeedUpTipLab *lab = [ApplySpeedUpTipLab new];
        [self.bgView2 addSubview:lab];
        lab.sd_layout
        .leftSpaceToView(self.bgView2, 94 * i + 20)
        .heightIs(25)
        .widthIs(82)
        .topSpaceToView(titleLab, 15);
        lab.text = labArr[i];
        lab.sd_cornerRadius = @(12.5);
        lab.textAlignment = NSTextAlignmentCenter;
    }
    
    UILabel *introductionLab = [UILabel new];
    [self.bgView2 addSubview:introductionLab];
    introductionLab.sd_layout
    .rightSpaceToView(self.bgView2, 15)
    .topSpaceToView(titleLab, 60)
    .leftSpaceToView(self.bgView2, 120)
    .autoHeightRatio(0);
    introductionLab.text = @"校招求职季，HR每天收到大量的申请表，全部打开查看的概率可想而知。网申有技巧，牢牢占据靠前的位置，可以提升答复率";
    introductionLab.font = DEFAULTFONT;
    
    UIImageView *imgView = [UIImageView new];
    [self.bgView2 addSubview:imgView];
    imgView.sd_layout
    .leftSpaceToView(self.bgView2, 20)
    .centerYEqualToView(introductionLab)
    .rightSpaceToView(introductionLab, 20)
    .heightEqualToWidth();
    imgView.image =[UIImage imageNamed:@"应聘优先"];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    
    NSArray *tipArr = @[@"·投递的申请表在企业HR查看到的列表中优先靠前显示",@"·区别于其他申请表突出展示",@"·HR主动搜索简历时，如果与搜索条件匹配，也会置顶展示"];
    
    for (int i = 0; i < tipArr.count ; i ++) {
        UILabel *lab = [UILabel new];
        [self.bgView2  addSubview:lab];
        lab.sd_layout
        .leftEqualToView(imgView)
        .topSpaceToView(introductionLab, 15 + 20*i)
        .rightEqualToView(introductionLab)
        .heightIs(20);
        lab.text = tipArr[i];
        lab.font = DEFAULTFONT;
        lab.textColor = [UIColor colorWithHex:0xFF8117];
    }
    
    UIButton *button  = [UIButton new];
    [self.bgView2 addSubview:button];
    button.sd_layout
    .leftSpaceToView(self.bgView2, 20)
    .rightSpaceToView(self.bgView2, 20)
    .topSpaceToView(introductionLab, 90)
    .heightIs(35);
    [button setTitle:@"获取特权，加速求职" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor colorWithHex:0xFF8117];
    button.sd_cornerRadius = @(5);
    [self.bgView2 setupAutoHeightWithBottomView:button bottomMargin:20];
    button.tag = 101;
    [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)buttonClick:(UIButton *)button{
    
    
    if (![CommonFunc checkLogin]) {
        
        UIViewController *loginCtrl = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"loginView"];
        [self.navigationController pushViewController:loginCtrl animated:YES];
        return;
    }
    
    if (button.tag == 100) {// 
        IntelligentApplyController *itv = [IntelligentApplyController new];
        itv.ordertype = 1;// 1智能网申
        [self.navigationController pushViewController:itv animated:YES];
    }else{
        IntelligentApplyController *itv = [IntelligentApplyController new];
        itv.ordertype = 2;// 2应聘优先
        [self.navigationController pushViewController:itv animated:YES];
    }
}

#pragma mark - 分享
- (void)shareClick{
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}
@end

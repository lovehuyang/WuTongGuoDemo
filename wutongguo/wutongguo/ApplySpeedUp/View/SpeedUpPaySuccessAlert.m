//
//  SpeedUpPaySuccessAlert.m
//  wutongguo
//
//  Created by Lucifer on 2019/3/20.
//  Copyright © 2019年 Lucifer. All rights reserved.
//

#import "SpeedUpPaySuccessAlert.h"

@interface SpeedUpPaySuccessAlert()
@property (nonatomic , strong) UIView *bgView;
@property (nonatomic , strong) UIView *alertView;
@property (nonatomic , strong) UILabel *titleLab;
@property (nonatomic , strong) UILabel *validLab;// 服务期限
@property (nonatomic , strong) UILabel *contentLab;
@property (nonatomic , strong) UIButton *btn;
@end
@implementation SpeedUpPaySuccessAlert

- (instancetype)init{
    self = [super init];
    if (self) {
        
        self.bgView = [UIView new];
        [self addSubview:self.bgView];
        self.bgView.sd_layout
        .leftSpaceToView(self, 0)
        .topSpaceToView(self, 0)
        .rightSpaceToView(self, 0)
        .bottomSpaceToView(self, 0);
        self.bgView.backgroundColor = [UIColor blackColor];
        self.bgView.alpha = 0.5;
        self.bgView.userInteractionEnabled = YES;
        
        //创建alertView
        self.alertView = [[UIView alloc]init];
        self.alertView.center = CGPointMake(self.center.x, self.center.y);
        self.alertView.layer.masksToBounds = YES;
        self.alertView.layer.cornerRadius = 5;
        self.alertView.clipsToBounds = YES;
        self.alertView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.alertView];
        self.alertView.sd_layout
        .centerXEqualToView(self)
        .leftSpaceToView(self, 40)
        .rightSpaceToView(self, 40)
        .heightIs(200)
        .centerYEqualToView(self);
        self.alertView.backgroundColor = [UIColor whiteColor];
        self.alertView.sd_cornerRadius = @(5);
        
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews{
    
    //
    UILabel *titleLab = [UILabel new];
    [self.alertView addSubview:titleLab];
    titleLab.font = [UIFont boldSystemFontOfSize:BIGGERFONTSIZE];
    titleLab.sd_layout
    .topSpaceToView(self.alertView, 20)
    .autoHeightRatio(0)
    .leftSpaceToView(self.alertView, 15)
    .rightSpaceToView(self.alertView, 15);
    self.titleLab = titleLab;
    
    // 服务期限
    self.validLab = [UILabel new];
    [self.alertView addSubview:self.validLab];
    self.validLab.sd_layout
    .leftEqualToView(titleLab)
    .rightEqualToView(titleLab)
    .topSpaceToView(titleLab, 5)
    .autoHeightRatio(0);
    self.validLab.font = DEFAULTFONT;
    self.validLab.textColor = TEXTGRAYCOLOR;
    
    // 简历不完整时的提示文字
    UILabel *contentLab = [UILabel new];
    [self.alertView addSubview:contentLab];
    contentLab.sd_layout
    .leftEqualToView(titleLab)
    .topSpaceToView(self.validLab, 10)
    .rightEqualToView(titleLab)
    .autoHeightRatio(0);
    contentLab.font =DEFAULTFONT;
    contentLab.textColor = [UIColor colorWithHex:0xFF0317];
    self.contentLab = contentLab;

    UIButton *btn = [UIButton new];
    [self.alertView addSubview:btn];
    btn.sd_layout
    .leftEqualToView(titleLab)
    .rightEqualToView(titleLab)
    .heightIs(35)
    .topSpaceToView(contentLab, 15);
    btn.backgroundColor = NAVBARCOLOR;
    btn.sd_cornerRadius = @(3);
    btn.titleLabel.font = DEFAULTFONT;
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    self.btn = btn;
    [self.alertView setupAutoHeightWithBottomView:btn bottomMargin:20];
}

- (void)setTitle:(NSString *)title markContent:(NSString *)markContent content:(NSString *)content btnTitle:(NSString *)btnTitle validTime:(NSString *)validTime{
    
    NSRange range = [title rangeOfString:markContent];
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc]initWithString:title];
    [attributedStr addAttribute:NSForegroundColorAttributeName value:NAVBARCOLOR range:range];
    self.titleLab.attributedText = attributedStr;
    [self.btn setTitle:btnTitle forState:UIControlStateNormal];
    self.validLab.text = validTime;
    
    //
    if(content.length >0){
        self.contentLab.text = content;
    }else{
        self.contentLab.hidden = YES;
        self.btn.sd_layout
        .topSpaceToView(self.validLab, 15);
        [self.btn updateLayout];
        [self.alertView setupAutoHeightWithBottomView:self.btn bottomMargin:20];
    }
}

- (void)show{
    
    UIView *view = [[UIApplication sharedApplication] keyWindow];
    [view addSubview:self];
    self.sd_layout
    .leftSpaceToView(view, 0)
    .rightSpaceToView(view, 0)
    .topSpaceToView(view, 0)
    .bottomSpaceToView(view, 0);
    
    self.alertView.transform = CGAffineTransformMakeScale(1.21f, 1.21f);
    
    [UIView animateWithDuration:.5f delay:0.f usingSpringWithDamping:.7f initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alertView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        
    } completion:nil];
}

- (void)dissmiss {
    
    [UIView animateWithDuration:.3 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        self.bgView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)btnClick{
    [self dissmiss];
    self.btnBlock();
}

@end

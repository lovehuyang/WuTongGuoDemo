//
//  BottomPayView.m
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/3.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "BottomPayView.h"

@interface BottomPayView()
@property (nonatomic , strong)UILabel *moneyLab;
@end
@implementation BottomPayView

- (instancetype)init{
    self = [super init];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        UIButton *payBtn = [UIButton new];
        [self addSubview:payBtn];
        payBtn.sd_layout
        .rightSpaceToView(self, 10)
        .topSpaceToView(self, 5)
        .bottomSpaceToView(self, 5)
        .widthRatioToView(self, 0.6);
        payBtn.backgroundColor = [UIColor colorWithHex:0xFF8117];
        [payBtn setTitle:@"去付款" forState:UIControlStateNormal];
        payBtn.titleLabel.font  = DEFAULTFONT;
        [payBtn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *moneyLab = [UILabel new];
        [self addSubview:moneyLab];
        moneyLab.sd_layout
        .rightSpaceToView(payBtn, 0)
        .leftSpaceToView(self, 5)
        .topSpaceToView(self, 0)
        .bottomSpaceToView(self, 0);
        moneyLab.textAlignment = NSTextAlignmentCenter;
        moneyLab.font = DEFAULTFONT;
        moneyLab.textColor = [UIColor colorWithHex:0xFF8117];
        self.moneyLab = moneyLab;
    }
    return self;
}

- (void)setMoney:(NSString *)money{
    _money = money;
    NSString *contentStr = [NSString stringWithFormat:@"待支付 ￥%@",money];
    NSRange range = [contentStr rangeOfString:@"待支付"];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:contentStr];
    [attStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:range];
    self.moneyLab.attributedText = attStr;
}

- (void)btnClick{
    self.payEvent();
}
@end

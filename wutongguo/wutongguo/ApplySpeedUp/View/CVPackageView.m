//
//  CVPackageView.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/12/29.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import "CVPackageView.h"
#import "PaOrderPriceModel.h"

@interface CVPackageView()
@property (nonatomic , strong) UILabel *titleLab;
@property (nonatomic , strong) UILabel *nowPriceLab;
@property (nonatomic , strong) UILabel *tipLab;
@end

@implementation CVPackageView
- (instancetype)init{
    if (self = [super init]) {
        [self setupSubViews];
    }
    return self;
}
- (void)setupSubViews{
    
//    CGFloat H = SCREEN_WIDTH/2;
    
    UIView *bgView = [UIView new];
    [self addSubview:bgView];
    bgView.sd_layout
    .leftSpaceToView(self, 5)
    .rightSpaceToView(self, 5)
    .topSpaceToView(self, 0)
    .bottomSpaceToView(self, 0);
    bgView.layer.borderWidth = 1;
    bgView.layer.borderColor = SEPARATECOLOR.CGColor;
    bgView.sd_cornerRadius = @(5);

    // 套餐标题
    UILabel *titleLab = [UILabel new];
    [bgView addSubview: titleLab];
    titleLab.sd_layout
    .leftSpaceToView(bgView, 0)
    .rightSpaceToView(bgView, 0)
    .topSpaceToView(bgView, 15)
    .autoHeightRatio(0);
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.font = DEFAULTFONT;
    self.titleLab = titleLab;
    
    // 现价
    UILabel *nowPriceLab = [UILabel new];
    [bgView addSubview:nowPriceLab];
    nowPriceLab.sd_layout
    .leftSpaceToView(bgView, 0)
    .rightSpaceToView(bgView, 0)
    .topSpaceToView(titleLab, 15)
    .autoHeightRatio(0);
    nowPriceLab.textAlignment = NSTextAlignmentCenter;
    nowPriceLab.font = [UIFont boldSystemFontOfSize:BIGGERFONTSIZE];
    nowPriceLab.textColor = [UIColor colorWithHex:0xFF0015];
    self.nowPriceLab = nowPriceLab;
    
    UILabel *tipLab = [UILabel new];
    [bgView addSubview:tipLab];
    tipLab.sd_layout
    .leftSpaceToView(bgView, 5)
    .rightSpaceToView(bgView, 5)
    .topSpaceToView(nowPriceLab, 15)
    .autoHeightRatio(0);
    tipLab.textColor = TEXTGRAYCOLOR;
    tipLab.font = SMALLERFONT;
    tipLab.textAlignment = NSTextAlignmentCenter;
    self.tipLab = tipLab;
    
    // 购买
    UIButton *buyBtn = [UIButton new];
    [bgView addSubview:buyBtn];
    buyBtn.sd_layout
    .heightIs(25)
    .topSpaceToView(tipLab, 15)
    .rightSpaceToView(bgView, 20)
    .leftSpaceToView(bgView, 20)
    .centerXEqualToView(bgView);
    [buyBtn setTitle:@"购买" forState:UIControlStateNormal];
    buyBtn.sd_cornerRadius = @(5);
    buyBtn.backgroundColor = NAVBARCOLOR;;
    buyBtn.titleLabel.font = DEFAULTFONT;
    [buyBtn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self setupAutoHeightWithBottomView:buyBtn bottomMargin:15];
}

- (void)setModel:(PaOrderPriceModel *)model{
    _model = model;
    
    NSString *orderName = [_model.OrderType isEqualToString:@"1"]?@"智能网申":@"应聘优先";
    self.titleLab.text = [NSString stringWithFormat:@"%@天%@",_model.Days,orderName];
    self.tipLab.text = [NSString stringWithFormat:@"推荐人才获得求职鼓励金可抵扣%@元",_model.MaxDiscount];
    self.nowPriceLab.text = [NSString stringWithFormat:@"%@元",model.Price];
}

- (void)btnClick{
    self.buyBtnClickBlock(self.model);
}
@end

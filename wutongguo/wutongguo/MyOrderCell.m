//
//  MyOrderCell.m
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/4.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "MyOrderCell.h"
#import "OrderListModel.h"

@interface MyOrderCell ()
@property (nonatomic , strong)UILabel *orderNumLab;
@property (nonatomic , strong)UILabel *orderNameLab;
@property (nonatomic , strong)UILabel *moneyLab;
@property (nonatomic , strong)UILabel *discountMoneyLab;
@property (nonatomic , strong)UILabel *payMethodLab;
@property (nonatomic , strong)UILabel *validTimeLab;// 服务有效期

@end
@implementation MyOrderCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setupSubViews{
    
    for (UIView *subView in self.contentView.subviews) {
        [subView removeFromSuperview];
    }
    
    // 订单号
    self.orderNumLab = [UILabel new];
    [self.contentView addSubview:self.orderNumLab];
    self.orderNumLab.sd_layout
    .leftSpaceToView(self.contentView, 15)
    .topSpaceToView(self.contentView,15)
    .rightSpaceToView(self.contentView, 15);
    self.orderNumLab.font = SMALLERFONT;
    self.orderNumLab.textColor = TEXTGRAYCOLOR;
    
    UIView *separateLine = [UIView new];
    [self.contentView addSubview:separateLine];
    separateLine.sd_layout
    .leftEqualToView(self.orderNumLab)
    .topSpaceToView(self.orderNumLab, 10)
    .rightSpaceToView(self.contentView, 15)
    .heightIs(1);
    separateLine.backgroundColor = SEPARATECOLOR;
    
    // 订单名称
    self.orderNameLab = [UILabel new];
    [self.contentView addSubview:self.orderNameLab];
    self.orderNameLab.sd_layout
    .leftEqualToView(self.orderNumLab)
    .topSpaceToView(separateLine, 10)
    .autoHeightRatio(0);
    [self.orderNameLab setSingleLineAutoResizeWithMaxWidth:SCREEN_WIDTH];
    [self.orderNameLab setFont:[UIFont fontWithName:@"Helvetica-Bold" size:BIGGERFONTSIZE]];
    
    // 金额
    self.moneyLab = [UILabel new];
    [self.contentView addSubview:self.moneyLab];
    self.moneyLab.sd_layout
    .leftSpaceToView(self.orderNameLab, 5)
    .centerYEqualToView(self.orderNameLab)
    .heightRatioToView(self.orderNameLab, 1);
    [self.moneyLab setSingleLineAutoResizeWithMaxWidth:SCREEN_WIDTH];
    self.moneyLab.textColor = [UIColor colorWithHex:0xFF8117];
    self.moneyLab.font = self.orderNameLab.font;
    // 求职鼓励金
    self.discountMoneyLab = [UILabel new];
    [self.contentView addSubview:self.discountMoneyLab];
    self.discountMoneyLab.sd_layout
    .leftSpaceToView(self.moneyLab, 0)
    .centerYEqualToView(self.moneyLab)
    .heightRatioToView(self.moneyLab, 1);
    [self.discountMoneyLab setSingleLineAutoResizeWithMaxWidth:SCREEN_WIDTH];
    self.discountMoneyLab.textColor = self.moneyLab.textColor;
    self.discountMoneyLab.font = self.moneyLab.font;
    
    //支付方式
    self.payMethodLab = [UILabel new];
    [self.contentView addSubview:self.payMethodLab];
    self.payMethodLab.sd_layout
    .leftSpaceToView(self.discountMoneyLab, 0)
    .centerYEqualToView(self.discountMoneyLab)
    .heightRatioToView(self.discountMoneyLab, 1);
    self.payMethodLab.textColor = TEXTGRAYCOLOR;
    self.payMethodLab.font = DEFAULTFONT;
    [self.payMethodLab setSingleLineAutoResizeWithMaxWidth:SCREEN_WIDTH];
    
    
    self.validTimeLab = [UILabel new];
    [self.contentView addSubview:self.validTimeLab];
    self.validTimeLab.sd_layout
    .leftEqualToView(separateLine)
    .rightEqualToView(separateLine)
    .topSpaceToView(self.orderNameLab, 10)
    .autoHeightRatio(0);
    self.validTimeLab.font = DEFAULTFONT;
}

- (void)setModel:(OrderListModel *)model{
    _model = model;
    [self setupSubViews];
    [self setValue];
}

- (void)setValue{

     NSString *orderName = [_model.OrderType isEqualToString:@"1"]?@"智能网申":@"应聘优先";
    self.orderNameLab.text = [NSString stringWithFormat:@"%@天%@",_model.Days,orderName];
    self.orderNumLab.text = [NSString stringWithFormat:@"订单号:%@",_model.PayOrderNum];
    self.moneyLab.text = [NSString stringWithFormat:@"%@元",_model.Money];
    if (_model.Discount != nil && _model.Discount.length && ![_model.Discount isEqualToString:@"0"]) {
        self.discountMoneyLab.text = [NSString stringWithFormat:@"+%@元求职鼓励金",_model.Discount];
    }
    if (self.discountMoneyLab.text.length == 0) {
        self.payMethodLab.sd_layout
        .leftSpaceToView(self.moneyLab, 0)
        .centerYEqualToView(self.moneyLab)
        .heightRatioToView(self.moneyLab, 1);
    }
    
    if ([_model.PayType isEqualToString:@"1"]) {
        self.payMethodLab.text = @"(微信付款)";
    }else if ([_model.PayType isEqualToString:@"2"]){
        self.payMethodLab.text = @"(支付宝付款)";
    }
    
    // 服务有效期
    NSString *validTime = [NSString stringWithFormat:@"服务有效期:%@至%@",[self changeBeginFormatWithDateString:_model.BeginDate],[self changeBeginFormatWithDateString:_model.EndDate]];
    NSMutableAttributedString * attributedStr = [[NSMutableAttributedString alloc] initWithString:validTime];
    NSRange range = [validTime rangeOfString:@"服务有效期:"];
    [attributedStr setAttributes:@{NSForegroundColorAttributeName:TEXTGRAYCOLOR} range:range];
    self.validTimeLab.attributedText = attributedStr;
    
    
    UIView *seperateView = [UIView new];
    [self.contentView addSubview:seperateView];
    seperateView.sd_layout
    .leftSpaceToView(self.contentView, 0)
    .topSpaceToView(self.validTimeLab, 15)
    .rightSpaceToView(self.contentView, 0)
    .heightIs(10);
    seperateView.backgroundColor = [UIColor colorWithHex:0xF6F5FA];
    [self setupAutoHeightWithBottomView:seperateView bottomMargin:0];
}

-(NSString *)changeFormatWithDateString:(NSString *)date{
    //2019-01-07T09:43:58.233+08:00
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'+'ss:ss"];
    NSDate *currentDate = [dateFormatter dateFromString:date];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateStr=[dateFormatter stringFromDate:currentDate];
    return dateStr;
}

-(NSString *)changeBeginFormatWithDateString:(NSString *)date{
    //2019-01-04T17:54:00+08:00
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'+'ss:ss"];
    NSDate *currentDate = [dateFormatter dateFromString:date];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateStr=[dateFormatter stringFromDate:currentDate];
    return dateStr;
}
@end

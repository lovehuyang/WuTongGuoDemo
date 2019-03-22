//
//  PaSpreadCell.m
//  wutongguo
//
//  Created by Lucifer on 2019/3/21.
//  Copyright © 2019年 Lucifer. All rights reserved.
//

#import "PaSpreadCell.h"
#import "PaSpreadModel.h"

@implementation PaSpreadCell

- (void)setupSubViews{
    
    UILabel *timeLab = [UILabel new];
    [self.contentView addSubview:timeLab];
    timeLab.sd_layout
    .rightSpaceToView(self.contentView, 0)
    .centerYEqualToView(self.contentView)
    .autoHeightRatio(0)
    .widthIs(120);
    timeLab.font = [UIFont systemFontOfSize:12];
    timeLab.textColor = TEXTGRAYCOLOR;
    timeLab.textAlignment = NSTextAlignmentCenter;
    timeLab.text = [CommonToos changeBeginFormatWithDateString:_model.AddDate];
    
    UILabel *contentLab = [UILabel new];
    [self.contentView addSubview:contentLab];
    contentLab.sd_layout
    .leftSpaceToView(self.contentView, 0)
    .rightSpaceToView(timeLab, 5)
    .topSpaceToView(self.contentView, 5)
    .autoHeightRatio(0);
    contentLab.font = DEFAULTFONT;
    
    //type =1 鼓励金增加记录,0是鼓励金使用记录
    NSString *contentStr = @"";
    if ([_model.TYPE isEqualToString:@"1" ]) {
        contentStr = [NSString stringWithFormat:@"成功邀请%@注册获得%@元求职奖励金",_model.Name,_model.Money];
        NSMutableAttributedString * attributedStr = [[NSMutableAttributedString alloc] initWithString:contentStr];
        NSRange range = [contentStr rangeOfString:_model.Name];
        [attributedStr setAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithHex:0xFF8117]} range:range];
        contentLab.attributedText = attributedStr;
        
    }else if ([_model.TYPE isEqualToString:@"0" ]){
        contentStr = [NSString stringWithFormat:@"购买%@抵扣%@元求职奖励金",_model.Name,_model.Money];
        contentLab.text = contentStr;
    }
    
    [self setupAutoHeightWithBottomView:contentLab bottomMargin:5];
}

- (void)setModel:(PaSpreadModel *)model{
    _model = model;
    [self setupSubViews];
}

@end

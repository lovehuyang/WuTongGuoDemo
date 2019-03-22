//
//  DiscountCell.m
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/3.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "DiscountCell.h"
@interface DiscountCell()

@property (nonatomic , strong)UILabel *cvTitleLab;
@property (nonatomic , strong)UIButton *selectBtn;

@end

@implementation DiscountCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier indexPath:(NSIndexPath *)indexPath{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubViews:indexPath];
    }
    return self;
}
- (void)setupSubViews:(NSIndexPath *)indexPath{

//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectClick)];
//    [self.contentView addGestureRecognizer:tap];
    self.contentView.userInteractionEnabled = YES;
    UILabel *cvTitleLab = [UILabel new];
    [self.contentView addSubview:cvTitleLab];
    cvTitleLab.sd_layout
        .leftSpaceToView(self.contentView, 15)
        .topSpaceToView(self.contentView, 0)
        .bottomSpaceToView(self.contentView, 0);
    [cvTitleLab setSingleLineAutoResizeWithMaxWidth:SCREEN_WIDTH - 15 - 15 - 25];
    cvTitleLab.font = DEFAULTFONT;
    self.cvTitleLab = cvTitleLab;
    self.cvTitleLab.textColor = [UIColor colorWithHex:0xFF8117];
        
    self.selectBtn = [UIButton new];
    [self.contentView addSubview:self.selectBtn];
    self.selectBtn.sd_layout
        .rightSpaceToView(self.contentView, 15)
        .centerYEqualToView(self.contentView)
        .widthIs(20)
        .heightEqualToWidth();
    [self.selectBtn setImage:[UIImage imageNamed:@"img_checksmall2"] forState:UIControlStateNormal];
    [self.selectBtn setImage:[UIImage imageNamed:@"img_checksmall1"] forState:UIControlStateSelected];
    [self.selectBtn addTarget:self action:@selector(selectClick:) forControlEvents:UIControlEventTouchUpInside];
    self.selectBtn.selected = YES;
}


- (void)setDiscount:(NSString *)discount{
    _discount = discount;
     self.cvTitleLab.text = [NSString stringWithFormat:@"求职鼓励金%.2f元",[_discount floatValue]];
}
- (void)selectClick:(UIButton *)button{
    self.selectBtn.selected = !self.selectBtn.selected;
    self.selectDiscountBlock(button.selected);
}

@end

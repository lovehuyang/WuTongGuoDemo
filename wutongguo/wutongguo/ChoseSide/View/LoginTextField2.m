//
//  LoginTextField2.m
//  wutongguo
//
//  Created by Lucifer on 2019/2/26.
//  Copyright © 2019年 Lucifer. All rights reserved.
//

#import "LoginTextField2.h"
#import "CommonMacro.h"


@implementation LoginTextField2

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title placeholder:(NSString *)placeholder{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = frame.size.height/2;
        self.layer.masksToBounds = YES;
        self.placeholder = placeholder;
        self.font = [UIFont systemFontOfSize:14];
        self.textAlignment = NSTextAlignmentLeft;
        self.tintColor= [UIColor blackColor];
        self.leftView = [self addLefttViewWithTitel:title];
        self.leftViewMode = UITextFieldViewModeAlways;
        self.rightView = [self addRightView];
        self.rightViewMode = UITextFieldViewModeAlways;
        self.clearButtonMode = UITextFieldViewModeWhileEditing;
        self.secureTextEntry = YES;
    }
    return self;
}

-(UIView *)addLefttViewWithTitel:(NSString *)title{
    
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 83, self.frame.size.height)];
    UILabel *titleLab = [[UILabel alloc]initWithFrame:CGRectMake(2 , 0 , 70 , bgView.frame.size.height)];
    titleLab.text = title;
    titleLab.textAlignment = NSTextAlignmentRight;
    titleLab.textColor = [UIColor blackColor];
    titleLab.font = [UIFont systemFontOfSize:14];
    [bgView addSubview:titleLab];
    UILabel *lineLab = [UILabel new];
    lineLab.frame = CGRectMake(CGRectGetMaxX(titleLab.frame)+ 6, 10, 1, CGRectGetHeight(bgView.frame) - 20);
    lineLab.backgroundColor = SEPARATECOLOR;
    [bgView addSubview:lineLab];
    return bgView;
}

- (UIButton *)addRightView{
    CGFloat Btn_W = self.frame.size.height;
    CGFloat Btn_H = self.frame.size.height;
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, Btn_W, Btn_H);
    rightBtn.layer.masksToBounds = YES;
    [rightBtn setImage:[UIImage imageNamed:@"open_eye"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(rightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    return rightBtn;
}

- (void)rightBtnClick:(UIButton *)btn{
    if (self.secureTextEntry) {
        self.secureTextEntry = NO;
        [btn setImage:[UIImage imageNamed:@"close_eye"] forState:UIControlStateNormal];
    }else{
        
        [RCToast showMessage:@"哈哈哈"];
        self.secureTextEntry = YES;
        [btn setImage:[UIImage imageNamed:@"open_eye"] forState:UIControlStateNormal];
    }
}
@end

//
//  LoginTextField.m
//  wutongguo
//
//  Created by Lucifer on 2019/2/25.
//  Copyright © 2019年 Lucifer. All rights reserved.
//

#import "LoginTextField.h"
#import "CommonMacro.h"

@implementation LoginTextField


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
        self.clearButtonMode = UITextFieldViewModeWhileEditing;
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

//- (void)drawRect:(CGRect)rect{
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    //设定起点
//    CGContextMoveToPoint(ctx, 0, self.frame.size.height - 0.3);
//    //添加一条线段到坐标为（100，100）的点
//    CGContextAddLineToPoint(ctx, self.frame.size.width , self.frame.size.height - 0.3);
//    //设置线条的颜色
//    CGContextSetStrokeColorWithColor(ctx, [UIColor lightGrayColor].CGColor);
//    CGContextSetLineWidth(ctx, 0.3);
//    CGContextStrokePath(ctx);
//
//    //3、渲染显示到view上面 (Stroke:空心的)
//    CGContextStrokePath(ctx);
//}
@end

//
//  RCToast.m
//  iOS51rcProject
//
//  Created by Lucifer on 2019/2/18.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "RCToast.h"

@implementation RCToast
+(void)showMessage:(NSString *)message withView:(UIView *)view{
    
    UIView *showview =  [[UIView alloc]init];
    showview.backgroundColor = UIColorWithRGBA(0, 0, 0, 0.8) ;//  RGBA(0, 0, 0, 0.8);
    showview.frame = CGRectZero;
    
    showview.alpha = 1.0f;
    showview.layer.cornerRadius = 5.0f;
    showview.layer.masksToBounds = YES;
    [view addSubview:showview];
    
    UILabel *label = [[UILabel alloc]init];
    //CGSize labelSize = [message sizeWithFont:[UIFont systemFontOfSize:17] constrainedToSize:CGSizeMake(290, 9000)];
    NSDictionary *attribute = @{NSFontAttributeName : [UIFont systemFontOfSize:14]};
    CGSize labelSize = [message boundingRectWithSize:CGSizeMake(SCREEN_WIDTH - 100, 9000) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin attributes:attribute context:nil].size;
    label.frame = CGRectMake(10, 5, labelSize.width, labelSize.height);
    label.text = message;
    label.numberOfLines = 0;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.font = DEFAULTFONT;
    [showview addSubview:label];
    //提示框的位置
    showview.frame = CGRectMake(0, 0, labelSize.width+21*2, labelSize.height+21*2);
    showview.center =CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    label.center = CGPointMake(showview.frame.size.width/2, showview.frame.size.height/2);
    [UIView animateWithDuration:0.5 delay:1.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        showview.alpha = 0;
        
    } completion:^(BOOL finished) {
        [showview removeFromSuperview];
        
    }];
}

+(void)showMessage:(NSString *)message{
    
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    [RCToast showMessage:message withView:window];
}

@end

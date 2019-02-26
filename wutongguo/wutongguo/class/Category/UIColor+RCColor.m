//
//  UIColor+RCColor.m
//  QLRCDemo
//
//  Created by Lucifer on 2019/2/23.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "UIColor+RCColor.h"

@implementation UIColor (RCColor)

/**
 十六进制颜色

 @param hex 十六进制色值
 @return 颜色
 */
+(UIColor *)colorWithHex:(NSInteger)hex{
    
    return [UIColor colorWithHex:hex andAlpha:1.0];
}


/**
  十六进制颜色

 @param hex 十六进制色值
 @param alpha 透明度
 @return 颜色
 */
+ (UIColor *)colorWithHex:(NSInteger)hex andAlpha:(float)alpha{
    
    return [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255 green:((float)((hex & 0xFF00) >> 8))/255 blue:((float)(hex & 0xFF))/255 alpha:alpha];
}

@end

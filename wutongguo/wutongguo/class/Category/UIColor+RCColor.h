//
//  UIColor+RCColor.h
//  QLRCDemo
//
//  Created by Lucifer on 2019/2/23.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (RCColor)

+ (UIColor *) colorWithHex: (NSInteger )hex;

+ (UIColor *)colorWithHex:(NSInteger)hex andAlpha:(float)alpha;

@end

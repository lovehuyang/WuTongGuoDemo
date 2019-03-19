//
//  ApplySpeedUpTipLab.m
//  wutongguo
//
//  Created by Lucifer on 2019/3/19.
//  Copyright © 2019年 Lucifer. All rights reserved.
//

#import "ApplySpeedUpTipLab.h"

@implementation ApplySpeedUpTipLab

- (instancetype)init{
    if (self = [super init]) {
        self.font = DEFAULTFONT;
        self.textColor = [UIColor colorWithHex:0x5142CC];
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = self.textColor.CGColor;
    }
    return self;
}

@end

//
//  RoleView.m
//  wutongguo
//
//  Created by Lucifer on 2019/2/25.
//  Copyright © 2019年 Lucifer. All rights reserved.
//

#import "RoleView.h"

@implementation RoleView

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title img:(NSString *)imgName{
    if (self = [super initWithFrame:frame]) {
        
        UIImageView *imgView = [UIImageView new];
        imgView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 150);
        [self addSubview:imgView];
        [imgView setImage:[UIImage imageNamed:imgName]];
        imgView.contentMode = UIViewContentModeScaleAspectFit;

        
        UILabel *titleLab = [UILabel new];
        titleLab.frame = CGRectMake(0, CGRectGetMaxY(imgView.frame), CGRectGetWidth(imgView.frame), 25);
        [self addSubview:titleLab];
        titleLab.textAlignment = NSTextAlignmentCenter;
        titleLab.font = [UIFont boldSystemFontOfSize:16];
        titleLab.text = title;
        
    }
    return self;
}

@end

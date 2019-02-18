//
//  CommonButton.m
//  wutongguo
//
//  Created by Lucifer on 15-5-10.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "CustomButton.h"
#import "CommonMacro.h"

@implementation CustomButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self.layer setMasksToBounds:YES];
        self.layer.borderColor = [UIColorWithRGBA(152, 152, 152, 1) CGColor];
        self.layer.borderWidth = 0.5;
        self.layer.cornerRadius = 5;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

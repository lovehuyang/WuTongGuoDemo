//
//  CustomLabel.m
//  wutongguo
//
//  Created by Lucifer on 15-5-10.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "CustomLabel.h"
#import "CommonMacro.h"

@implementation CustomLabel

- (id) initWithFixedHeight:(CGRect)frame content:(NSString *)content size:(float)size color:(UIColor *)color {
    self = [super initWithFrame:frame];
    [self setText:content];
    [self setFont:FONT(size)];
    CGSize labelSize = LABEL_SIZE(content, frame.size.width, frame.size.height, size);
    CGRect labelFrame = self.frame;
    labelFrame.size.width = labelSize.width;
    [self setFrame:labelFrame];
    if (color != nil) {
        [self setTextColor:color];
    }
    return self;
}

- (id) initWithFixed:(CGRect)frame content:(NSString *)content size:(float)size color:(UIColor *)color {
    self = [super initWithFrame:frame];
    [self setText:content];
    [self setFont:FONT(size)];
    CGSize labelSize = LABEL_SIZE(content, frame.size.width, frame.size.height, size);
    CGRect labelFrame = self.frame;
    labelFrame.size.width = labelSize.width;
    labelFrame.size.height = labelSize.height;
    [self setFrame:labelFrame];
    [self setNumberOfLines:0];
    if (color != nil) {
        [self setTextColor:color];
    }
    return self;
}

- (id) initWithFixedSpacing:(CGRect)frame content:(NSString *)content size:(float)size color:(UIColor *)color {
    self = [super initWithFrame:frame];
    if (content == nil) {
        frame.size.height = 20;
        [self setFrame:frame];
        return self;
    }
    [self setFont:FONT(size)];
    CGSize labelSize = LABEL_SIZE(content, frame.size.width, frame.size.height, size);
    CGRect labelFrame = self.frame;
    labelFrame.size.width = labelSize.width;
    labelFrame.size.height = labelSize.height;
    [self setFrame:labelFrame];
    if (color != nil) {
        [self setTextColor:color];
    }
    [self setNumberOfLines:0];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:content];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:7];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [content length])];
    [self setAttributedText:attributedString];
    [self setLineBreakMode:NSLineBreakByCharWrapping];
    [self sizeToFit];
    return self;
}

- (id) initWithFrame:(CGRect)frame content:(NSString *)content size:(float)size color:(UIColor *)color {
    self = [super initWithFrame:frame];
    [self setText:content];
    [self setFont:FONT(size)];
    if (color != nil) {
        [self setTextColor:color];
    }
    return self;
}

- (id)initSeparate:(UIView *)parentView {
    self = [super initWithFrame:CGRectMake(0, VIEW_H(parentView) - 0.5, SCREEN_WIDTH, 0.5)];
    [self setBackgroundColor:SEPARATECOLOR];
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

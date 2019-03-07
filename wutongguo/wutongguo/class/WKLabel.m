//
//  WKLabel.m
//
//  Created by Lucifer on 15-5-10.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "WKLabel.h"
#import "Common.h"
#import "CommonMacro.h"

@implementation WKLabel

- (id)initWithFixedHeight:(CGRect)frame content:(NSString *)content size:(float)size color:(UIColor *)color {
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

- (id)initWithFixedSpacing:(CGRect)frame content:(NSString *)content size:(float)size color:(UIColor *)color spacing:(float)spacing {
    if (content == nil) {
        content = @"";
    }
    CGRect multiRect = frame;
    multiRect.size.height = 5000;
    NSArray *arrayLines = [Common getTextLines:content font:[UIFont systemFontOfSize:size] rect:multiRect];
    if (arrayLines.count > 1) {
        if (spacing == 0) {
            spacing = 5;
        }
    }
    else {
        spacing = 0;
    }
    self = [super initWithFrame:frame];
    [self setNumberOfLines:0];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:content];
    [attributedString addAttribute:NSFontAttributeName value:FONT(size) range:NSMakeRange(0, content.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName value:(color == nil ? [UIColor blackColor] : color) range:NSMakeRange(0, content.length)];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:spacing];
    [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [content length])];
    [self setAttributedText:attributedString];
    [self setLineBreakMode:NSLineBreakByCharWrapping];
    [self sizeToFit];
    return self;
}

- (id)initWithFrame:(CGRect)frame content:(NSString *)content size:(float)size color:(UIColor *)color {
    self = [super initWithFrame:frame];
    [self setText:content];
    [self setFont:FONT(size)];
    if (color != nil) {
        [self setTextColor:color];
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

//
//  CustomLabel.h
//  wutongguo
//
//  Created by Lucifer on 15-5-10.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomLabel : UILabel

- (id) initWithFrame:(CGRect)frame content:(NSString *)content size:(float)size color:(UIColor *)color;
- (id) initWithFixedHeight:(CGRect)frame content:(NSString *)content size:(float)size color:(UIColor *)color;
- (id) initWithFixed:(CGRect)frame content:(NSString *)content size:(float)size color:(UIColor *)color;
- (id) initWithFixedSpacing:(CGRect)frame content:(NSString *)content size:(float)size color:(UIColor *)color;
- (id)initSeparate:(UIView *)parentView;
@end

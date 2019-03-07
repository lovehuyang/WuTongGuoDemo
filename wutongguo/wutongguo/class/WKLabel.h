//
//  WKLabel.h
//
//  Created by Lucifer on 15-5-10.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WKLabel : UILabel

- (id)initWithFrame:(CGRect)frame content:(NSString *)content size:(float)size color:(UIColor *)color;
- (id)initWithFixedHeight:(CGRect)frame content:(NSString *)content size:(float)size color:(UIColor *)color;
- (id)initWithFixedSpacing:(CGRect)frame content:(NSString *)content size:(float)size color:(UIColor *)color spacing:(float)spacing;
@end

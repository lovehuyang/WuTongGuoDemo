//
//  CommonToos.m
//  wutongguo
//
//  Created by Lucifer on 2019/2/20.
//  Copyright © 2019年 Lucifer. All rights reserved.
//

#import "CommonToos.h"

@implementation CommonToos
/**
 获取状态栏的高度
 
 @return 状态栏高度
 */
+ (CGFloat)getStatusHight{
    
    CGRect StatusRect = [[UIApplication sharedApplication]statusBarFrame];
    return StatusRect.size.height;
}

/**
 获取状态栏和导航栏的高度
 
 @return 状态栏和导航栏的高度
 */
+ (CGFloat)getStatusAndNavHight{
    
    return  [self getStatusHight] + 44;
}
@end

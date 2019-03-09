//
//  WTGTabbarController.m
//  wutongguo
//
//  Created by Lucifer on 2019/3/8.
//  Copyright © 2019年 Lucifer. All rights reserved.
//

#import "WTGTabbarController.h"
#import "BaseTabbar.h"// 自定义的tabbar

@interface WTGTabbarController ()<UITabBarDelegate>

@end

@implementation WTGTabbarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    BaseTabbar *baseTabbar = [[BaseTabbar alloc]init];
    baseTabbar.delegate = self;
    [self setValue:baseTabbar forKey:@"tabBar"];
}

@end

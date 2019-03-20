//
//  SpeedUpPaySuccessAlert.h
//  wutongguo
//
//  Created by Lucifer on 2019/3/20.
//  Copyright © 2019年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpeedUpPaySuccessAlert : UIView

- (void)setTitle:(NSString *)title markContent:(NSString *)markContent content:(NSString *)content btnTitle:(NSString *)btnTitle validTime:(NSString *)validTime;
- (void)show;
@property (nonatomic , copy)void(^btnBlock)();
@end

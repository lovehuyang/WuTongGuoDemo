//
//  BottomPayView.h
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/3.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BottomPayView : UIView
@property (nonatomic , copy) NSString *money;
@property (nonatomic , copy)void (^payEvent)();
@end

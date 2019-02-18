//
//  LoginViewController.h
//  wutongguo
//
//  Created by Lucifer on 15-5-6.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIButton *btnLogin;
@property (strong, nonatomic) IBOutlet UITextField *txtUsername;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;
@property (strong, nonatomic) IBOutlet UIView *viewThirdLogin;
@property (strong, nonatomic) IBOutlet UIButton *btnWechatLogin;
@property (strong, nonatomic) IBOutlet UIButton *btnQQLogin;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constantQQLogin;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constantWechatLogin;
@property (strong, nonatomic) IBOutlet UIView *viewBottomWithWechat;
@property (strong, nonatomic) IBOutlet UIView *viewBottom;

@property (nonatomic) BOOL fromWechatRegister;
@property (nonatomic) BOOL fromJobApply;
@end

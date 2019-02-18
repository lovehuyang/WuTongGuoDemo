//
//  EmailRegViewController.h
//  wutongguo
//
//  Created by Lucifer on 15-5-6.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmailRegViewController : UIViewController

@property (nonatomic, strong) NSString *openId;
@property (nonatomic, strong) NSString *unionId;
@property (nonatomic, strong) NSString *contactType;
@property (strong, nonatomic) IBOutlet UIButton *btnRegister;
@property (strong, nonatomic) IBOutlet UIButton *btnAgree;
@property (strong, nonatomic) IBOutlet UIImageView *imgAgree;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;
@property (strong, nonatomic) IBOutlet UITextField *txtEmail;
@property (strong, nonatomic) IBOutlet UITextField *txtConfirm;
@property (strong, nonatomic) IBOutlet UIView *viewBottom;
@property (nonatomic) BOOL fromJobApply;
@end

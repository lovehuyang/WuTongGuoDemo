//
//  BindLoginViewController.h
//  wutongguo
//
//  Created by Lucifer on 15/6/4.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BindLoginViewController : UIViewController

@property (nonatomic, strong) NSString *openId;
@property (nonatomic, strong) NSString *unionId;
@property (nonatomic, strong) NSString *contactType;
@property (nonatomic) BOOL fromJobApply;
@property (strong, nonatomic) IBOutlet UIButton *btnLogin;
@property (strong, nonatomic) IBOutlet UITextField *txtUsername;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;
@end

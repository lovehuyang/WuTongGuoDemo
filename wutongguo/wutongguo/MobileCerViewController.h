//
//  MobileCerViewController.h
//  wutongguo
//
//  Created by Lucifer on 15/6/7.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MobileCerViewController : UIViewController

@property (strong, nonatomic) NSString *mobile;
@property (strong, nonatomic) IBOutlet UITextField *txtMobile;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;
@property (strong, nonatomic) IBOutlet UIButton *btnCode;
@property (strong, nonatomic) IBOutlet UITextField *txtCode;
@property (strong, nonatomic) IBOutlet UIButton *btnSave;
@end

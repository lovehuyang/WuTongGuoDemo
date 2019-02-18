//
//  GetPsdStepThreeViewController.h
//  wutongguo
//
//  Created by Lucifer on 15-5-8.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GetPsdStepThreeViewController : UIViewController

@property (nonatomic, strong) NSString *paCode;
@property (nonatomic, strong) NSString *paMainId;
@property (nonatomic, strong) NSString *userName;
@property (strong, nonatomic) IBOutlet UILabel *lbUserName;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;
@property (strong, nonatomic) IBOutlet UITextField *txtConfirm;
@property (strong, nonatomic) IBOutlet UIButton *btnReset;
@end

//
//  GetPsdStepTwoViewController.h
//  wutongguo
//
//  Created by Lucifer on 15-5-8.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GetPsdStepTwoViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *lbUsername;
@property (strong, nonatomic) IBOutlet UITextField *txtCode;
@property (strong, nonatomic) IBOutlet UILabel *lbValue;
@property (strong, nonatomic) IBOutlet UIButton *btnCheckCode;
@property (nonatomic, strong) NSString *uniqueId;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *mobile;
@end

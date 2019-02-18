//
//  PaInfoViewController.h
//  wutongguo
//
//  Created by Lucifer on 16/1/13.
//  Copyright © 2016年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaInfoViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *txtName;
@property (strong, nonatomic) IBOutlet UISegmentedControl *segGender;
@property (strong, nonatomic) IBOutlet UIButton *btnBirth;
@property (strong, nonatomic) IBOutlet UIButton *btnAccountPlace;
@property (strong, nonatomic) IBOutlet UIButton *btnCollege;
@property (strong, nonatomic) IBOutlet UIButton *btnGraduation;
@property (strong, nonatomic) IBOutlet UIButton *btnDegree;
@property (strong, nonatomic) IBOutlet UIButton *btnMajor;
@property (strong, nonatomic) IBOutlet UITextField *txtMobile;
@property (strong, nonatomic) IBOutlet UIButton *btnSave;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@end

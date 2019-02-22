//
//  UserCenterViewController.h
//  wutongguo
//
//  Created by Lucifer on 15-5-8.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserCenterViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIView *viewUser;
@property (strong, nonatomic) IBOutlet UIButton *btnLogin;
@property (strong, nonatomic) IBOutlet UILabel *lbName;
@property (strong, nonatomic) IBOutlet UILabel *lbMobile;
@property (strong, nonatomic) IBOutlet UILabel *lbEmail;
@property (strong, nonatomic) IBOutlet UIView *lbUserSeparate;
@property (strong, nonatomic) IBOutlet UILabel *lbMobileCer;
@property (strong, nonatomic) IBOutlet UIImageView *imgMobileCer;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIButton *btnMobileCer;
@property (strong, nonatomic) IBOutlet UIView *viewPhoto;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintEmail;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintMobile;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIImageView *imgCamera;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintEmailCenterY;
@end

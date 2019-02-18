//
//  SchoolViewController.h
//  wutongguo
//
//  Created by Lucifer on 15-5-15.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SchoolViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIView *viewSchool;
@property (strong, nonatomic) IBOutlet UIView *viewContent;
@property (nonatomic) NSInteger schoolId;
@property (nonatomic) NSInteger tabIndex;
@property (strong, nonatomic) IBOutlet UIButton *btnFocus;
@property (strong, nonatomic) IBOutlet UIImageView *imgLogo;
@end

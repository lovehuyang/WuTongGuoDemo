//
//  SchoolListViewController.h
//  wutongguo
//
//  Created by Lucifer on 15-5-15.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SchoolListViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITableView *tbView;
@property (strong, nonatomic) IBOutlet UILabel *lbJobPlace;
@property (strong, nonatomic) IBOutlet UILabel *lbSchoolType;
@property (strong, nonatomic) IBOutlet UILabel *lbMajorType;
@property (strong, nonatomic) IBOutlet UIImageView *imgJobPlace;
@property (strong, nonatomic) IBOutlet UIImageView *imgSchoolType;
@property (strong, nonatomic) IBOutlet UIImageView *imgMajorType;
@property (strong, nonatomic) IBOutlet UIButton *btnJobPlace;
@property (strong, nonatomic) IBOutlet UIButton *btnSchoolType;
@property (strong, nonatomic) IBOutlet UIButton *btnMajorType;
@property (strong, nonatomic) IBOutlet UIView *viewFilter;
@property (nonatomic) NSString *keyWord;
@end

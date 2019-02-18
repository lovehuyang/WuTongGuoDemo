//
//  FamousViewController.h
//  wutongguo
//
//  Created by Lucifer on 15/5/26.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FamousViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *lbIndustry;
@property (strong, nonatomic) IBOutlet UIImageView *imgIndustry;
@property (strong, nonatomic) IBOutlet UIButton *btnIndustry;
@property (strong, nonatomic) IBOutlet UIView *viewFilter;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintFilterHeight;
@property (nonatomic) NSString *keyWord;
@property (nonatomic) BOOL fromSearch;
@end

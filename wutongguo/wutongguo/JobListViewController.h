//
//  SearchListViewController.h
//  wutongguo
//
//  Created by Lucifer on 15-5-4.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JobListViewController : UIViewController

@property (nonatomic, strong) NSString *keyWord;
@property (nonatomic, strong) NSString *majorId;
@property (nonatomic, strong) NSString *majorName;
@property (nonatomic) BOOL fromSearch;
@property (nonatomic) NSInteger searchType;
@property (strong, nonatomic) IBOutlet UILabel *lbCity;
@property (strong, nonatomic) IBOutlet UIImageView *arrowCity;
@property (strong, nonatomic) IBOutlet UIButton *btnCity;
@property (strong, nonatomic) IBOutlet UILabel *lbIndustry;
@property (strong, nonatomic) IBOutlet UIImageView *arrowIndustry;
@property (strong, nonatomic) IBOutlet UIButton *btnIndustry;
@property (strong, nonatomic) IBOutlet UILabel *lbMajor;
@property (strong, nonatomic) IBOutlet UIImageView *arrowMajor;
@property (strong, nonatomic) IBOutlet UIButton *btnMajor;
@property (strong, nonatomic) IBOutlet UIImageView *arrowCombo;
@property (strong, nonatomic) IBOutlet UIButton *btnCombo;
@property (strong, nonatomic) IBOutlet UIView *viewFilter;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (void)getData;
@end

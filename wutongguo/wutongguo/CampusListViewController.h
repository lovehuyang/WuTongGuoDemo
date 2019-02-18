//
//  CampusViewController.h
//  wutongguo
//
//  Created by Lucifer on 15-5-14.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CampusListViewController : UIViewController

@property (nonatomic, strong) NSString *keyWord;
@property (nonatomic) BOOL fromSearch;
@property (strong, nonatomic) IBOutlet UILabel *lbCity;
@property (strong, nonatomic) IBOutlet UIImageView *arrowCity;
@property (strong, nonatomic) IBOutlet UIButton *btnCity;
@property (strong, nonatomic) IBOutlet UILabel *lbSchool;
@property (strong, nonatomic) IBOutlet UIImageView *arrowSchool;
@property (strong, nonatomic) IBOutlet UIButton *btnSchool;
@property (strong, nonatomic) IBOutlet UILabel *lbIndustry;
@property (strong, nonatomic) IBOutlet UIImageView *arrowIndustry;
@property (strong, nonatomic) IBOutlet UIButton *btnIndustry;
@property (strong, nonatomic) IBOutlet UILabel *lbDate;
@property (strong, nonatomic) IBOutlet UIImageView *arrowDate;
@property (strong, nonatomic) IBOutlet UIButton *btnDate;
@property (strong, nonatomic) IBOutlet UIView *viewFilter;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end

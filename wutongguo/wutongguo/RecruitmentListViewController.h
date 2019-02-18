//
//  RecruitmentListViewController.h
//  wutongguo
//
//  Created by Lucifer on 15-5-14.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecruitmentListViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *lbType;
@property (strong, nonatomic) IBOutlet UIImageView *arrowType;
@property (strong, nonatomic) IBOutlet UIButton *btnType;
@property (strong, nonatomic) IBOutlet UILabel *lbCity;
@property (strong, nonatomic) IBOutlet UIImageView *arrowCity;
@property (strong, nonatomic) IBOutlet UIButton *btnCity;
@property (strong, nonatomic) IBOutlet UILabel *lbPlace;
@property (strong, nonatomic) IBOutlet UIImageView *arrowPlace;
@property (strong, nonatomic) IBOutlet UIButton *btnPlace;
@property (strong, nonatomic) IBOutlet UILabel *lbDate;
@property (strong, nonatomic) IBOutlet UIImageView *arrowDate;
@property (strong, nonatomic) IBOutlet UIButton *btnDate;
@property (strong, nonatomic) IBOutlet UIView *viewFilter;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) NSString *keyWord;
@property (nonatomic, strong) NSString *typeId;
@property (nonatomic) BOOL fromSearch;
@end

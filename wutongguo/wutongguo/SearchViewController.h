//
//  SearchViewController.h
//  wutongguo
//
//  Created by Lucifer on 15-5-13.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UIViewController

@property (nonatomic) NSInteger searchType;
@property (strong, nonatomic) IBOutlet UILabel *lbHot;
@property (strong, nonatomic) IBOutlet UIView *viewNoHistory;
@property (strong, nonatomic) IBOutlet UIView *viewHistory;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end

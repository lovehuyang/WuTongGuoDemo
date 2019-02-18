//
//  SwitchCampusListViewController.h
//  wutongguo
//
//  Created by Lucifer on 15-5-14.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SwitchCampusListViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSInteger searchType;
@property (nonatomic) NSInteger schoolId;
@end

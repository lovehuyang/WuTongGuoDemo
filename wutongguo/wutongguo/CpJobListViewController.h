//
//  CpJobListViewController.h
//  wutongguo
//
//  Created by Lucifer on 15-5-18.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CompanyViewController.h"

@interface CpJobListViewController : UIViewController

@property (nonatomic) NSString *secondId;
@property (nonatomic) NSString *companySecondId;
@property (nonatomic, strong) CompanyViewController *companyCtrl;
@end

//
//  CpBrochureViewController.h
//  wutongguo
//
//  Created by Lucifer on 15-5-16.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CompanyViewController.h"

@interface CpBrochureViewController : UIViewController

@property (nonatomic, strong) NSString *companySecondId;
@property (nonatomic, strong) NSString *secondId;
@property (nonatomic, strong) CompanyViewController *companyCtrl;
@end

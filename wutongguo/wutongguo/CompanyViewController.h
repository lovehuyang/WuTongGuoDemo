//
//  CompanyViewController.h
//  wutongguo
//
//  Created by Lucifer on 15-5-16.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CompanyViewController : UIViewController

@property (nonatomic, strong) NSString *secondId;
@property (nonatomic, strong) NSString *cpBrochureSecondId;
@property NSInteger tabIndex;
@property (nonatomic, strong) NSMutableArray *arrayViewHeight;
- (void)setHeight:(NSInteger)index;
@end

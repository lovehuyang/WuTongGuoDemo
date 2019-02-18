//
//  MapViewController.h
//  wutongguo
//
//  Created by Lucifer on 15/6/5.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapViewController : UIViewController

@property (nonatomic) float lng;
@property (nonatomic) float lat;
@property (nonatomic, strong) NSString *mapTitle;
@property (nonatomic, strong) NSString *mapAddress;
@property (strong, nonatomic) IBOutlet UIView *viewOutMap;
@property (strong, nonatomic) IBOutlet UIView *viewMap;
@property (strong, nonatomic) IBOutlet UIView *viewLine;
@property (strong, nonatomic) IBOutlet UIView *viewEnd;
@property (strong, nonatomic) IBOutlet UITextField *txtBegin;
@property (strong, nonatomic) IBOutlet UILabel *lbEnd;
@property (strong, nonatomic) IBOutlet UILabel *lbTitle;
@property (strong, nonatomic) IBOutlet UIButton *btnBusLine;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintMapViewHeight;

@end

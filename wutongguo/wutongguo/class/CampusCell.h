//
//  CampusCell.h
//  wutongguo
//
//  Created by Lucifer on 15-5-14.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NetWebServiceRequest.h"

@interface CampusCell : UITableViewCell<NetWebServiceRequestDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) NSString *attentionId;
@property (nonatomic, strong) NSString *attentionType;
@property (nonatomic, strong) UIViewController *superViewController;
@property (nonatomic, strong) NSDictionary *cellData;

- (void)fillCell:(NSDictionary *)data
      searchType:(NSInteger)searchType
      fromSchool:(BOOL)fromSchool
  viewController:(UIViewController *)viewController;
@end

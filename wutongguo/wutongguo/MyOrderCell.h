//
//  MyOrderCell.h
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/4.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OrderListModel;

@interface MyOrderCell : UITableViewCell
@property (nonatomic , strong) OrderListModel *model;
@end

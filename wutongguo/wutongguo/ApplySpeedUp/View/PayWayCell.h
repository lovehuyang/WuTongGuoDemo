//
//  PayWayCell.h
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/3.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PayWayModel;

@interface PayWayCell : UITableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier indexPath:(NSIndexPath *)indexPath;
@property (nonatomic , strong) PayWayModel *payModel;
@property (nonatomic , copy) void (^selectPayWay)(PayWayModel *payModel);
@end

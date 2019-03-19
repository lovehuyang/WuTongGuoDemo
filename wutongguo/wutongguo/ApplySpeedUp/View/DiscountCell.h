//
//  DiscountCell.h
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/3.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DiscountInfoModle;

@interface DiscountCell : UITableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier indexPath:(NSIndexPath *)indexPath;

@property (nonatomic , strong)NSString *discount;

@property (nonatomic , copy)void (^selectDiscountBlock)(BOOL useDiscount);
@end

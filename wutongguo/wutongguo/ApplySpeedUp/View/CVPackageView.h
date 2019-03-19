//
//  CVPackageView.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/12/29.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PaOrderPriceModel;

@interface CVPackageView : UIView

@property (nonatomic , copy) void (^buyBtnClickBlock)(PaOrderPriceModel *model);
@property (nonatomic , strong) PaOrderPriceModel *model;
@end

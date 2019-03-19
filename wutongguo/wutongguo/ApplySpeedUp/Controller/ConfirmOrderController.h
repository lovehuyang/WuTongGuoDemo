//
//  ConfirmOrderController.h
//  wutongguo
//
//  Created by Lucifer on 2019/3/19.
//  Copyright © 2019年 Lucifer. All rights reserved.
//

#import "WTGRootViewController.h"
#import "PaOrderPriceModel.h"
@interface ConfirmOrderController : WTGRootViewController
@property (nonatomic , strong) PaOrderPriceModel *model;
@property (nonatomic , strong) NSString *myDiscount;// 我的抵扣金金额

@property (nonatomic , copy)void (^sendbackOrderName)(BOOL paySuccess, NSDictionary *resultDict);
@end

//
//  OrderListModel.h
//  wutongguo
//
//  Created by Lucifer on 2019/3/20.
//  Copyright © 2019年 Lucifer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderListModel : NSObject
@property (nonatomic , copy) NSString *Account;
@property (nonatomic , copy) NSString *AddDate;
@property (nonatomic , copy) NSString *BeginDate;
@property (nonatomic , copy) NSString *Days;
@property (nonatomic , copy) NSString *DcPaOrderPriceID;
@property (nonatomic , copy) NSString *Discount;
@property (nonatomic , copy) NSString *EndDate;
@property (nonatomic , copy) NSString *IDCard;
@property (nonatomic , copy) NSString *Money;
@property (nonatomic , copy) NSString *OpenDate;
@property (nonatomic , copy) NSString *OrderType;
@property (nonatomic , copy) NSString *PaMainID;
@property (nonatomic , copy) NSString *PayFrom;
@property (nonatomic , copy) NSString *PayOrderNum;
@property (nonatomic , copy) NSString *PayType;
@property (nonatomic , copy) NSString *ReceiveDate;
@property (nonatomic , copy) NSString *Id;

+ (id)buildModelWithDic:(NSDictionary *)dic;
@end

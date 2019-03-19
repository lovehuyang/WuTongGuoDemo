//
//  PaOrderPriceModel.h
//  wutongguo
//
//  Created by Lucifer on 2019/3/19.
//  Copyright © 2019年 Lucifer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PaOrderPriceModel : NSObject
@property (nonatomic ,copy)NSString *Days;
@property (nonatomic ,copy)NSString *MaxDiscount;
@property (nonatomic ,copy)NSString *OrderType;
@property (nonatomic ,copy)NSString *Price;
@property (nonatomic ,copy)NSString *Id;

+ (id)buildModelWithDic:(NSDictionary *)dic;
@end

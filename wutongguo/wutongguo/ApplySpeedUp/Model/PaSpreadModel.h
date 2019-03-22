//
//  PaSpreadModel.h
//  wutongguo
//
//  Created by Lucifer on 2019/3/21.
//  Copyright © 2019年 Lucifer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PaSpreadModel : NSObject
@property (nonatomic , copy) NSString *TYPE;
@property (nonatomic , copy) NSString *Money;
@property (nonatomic , copy) NSString *AddDate;
@property (nonatomic , copy) NSString *Name;

+ (id)buildModelWithDic:(NSDictionary *)dic;
@end

//
//  OrderListModel.m
//  wutongguo
//
//  Created by Lucifer on 2019/3/20.
//  Copyright © 2019年 Lucifer. All rights reserved.
//

#import "OrderListModel.h"

@implementation OrderListModel
+ (id)buildModelWithDic:(NSDictionary *)dic{
    
    return [[OrderListModel alloc] initWithDic:dic];
}

- (id)initWithDic:(NSDictionary *)dic {
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if ([key isEqualToString:@"id"]) {
        
        self.Id = value;
    }
}
@end

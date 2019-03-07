//
//  CpRegisterModel.h
//  wutongguo
//
//  Created by Lucifer on 2019/2/26.
//  Copyright © 2019年 Lucifer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CpRegisterModel : NSObject

@property (nonatomic , copy) NSString *cpName;// 企业名称
@property (nonatomic , copy) NSString *dcRegionID;// 所在城市
@property (nonatomic , copy) NSString *LinkMan;// 联系人
@property (nonatomic , copy) NSString *Mobile;// 手机号
@property (nonatomic , copy) NSString *Email;// 电子邮箱
@property (nonatomic , copy) NSString *Username;// 用户名
@property (nonatomic , copy) NSString *Password;// 密码

@end

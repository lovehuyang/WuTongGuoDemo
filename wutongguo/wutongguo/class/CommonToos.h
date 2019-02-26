//
//  CommonToos.h
//  wutongguo
//
//  Created by Lucifer on 2019/2/20.
//  Copyright © 2019年 Lucifer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CommonToos : NSObject

+ (CGFloat)getStatusHight;
+ (CGFloat)getStatusAndNavHight;
+ (NSString *)getIPaddress;
+ (NSString *)getCurrentTime;
+ (void)saveData:(NSString *)key value:(NSString *)value;
+ (NSString *)getValue:(NSString *)key;
@end

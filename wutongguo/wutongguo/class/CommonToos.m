//
//  CommonToos.m
//  wutongguo
//
//  Created by Lucifer on 2019/2/20.
//  Copyright © 2019年 Lucifer. All rights reserved.
//

#import "CommonToos.h"
#import <ifaddrs.h>
#import <arpa/inet.h>

@implementation CommonToos
/**
 获取状态栏的高度
 
 @return 状态栏高度
 */
+ (CGFloat)getStatusHight{
    
    CGRect StatusRect = [[UIApplication sharedApplication]statusBarFrame];
    return StatusRect.size.height;
}

/**
 获取状态栏和导航栏的高度
 
 @return 状态栏和导航栏的高度
 */
+ (CGFloat)getStatusAndNavHight{
    
    return  [self getStatusHight] + 44;
}

//获取ip地址
+ (NSString *)getIPaddress{
    
    NSString *address = @"error";
    struct ifaddrs * ifaddress = NULL;
    struct ifaddrs * temp_address = NULL;
    int success = 0;
    success = getifaddrs(&ifaddress);
    if(success == 0) {
        temp_address = ifaddress;
        while(temp_address != NULL) {
            if(temp_address->ifa_addr->sa_family == AF_INET) {
                if([[NSString stringWithUTF8String:temp_address->ifa_name] isEqualToString:@"en0"]) {
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_address->ifa_addr)->sin_addr)];
                }
            }
            temp_address = temp_address->ifa_next;
        }
    }
    return address;
}

+ (NSString *)getCurrentTime{
    //获取当前时间日期
    NSDate *date=[NSDate date];
    NSDateFormatter *format1=[[NSDateFormatter alloc] init];
    [format1 setDateFormat:@"yyyyMMddhhmmssfff"];
    NSString *dateStr;
    dateStr=[format1 stringFromDate:date];
    NSLog(@"%@",dateStr);
    return dateStr;
}

+ (void)saveData:(NSString *)key value:(NSString *)value{
    [[NSUserDefaults standardUserDefaults] setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)getValue:(NSString *)key{
    NSString *value = [[NSUserDefaults standardUserDefaults]objectForKey:key];
    return value;
}
@end

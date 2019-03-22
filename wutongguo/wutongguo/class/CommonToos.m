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

+ (void)removeData:(NSString *)key{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults]synchronize];
}
+ (BOOL) deptNumInputShouldNumber:(NSString *)str{
    if (str.length == 0) {
        return NO;
    }
    NSString *regex = @"[0-9]*";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    if ([pred evaluateWithObject:str]) {
        return YES;
    }
    return NO;
}

+ (CGFloat)stringWidth:(NSString *)str fontSize:(CGFloat)fontSize{
    CGSize size = [str sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:fontSize]}];
    CGSize statuseStrSize = CGSizeMake(ceilf(size.width), ceilf(size.height));
    return statuseStrSize.width;
    
}


/**
 注册接口返回的错误信息

 @param errorCode 错误码
 @return 错误原因
 */
+ (NSString *)registerResult:(NSInteger)errorCode{
    switch (errorCode) {
        case -1:
            return @"企业名称在黑名单";
            break;
          case -2:
            return @"email在黑名单";
            break;
        case -3:
            return @"手机号在黑名单";
            break;
        case -4:
            return @"ip在黑名单";
            break;
        case -5:
            return @"用户名重复";
            break;
        case -7:
            return @"企业名称重复";
            break;
        case -8:
            return @"Email重复";
            break;
        case -11:
            return @"email不正确";
            break;
        case -12:
            return @"手机号不正确";
            break;
        case -13:
            return @"用户名不正确";
            break;
        case -15:
            return @"地区选择错误";
            break;
        default:
            return @"注册失败,未知错误";
            break;
    }
    
    /*
     
     1 注册成功
     0 注册失败 未知错误
     -1 企业名称在黑名单
     -2 email在黑名单
     -3 手机号在黑名单
     -4 ip在黑名单
     -5 用户名重复
     -7 企业名称重复
     -8 Email重复
     -11 email不正确
     -12 手机号不正确
     -13 用户名不正确
     -15 地区选择错误
     
     */
    
}

/**
 把json字符串转成字典
 
 @param jsonStr json字符串
 @return 字典
 */
+ (NSDictionary *)translateJsonStrToDictionary:(NSString *)jsonStr{
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    return resultDict;
}

+ (NSString *)changeBeginFormatWithDateString:(NSString *)date{
    //2019-01-04T17:54:00+08:00
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'+'ss:ss"];
    NSDate *currentDate = [dateFormatter dateFromString:date];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateStr=[dateFormatter stringFromDate:currentDate];
    return dateStr;
}
+ (NSString *)changeFormatWithDateString:(NSString *)date{
    //2019-01-07T09:43:58.233+08:00
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'+'ss:ss"];
    NSDate *currentDate = [dateFormatter dateFromString:date];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateStr=[dateFormatter stringFromDate:currentDate];
    return dateStr;
}
@end

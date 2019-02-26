//
//  CommonFunc.h
//  wutongguo
//
//  Created by Lucifer on 15-5-11.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GDataXMLNode.h"

@interface CommonFunc : NSObject

+ (NSArray *)getDataFromDB:(NSString *)Sql;
+ (NSArray *)getHistoryFromDB:(NSString *)Sql;
+ (void)updateFromDB:(NSString *)Sql;
+ (NSArray *)getSeparatedLinesFromLabel:(UILabel *)label;
+ (NSArray *)getArrayFromXml:(GDataXMLDocument *)xmlContent
                   tableName:(NSString *)tableName;
+ (NSArray *)getArrayFromXmlWithSelect:(GDataXMLDocument *)xmlContent
                             tableName:(NSString *)tableName
                                 param:(NSArray *)param;
+ (NSArray *)getArrayFromArrayWithSelect:(NSArray *)arrXml
                                   param:(NSArray *)param;
+ (BOOL)checkEmailValid:(NSString *)email;
+ (BOOL)checkMobileValid:(NSString *)mobile;
+ (BOOL)checkPasswordValid:(NSString *)password;
+ (BOOL)checkPasswordIncludeChinese:(NSString *)password;
+ (BOOL)checkLogin;
+ (NSString *)stringFromDateString:(NSString *)date
                        formatType:(NSString *)formatType;
+ (NSString *)stringFromDate:(NSDate *)date
                  formatType:(NSString *)formatType;
+ (NSDate *)dateFromString:(NSString *)dateString;
+ (NSArray *)getMajorType;
+ (NSArray *)getFilterDate;
+ (NSString *)getPaMainId;
+ (NSString *)getCode;
+ (NSString *)getWeek:(NSString *)date;
+ (NSInteger)getCpBrochureStatus:(NSString *)brochureStatus
                       beginDate:(NSString *)beginDate
                         endDate:(NSString *)endDate;
+ (void)share:(NSString *)title
      content:(NSString *)content
          url:(NSString *)url
         view:(UIView *)view
     imageUrl:(NSString *)imageUrl
     content2:(NSString *)content2;

+ (NSString *)passwordProcess:(NSString *)password;
+ (NSString *)escape:(NSString *)str;
+ (NSString *)MD5:(NSString *)signString;
+ (NSString *)getDeviceID;
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
@end

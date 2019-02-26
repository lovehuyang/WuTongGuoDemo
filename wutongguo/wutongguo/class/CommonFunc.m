//
//  CommonFunc.m
//  wutongguo
//
//  Created by Lucifer on 15-5-11.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "CommonFunc.h"
#import "FMDatabase.h"
#import "CommonMacro.h"
#import <CoreText/CoreText.h>
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <CommonCrypto/CommonDigest.h>

@implementation CommonFunc

+ (NSArray *)getDataFromDB:(NSString *)Sql
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:@"dictionary.db"];

    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        NSLog(@"Could Not Open DB");
    }
    FMResultSet *dictionaryList = [db executeQuery:Sql];
    NSMutableArray *arrData = [[NSMutableArray alloc] init];
    NSString *columnName;
    while ([dictionaryList next]) {
        NSString *value;
        if (columnName == nil) {
            if ([dictionaryList columnIndexForName:@"description"] > -1) {
                columnName = @"description";
            }
            else {
                columnName = @"name";
            }
        }
        value = [dictionaryList stringForColumn:columnName];
        [arrData addObject:[[NSDictionary alloc] initWithObjectsAndKeys:[dictionaryList stringForColumn:@"_id"], @"id", value, @"name", nil]];
    }
    [db close];
    return arrData;
}

+ (NSArray *)getHistoryFromDB:(NSString *)Sql
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:@"dictionary.db"];
    
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        NSLog(@"Could Not Open DB");
    }
    FMResultSet *dictionaryList = [db executeQuery:Sql];
    NSMutableArray *arrData = [[NSMutableArray alloc] init];
    while ([dictionaryList next]) {
        [arrData addObject:[[NSDictionary alloc] initWithObjectsAndKeys:[dictionaryList stringForColumn:@"_id"], @"id", [dictionaryList stringForColumn:@"keyWords"], @"keyword", [dictionaryList stringForColumn:@"reSearchDate"], @"searchDate", nil]];
    }
    [db close];
    return arrData;
}

+ (void)updateFromDB:(NSString *)Sql
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:@"dictionary.db"];
    
    FMDatabase *db = [FMDatabase databaseWithPath:dbPath];
    if (![db open]) {
        NSLog(@"Could Not Open DB");
    }
    [db executeUpdate:Sql];
    [db close];
}

+ (NSArray *)getSeparatedLinesFromLabel:(UILabel *)label
{
    NSString *text = [label text];
    UIFont   *font = [label font];
    CGRect    rect = [label frame];
    
    CTFontRef myFont = CTFontCreateWithName((__bridge CFStringRef)([font fontName]), [font pointSize], NULL);
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:text];
    [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)myFont range:NSMakeRange(0, attStr.length)];
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attStr);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0,0,rect.size.width,100000));
    
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    
    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frame);
    NSMutableArray *linesArray = [[NSMutableArray alloc]init];
    
    for (id line in lines)
    {
        CTLineRef lineRef = (__bridge CTLineRef )line;
        CFRange lineRange = CTLineGetStringRange(lineRef);
        NSRange range = NSMakeRange(lineRange.location, lineRange.length);
        NSString *lineString = [text substringWithRange:range];
        [linesArray addObject:lineString];
    }
    return (NSArray *)linesArray;
}

+ (NSArray *)getArrayFromXml:(GDataXMLDocument *)xmlContent
                   tableName:(NSString *)tableName
{
    NSArray *xmlTable = [xmlContent nodesForXPath:[NSString stringWithFormat:@"//%@", tableName] error:nil];
    NSMutableArray *arrXml = [[NSMutableArray alloc] init];
    for (int i=0; i<xmlTable.count; i++) {
        GDataXMLElement *oneXmlElement = [xmlTable objectAtIndex:i];
        NSArray *arrChild = [oneXmlElement children];
        NSMutableDictionary *dicOneXml = [[NSMutableDictionary alloc] init];
        for (int j=0; j<arrChild.count; j++) {
            [dicOneXml setObject:[arrChild[j] stringValue] forKey:[arrChild[j] name]];
        }
        [arrXml addObject:dicOneXml];
    }
    return arrXml;
}

+ (NSArray *)getArrayFromArrayWithSelect:(NSArray *)arrXml
                                 param:(NSArray *)param {
    NSMutableArray *arrData = [[NSMutableArray alloc] init];
    for (NSDictionary *oneXml in arrXml) {
        BOOL blnMatch = YES;
        for (NSDictionary *oneParam in param) {
            if (![[oneXml objectForKey:[[oneParam allKeys] objectAtIndex:0]] isEqualToString:[[oneParam allValues] objectAtIndex:0]]) {
                blnMatch = NO;
                break;
            }
        }
        if (blnMatch) {
            [arrData addObject:oneXml];
        }
    }
    return arrData;
}

+ (NSArray *)getArrayFromXmlWithSelect:(GDataXMLDocument *)xmlContent
                             tableName:(NSString *)tableName
                                 param:(NSArray *)param {
    NSMutableArray *arrData = [[NSMutableArray alloc] init];
    NSArray *arrXml = [self getArrayFromXml:xmlContent tableName:tableName];
    for (NSDictionary *oneXml in arrXml) {
        BOOL blnMatch = YES;
        for (NSDictionary *oneParam in param) {
            if (![[oneXml objectForKey:[oneParam objectForKey:@"column"]] isEqualToString:[oneParam objectForKey:@"value"]]) {
                blnMatch = NO;
                break;
            }
        }
        if (blnMatch) {
            [arrData addObject:oneXml];
        }
    }
    return arrXml;
}

+ (BOOL)checkEmailValid:(NSString *)email {
    BOOL result = true;
    NSString * regex = @"^([a-zA-Z0-9_\\-\\.]+)@((\\[[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\\]?)$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    NSString *emailReg = @"^[\\.\\-_].*$";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailReg];
    BOOL isEmail = [emailTest evaluateWithObject:email];
    BOOL isMatch = [pred evaluateWithObject:email];
    if(!isMatch){
        result = false;
    }
    if(isEmail){
        result = false;
    }
    return result;
}

+ (BOOL)checkMobileValid:(NSString *)mobile {
    NSString *phoneRegex = @"^(13[0-9]|14[0-9]|15[0-9]|16[0-9]|17[0-9]|18[0-9]|19[0-9])\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    return [phoneTest evaluateWithObject:mobile];
}

+ (BOOL)checkPasswordValid:(NSString *)password {
    if (password.length < 8) {
        return NO;
    }
    else if (password.length > 20) {
        return NO;
    }
    else {
        return YES;
    }
//    NSString *passwordReg = @"^[a-zA-Z0-9\\-_\\.]+$";
//    NSPredicate *passwordTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", passwordReg];
//    return [passwordTest evaluateWithObject:password];
}

+ (BOOL)checkPasswordIncludeChinese:(NSString *)password {
    NSLog(@"%@", [self escape:password]);
    if ([[self escape:password] rangeOfString:@"%u"].location != NSNotFound) {
        return YES;
    }
    return NO;
}

+ (BOOL)checkLogin {
    if ([USER_DEFAULT objectForKey:@"paMainId"] == nil) {
        return false;
    }
    else {
        return true;
    }
}

+ (NSDate *)dateFromString:(NSString *)dateString {
    NSRange indexOfLength = [dateString rangeOfString:@"T" options:NSCaseInsensitiveSearch];
    if(indexOfLength.length > 0) {
        dateString = [dateString stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    }
    indexOfLength = [dateString rangeOfString:@"+" options:NSCaseInsensitiveSearch];
    if(indexOfLength.length > 0) {
        dateString = [dateString substringToIndex:19];
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-M-d HH:mm:ss"];
    NSDate *thisDate = [dateFormatter dateFromString:dateString];
    return thisDate;
}

+ (NSString *)stringFromDate:(NSDate *)date
                 formatType:(NSString *)formatType {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:[NSString stringWithFormat:@"%@",formatType]];
    NSString *thisDate = [dateFormatter stringFromDate:date];
    return thisDate;
}

+ (NSString *)stringFromDateString:(NSString *)date
                       formatType:(NSString *)formatType {
    NSDate *newDate = [self dateFromString:date];
    return [self stringFromDate:newDate formatType:formatType];
}

+ (NSArray *)getMajorType {
    return [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"1", @"id", @"综合类", @"name", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"2", @"id", @"理工类", @"name", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"3", @"id", @"师范类", @"name", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"4", @"id", @"农林类", @"name", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"5", @"id", @"政法类", @"name", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"6", @"id", @"医药类", @"name", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"7", @"id", @"财经类", @"name", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"8", @"id", @"民族类", @"name", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"9", @"id", @"语言类", @"name", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"10", @"id", @"艺术类", @"name", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"11", @"id", @"体育类", @"name", nil],[NSDictionary dictionaryWithObjectsAndKeys:@"12", @"id", @"军事类", @"name", nil], nil];
}

+ (NSArray *)getFilterDate {
    return [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"1", @"id", @"今天", @"name", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"2", @"id", @"明天", @"name", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"3", @"id", @"后天", @"name", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"4", @"id", @"本周", @"name", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"5", @"id", @"下周", @"name", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"6", @"id", @"本月", @"name", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"7", @"id", @"下个月", @"name", nil], nil];
}

+ (NSString *)getPaMainId {
    NSString *paMainId = [USER_DEFAULT objectForKey:@"paMainId"];
    if (paMainId.length == 0) {
        paMainId = @"0";
    }
    return paMainId;
}

+ (NSString *)getCode {
    NSString *code = [USER_DEFAULT objectForKey:@"code"];
    if (code.length == 0) {
        code = @"0";
    }
    return code;
}

+ (NSString *)getWeek:(NSString *)date {
    NSDate *thisDate = [self dateFromString:date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [calendar components:NSCalendarUnitWeekday fromDate:thisDate];
    NSString *strWeek = @"";
    NSInteger week = [comps weekday];
    switch (week){
        case 1:
            strWeek = @"周日";
            break;
        case 2:
            strWeek = @"周一";
            break;
        case 3:
            strWeek = @"周二";
            break;
        case 4:
            strWeek = @"周三";
            break;
        case 5:
            strWeek = @"周四";
            break;
        case 6:
            strWeek = @"周五";
            break;
        case 7:
            strWeek = @"周六";
            break;
        default:
            strWeek = @"周日";
            break;
    }
    return strWeek;
}

+ (NSInteger)getCpBrochureStatus:(NSString *)brochureStatus
                       beginDate:(NSString *)beginDate
                         endDate:(NSString *)endDate {
    NSInteger statusType = 0;
    NSDate *dateBegin = [self dateFromString:beginDate];
    NSDate *dateEnd = [self dateFromString:endDate];
    NSDate *dateToday = [[NSDate alloc] init];
    if ([dateEnd compare:dateToday] == NSOrderedAscending) {
        statusType = 2; //已过期
    }
    else if ([dateBegin compare:dateToday] == NSOrderedDescending) {
        statusType = 3; //未开始
    }
    else {
        if ([brochureStatus isEqualToString:@"2"]) {
            statusType = 4; //已暂停
        }
        else {
            statusType = 1; //网申中
        }
    }
    return statusType;
}

+ (void)share:(NSString *)title
      content:(NSString *)content
          url:(NSString *)url
         view:(UIView *)view
     imageUrl:(NSString *)imageUrl
     content2:(NSString *)content2 {
    //1、创建分享参数
    if (![url containsString:@"http"]) {
        url = [NSString stringWithFormat:@"http://m.wutongguo.com%@", url];
    }
    NSArray* imageArray;
    if (imageUrl.length == 0) {
        imageArray = @[[UIImage imageNamed:@"ShareLogo.jpg"]];
    }
    else {
        imageArray = @[[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]]];
    }
    if (imageArray) {
        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
        [shareParams SSDKSetupShareParamsByText:[NSString stringWithFormat:@"%@ --来自梧桐果%@", content, url]
                                         images:imageArray
                                            url:[NSURL URLWithString:url]
                                          title:title
                                           type:SSDKContentTypeAuto];
        //微信朋友圈平台
        [shareParams SSDKSetupWeChatParamsByText:content2 title:content2 url:[NSURL URLWithString:url] thumbImage:nil image:imageArray musicFileURL:nil extInfo:nil fileData:nil emoticonData:nil type:SSDKContentTypeAuto forPlatformSubType:SSDKPlatformSubTypeWechatTimeline];
        //微信好友
        [shareParams SSDKSetupWeChatParamsByText:content title:title url:[NSURL URLWithString:url] thumbImage:nil image:imageArray musicFileURL:nil extInfo:nil fileData:nil emoticonData:nil type:SSDKContentTypeAuto forPlatformSubType:SSDKPlatformSubTypeWechatSession];
        //QQ
        [shareParams SSDKSetupQQParamsByText:content title:title url:[NSURL URLWithString:url] thumbImage:nil image:imageArray type:SSDKContentTypeAuto forPlatformSubType:SSDKPlatformSubTypeQQFriend];
        
        [ShareSDK showShareActionSheet:nil
                                 items:nil
                           shareParams:shareParams
                   onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                       
                       switch (state) {
                           case SSDKResponseStateSuccess:
                           {
                               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                                                   message:nil
                                                                                  delegate:nil
                                                                         cancelButtonTitle:@"确定"
                                                                         otherButtonTitles:nil];
                               [alertView show];
                               break;
                           }
                           case SSDKResponseStateFail:
                           {
                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                                                               message:[NSString stringWithFormat:@"%@",error]
                                                                              delegate:nil
                                                                     cancelButtonTitle:@"OK"
                                                                     otherButtonTitles:nil, nil];
                               [alert show];
                               break;
                           }
                           default:
                               break;
                       }
                   }
         ];}
}

+ (NSString *)passwordProcess:(NSString *)password {
    NSString *result = [password stringByReplacingOccurrencesOfString:@"&" withString:@"@#U7"];
    result = [password stringByReplacingOccurrencesOfString:@"<" withString:@"@#U8"];
    return result;
}

+ (NSString *)escape:(NSString *)str {
    NSArray *hex = [NSArray arrayWithObjects:
                    @"00",@"01",@"02",@"03",@"04",@"05",@"06",@"07",@"08",@"09",@"0A",@"0B",@"0C",@"0D",@"0E",@"0F",
                    @"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"1A",@"1B",@"1C",@"1D",@"1E",@"1F",
                    @"20",@"21",@"22",@"23",@"24",@"25",@"26",@"27",@"28",@"29",@"2A",@"2B",@"2C",@"2D",@"2E",@"2F",
                    @"30",@"31",@"32",@"33",@"34",@"35",@"36",@"37",@"38",@"39",@"3A",@"3B",@"3C",@"3D",@"3E",@"3F",
                    @"40",@"41",@"42",@"43",@"44",@"45",@"46",@"47",@"48",@"49",@"4A",@"4B",@"4C",@"4D",@"4E",@"4F",
                    @"50",@"51",@"52",@"53",@"54",@"55",@"56",@"57",@"58",@"59",@"5A",@"5B",@"5C",@"5D",@"5E",@"5F",
                    @"60",@"61",@"62",@"63",@"64",@"65",@"66",@"67",@"68",@"69",@"6A",@"6B",@"6C",@"6D",@"6E",@"6F",
                    @"70",@"71",@"72",@"73",@"74",@"75",@"76",@"77",@"78",@"79",@"7A",@"7B",@"7C",@"7D",@"7E",@"7F",
                    @"80",@"81",@"82",@"83",@"84",@"85",@"86",@"87",@"88",@"89",@"8A",@"8B",@"8C",@"8D",@"8E",@"8F",
                    @"90",@"91",@"92",@"93",@"94",@"95",@"96",@"97",@"98",@"99",@"9A",@"9B",@"9C",@"9D",@"9E",@"9F",
                    @"A0",@"A1",@"A2",@"A3",@"A4",@"A5",@"A6",@"A7",@"A8",@"A9",@"AA",@"AB",@"AC",@"AD",@"AE",@"AF",
                    @"B0",@"B1",@"B2",@"B3",@"B4",@"B5",@"B6",@"B7",@"B8",@"B9",@"BA",@"BB",@"BC",@"BD",@"BE",@"BF",
                    @"C0",@"C1",@"C2",@"C3",@"C4",@"C5",@"C6",@"C7",@"C8",@"C9",@"CA",@"CB",@"CC",@"CD",@"CE",@"CF",
                    @"D0",@"D1",@"D2",@"D3",@"D4",@"D5",@"D6",@"D7",@"D8",@"D9",@"DA",@"DB",@"DC",@"DD",@"DE",@"DF",
                    @"E0",@"E1",@"E2",@"E3",@"E4",@"E5",@"E6",@"E7",@"E8",@"E9",@"EA",@"EB",@"EC",@"ED",@"EE",@"EF",
                    @"F0",@"F1",@"F2",@"F3",@"F4",@"F5",@"F6",@"F7",@"F8",@"F9",@"FA",@"FB",@"FC",@"FD",@"FE",@"FF", nil];
    
    NSMutableString *result = [NSMutableString stringWithString:@""];
    NSInteger strLength = str.length;
    for (int i=0; i<strLength; i++) {
        int ch = [str characterAtIndex:i];
        if (ch == ' ')
        {
            [result appendFormat:@"%c",'+'];
        }
        else if ('A' <= ch && ch <= 'Z')
        {
            [result appendFormat:@"%c",(char)ch];
            
        }
        else if ('a' <= ch && ch <= 'z')
        {
            [result appendFormat:@"%c",(char)ch];
        }
        else if ('0' <= ch && ch<='9')
        {
            [result appendFormat:@"%c",(char)ch];
        }
        else if (ch == '-' || ch == '_'
                 || ch == '.' || ch == '!'
                 || ch == '~' || ch == '*'
                 || ch == '\'' || ch == '('
                 || ch == ')')
        {
            [result appendFormat:@"%c",(char)ch];
        }
        else if (ch <= 0x007F)
        {
            [result appendFormat:@"%c",'%'];
            [result appendString:[hex objectAtIndex:ch]];
        }
        else
        {
            [result appendFormat:@"%c",'%'];
            [result appendFormat:@"%c",'u'];
            [result appendString:[hex objectAtIndex:ch>>8]];
            [result appendString:[hex objectAtIndex:0x00FF & ch]];
        }
    }
    return result;
}

+ (NSString *)MD5:(NSString *)signString
{
    const char*cStr =[signString UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    return[NSString stringWithFormat:
           @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
           result[0], result[1], result[2], result[3],
           result[4], result[5], result[6], result[7],
           result[8], result[9], result[10], result[11],
           result[12], result[13], result[14], result[15]
           ];
}

+ (NSString *)getDeviceID {
    return [[UIDevice currentDevice].identifierForVendor UUIDString];
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

@end

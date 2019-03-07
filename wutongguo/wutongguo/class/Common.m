#import "Common.h"
#import "CommonMacro.h"
#import <CommonCrypto/CommonDigest.h>
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <CoreText/CoreText.h>
#import <ifaddrs.h>
#import <arpa/inet.h>

@implementation Common

/**
 ISO时间转普通时间格式

 @param dateString ISO时间串
 @return 处理结果
 */
+ (NSDate *)dateFromString:(NSString *)dateString {
    if ([dateString length] == 10) {
        dateString = [NSString stringWithFormat:@"%@ 00:00:00", dateString];
    }
    if ([dateString length] == 16) {
        dateString = [NSString stringWithFormat:@"%@:00", dateString];
    }
    NSRange indexOfLength = [dateString rangeOfString:@"T" options:NSCaseInsensitiveSearch];
    if(indexOfLength.length > 0) {
        dateString = [dateString stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    }
    indexOfLength = [dateString rangeOfString:@"+" options:NSCaseInsensitiveSearch];
    if(indexOfLength.length > 0) {
        dateString = [dateString substringToIndex:19];
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
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
    if ([date length] == 10) {
        date = [NSString stringWithFormat:@"%@ 00:00:00", date];
    }
    NSDate *newDate = [self dateFromString:date];
    return [self stringFromDate:newDate formatType:formatType];
}

//检查密码格式
+ (BOOL)checkPassword:(NSString *)password {
    NSString *passwordreg=@"^[a-zA-Z0-9\\-_\\.]+$";
    NSPredicate *passreg = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", passwordreg];
    BOOL ispassWordMatch = [passreg evaluateWithObject:password];
    if(!(ispassWordMatch)) {
        return false;
    }
    else {
        return true;
    }
}

//检查密码格式
+ (BOOL)checkCpPassword:(NSString *)password {
    NSString *passwordreg=@"^(?=.*[a-zA-Z])(?=.*\\d)[\\s\\S]{8,16}$";
    NSPredicate *passreg = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", passwordreg];
    BOOL ispassWordMatch = [passreg evaluateWithObject:password];
    if(!(ispassWordMatch)) {
        return false;
    }
    else {
        return true;
    }
}

//验证邮箱
+ (BOOL)checkEmail:(NSString *)email {
    BOOL result = true;
    NSString * regex = @"^([a-zA-Z0-9_\\-\\.]+)@((\\[[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\\]?)$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    NSString *emailRegex = @"^[\\.\\-_].*$";
    NSPredicate *emailPred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL isEmail=[emailPred evaluateWithObject:email];
    BOOL isMatch = [pred evaluateWithObject:email];
    if(!isMatch) {
        result = false;
    }
    if(isEmail) {
        result = false;
    }
    return result;
}

+ (BOOL)checkMobile:(NSString *)mobile {
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^(13[0-9]|14[0-9]|15[0-9]|16[0-9]|17[0-9]|18[0-9]|19[0-9])\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    BOOL result = [phoneTest evaluateWithObject:mobile];
    return result;
}

+ (NSString *) MD5:(NSString *)signString {
    const char *cStr = [signString UTF8String];
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

+ (BOOL)isPureInt:(NSString*)string {
    NSScanner *scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

+ (BOOL)isPureChinese:(NSString *)string {
    for (int i = 0; i < [string length]; i++) {
        int a = [string characterAtIndex:i];
        if (a > 0x4e00 && a < 0x9fff) {
            
        }
        else {
            return NO;
        }
    }
    return YES;
}

+ (void)share:(NSString *)title
      content:(NSString *)content
          url:(NSString *)url
     imageUrl:(NSString *)imageUrl {
    NSArray* imageArray;
    if (imageUrl.length == 0) {
        imageArray = @[[UIImage imageNamed:@"img_defaultlogo.png"]];
    }
    else {
        imageArray = @[[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]]];
    }
    if (imageArray) {
        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
        [shareParams SSDKSetupShareParamsByText:content
                                         images:imageArray
                                            url:[NSURL URLWithString:url]
                                          title:title
                                           type:SSDKContentTypeAuto];
        [shareParams SSDKEnableUseClientShare];
        
        //微信朋友圈平台
        [shareParams SSDKSetupWeChatParamsByText:title title:content url:[NSURL URLWithString:url] thumbImage:nil image:imageArray musicFileURL:nil extInfo:nil fileData:nil emoticonData:nil type:SSDKContentTypeAuto forPlatformSubType:SSDKPlatformSubTypeWechatTimeline];
        
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
        ];
    }
}

+ (NSArray *)getArrayFromXml:(GDataXMLDocument *)xmlContent
                   tableName:(NSString *)tableName {
    NSArray *xmlTable = [xmlContent nodesForXPath:[NSString stringWithFormat:@"//%@", tableName] error:nil];
    NSMutableArray *arrXml = [[NSMutableArray alloc] init];
    for (int i = 0; i < xmlTable.count; i++) {
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

+ (NSString *)getValueFromXml:(GDataXMLDocument *)xmlContent{

    GDataXMLElement *xmlEle = [xmlContent rootElement];
    
    NSArray *array = [xmlEle children];
    if (array.count > 0) {
        GDataXMLElement *ele = [array firstObject];
        return [ele stringValue];
    }else{
        return nil;
    }
    
//    for (int i =0; i < [array count]; i++) {
//        GDataXMLElement *ele = [array objectAtIndex:i];
//        DLog(@"%@",[ele stringValue]);
//        return [ele stringValue];
//    }
    return nil;
}

/**
 处理时间

 @param date ISO格式时间
 @return 处理结果
 */
+ (NSString *)stringFromRefreshDate:(NSString *)date {
    NSDate *d = [self dateFromString:date];
    
    return [self calculateTimeInterval:d];;
}


/**
 计算时间间隔

 @param timeDate 时间
 @return 时间间隔
 */
+ (NSString *)calculateTimeInterval:(NSDate *)timeDate{
    
    //八小时时区
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:timeDate];
    NSDate *mydate = [timeDate dateByAddingTimeInterval:interval];
    NSDate *nowDate = [[NSDate date]dateByAddingTimeInterval:interval];
    //两个时间间隔
    NSTimeInterval timeInterval = [mydate timeIntervalSinceDate:nowDate];
    timeInterval = -timeInterval;
    long temp = 0;
    NSString *timeState = nil;
    if (timeInterval<300) {
        timeState = [NSString stringWithFormat:@"刚刚"];
    }else if ((temp = timeInterval/60)<10){
        timeState = @"5分钟";
    }else if ((temp = timeInterval/60)<30){
        timeState = @"10分钟";
    }else if ((temp = timeInterval/60)<60){
        timeState = @"30分钟";
    }else if ((temp = timeInterval/60)<120){
        timeState = @"1小时";
    }else if ((temp = timeInterval/60)<180){
        timeState = @"2小时";
    }else if ((180<=(temp = timeInterval/60)) && [[self compareDate:timeDate] isEqualToString:@"今天"]){
        timeState = @"今天";
    }else if ((180<=(temp = timeInterval/60)) && [[self compareDate:timeDate] isEqualToString:@"昨天"]){
        timeState = @"昨天";
    }else{
        timeState = [self compareDate:timeDate];
    }
    
    return timeState;
}

#pragma mark - 获取今天是几号
+ (NSString *)compareDate:(NSDate *)date{
    
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *today = [[NSDate alloc] init];
    NSDate *tomorrow, *yesterday;
    
    tomorrow = [today dateByAddingTimeInterval: secondsPerDay];
    yesterday = [today dateByAddingTimeInterval: -secondsPerDay];
    
    // 10 first characters of description is the calendar date:
    NSString * todayString = [[today description] substringToIndex:10];
    NSString * yesterdayString = [[yesterday description] substringToIndex:10];
    NSString * tomorrowString = [[tomorrow description] substringToIndex:10];
    
    NSString * dateString = [[date description] substringToIndex:10];
    
    if ([dateString isEqualToString:todayString])
    {
        return @"今天";
    } else if ([dateString isEqualToString:yesterdayString])
    {
        return @"昨天";
    }else if ([dateString isEqualToString:tomorrowString])
    {
        return @"明天";
    }
    else
    {
        return dateString;
    }
}
+ (NSArray *)getTextLines:(NSString *)text font:(UIFont *)font rect:(CGRect)rect {
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
        CTLineRef lineRef = (__bridge CTLineRef)line;
        CFRange lineRange = CTLineGetStringRange(lineRef);
        NSRange range = NSMakeRange(lineRange.location, lineRange.length);
        NSString *lineString = [text substringWithRange:range];
        [linesArray addObject:lineString];
    }
    return linesArray;
}

+ (float)getLastLineWidth:(UILabel *)label {
    NSString *text = [label text];
    UIFont   *font = [label font];
    CGRect    rect = [label frame];
    NSArray *linesArray = [self getTextLines:text font:font rect:rect];
    NSString *lastLineText = [linesArray objectAtIndex:linesArray.count - 1];
    CGSize sizeLastLine = LABEL_SIZE(lastLineText, rect.size.width, 20, font.pointSize);
    return sizeLastLine.width;
}

+ (void)changeFontSize:(UIView *)parentView {
    for (UIView *view in parentView.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            [(UILabel *)view setFont:DEFAULTFONT];
        }
        else if ([view isKindOfClass:[UITextField class]]) {
            [(UITextField *)view setFont:DEFAULTFONT];
        }
        else if ([view isKindOfClass:[UITextView class]]) {
            [(UITextView *)view setFont:DEFAULTFONT];
        }
        else if ([view isKindOfClass:[UIButton class]]) {
            [[(UIButton *)view titleLabel] setFont:DEFAULTFONT];
        }
        [self changeFontSize:view];
    }
}

+ (NSArray *)querySql:(NSString *)sql dataBase:(FMDatabase *)dataBase {
    Boolean blnCpSalary = NO;
    if ([[sql lowercaseString] rangeOfString:@"dcsalarycp"].location != NSNotFound) {
        blnCpSalary = YES;
        sql = [sql stringByReplacingOccurrencesOfString:@"dcSalaryCp" withString:@"dcSalary"];
    }
    if (dataBase == nil) {
        NSString* dbPath = [[NSBundle mainBundle] pathForResource:@"dictionary.db" ofType:@""];
        dataBase = [FMDatabase databaseWithPath:dbPath];
        [dataBase open];
    }
    FMResultSet *resultSet = [dataBase executeQuery:sql];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    while ([resultSet next]) {
        [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:[resultSet stringForColumn:@"_id"], @"id", [resultSet stringForColumn:(blnCpSalary ? @"descriptioncp" : @"description")], @"value", nil]];
    }
    return array;
}

+ (NSString *)getPaPhotoUrl:(NSString *)fileName paMainId:(NSString *)paMainId {
    NSString *path = [NSString stringWithFormat:@"%d",([paMainId intValue] / 100000 + 1) * 100000];
    NSInteger lastLength = 9 - path.length;
    for (int i = 0; i < lastLength; i++) {
        path = [NSString stringWithFormat:@"0%@",path];
    }
    path = [NSString stringWithFormat:@"L%@",path];
    path = [NSString stringWithFormat:@"http://down.51rc.com/imagefolder/Photo/%@/Processed/%@", path, fileName];
    return path;
}

+ (NSArray *)arrayWelfare {
    return [[NSArray alloc] initWithObjects:@"社会保险", @"商业保险", @"公积金", @"年终奖", @"奖金提成", @"全勤奖", @"节日福利", @"双休", @"8小时工作制", @"带薪年假", @"公费培训", @"公费旅游", @"健康体检", @"通讯补贴", @"提供住宿", @"餐补/工作餐", @"住房补贴", @"交通补贴", @"班车接送", nil];
}

+ (NSArray *)arrayWelfareId {
    return [[NSArray alloc] initWithObjects:@"1", @"19", @"2", @"4", @"13", @"14", @"11", @"3", @"9", @"5", @"12", @"6", @"16", @"17", @"10", @"7", @"18", @"8", @"15", nil];
}

+ (NSString *)getWelfare:(NSArray *)arrayWelfareIdSelected {
    NSMutableArray *arrayWelfareSelected = [[NSMutableArray alloc] init];
    for (NSInteger index = 0; index < self.arrayWelfareId.count; index++) {
        NSInteger welfareId = [[self.arrayWelfareId objectAtIndex:index] integerValue];
        if ([[arrayWelfareIdSelected objectAtIndex:(welfareId - 1)] isEqualToString:@"1"]) {
            [arrayWelfareSelected addObject:[self.arrayWelfare objectAtIndex:index]];
        }
    }
    return [arrayWelfareSelected componentsJoinedByString:@"+"];
}

+ (NSArray *)arrayPush {
    return [[NSArray alloc] initWithObjects:@"周一", @"周二", @"周三", @"周四", @"周五", @"周六", @"周日", nil];
}

+ (NSString *)getPushIdWithBin:(NSString *)pushId {
    pushId = [self toBinarySystemWithDecimalSystem:pushId];
    for (NSInteger i = 7 - pushId.length; i > 0; i--) {
        pushId = [NSString stringWithFormat:@"0%@", pushId];
    }
    return pushId;
}

+ (NSString *)getPush:(NSString *)pushId {
    NSMutableArray *arrayPushSelected = [[NSMutableArray alloc] init];
    for (NSInteger index = 0; index < 7; index++) {
        NSRange range = NSMakeRange(index, 1);
        if ([[pushId substringWithRange:range] isEqualToString:@"1"]) {
            [arrayPushSelected addObject:[self.arrayPush objectAtIndex:index]];
        }
    }
    return [arrayPushSelected componentsJoinedByString:@"+"];
}

+ (NSString *)toBinarySystemWithDecimalSystem:(NSString *)decimal {
    int num = [decimal intValue];
    int remainder = 0;      //余数
    int divisor = 0;        //除数
    NSString * prepare = @"";
    while (true) {
        remainder = num % 2;
        divisor = num / 2;
        num = divisor;
        prepare = [prepare stringByAppendingFormat:@"%d",remainder];
        if (divisor == 0) {
            break;
        }
    }
    NSString * result = @"";
    for (NSInteger i = prepare.length - 1; i >= 0; i --) {
        result = [result stringByAppendingFormat:@"%@", [prepare substringWithRange:NSMakeRange(i , 1)]];
    }
    return result;
}

+ (NSString *)toDecimalSystemWithBinarySystem:(NSString *)binary {
    int ll = 0 ;
    int temp = 0 ;
    for (int i = 0; i < binary.length; i ++) {
        temp = [[binary substringWithRange:NSMakeRange(i, 1)] intValue];
        temp = temp * powf(2, binary.length - i - 1);
        ll += temp;
    }
    NSString * result = [NSString stringWithFormat:@"%d",ll];
    return result;
}

+ (NSString *)getSalary:(NSString *)salaryId salaryMin:(NSString *)salaryMin salaryMax:(NSString *)salaryMax negotiable:(NSString *)negotiable {
    NSString *salary = [NSString stringWithFormat:@"%@-%@", salaryMin, salaryMax];
    if ([salaryId isEqualToString:@"100"]) {
        salary = @"面议";
    }
    else {
        if ([salaryId isEqualToString:@"16"]) {
            salary = [NSString stringWithFormat:@"%@以上", salaryMin];
        }
        if ([negotiable boolValue]) {
            salary = [NSString stringWithFormat:@"%@（可面议）", salary];
        }
    }
    return salary;
}

+ (NSString *)enMobile:(NSString *)mobile {
    mobile = [self toHex:[mobile integerValue]];
    mobile = [mobile stringByReplacingOccurrencesOfString:@"1" withString:@"u"];
    mobile = [mobile stringByReplacingOccurrencesOfString:@"2" withString:@"m"];
    mobile = [mobile stringByReplacingOccurrencesOfString:@"3" withString:@"z"];
    mobile = [mobile stringByReplacingOccurrencesOfString:@"4" withString:@"s"];
    mobile = [mobile stringByReplacingOccurrencesOfString:@"5" withString:@"n"];
    mobile = [mobile stringByReplacingOccurrencesOfString:@"6" withString:@"x"];
    mobile = [mobile stringByReplacingOccurrencesOfString:@"7" withString:@"g"];
    mobile = [mobile stringByReplacingOccurrencesOfString:@"8" withString:@"v"];
    mobile = [mobile stringByReplacingOccurrencesOfString:@"9" withString:@"j"];
    mobile = [mobile stringByReplacingOccurrencesOfString:@"0" withString:@"t"];
    NSArray *arrInsert = @[@"y", @"l", @"9", @"8", @"h", @"p", @"o", @"5", @"k", @"6", @"1", @"w", @"0", @"2", @"r", @"4", @"7", @"i", @"3", @"q"];
    NSMutableString *enMobile = [[NSMutableString alloc] initWithString:mobile];
    for (NSInteger i = mobile.length; i < 40; i++) {
        int a = arc4random() % (arrInsert.count - 1);
        int b = arc4random() % (enMobile.length - 1);
        [enMobile insertString:arrInsert[a] atIndex:b];
    }
    return enMobile;
}

//将十进制转化为十六进制
+ (NSString *)toHex:(NSInteger)tmpid {
    NSString *nLetterValue;
    NSString *str = @"";
    uint16_t ttmpig;
    for (int i = 0; i < 9; i++) {
        ttmpig = tmpid % 16;
        tmpid = tmpid / 16;
        switch (ttmpig)
        {
            case 10:
                nLetterValue = @"a";
                break;
            case 11:
                nLetterValue = @"b";
                break;
            case 12:
                nLetterValue = @"c";
                break;
            case 13:
                nLetterValue = @"d";
                break;
            case 14:
                nLetterValue = @"e";
                break;
            case 15:
                nLetterValue = @"f";
                break;
            default:
                nLetterValue = [NSString stringWithFormat:@"%u", ttmpig];
        }
        str = [nLetterValue stringByAppendingString:str];
        if (tmpid == 0) {
            break;
        }
    }
    return str;
}

/**
 验证码登录:获取验证码接口返回的错误码信息

 @param result 返回值
 @return 处理结果
 */
+ (NSString *)verifyCodeGetResult:(NSInteger)result{
    switch (result) {
        case -11:
            return @"网络链接错误，请稍候重试！";
            break;
        case -99:
            return @"请输入正确的手机号！";
            break;
        case -98:
            return @"请输入已认证的手机号！";
            break;
        case -3:
            return @"该手机号发送短信验证码次数过多！";
            break;
        case -2:
            return @"该ip今天发送短信验证码次数过多！";
            break;
        case -1:
            return @"您的手机号已被列入黑名单，请尝试其他方式登录！";
        case -4:
            return @"您输入手机号获取验证码太频繁，请稍候再试！";
        case -5:
            return @"您在180s内获取过验证码，请稍候重试！";
        case -97:
            return @"获取验证码失败，请稍候重试！";
        case 1:
            return @"获取验证码成功！";
        default:
            return @"未知错误";
            break;
    }
}

/**
 验证码登录接口返回的错误码信息
 
 @param result 返回值
 @return 处理结果
 */
+ (NSString *)verifyCodeLoginResult:(NSInteger)result{
    switch (result) {
        case 0:
            return @"用户名或密码错误，请重新输入";
            break;
        case -1:
            return @"手机号或短信验证码为空";
            break;
        case -2:
            return @"手机号错误 ";
            break;
        case -3:
            return @"短信验证码错误";
            break;
        case -4:
            return @"您的手机号没有获取过验证码";
            break;
        default:
            return @"未知错误";
            break;
    }
}

/**
 一分钟填写简历验证码接口返回的错误码信息
 
 @param result 返回值
 @return 处理结果
 */
+ (NSString *)oneminuteMobileCerCodeResult:(NSInteger)result{
    switch (result) {
        case 0:
            return @"短信发送失败，请稍后重试！";
            break;
        case -1:
            return @"该手机号已经认证过，无需重复认证！";
            break;
        case -2:
            return @"该手机号当天认证次数过多！";
            break;
        case -3:
            return @"短信发送失败，请稍后重试！";
            break;
        case -4:
            return @"您输入手机号已经存在，请重新输入！";
            break;
        case -5:
            return @"您在180s内获取过验证码，请稍候重试！";
            break;
        case -11:
            return @"网络链接错误，请稍候重试！";
            break;
        case -100:
            return @"数据异常，请返回并重试！";
            break;
        case -102:
            return @"手机号格式错误！";
            break;
        case -103:
            return @"该手机号60天之内认证过其他账号，建议您用该手机号取回密码！";
            break;
        default:
            return @"未知错误";
            break;
    }
}

/**
 账号密码登录接口返回的错误码信息
 
 @param result 返回值
 @return 处理结果
 */
+ (NSString *)loginResult:(NSInteger)result{
    switch (result) {
        case -1:
            return @"您今天的登录次数已超过20次的限制，请明天再来";
            break;
        case -2:
            return @"请提交意见反馈向我们反映，谢谢配合";
            break;
        case -3:
            return @"提交错误，请检查您的网络链接，并稍后重试";
            break;
        case 0:
            return @"用户名或密码错误，请重新输入";
            break;
        default:
            return @"您今天的登录次数已超过20次的限制，请明天再来";
            break;
    }
}

/**
 个人用户注册页面获取验证码接口返回结果

 @param result 错误码
 @return 错误信息
 */
+ (NSString *)getPaMobileVerifyCodeResult:(NSInteger)result{
    switch (result) {
        case 0:
            return @"该手机号发送短信验证码次数过多";
            break;
        case -1:
            return @"该ip今天发送短信验证码次数过多";
            break;
        case -2:
            return @"您输入手机号已经存在，请重新输入";
            break;
        case -3:
            return @"短信发送失败，请稍后重试";
            break;
        case -4:
            return @"您输入的手机号已经存在";
            break;
        case -5:
            return @"您在180s内获取过验证码，请稍后重试";
            break;
        default:
            return @"未知错误";
            break;
    }
}

/**
 读取本地数据库省信息

 @return 数组
 */
+ (NSArray *)getProvince{
    FMDatabase *dataBase;
    NSString  *sqlString = @"SELECT * FROM dcRegion WHERE ParentId = 0 AND _id < 90";
    NSArray *arr = [Common querySql:sqlString dataBase:dataBase];
    return arr;
}


/**
 读取本地数据库求职状态

 @return 数组
 */
+ (NSArray *)getCareerStatus{
    FMDatabase *dataBase;
    NSString *sqlString = @"SELECT * FROM dcCareerStatus";
    NSArray *array = [Common querySql:sqlString dataBase:dataBase];
    return array;
}


/**
 获取学历数组

 @return 学历
 */
+ (NSArray *)getEducation{
    FMDatabase *dataBase;
    NSString *sqlString = @"SELECT * FROM dcEducation";
    NSArray *array = [Common querySql:sqlString dataBase:dataBase];
    return array;
}

/**
 获取期望月薪

 @return 月薪
 */
+ (NSArray *)getSalary{
    
    FMDatabase *dataBase;
    NSString *sqlString = @"SELECT * FROM dcSalary WHERE _id < 15";
    NSArray *array = [Common querySql:sqlString dataBase:dataBase];
    return array;
}
+ (NSDictionary *)welfare:(NSDictionary *)dict{
    NSDictionary *welfareDict = @{
                                  @"Welfare1":dict[@"Welfare1"],
                                  @"Welfare2":dict[@"Welfare2"],
                                  @"Welfare3":dict[@"Welfare3"],
                                  @"Welfare4":dict[@"Welfare4"],
                                  @"Welfare5":dict[@"Welfare5"],
                                  @"Welfare6":dict[@"Welfare6"],
                                  @"Welfare7":dict[@"Welfare7"],
                                  @"Welfare8":dict[@"Welfare8"],
                                  @"Welfare9":dict[@"Welfare9"],
                                  @"Welfare10":dict[@"Welfare10"],
                                  @"Welfare11":dict[@"Welfare11"],
                                  @"Welfare12":dict[@"Welfare12"],
                                  @"Welfare13":dict[@"Welfare13"],
                                  @"Welfare14":dict[@"Welfare14"],
                                  @"Welfare15":dict[@"Welfare15"],
                                  @"Welfare16":dict[@"Welfare16"],
                                  @"Welfare17":dict[@"Welfare17"],
                                  @"Welfare18":dict[@"Welfare18"],
                                  @"Welfare19":dict[@"Welfare19"],
                                  };
    return welfareDict;
}
+ (NSArray *)getRegion{
    NSMutableArray *arrayData = [NSMutableArray array];
    NSMutableArray *provinData = [NSMutableArray array];
    NSString *sqlString;
    sqlString = [NSString stringWithFormat:@"SELECT * FROM dcRegion WHERE ParentId = '%@' ORDER BY CASE _id WHEN %@ THEN 0 ELSE _id END", @"0", [USER_DEFAULT stringForKey:@"provinceId"]];
    FMDatabase *dataBase;
    NSArray *array = [Common querySql:sqlString dataBase:dataBase];
    [provinData addObjectsFromArray:array];
    [arrayData addObjectsFromArray:provinData];
    
    for (int i = 0; i < provinData.count;i ++){
        NSString *parentId = [[provinData objectAtIndex:i ]  objectForKey:@"id"];
        sqlString = [NSString stringWithFormat:@"SELECT * FROM dcRegion WHERE ParentId = '%@' ORDER BY CASE _id WHEN %@ THEN 0 ELSE _id END", parentId, [USER_DEFAULT stringForKey:@"provinceId"]];
        FMDatabase *dataBase;
        NSArray *array = [Common querySql:sqlString dataBase:dataBase];
        [arrayData addObjectsFromArray:array];
    }

    return arrayData;
}

+ (NSDictionary *)welfare:(NSDictionary *)dict1 dict2:(NSDictionary *)dict2{
    NSDictionary *welfareDict =@{
                                 @"Welfare1":[Common compareStr:dict1[@"Welfare1"] str2:dict2[@"Welfare1"]],
                                 @"Welfare2":[Common compareStr:dict1[@"Welfare2"] str2:dict2[@"Welfare2"]],
                                 @"Welfare3":[Common compareStr:dict1[@"Welfare3"] str2:dict2[@"Welfare3"]],
                                 @"Welfare4":[Common compareStr:dict1[@"Welfare4"] str2:dict2[@"Welfare4"]],
                                 @"Welfare5":[Common compareStr:dict1[@"Welfare5"] str2:dict2[@"Welfare5"]],
                                 @"Welfare6":[Common compareStr:dict1[@"Welfare6"] str2:dict2[@"Welfare6"]],
                                 @"Welfare7":[Common compareStr:dict1[@"Welfare7"] str2:dict2[@"Welfare7"]],
                                 @"Welfare8":[Common compareStr:dict1[@"Welfare8"] str2:dict2[@"Welfare8"]],
                                 @"Welfare9":[Common compareStr:dict1[@"Welfare9"] str2:dict2[@"Welfare9"]],
                                 @"Welfare10":[Common compareStr:dict1[@"Welfare10"] str2:dict2[@"Welfare10"]],
                                 @"Welfare11":[Common compareStr:dict1[@"Welfare11"] str2:dict2[@"Welfare11"]],
                                 @"Welfare12":[Common compareStr:dict1[@"Welfare12"] str2:dict2[@"Welfare12"]],
                                 @"Welfare13":[Common compareStr:dict1[@"Welfare13"] str2:dict2[@"Welfare13"]],
                                 @"Welfare14":[Common compareStr:dict1[@"Welfare14"] str2:dict2[@"Welfare14"]],
                                 @"Welfare15":[Common compareStr:dict1[@"Welfare15"] str2:dict2[@"Welfare15"]],
                                 @"Welfare16":[Common compareStr:dict1[@"Welfare16"] str2:dict2[@"Welfare16"]],
                                 @"Welfare17":[Common compareStr:dict1[@"Welfare17"] str2:dict2[@"Welfare17"]],
                                 @"Welfare18":[Common compareStr:dict1[@"Welfare18"] str2:dict2[@"Welfare18"]],
                                 @"Welfare19":[Common compareStr:dict1[@"Welfare19"] str2:dict2[@"Welfare19"]],
                                 };
    return welfareDict;
}

+ (NSString *)compareStr:(NSString *)str1 str2:(NSString *)str2{
    BOOL bool1 = [str1 boolValue];
    BOOL bool2 = [str2 boolValue];
    if (bool1 && bool2) {
        return @"true";
    }else{
        return @"false";
    }
}

// 获取福利待遇
+ (NSString *)getWelfareIdSelected:(NSDictionary *)welfareDict{
//    NSArray *welfareIdArray = [Common arrayWelfareId];
    NSArray *welfareIdArray = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19"];
    NSMutableString *selectId = [[NSMutableString alloc]init];
    for (int i = 0; i < welfareIdArray.count; i ++) {
        NSInteger welfareId = [welfareIdArray[i] integerValue];
        BOOL selectedState = [welfareDict[[NSString stringWithFormat:@"Welfare%ld",welfareId]] boolValue];
        if (i == welfareIdArray.count-1) {
            [selectId appendString:selectedState ? @"1":@"0"];
        }else{
            [selectId appendString:selectedState ? @"1,":@"0,"];
        }
        
    }
    
    return [NSString stringWithString:selectId];
}

/**
 计算文字的的长度
 
 @param text 文字
 @param font 字体大小
 @param maxSize 最大尺寸
 @return 计算完的尺寸
 */
+ (CGSize)sizeWithText:(NSString *)text font:(UIFont *)font maxSize:(CGSize)maxSize{
    
    if ([text isKindOfClass:[NSNull class]] ||text == nil) {
        return CGSizeMake(0, 0);
        
    }else{
        NSDictionary *attrs = @{NSFontAttributeName : font};
        return [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size;
    }
}


/**
 根据学历计算工作年限应该减的年数

 @param EducationId 学历ID
 @return 应该减的年数
 */
+ (NSInteger )calulateRelatedWorkYearsWithEducation:(NSInteger)EducationId{
    NSInteger minusNum = 0;
    switch (EducationId) {
        case 1:// 初中
            minusNum = -15;
            break;
        case 2:// 高中
            minusNum = -18;
            break;
        case 3:// 中专
            minusNum = -21;
            break;
        case 4:// 中技
            minusNum = -21;
            break;
        case 5:// 大专
            minusNum = -21;
            break;
        case 6:// 本科
            minusNum = -22;
            break;
        case 7:// 硕士
            minusNum = -25;
            break;
        case 8:// 博士
            minusNum = -28;
            break;
        default:
            break;
    }
    return minusNum;
}

/**
 汉字数字转阿拉伯数字

 @param chnStr 汉字文字
 @return 阿拉伯数字
 */
+ (NSString *)translatNum:(NSString *)chnStr{

    if ([Common deptNumInputShouldNumber:chnStr]) {
        return chnStr;
    }
    
    //测试数据
    NSDictionary *chnNumChar = @{@"零":@0,@"一":@1,@"二":@2,@"两":@2,@"三":@3,@"四":@4,@"五":@5,@"六":@6,@"七":@7,@"八":@8,@"九":@9,@"十":@10,@"百":@100,@"千":@1000,@"万":@10000,@"亿":@100000000};
    //遍历字符串用数组接收单个字符
    NSMutableArray *strArrM = [NSMutableArray array];
    for (NSInteger i = 0;i < chnStr.length;i ++) {
        NSString *charStr = [chnStr substringWithRange:NSMakeRange(i, 1)];
        if (chnNumChar[charStr] != nil) {
            NSString *tempStr = [chnStr substringWithRange:NSMakeRange(i - 1, 1)];
            //如果第一个字符为十则在其前面添‘一’；如果字符“十”的前一个字符为“零”或者前面没有数字字符则在其前面添“一”
            if (i == 0 && [charStr isEqual:@"十"]) {
                [strArrM addObject:@"一"];
            }else if( i > 0 && (chnNumChar[tempStr] == nil || [tempStr isEqual:@"零"]) && [charStr isEqual:@"十"]){
                [strArrM addObject:@"一"];
            }
            [strArrM addObject:charStr];
        }
    }
    NSArray *arr = [[strArrM reverseObjectEnumerator] allObjects];//数组倒序
    NSInteger total = 0;//总值
    NSInteger r = 1;//位权
    NSInteger u = 1;//记录单位节点
    for (NSInteger i = 0; i < arr.count; i ++) {
        NSInteger val = [chnNumChar[arr[i]] integerValue];//从右至左(从低位到高位)逐位取值 ←----
        if (val >= 10){        //单位字符
            if (val > r) {      //如果此时的字符单位值大于之前的位权
                //把单位值赋值给位权r，并记录此时的最大单位u
                r = val;
                u = val;
            }else{      //如果此时的字符单位值不大于之前的位权
                //此前的最大单位u与此时的字符单位的乘积即为此时的位权
                r = u * val;
            }
        }else{      //数字字符
            //累加计算当前的总值
            total +=  r * val;
            //NSLog(@"%ld",total);
        }
    }
    
    
    // 删除字符串中的其他中文
    NSString *totalStr = [NSString stringWithFormat:@"%ld",total];
    NSString *hanziStr = @"";
    for (int i=0; i<totalStr.length; i++) {
        NSRange range =NSMakeRange(i, 1);
        NSString * strFromSubStr=[totalStr substringWithRange:range];
        const char * cStringFromstr=[strFromSubStr UTF8String];
        
        if (strlen(cStringFromstr)==3) {
            //汉字
            NSRange range2 = NSMakeRange(i,  totalStr.length - i);
            hanziStr = [totalStr substringWithRange:range2];
            NSString *resultStr = [totalStr stringByReplacingOccurrencesOfString:hanziStr withString:@""];
            return resultStr;
        }
    }
    return totalStr;
}

    
/**
 判断字符串是否全是数字

 @param str 字符串
 @return 结果
 */
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
/**
 声音识别日期转阿拉伯数字
 
 @param chnStr 识别文字
 @return 阿拉伯数字
 */
+ (NSString *)translatBirth:(NSString *)chnStr{
    
    //测试数据
    NSDictionary *chnNumChar = @{@"零":@0,@"一":@1,@"二":@2,@"两":@2,@"三":@3,@"四":@4,@"五":@5,@"六":@6,@"七":@7,@"八":@8,@"九":@9,@"十":@10,@"百":@100,@"千":@1000,@"万":@10000,@"亿":@100000000};
    //遍历字符串用数组接收单个字符
    NSMutableArray *strArrM = [NSMutableArray array];
    for (NSInteger i = 0;i < chnStr.length;i ++) {
        NSString *charStr = [chnStr substringWithRange:NSMakeRange(i, 1)];
        if (chnNumChar[charStr] != nil) {
            NSString *tempStr = [chnStr substringWithRange:NSMakeRange(i - 1, 1)];
            //如果第一个字符为十则在其前面添‘一’；如果字符“十”的前一个字符为“零”或者前面没有数字字符则在其前面添“一”
            if (i == 0 && [charStr isEqual:@"十"]) {
                [strArrM addObject:@"一"];
            }else if( i > 0 && (chnNumChar[tempStr] == nil || [tempStr isEqual:@"零"]) && [charStr isEqual:@"十"]){
                [strArrM addObject:@"一"];
            }
            [strArrM addObject:charStr];
        }
    }
    NSArray *arr = [[strArrM reverseObjectEnumerator] allObjects];//数组倒序
    NSInteger total = 0;//总值
    NSInteger r = 1;//位权
    NSInteger u = 1;//记录单位节点
    for (NSInteger i = 0; i < arr.count; i ++) {
        NSInteger val = [chnNumChar[arr[i]] integerValue];//从右至左(从低位到高位)逐位取值 ←----
        if (val >= 10){        //单位字符
            if (val > r) {      //如果此时的字符单位值大于之前的位权
                //把单位值赋值给位权r，并记录此时的最大单位u
                r = val;
                u = val;
            }else{      //如果此时的字符单位值不大于之前的位权
                //此前的最大单位u与此时的字符单位的乘积即为此时的位权
                r = u * val;
            }
        }else{      //数字字符
            //累加计算当前的总值
            total +=  r * val;
            //NSLog(@"%ld",total);
        }
    }
    
    
    // 删除字符串中的其他中文
    NSString *totalStr = [NSString stringWithFormat:@"%ld",total];
    return totalStr;
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

@end

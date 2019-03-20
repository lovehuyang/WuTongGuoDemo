//
//  AFNManager.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/10/31.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import "AFNManager.h"
#import "AFNetworking.h"
#import "Reachability.h"
#import "Common.h"
#import "GDataXMLNode.h"
#import "Common.h"

@interface AFNManager()<NSXMLParserDelegate>

@end

@implementation AFNManager

/**
 *  网络判断
 *
 *  @return 是否可以联网
 */
- (BOOL)isConnectionAvailable{
    
    BOOL isExistenceNetwork = YES;
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:                      //无网络(无法判断内外网)
            isExistenceNetwork = NO;
            break;
        case ReachableViaWiFi:                  //WIFI
            isExistenceNetwork = YES;
            break;
        case ReachableViaWWAN:                  //流量
            isExistenceNetwork = YES;
            break;
    }
    
    return isExistenceNetwork;
}


#pragma mark - 个人用户优化接口
+(NSURLSessionDataTask *)requestPaWithParamDict:(NSDictionary *)paramDict url:(NSString *)url tableNames:(NSArray *)tableNames successBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock{
    
    // 判断是否有网络链接
    if(![[self alloc] isConnectionAvailable])
    {
        failureBlock(0,@"您已断开网络链接！");
        return nil;
    }
    
    NSString *WebURL = @"http://webservice3819383118.wutongguo.com/cvService.asmx";
    NSString *nameSpace = @"http://www.wutongguo.com/";
    NSString *soapParam = @"";
    for (id key in paramDict) {
        soapParam = [NSString stringWithFormat:@"%@<%@>%@</%@>\n",soapParam,key,[paramDict objectForKey:key],key];
    }
    NSString *soapMsg = [NSString stringWithFormat:
                         @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                         "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                         "<soap:Body>\n"
                         "<%@ xmlns=\"%@\">\n"
                         "%@"
                         "</%@>\n"
                         "</soap:Body>\n"
                         "</soap:Envelope>\n", url, nameSpace, soapParam, url
                         ];

    
    // 请求地址
    NSString * urlString = [NSString stringWithFormat:@"%@",WebURL];
    // 请求类
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/xml",nil];
    [manager.requestSerializer setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%zd", soapMsg.length] forHTTPHeaderField:@"Content-Length"];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    // 设置HTTPBody
    [manager.requestSerializer setQueryStringSerializationWithBlock:^NSString *(NSURLRequest *request, NSDictionary *parameters, NSError *__autoreleasing *error) {
        return soapMsg;
    }];
        NSURLSessionDataTask *task = [manager POST:urlString parameters:paramDict progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            NSString *xmlStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSError *error = nil;
            GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithXMLString:xmlStr options:0 error:&error];
            
            NSMutableArray *resultArr = [NSMutableArray array];
            for (NSString *tableName in tableNames) {
                NSArray *dataArr = [Common getArrayFromXml:xmlDoc tableName:tableName];
                [resultArr addObject:dataArr];
            }
            if (resultArr.count > 0) {
                successBlock(resultArr, resultArr[0]);
            }else{
                NSString *value = [Common getValueFromXml:xmlDoc];
                successBlock(resultArr, value);
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            failureBlock(error.code ,@"网络请求失败，请重试");
        }];
        return task;
}

/*

 <?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><GetPaDiscountResponse xmlns="http://www.wutongguo.com/"><GetPaDiscountResult><xs:schema id="NewDataSet" xmlns="" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:msdata="urn:schemas-microsoft-com:xml-msdata"><xs:element name="NewDataSet" msdata:IsDataSet="true" msdata:MainDataTable="data1" msdata:UseCurrentLocale="true"><xs:complexType><xs:choice minOccurs="0" maxOccurs="unbounded"><xs:element name="data1"><xs:complexType></xs:complexType></xs:element></xs:choice></xs:complexType></xs:element></xs:schema><diffgr:diffgram xmlns:msdata="urn:schemas-microsoft-com:xml-msdata" xmlns:diffgr="urn:schemas-microsoft-com:xml-diffgram-v1" /></GetPaDiscountRes
 
 */
@end

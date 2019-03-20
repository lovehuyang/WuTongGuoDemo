//
//  AFNManager.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/10/31.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 请求方式
 
 - POST: POST
 - GET: GET
 - DELETE: DELETE
 - UPLOAD: UPLOAD
 */
typedef NS_ENUM(NSInteger ,RequestMethod) {
    POST ,
    GET,
    DELETE,
    UPLOAD,
};

/**
 请求成功的回调

 @param requestData 原始数据解析完的数组
 @param dataDict 数字第一个元素
 */
typedef void(^SuccessBlock) (NSArray * requestData, NSDictionary *dataDict);

/**
 请求失败的block
 
 @param errCode 错误代码
 @param msg 错误信息
 */
typedef void(^FailureBlock) (NSInteger errCode , NSString *msg);
@interface AFNManager : NSObject

#pragma mark - 个人用户优化接口1.0
+(NSURLSessionDataTask *)requestPaWithParamDict:(NSDictionary *)paramDict url:(NSString *)url tableNames:(NSArray *)tableNames successBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock;
@end

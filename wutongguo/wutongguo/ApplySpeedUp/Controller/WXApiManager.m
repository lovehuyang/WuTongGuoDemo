//
//  WXApiManager.m
//  SDKSample
//
//  Created by Jeason on 16/07/2015.
//
//

#import "WXApiManager.h"

@implementation WXApiManager

#pragma mark - LifeCycle
+(instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static WXApiManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[WXApiManager alloc] init];
    });
    return instance;
}

#pragma mark - WXApiDelegate
- (void)onResp:(BaseResp *)resp {
    if([resp isKindOfClass:[PayResp class]]){
        //支付返回结果，实际支付结果需要去微信服务器端查询
        
        switch (resp.errCode) {
            case WXSuccess:
                // 微信支付成功
                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_WXPAYSUCCESS object:nil];
                break;
                
            default:
                // 微信支付失败
                [[NSNotificationCenter defaultCenter]postNotificationName:NOTIFICATION_WXPAYFAILED object:nil];
                break;
        }
    
    }else {
        
    }
}

- (void)onReq:(BaseReq *)req {

}

@end

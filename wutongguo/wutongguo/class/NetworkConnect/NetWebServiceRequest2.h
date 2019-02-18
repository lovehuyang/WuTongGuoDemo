//
//  NetWebServiceRequest2.h
//  HttpRequest
//
//  Created by Richard Liu on 13-3-18.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "SoapXmlParseHelper.h"

extern NSString* const NetWebServiceRequest2ErrorDomain;

@protocol NetWebServiceRequest2Delegate;

@interface NetWebServiceRequest2 : NSObject

@property (nonatomic, assign) id<NetWebServiceRequest2Delegate> delegate;
@property (nonatomic, assign) NSInteger tag;

+ (id)serviceRequestUrl:(NSString *)method
                 params:(NSDictionary *)params
                    tag:(NSInteger)tag;

//创建请求对象
- (id)initWithUrl:(NSString *)WebURL
          SOAPActionURL:(NSString *)soapActionURL
      ServiceMethodName:(NSString *)strMethod
            SoapMessage:(NSString *)soapMsg;

- (void)cancel;
- (BOOL)isCancelled;
- (BOOL)isExecuting;
- (BOOL)isFinished;
- (void)startAsynchronous;
- (void)startSynchronous;
@end

@protocol NetWebServiceRequest2Delegate <NSObject>
@optional
//开始
- (void)netRequestStarted2:(NetWebServiceRequest2 *)request;
//失败
- (void)netRequestFailed2:(NetWebServiceRequest2 *)request didRequestError:(int *)error;
@required
//成功
- (void)netRequestFinished2:(NetWebServiceRequest2 *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData;

@end


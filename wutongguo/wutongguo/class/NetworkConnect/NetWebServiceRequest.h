//
//  NetWebServiceRequest.h
//  HttpRequest
//
//  Created by Richard Liu on 13-3-18.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "SoapXmlParseHelper.h"

extern NSString* const NetWebServiceRequestErrorDomain;

@protocol NetWebServiceRequestDelegate;

@interface NetWebServiceRequest : NSObject 

@property (nonatomic, assign) id<NetWebServiceRequestDelegate> delegate;
@property (nonatomic, assign) NSInteger tag;

+ (id)serviceRequestUrl:(NSString *)method
                 params:(NSDictionary *)params
                    tag:(NSInteger)tag;
+ (id)cpServiceRequestUrl:(NSString *)method
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

@protocol NetWebServiceRequestDelegate <NSObject>
@optional
//开始
- (void)netRequestStarted:(NetWebServiceRequest *)request;
//失败
- (void)netRequestFailed:(NetWebServiceRequest *)request didRequestError:(int *)error;
@required
//成功
- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData;

@end


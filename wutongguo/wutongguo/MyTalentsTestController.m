//
//  MyTalentsTestController.m
//  wutongguo
//
//  Created by Lucifer on 2019/2/20.
//  Copyright © 2019年 Lucifer. All rights reserved.
//

#import "MyTalentsTestController.h"
#import <WebKit/WebKit.h>
#import "CommonFunc.h"

@interface MyTalentsTestController ()<WKNavigationDelegate, WKScriptMessageHandler>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) NSString *currentUrlStr;// 当前页面地址
@end

@implementation MyTalentsTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"加载中...";
    
   self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"menu-back"] style:UIBarButtonItemStylePlain target:self action:@selector(viewPop)];
    
    WKWebViewConfiguration *config =
    [[WKWebViewConfiguration alloc] init];
    [config.userContentController addScriptMessageHandler:self name:@"popView"];
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT ) configuration:config];
    [self.webView setNavigationDelegate:self];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://m.wutongguo.com/personal/assess/mytest?pamainid=%@&code=%@&privi=authorize",[CommonFunc getPaMainId],[CommonFunc getCode]]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    [self.view addSubview:self.webView];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    self.title = webView.title;
    if([webView.title isEqualToString:@"我要反馈"]){
        self.navigationItem.rightBarButtonItem = nil;
    }else{
        UIBarButtonItem *feedbackItem = [[UIBarButtonItem alloc] initWithTitle:@"测评反馈" style:UIBarButtonItemStylePlain target:self action:@selector(feedbackItemClick)];
        self.navigationItem.rightBarButtonItem = feedbackItem;
    }
    
    [webView evaluateJavaScript:@"$('a:first').remove()" completionHandler:^(id _Nullable id, NSError * _Nullable error) {

    }];

    [webView evaluateJavaScript:@"$('header').remove()" completionHandler:^(id _Nullable id, NSError * _Nullable error) {
        
    }];
    
    [webView evaluateJavaScript:@"document.getElementsByTagName('header')[0].remove();document.getElementsByClassName('footer')[0].remove();document.getElementsByClassName('detail-bg mt10 comment')[0].remove();document.getElementsByClassName('detail-bg mt10')[0].remove();document.getElementsByClassName('da-box daBox responsive ui-border-tb')[0].remove();document.getElementsByClassName('ui-share2')[0].remove();document.getElementsByClassName('ui-border-tb prl15')[0].remove();"completionHandler:^(id evaluate,NSError* error) {NSLog(@"---%@",error.domain);}];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    self.title = @"加载中...";
    
    NSString *currentURL = webView.URL.absoluteString;
    NSLog(@"%@",currentURL);
    self.currentUrlStr = [[NSString alloc]initWithString:currentURL];
}

- (void)viewPop{

    if([self.currentUrlStr containsString:@"mytest"]){
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self.webView goBack];
    }
}

#pragma mark - 测评反馈
- (void)feedbackItemClick{
    NSURL *url = [NSURL URLWithString:@"http://m.wutongguo.com/personal/account/feedback"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView setNavigationDelegate:self];

    [self.webView loadRequest:request];
}
/*
 我的测评
 http://m.wutongguo.com/personal/assess/mytest?pamainid=405319&code=AE434854E6CDC4CCF5A615D17E103171&privi=authorize
 
测评类型
 http://m.wutongguo.com/personal/assess/AssessType

霍兰德职业兴趣测评
 http://m.wutongguo.com/personal/assess/NoticeBegin?AssessTypeID=2
 
http://m.wutongguo.com/personal/account/feedback
 */
@end

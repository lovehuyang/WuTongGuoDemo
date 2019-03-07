//
//  CpWebViewController.m
//  wutongguo
//
//  Created by Lucifer on 2019/2/28.
//  Copyright © 2019年 Lucifer. All rights reserved.
//

#import "CpWebViewController.h"
#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "ExchangeRoleViewController.h"

@interface CpWebViewController ()<WKNavigationDelegate>
@property (nonatomic ,strong) WKWebView *webView;// 加载模板的容器
@property (nonatomic, strong) JSContext *jsContext;
@property (strong, nonatomic) UIProgressView *progressView;// 加载进度条

@end

@implementation CpWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createWebView];
    
    NSString *CpAccountID  = [CommonToos getValue:CP_ACCOUNTID_KEY];
    NSString *CpMainID = [CommonToos getValue:CP_MAINID_KEY];
    NSString *code = [CommonToos getValue:CP_CODE_KEY];

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://m.wutongguo.com/company/sys/index?CpAccountID=%@&CpMainID=%@&code=%@", CpAccountID,CpMainID,code]];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)createWebView{
    
    self.webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH , SCREEN_HEIGHT - 0)];
    [self.view addSubview:self.webView];
    
    self.webView.navigationDelegate = self;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.scrollView.backgroundColor = [UIColor whiteColor];
    self.webView.allowsBackForwardNavigationGestures = YES;
    [self.webView setNeedsUpdateConstraints];
    
    _progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,2)];
    _progressView.tintColor =[UIColor redColor];
    _progressView.trackTintColor = [UIColor grayColor];
    [self.view addSubview:_progressView];
    
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew| NSKeyValueObservingOptionOld context:nil];
}

#pragma mark - 进度条

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progressView.progress = self.webView.estimatedProgress;
        if (self.progressView.progress == 1) {
            
            __weak typeof (self)weakSelf = self;
            [UIView animateWithDuration:0.25f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                weakSelf.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.4f);
            } completion:^(BOOL finished) {
                weakSelf.progressView.hidden = YES;
                
            }];
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

//开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    self.progressView.hidden = NO;
    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    [self.view bringSubviewToFront:self.progressView];
    
    
    NSString *requestString = webView.URL.absoluteString;
    NSArray *components = [requestString componentsSeparatedByString:@"|"];
    NSString *str1 = [components objectAtIndex:0];
    NSArray *array2 = [str1 componentsSeparatedByString:@"/"];
    NSInteger coun = array2.count;
    NSString *method = array2[coun-1];
    if ([method isEqualToString:@"changeInfo"]){
        [self.webView stopLoading];
        ExchangeRoleViewController *evc = [ExchangeRoleViewController new];
        evc.status = @"企业";
        [self.navigationController pushViewController:evc animated:YES];
    }else if ([method isEqualToString:@"logout"]){
        [self.webView stopLoading];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    
    
}

- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

@end

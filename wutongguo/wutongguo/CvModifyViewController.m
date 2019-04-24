//
//  CvModifyViewController.m
//  wutongguo
//
//  Created by Lucifer on 16/5/23.
//  Copyright © 2016年 Lucifer. All rights reserved.
//

#import "CvModifyViewController.h"
#import <WebKit/WebKit.h>
#import "ApplySpeedUpIntroduceController.h"
#import "CommonMacro.h"
#import "CommonFunc.h"

@interface CvModifyViewController ()<WKNavigationDelegate>
//@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIBarButtonItem *leftBarItem;

@property (strong, nonatomic) UIProgressView *progressView;// 加载进度条
@property (nonatomic ,strong) WKWebView *webView;// 加载模板的容器
@end

@implementation CvModifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createWebView];
    self.title = @"加载中...";
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://m.wutongguo.com/personal/cv/chscv?pamainid=%@&code=%@&fa=1&privi=authorize", [CommonFunc getPaMainId], [CommonFunc getCode]]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(webRefresh)];
}

- (void)webGoBack {
    NSString *url = self.webView.URL.absoluteString;
    NSRange range = [[url lowercaseString] rangeOfString:@"chscv"];
    if (range.length > 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://m.wutongguo.com/personal/cv/chscv?pamainid=%@&code=%@&fa=1&privi=authorize", [CommonFunc getPaMainId], [CommonFunc getCode]]];
        [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    }
    //[self.webView goBack];
}

- (void)webRefresh {
    [self.webView reload];
}

- (void)viewPop {
    [self.navigationController popViewControllerAnimated:YES];
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
    //http://m.wutongguo.com/Personal/Account/Accelerate 求职加速页面
    if([requestString containsString:@"/Personal/Account/Accelerate"]){
        ApplySpeedUpIntroduceController *avc = [ApplySpeedUpIntroduceController new];
        [self.navigationController pushViewController:avc animated:YES];
        [webView stopLoading];
        return;
    }
    
    self.title = @"加载中...";
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    self.title = webView.title;
    
    if ([webView canGoBack]) {
        if (self.leftBarItem == nil) {
            self.leftBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-back.png"] style:UIBarButtonItemStyleDone target:self action:@selector(viewPop)];
            self.navigationItem.leftBarButtonItem = self.leftBarItem;
        }
        [self.navigationItem.leftBarButtonItem setAction:@selector(webGoBack)];
    }
    else {
        if (self.leftBarItem != nil) {
            [self.navigationItem.leftBarButtonItem setAction:@selector(viewPop)];
        }
    }
    
    
//    [webView evaluateJavaScript:@"$('a:first').remove()" completionHandler:^(id _Nullable id, NSError * _Nullable error) {
//        [[self.view viewWithTag:LOADINGTAG] setHidden:YES];
//    }];
    
    [webView evaluateJavaScript:@"$('header').remove()" completionHandler:^(id _Nullable id, NSError * _Nullable error) {
        [[self.view viewWithTag:LOADINGTAG] setHidden:YES];
    }];
}

- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}


@end

//
//  CvModifyViewController.m
//  wutongguo
//
//  Created by Lucifer on 16/5/23.
//  Copyright © 2016年 Lucifer. All rights reserved.
//

#import "CvModifyViewController.h"
#import "CommonMacro.h"
#import "CommonFunc.h"

@interface CvModifyViewController ()<UIWebViewDelegate>
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIBarButtonItem *leftBarItem;

@end

@implementation CvModifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.webView setDelegate:self];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://m.wutongguo.com/personal/cv/chscv?pamainid=%@&code=%@&fa=1&privi=authorize", [CommonFunc getPaMainId], [CommonFunc getCode]]];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
    [(UIScrollView *)[[self.webView subviews] objectAtIndex:0] setBounces:NO];
    [self.view addSubview:self.webView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(webRefresh)];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.title = @"正在加载…";
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.title = @"申请表填写";
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
}

- (void)webGoBack {
    NSString *url = [[self.webView.request URL] absoluteString];
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

@end

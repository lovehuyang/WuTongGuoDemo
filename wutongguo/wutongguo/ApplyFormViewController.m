//
//  ApplyFormViewController.m
//  wutongguo
//
//  Created by Lucifer on 16/1/19.
//  Copyright © 2016年 Lucifer. All rights reserved.
//

#import "ApplyFormViewController.h"
#import "CommonMacro.h"
#import "CommonFunc.h"

@interface ApplyFormViewController ()<UIWebViewDelegate>

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIBarButtonItem *leftBarItem;
@end

@implementation ApplyFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.webView setDelegate:self];
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://m.wutongguo.com/personal/applyform/module?jid=%@&pamainid=%@&code=%@&fa=1&privi=authorize", self.jobId, [CommonFunc getPaMainId], [CommonFunc getCode]]]]];
    [(UIScrollView *)[[self.webView subviews] objectAtIndex:0] setBounces:NO];
    [self.view addSubview:self.webView];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(webRefresh)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *url = [[request URL] absoluteString];
    NSRange range = [[url lowercaseString] rangeOfString:@"applicationlist"];
    if (range.length > 0) {
        [self.navigationController popViewControllerAnimated:YES];
        return NO;
    }
    return YES;
}

- (void)webGoBack {
//    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://m.wutongguo.com/personal/applyform/module?jid=%@&pamainid=%@&code=%@&fa=1&privi=authorize", self.jobId, [CommonFunc getPaMainId], [CommonFunc getCode]]]]];
    [self.webView goBack];
}

- (void)webRefresh {
    [self.webView reload];
}

- (void)viewPop {
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

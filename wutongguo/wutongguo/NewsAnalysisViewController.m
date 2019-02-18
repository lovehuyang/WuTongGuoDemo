//
//  NewsAnalysisViewController.m
//  wutongguo
//
//  Created by Lucifer on 2017/1/22.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "NewsAnalysisViewController.h"
#import "CommonMacro.h"

@interface NewsAnalysisViewController ()

@end

@implementation NewsAnalysisViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"就业大数据";
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.view addSubview:webView];
    NSURLRequest *request;
    if(self.newsAnalysisId == 0) {
        request =[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://m.wutongguo.com/report/?fromapp=1"]];
    }
    else {
        request =[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://m.wutongguo.com/report/%ld.html?fromapp=1", (long)self.newsAnalysisId]]];
    }
    [webView loadRequest:request];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

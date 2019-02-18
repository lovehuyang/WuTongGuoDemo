//
//  ApplyOtherViewController.m
//  wutongguo
//
//  Created by Lucifer on 15-5-9.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "ApplyOtherViewController.h"
#import "CommonFunc.h"

@interface ApplyOtherViewController ()

@end

@implementation ApplyOtherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://m.wutongguo.com/personal/application/others?pamainid=%@&code=%@", [CommonFunc getPaMainId], [CommonFunc getCode]]]]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

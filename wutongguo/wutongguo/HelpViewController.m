//
//  HelpViewController.m
//  wutongguo
//
//  Created by Lucifer on 15/6/6.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "HelpViewController.h"
#import "CommonMacro.h"

@interface HelpViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *pageView;
@property (nonatomic, strong) NSArray *arrBgColor;
@property (nonatomic, strong) NSArray *arrRatio;
@property (nonatomic, strong) NSArray *arrTitleRatio;
@property (nonatomic) int prevPage;
@end

@implementation HelpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.scrollView setContentSize:CGSizeMake(SCREEN_WIDTH * 4, VIEW_H(self.scrollView))];
    [self.scrollView setBounces:NO];
    [self.scrollView setPagingEnabled:YES];
    [self.scrollView setShowsVerticalScrollIndicator:NO];
    [self.scrollView setDelegate:self];
    [self.view addSubview:self.scrollView];
    
    self.arrBgColor = @[UIColorWithRGBA(21, 152, 232, 1), UIColorWithRGBA(243, 82, 84, 1), UIColorWithRGBA(17, 206, 202, 1), UIColorWithRGBA(131, 224, 127, 1)];
    self.arrRatio = @[@"1.2", @"1.04", @"1.11", @"1.22"];
    self.arrTitleRatio = @[@"0.46", @"0.57", @"0.51", @"0.47"];
    self.pageView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - 30, 105, 15)];
    [self.pageView setCenter:CGPointMake(self.view.center.x, self.pageView.center.y)];
    [self.view addSubview:self.pageView];
    for (int index = 0; index < 4; index++) {
        UIView *viewHelp = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH * index, 0, SCREEN_WIDTH, VIEW_H(self.scrollView))];
        [viewHelp setTag:index];
        [viewHelp setBackgroundColor:[self.arrBgColor objectAtIndex:index]];
        [self.scrollView addSubview:viewHelp];
        //分页
        UIImageView *imgPage = [[UIImageView alloc] initWithFrame:CGRectMake(index * 30, 0, 15, 15)];
        [imgPage setImage:[UIImage imageNamed:@"yindaonav.png"]];
        [imgPage setTag:index];
        [self.pageView addSubview:imgPage];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self fillHelp:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int page = (self.scrollView.contentOffset.x / SCREEN_WIDTH);
    for (UIView *view in self.scrollView.subviews) {
        if (view.tag != page) {
            for (UIView *childView in view.subviews) {
                [childView removeFromSuperview];
            }
        }
    }
    if (self.prevPage != page) {
        [self fillHelp:page];
    }
    self.prevPage = page;
}

- (void)fillHelp:(int)page {
    UIView *viewHelp;
    for (UIView *view in self.scrollView.subviews) {
        if (view.tag == page) {
            viewHelp = view;
            break;
        }
    }
    if (viewHelp == nil) {
        return;
    }
    UIImageView *imgHelp = [[UIImageView alloc] initWithFrame:CGRectMake(0, VIEW_H(self.scrollView) - SCREEN_WIDTH * [[self.arrRatio objectAtIndex:page] floatValue], SCREEN_WIDTH, SCREEN_WIDTH * [[self.arrRatio objectAtIndex:page] floatValue])];
    [imgHelp setImage:[UIImage imageNamed:[NSString stringWithFormat:@"yindao%d.png", page + 1]]];
    [imgHelp setAlpha:0];
    [viewHelp addSubview:imgHelp];
    UIImageView *imgTitle = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0 - SCREEN_WIDTH * [[self.arrTitleRatio objectAtIndex:page] floatValue], SCREEN_WIDTH, SCREEN_WIDTH * [[self.arrTitleRatio objectAtIndex:page] floatValue])];
    [imgTitle setImage:[UIImage imageNamed:[NSString stringWithFormat:@"yindaotitle%d.png", page + 1]]];
    [imgTitle setAlpha:0];
    [viewHelp addSubview:imgTitle];
    [UIView animateWithDuration:0.5 animations:^{
        [imgHelp setAlpha:1];
        [imgTitle setAlpha:1];
        CGRect frameTitle = imgTitle.frame;
        frameTitle.origin.y = 0;
        [imgTitle setFrame:frameTitle];
    }];
    if (page == 3) {
        UIButton *btnEnter = [[UIButton alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - VIEW_H(imgHelp) * 0.27, 70 * 2.7, 70)];
        [btnEnter setImage:[UIImage imageNamed:@"yindaoenter.png"] forState:UIControlStateNormal];
        [btnEnter addTarget:self action:@selector(enterClick) forControlEvents:UIControlEventTouchUpInside];
        [btnEnter setAlpha:0];
        [btnEnter setCenter:CGPointMake(self.view.center.x, btnEnter.center.y)];
        [viewHelp addSubview:btnEnter];
        [UIView animateWithDuration:0.5 animations:^{
            [btnEnter setAlpha:1];
        }];
    }
    for (UIView *view in self.pageView.subviews) {
        UIImageView *imgView = (UIImageView *)view;
        if (view.tag == page) {
            [imgView setImage:[UIImage imageNamed:@"yindaonavhigh.png"]];
        }
        else {
            [imgView setImage:[UIImage imageNamed:@"yindaonav.png"]];
        }
    }
}

- (void)enterClick {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

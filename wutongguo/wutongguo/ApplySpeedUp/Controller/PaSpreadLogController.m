//
//  PaSpreadLogController.m
//  wutongguo
//
//  Created by Lucifer on 2019/3/21.
//  Copyright © 2019年 Lucifer. All rights reserved.
//  我的求职鼓励金列表页面

#import "PaSpreadLogController.h"
#import "CommonFunc.h"
#import "PaSpreadModel.h"
#import "PaSpreadCell.h"

@interface PaSpreadLogController ()<UITableViewDelegate,UITableViewDataSource,DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
@property (nonatomic , strong) LoadingAnimationView *loadingView;
@property (nonatomic , strong) UIView *bgView;// 半色透明背景
@property (nonatomic , strong) UIView *whiteView;// 白色背景
@property (nonatomic , strong) UIView *dottedLine;// 虚线分割线
@property (nonatomic , strong) UITableView *tableView;
@property (nonatomic , strong) NSMutableArray *dataArr;
@end

@implementation PaSpreadLogController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.whiteView addSubview:self.loadingView];
    [self getPaSpreadLog];
}
- (void)createUI{
    
    self.bgView = [UIView new];
    [self.view addSubview:self.bgView];
    self.bgView.sd_layout
    .leftSpaceToView(self.view, 0)
    .topSpaceToView(self.view, 0)
    .rightSpaceToView(self.view, 0)
    .bottomSpaceToView(self.view, 0);
    self.bgView.backgroundColor = [UIColor blackColor];
    self.bgView.alpha = 0.5;
    self.bgView.userInteractionEnabled = YES;
    
    self.whiteView = [UIView new];
    [self.view addSubview:self.whiteView];
    self.whiteView.sd_layout
    .leftSpaceToView(self.view, 35)
    .rightSpaceToView(self.view, 35)
    .topSpaceToView(self.view, HEIGHT_STATUS_NAV + 20)
    .bottomSpaceToView(self.view, HEIGHT_STATUS_NAV + 20);
    self.whiteView.backgroundColor = [UIColor whiteColor];
    self.whiteView.sd_cornerRadius = @(10);
    
    
    UILabel *titleLab = [UILabel new];
    [self.whiteView addSubview:titleLab];
    titleLab.sd_layout
    .widthIs(150)
    .topSpaceToView(self.whiteView, 20)
    .centerXEqualToView(self.whiteView)
    .autoHeightRatio(0);
    titleLab.font = [UIFont boldSystemFontOfSize:BIGGERFONTSIZE];
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.text = @"操作记录";
    
    UIButton *closeBtn = [UIButton new];
    [self.whiteView addSubview:closeBtn];
    closeBtn.sd_layout
    .rightSpaceToView(self.whiteView, 15)
    .centerYEqualToView(titleLab)
    .heightRatioToView(titleLab, 1.05)
    .widthEqualToHeight();
    [closeBtn setImage:[UIImage imageNamed:@"speedup_close"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(dissmiss) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *dottedLine = [UIView new];
    [self.whiteView addSubview:dottedLine];
    dottedLine.sd_layout
    .topSpaceToView(titleLab, 10)
    .rightSpaceToView(self.whiteView, 15)
    .leftSpaceToView(self.whiteView, 15)
    .heightIs(5);
    dottedLine.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dot"]];
    self.dottedLine = dottedLine;
    
    self.tableView = [UITableView new];
    [self.whiteView addSubview:self.tableView];
    self.tableView.sd_layout
    .leftEqualToView(dottedLine)
    .rightEqualToView(dottedLine)
    .topSpaceToView(dottedLine, 15)
    .bottomSpaceToView(self.whiteView, 15);
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}
- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}
#pragma mark - UITableViewDelegate,UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PaSpreadCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[PaSpreadCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.model = self.dataArr[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self.tableView cellHeightForIndexPath:indexPath model:self.dataArr[indexPath.row] keyPath:@"model" cellClass:[PaSpreadCell class] contentViewWidth:SCREEN_WIDTH - 100];
}

#pragma mark - DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
// 图片
- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView{
    return [UIImage imageNamed:@"coNoMsgTips2"];
}
// 文本
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *title = @"呀，啥也没有";
    NSDictionary *attributes = @{
                                 NSFontAttributeName:DEFAULTFONT,
                                 NSForegroundColorAttributeName:[UIColor blackColor]
                                 };
    return [[NSAttributedString alloc] initWithString:title attributes:attributes];
}

- (void)getPaSpreadLog{
    [self.loadingView startAnimating];
    
    NSDictionary *paramDict = @{
                                @"paMainID":[CommonFunc getPaMainId],
                                @"code":[CommonFunc getCode]
                                };
    [AFNManager requestPaWithParamDict:paramDict url:@"GetPaSpreadLog" tableNames:@[@"Table"] successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
        NSLog(@"");
        if (requestData!=nil && requestData.count >0) {
            for (NSDictionary *dict in [requestData firstObject]) {
                PaSpreadModel *model = [PaSpreadModel buildModelWithDic:dict];
                [self.dataArr addObject:model];
            }
        }
        [self.loadingView stopAnimating];
        [self createUI];
        [self.tableView reloadData];
    } failureBlock:^(NSInteger errCode, NSString *msg) {
        [self.loadingView stopAnimating];
        [RCToast showMessage:@"操作记录获取失败，请稍后重试"];
        [self dissmiss];
    }];
}

- (void)show:(UIViewController *)vc{
    
    self.modalPresentationStyle = UIModalPresentationOverFullScreen;
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [vc presentViewController:self animated:YES completion:nil];
}

- (void)dissmiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end

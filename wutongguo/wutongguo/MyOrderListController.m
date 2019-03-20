//
//  MyOrderListController.m
//  wutongguo
//
//  Created by Lucifer on 2019/3/20.
//  Copyright © 2019年 Lucifer. All rights reserved.
//

#import "MyOrderListController.h"
#import "MyOrderCell.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "GDataXMLNode.h"
#import "CommonFunc.h"
#import "OrderListModel.h"
#import "MJRefresh.h"

@interface MyOrderListController ()<UITableViewDelegate,UITableViewDataSource,NetWebServiceRequestDelegate,DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
@property (nonatomic , strong) UITableView *tableView;
@property (nonatomic , strong) NSMutableArray *dataArr;// 数据源

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;

@end

@implementation MyOrderListController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"我的订单";
    self.view.backgroundColor = SEPARATECOLOR;
    UIView *bgView = [UIView new];
    [self.view addSubview:bgView];
    bgView.sd_layout
    .leftSpaceToView(self.view, 0)
    .rightSpaceToView(self.view, 0)
    .topSpaceToView(self.view, 0)
    .bottomSpaceToView(self.view, 0);
    
    [self.view addSubview:self.tableView];
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.view addSubview:self.loadingView];
    [self getPaOrder];
}

- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor colorWithHex:0xF6F5FA];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.emptyDataSetSource = self;
        _tableView.emptyDataSetDelegate = self;
        _tableView.hidden = YES;
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    OrderListModel *model = [self.dataArr objectAtIndex:indexPath.row];
    MyOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myOrderCell"];
    if (cell == nil) {
        cell = [[MyOrderCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"myOrderCell"];
    }
    cell.model = model;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    OrderListModel *model = [self.dataArr objectAtIndex:indexPath.row];
//    if ([model.cvTopStatus isEqualToString:@"待支付"]) {
//        ConfirmPaymentOrderController *cvc = [[ConfirmPaymentOrderController alloc]init];
//        cvc.model = self.dataArr[indexPath.row];
//        __weak typeof(self)weakself = self;
//        cvc.payResult = ^(BOOL success) {
//            if (success) {
//                [weakself.tableView.mj_header beginRefreshing];
//            }else{
//                [weakself.tableView.mj_header beginRefreshing];
//            }
//        };
//        [self.navigationController pushViewController:cvc animated:YES];
//    }else{
//        DLog(@"不能点击");
//    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return [self.tableView cellHeightForIndexPath:indexPath model:self.dataArr[indexPath.row] keyPath:@"model" cellClass:[MyOrderCell class] contentViewWidth:SCREEN_WIDTH];
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
// 位置
- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView{
    return -60;
}
#pragma mark - 获取订单
- (void)getPaOrder{
    
    [self.loadingView startAnimating];
    
    NSDictionary *paramDict = [NSDictionary dictionaryWithObjectsAndKeys:[USER_DEFAULT objectForKey:@"paMainId"], @"paMainID", [USER_DEFAULT objectForKey:@"code"], @"code", nil];
    self.runningRequest = [NetWebServiceRequest cvServiceRequestUrl:@"GetPaOrder" params:paramDict tag:1];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    [self.loadingView stopAnimating];
    if (request.tag == 1) {
        NSArray *arrContent = [CommonFunc getArrayFromXml:requestData tableName:@"Table"];
        for (NSDictionary *dict in arrContent) {
            OrderListModel *model = [OrderListModel buildModelWithDic:dict];
            [self.dataArr addObject:model];
        }
        _tableView.hidden = NO;
        [self.tableView reloadData];
    }
}

@end

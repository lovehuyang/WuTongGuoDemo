//
//  EmailApplyLogViewController.m
//  wutongguo
//
//  Created by Lucifer on 16/1/19.
//  Copyright © 2016年 Lucifer. All rights reserved.
//

#import "EmailApplyLogViewController.h"
#import "CommonMacro.h"
#import "CommonFunc.h"
#import "CustomLabel.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "GDataXMLNode.h"
#import "PopupView.h"
#import "CpJobDetailViewController.h"

@interface EmailApplyLogViewController ()<UITableViewDelegate, UITableViewDataSource, NetWebServiceRequestDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *arrLogData;
@property (nonatomic, strong) PopupView *viewNoList;
@end

@implementation EmailApplyLogViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.view addSubview:self.loadingView];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - TAB_TAB_HEIGHT - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT) style:UITableViewStylePlain];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:self.tableView];
    [self getData];
}

- (void)getData {
    [self.loadingView startAnimating];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"PaEmailApplyLogList" params:[NSDictionary dictionaryWithObjectsAndKeys:[USER_DEFAULT objectForKey:@"paMainId"], @"paMainID", [USER_DEFAULT objectForKey:@"code"], @"code", nil] tag:1];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrLogData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellView"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellView"];
    }
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    NSDictionary *rowData = [self.arrLogData objectAtIndex:indexPath.row];
    UIView *viewSeperate = [[UIView alloc] initWithFrame:CGRectMake(20, 12, 5, 16)];
    [viewSeperate setBackgroundColor:NAVBARCOLOR];
    [cell.contentView addSubview:viewSeperate];
    CGRect frameLbDate = CGRectMake(0, 10, 200, 20);
    CustomLabel *lbDate = [[CustomLabel alloc] initWithFixedHeight:frameLbDate content:[CommonFunc stringFromDateString:[rowData objectForKey:@"AddDate"] formatType:@"yyyy-MM-dd hh:mm"] size:14 color:TEXTGRAYCOLOR];
    frameLbDate.origin.x = SCREEN_WIDTH - VIEW_X(viewSeperate) - VIEW_W(lbDate);
    [lbDate setFrame:frameLbDate];
    [cell.contentView addSubview:lbDate];
    
    CustomLabel *lbJob = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(viewSeperate) + 5, VIEW_Y(lbDate), VIEW_X(lbDate) - VIEW_BX(viewSeperate) - 10, 20) content:[rowData objectForKey:@"name"] size:14 color:nil];
    [cell.contentView addSubview:lbJob];
    
    CustomLabel *lbCompany = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbJob), VIEW_BY(lbJob) + 5, SCREEN_WIDTH - VIEW_X(lbJob) - VIEW_X(viewSeperate), 20) content:[rowData objectForKey:@"CpName"] size:14 color:TEXTGRAYCOLOR];
    [cell.contentView addSubview:lbCompany];
    CGRect frameCell = cell.frame;
    frameCell.size.height = VIEW_BY(lbCompany) + 10;
    [cell setFrame:frameCell];
    [cell.contentView addSubview:[[CustomLabel alloc] initSeparate:cell]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *rowData = [self.arrLogData objectAtIndex:indexPath.row];
    CpJobDetailViewController *jobCtrl = [[CpJobDetailViewController alloc] init];
    jobCtrl.secondId = [rowData objectForKey:@"SecondID"];
    [self.navigationController pushViewController:jobCtrl animated:YES];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    [self.loadingView stopAnimating];
    if (request.tag == 1) {
        self.arrLogData = [CommonFunc getArrayFromXml:requestData tableName:@"Table"];
        [self.tableView reloadData];
        if (self.arrLogData.count == 0) {
            if (self.viewNoList == nil) {
                self.viewNoList = [[PopupView alloc] initWithNoListTips:self.tableView tipsMsg:@"<div style=\"text-align:center\"><p>同学，您暂无简历转发记录</p></div>"];
            }
            [self.tableView addSubview:self.viewNoList];
        }
    }
}

@end

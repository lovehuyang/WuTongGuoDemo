//
//  NoticeListViewController.m
//  wutongguo
//
//  Created by Lucifer on 15/6/2.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "NoticeListViewController.h"
#import "CommonMacro.h"
#import "CommonFunc.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "GDataXMLNode.h"
#import "CustomLabel.h"
#import "MJRefresh.h"
#import "CompanyViewController.h"
#import "NoticeViewController.h"
#import "PopupView.h"

@interface NoticeListViewController ()<NetWebServiceRequestDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) PopupView *viewNoList;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;
@property (nonatomic, strong) NSMutableArray *arrCompanyData;
@property (nonatomic, strong) NSMutableArray *arrNoticeData;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic) NSInteger page;
@end

@implementation NoticeListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"企业通知";
    self.automaticallyAdjustsScrollViewInsets = NO;
    //列表
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT) style:UITableViewStyleGrouped];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.view addSubview:self.tableView];
    //等待动画
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.view addSubview:self.loadingView];
    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
    self.arrCompanyData = [[NSMutableArray alloc] init];
    self.arrNoticeData = [[NSMutableArray alloc] init];
    self.page = 1;
    [self getData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateViewDate {
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"UpdateNewMessageByPaMainID" params:[NSDictionary dictionaryWithObjectsAndKeys:[CommonFunc getPaMainId], @"paMainID", @"2", @"type", [CommonFunc getCode], @"code", nil] tag:2];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (void)getData {
    [self.loadingView startAnimating];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetCpMsgEmailSendLogByPaMainID" params:[NSDictionary dictionaryWithObjectsAndKeys:[CommonFunc getPaMainId], @"paMainiD", [NSString stringWithFormat:@"%ld", (long)self.page], @"pageNO", [CommonFunc getCode], @"code", nil] tag:1];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.arrCompanyData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 11;
    }
    else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellView"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellView"];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    for(UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    NSDictionary *companyData = [self.arrCompanyData objectAtIndex:indexPath.section];
    CGRect frameCompany = CGRectMake(-0.5, 0, SCREEN_WIDTH + 1, 40);
    UIButton *btnCompany = [[UIButton alloc] initWithFrame:frameCompany];
    [btnCompany setTag:indexPath.section];
    [btnCompany addTarget:self action:@selector(companyClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:btnCompany];
    //绿色竖形条
    UIView *viewTips = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 5, 20)];
    [viewTips setBackgroundColor:NAVBARCOLOR];
    [btnCompany addSubview:viewTips];
    float widthForLabel = SCREEN_WIDTH - VIEW_BX(viewTips) - 90;
    //公司名称
    CustomLabel *lbCompany = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(viewTips) + 5, VIEW_Y(viewTips), widthForLabel, 20) content:[companyData objectForKey:@"CpName"] size:14 color:UIColorWithRGBA(20, 62, 103, 1)];
    [btnCompany addSubview:lbCompany];
    frameCompany.size.height = VIEW_BY(lbCompany) + 10;
    [btnCompany setFrame:frameCompany];
    float heightForCell = VIEW_BY(btnCompany);
    widthForLabel = SCREEN_WIDTH - 100;
    NSArray *arrNoticeDataWithSelect = [CommonFunc getArrayFromArrayWithSelect:self.arrNoticeData param:[NSArray arrayWithObject:[NSDictionary dictionaryWithObject:[companyData objectForKey:@"CpMainID"] forKey:@"CpMainiD"]]];
    for (NSDictionary *noticeData in arrNoticeDataWithSelect) {
        CGRect frameNotice = CGRectMake(0, heightForCell + 5, SCREEN_WIDTH, 50);
        UIButton *btnNotice = [[UIButton alloc] initWithFrame:frameNotice];
        [btnNotice addTarget:self action:@selector(noticeClick:) forControlEvents:UIControlEventTouchUpInside];
        [btnNotice setTag:[[noticeData objectForKey:@"ID"] intValue]];
        [cell.contentView addSubview:btnNotice];
        float xForLabel = 10;
        UIImageView *imgNew = [[UIImageView alloc] initWithFrame:CGRectMake(10, 7, 17, 20)];
        if ([[noticeData objectForKey:@"ViewDate"] length] == 0) {
            [imgNew setImage:[UIImage imageNamed:@"coNoticeNew.png"]];
            [btnNotice addSubview:imgNew];
            xForLabel = VIEW_BX(imgNew) + 3;
        }
        NSString *content = [[noticeData objectForKey:@"Title"] length] > 0 ? [noticeData objectForKey:@"Title"] : [noticeData objectForKey:@"Body"];
        content = [content stringByReplacingOccurrencesOfString:@"<br />" withString:@" "];
        content = [content stringByReplacingOccurrencesOfString:@"<BR />" withString:@" "];
        CustomLabel *lbNotice = [[CustomLabel alloc] initWithFrame:CGRectMake(xForLabel, 5, widthForLabel - xForLabel + 10, 40) content:content size:13 color:(xForLabel > 10 ? NAVBARCOLOR : nil)];
        [lbNotice setNumberOfLines:2];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:lbNotice.text];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineSpacing:7];
        [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, lbNotice.text.length)];
        [lbNotice setAttributedText:attributedString];
        [lbNotice setLineBreakMode:NSLineBreakByCharWrapping];
        //[lbNotice sizeToFit];
        [btnNotice addSubview:lbNotice];
        NSArray *arrNoticeLine = [CommonFunc getSeparatedLinesFromLabel:lbNotice];
        if (arrNoticeLine.count == 1) {
            [imgNew setFrame:CGRectMake(imgNew.frame.origin.x, imgNew.frame.origin.y + 5, imgNew.frame.size.width, imgNew.frame.size.height)];
        }
        CGRect frameType = CGRectMake(SCREEN_WIDTH - 80, VIEW_Y(lbNotice), 17, 17);
        UIImageView *imgType = [[UIImageView alloc] initWithFrame:frameType];
        if ([[noticeData objectForKey:@"SendType"] isEqualToString:@"1"]) {
            [imgType setImage:[UIImage imageNamed:@"coEmail.png"]];
        }
        else {
            frameType.size.width = 13;
            [imgType setFrame:frameType];
            [imgType setImage:[UIImage imageNamed:@"ucMobile.png"]];
        }
        [btnNotice addSubview:imgType];
        NSString *moduleType = @"";
        if ([[noticeData objectForKey:@"MouldType"] isEqualToString:@"1"]) {
            moduleType = @"正式通知";
        }
        else if ([[noticeData objectForKey:@"MouldType"] isEqualToString:@"2"]) {
            moduleType = @"结果通知";
        }
        else if ([[noticeData objectForKey:@"MouldType"] isEqualToString:@"3"]) {
            moduleType = @"其他通知";
        }
        CustomLabel *lbType = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgType) + ([[noticeData objectForKey:@"SendType"] isEqualToString:@"1"] ? 2 : 5), VIEW_Y(imgType) - 1, 80, 20) content:moduleType size:13 color:TEXTGRAYCOLOR];
        [btnNotice addSubview:lbType];
        CustomLabel *lbDate = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(imgType), VIEW_BY(lbType) + 2, 80, 20) content:[CommonFunc stringFromDateString:[noticeData objectForKey:@"AddDate"] formatType:@"MM-dd HH:mm"] size:13 color:TEXTGRAYCOLOR];
        [btnNotice addSubview:lbDate];
        //        [btnNotice setBackgroundColor:[UIColor redColor]];
        UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(10, VIEW_BY(btnNotice) + 5, SCREEN_WIDTH - 20, 0.5)];
        [viewSeparate setBackgroundColor:SEPARATECOLOR];
        [cell addSubview:viewSeparate];
        heightForCell = VIEW_BY(viewSeparate);
    }
    [cell setFrame:CGRectMake(0, 0, SCREEN_WIDTH, heightForCell)];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)companyClick:(UIButton *)sender {
    NSDictionary *companyData = [self.arrCompanyData objectAtIndex:sender.tag];
    CompanyViewController *companyCtrl = [[CompanyViewController alloc] init];
    companyCtrl.secondId = [companyData objectForKey:@"CpSecondID"];
    [self.navigationController pushViewController:companyCtrl animated:YES];
}

- (void)noticeClick:(UIButton *)sender {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NoticeViewController *noticeCtrl = [storyBoard instantiateViewControllerWithIdentifier:@"noticeView"];
    noticeCtrl.noticeId = [NSString stringWithFormat:@"%ld", (long)sender.tag];
    [self.navigationController pushViewController:noticeCtrl animated:YES];
}

- (void)footerRereshing{
    self.page++;
    [self getData];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    [self.loadingView stopAnimating];
    if (request.tag == 1) {
        if (self.page == 1) {
            [self.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
            [self.arrCompanyData removeAllObjects];
            [self.arrNoticeData removeAllObjects];
        }
        [self.arrCompanyData addObjectsFromArray:[CommonFunc getArrayFromXml:requestData tableName:@"Table"]];
        [self.arrNoticeData addObjectsFromArray:[CommonFunc getArrayFromXml:requestData tableName:@"Table1"]];
        [self.tableView reloadData];
        [self.tableView footerEndRefreshing];
        [self updateViewDate];
        [self.viewNoList popupClose];
        if (self.arrCompanyData.count == 0) {
            if (self.viewNoList == nil) {
                self.viewNoList = [[PopupView alloc] initWithNoListTips:self.tableView tipsMsg:@"<div style=\"text-align:center\"><p>同学，您暂无企业通知</p><p>果儿邀请您现在就去网申吧！</p></div>"];
            }
            [self.tableView addSubview:self.viewNoList];
        }
        self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"UpdateNewMessageByPaMainID" params:[NSDictionary dictionaryWithObjectsAndKeys:[USER_DEFAULT objectForKey:@"paMainId"], @"paMainID", @"2", @"type", [USER_DEFAULT objectForKey:@"code"], @"code", nil] tag:2];
        [self.runningRequest setDelegate:self];
        [self.runningRequest startAsynchronous];
    }
}

@end

//
//  FocusJobViewController.m
//  wutongguo
//
//  Created by Lucifer on 15/5/31.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "FocusJobViewController.h"
#import "CommonMacro.h"
#import "CommonFunc.h"
#import "CustomLabel.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "GDataXMLNode.h"
#import "MJRefresh.h"
#import "CpJobDetailViewController.h"
#import "PopupView.h"

@interface FocusJobViewController ()<NetWebServiceRequestDelegate, UITableViewDataSource, UITableViewDelegate, PopupViewDelegate>

@property (nonatomic, strong) PopupView *viewNoList;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;
@property (nonatomic, strong) NSMutableArray *arrData;
@property (nonatomic, strong) NSMutableArray *arrRegionData;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic) NSInteger page;
@property (nonatomic) NSInteger selectedRow;
@end

@implementation FocusJobViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //列表
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT) style:UITableViewStyleGrouped];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.view addSubview:self.tableView];
    //等待动画
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.view addSubview:self.loadingView];
    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
    self.arrData = [[NSMutableArray alloc] init];
    self.arrRegionData = [[NSMutableArray alloc] init];
    self.page = 1;
    [self getData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getData {
    [self.loadingView startAnimating];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetPaAttentionByAppPaMainID" params:[NSDictionary dictionaryWithObjectsAndKeys:[CommonFunc getPaMainId], @"paMainID", [NSString stringWithFormat:@"%ld", (long)self.page], @"pageNo", @"2", @"attentionType", [CommonFunc getCode], @"code", nil] tag:1];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.arrData.count;
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
    [cell setSelected:NO];
    for(UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    NSDictionary *rowData = [self.arrData objectAtIndex:indexPath.section];
    float widthForLabel = SCREEN_WIDTH - 95;
    //职位名称
    CustomLabel *lbJobName = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(10, 10, ([[rowData objectForKey:@"ISApply"] isEqualToString:@"1"] ? widthForLabel - 39 : widthForLabel), 20) content:[rowData objectForKey:@"JobName"] size:14 color:UIColorWithRGBA(20, 62, 103, 1)];
    [cell.contentView addSubview:lbJobName];
    //招聘简章状态
    UIImageView *imgStatus = [[UIImageView alloc] init];
    NSInteger brochureStatusType = [CommonFunc getCpBrochureStatus:[rowData objectForKey:@"BrochureStatus"] beginDate:[rowData objectForKey:@"BeginDate"] endDate:[rowData objectForKey:@"EndDate"]];
    NSString *statusImg = @"";
    if (brochureStatusType == 2) { //过期
        statusImg = @"coHasExpired.png";
        [imgStatus setFrame:CGRectMake(VIEW_BX(lbJobName) + 3, VIEW_Y(lbJobName) - 2, 46, 23)];
    }
    else if (brochureStatusType == 3) { //未开始
        statusImg = @"coNoStart.png";
        [imgStatus setFrame:CGRectMake(VIEW_BX(lbJobName) + 3, VIEW_Y(lbJobName), 46, 20)];
    }
    else if (brochureStatusType == 4 || [[rowData objectForKey:@"JobStatus"] isEqualToString:@"1"]) { //已暂停
        statusImg = @"coPause.png";
        [imgStatus setFrame:CGRectMake(VIEW_BX(lbJobName) + 3, VIEW_Y(lbJobName) - 2, 46, 23)];
    }
    else if (brochureStatusType == 1) { //网申中
        statusImg = @"coHasStart.png";
        [imgStatus setFrame:CGRectMake(VIEW_BX(lbJobName) + 3, VIEW_Y(lbJobName), 46, 20)];
    }
    [imgStatus setImage:[UIImage imageNamed:statusImg]];
    [cell.contentView addSubview:imgStatus];
    if ([[rowData objectForKey:@"ISApply"] isEqualToString:@"1"]) {
        UIImageView *imgApply = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_BX(imgStatus) + 2, VIEW_Y(imgStatus) + 4, 35, 13)];
        [imgApply setImage:[UIImage imageNamed:@"ucHasApply.png"]];
        [cell.contentView addSubview:imgApply];
    }
    //招聘简章
    CustomLabel *lbBrochure = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbJobName), VIEW_BY(lbJobName) + 7, widthForLabel, 20) content:[rowData objectForKey:@"Title"] size:13 color:nil];
    [cell.contentView addSubview:lbBrochure];
    //工作地点
    NSMutableString *jobCity = [[NSMutableString alloc] init];
    NSArray *arrRegion = [CommonFunc getArrayFromArrayWithSelect:self.arrRegionData param:[NSArray arrayWithObject:[NSDictionary dictionaryWithObject:[rowData objectForKey:@"JobID"] forKey:@"JobID"]]];
    for (NSDictionary *oneJobCity in arrRegion) {
        [jobCity appendFormat:@"%@ ", [oneJobCity objectForKey:@"FullName"]];
    }
    if (arrRegion.count == 0) {
        [jobCity appendString:@"全国"];
    }
    CustomLabel *lbJobPlace = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbJobName), VIEW_BY(lbBrochure) + 6, widthForLabel, 20) content:[NSString stringWithFormat:@"工作地点：%@", jobCity] size:12 color:TEXTGRAYCOLOR];
    [cell.contentView addSubview:lbJobPlace];
    //网申时间
    CustomLabel *lbDate = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbJobPlace), VIEW_BY(lbJobPlace) + 5, widthForLabel, 20) content:[NSString stringWithFormat:@"网申时间：%@-%@", [CommonFunc stringFromDateString:[rowData objectForKey:@"BeginDate"] formatType:@"M月d日"], [CommonFunc stringFromDateString:[rowData objectForKey:@"EndDate"] formatType:@"M月d日"]] size:12 color:TEXTGRAYCOLOR];
    if (brochureStatusType != 2) { //不是过期的，都是绿色的日期
        NSMutableAttributedString *attrDate = [[NSMutableAttributedString alloc] initWithString:lbDate.text];
        [attrDate addAttribute:NSForegroundColorAttributeName value:NAVBARCOLOR range:NSMakeRange(5, lbDate.text.length - 5)];
        [lbDate setAttributedText:attrDate];
    }
    [cell.contentView addSubview:lbDate];
    [cell setFrame:CGRectMake(0, 0, SCREEN_WIDTH, VIEW_BY(lbDate) + 10)];
    //关注按钮
    UIButton *btnFavorite = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 83, 0, 80, VIEW_BY(lbDate))];
    [btnFavorite setTag:indexPath.section];
    [btnFavorite addTarget:self action:@selector(favoriteClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:btnFavorite];
    UIImageView *imgFavorite = [[UIImageView alloc] initWithFrame:CGRectMake(25, VIEW_H(btnFavorite) / 2 - 26, 26, 26)];
    [imgFavorite setImage:[UIImage imageNamed:@"coFavorite.png"]];
    [btnFavorite addSubview:imgFavorite];
    CustomLabel *lbFavorite = [[CustomLabel alloc] initWithFrame:CGRectMake(0, VIEW_BY(imgFavorite) + 2, VIEW_W(btnFavorite), 20) content:[NSString stringWithFormat:@"%@关注", [CommonFunc stringFromDateString:[rowData objectForKey:@"AddDate"] formatType:@"yyyy-M-d"]] size:10 color:TEXTGRAYCOLOR];
    [lbFavorite setNumberOfLines:2];
    [lbFavorite setTextAlignment:NSTextAlignmentCenter];
    [btnFavorite addSubview:lbFavorite];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *rowData = [self.arrData objectAtIndex:indexPath.section];
    CpJobDetailViewController *jobCtrl = [[CpJobDetailViewController alloc] init];
    jobCtrl.secondId = [rowData objectForKey:@"JobSecondID"];
    [self.navigationController pushViewController:jobCtrl animated:YES];
}

- (void)footerRereshing{
    self.page++;
    [self getData];
}

- (void)favoriteClick:(UIButton *)sender {
    self.selectedRow = sender.tag;
    PopupView *alert = [[PopupView alloc] initWithWarningAlert:self.view title:@"提示" content:@"同学，你确定要取消关注该职位吗？" okMsg:@"确定取消关注" cancelMsg:@"我点错啦"];
    [alert setDelegate:self];
    [self.view.window addSubview:alert];
}

- (void)popupAlerConfirm {
    [self.loadingView startAnimating];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"DeletePaAttentionByID" params:[NSDictionary dictionaryWithObjectsAndKeys:[[self.arrData objectAtIndex:self.selectedRow] objectForKey:@"ID"], @"id", [CommonFunc getPaMainId], @"paMainID", [CommonFunc getCode], @"code", nil] tag:2];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    [self.loadingView stopAnimating];
    if (request.tag == 1) {
        if (self.page == 1) {
            [self.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
            [self.arrData removeAllObjects];
        }
        [self.arrData addObjectsFromArray:[CommonFunc getArrayFromXml:requestData tableName:@"Table"]];
        [self.arrRegionData addObjectsFromArray:[CommonFunc getArrayFromXml:requestData tableName:@"tabInfo"]];
        [self.tableView reloadData];
        [self.tableView footerEndRefreshing];
        [self.viewNoList popupClose];
        if (self.arrData.count == 0) {
            if (self.viewNoList == nil) {
                self.viewNoList = [[PopupView alloc] initWithNoListTips:self.tableView tipsMsg:@"<div style=\"text-align:center; font-size:14px;\"><p>同学，您尚未关注过任何职位，去搜索并关注感兴趣的职位，果儿会为您推送职位最新动态！</p></div>"];
            }
            [self.tableView addSubview:self.viewNoList];
        }
        self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"UpdateNewMessageByPaMainID" params:[NSDictionary dictionaryWithObjectsAndKeys:[USER_DEFAULT objectForKey:@"paMainId"], @"paMainID", @"3", @"type", [USER_DEFAULT objectForKey:@"code"], @"code", nil] tag:3];
        [self.runningRequest setDelegate:self];
        [self.runningRequest startAsynchronous];
    }
    else if (request.tag == 2) {
        self.page = 1;
        [self getData];
    }
}

@end

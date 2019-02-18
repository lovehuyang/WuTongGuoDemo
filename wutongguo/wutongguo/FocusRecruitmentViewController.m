//
//  FocusRecruitmentViewController.m
//  wutongguo
//
//  Created by Lucifer on 15/5/31.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "FocusRecruitmentViewController.h"
#import "CommonMacro.h"
#import "CommonFunc.h"
#import "CustomLabel.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "GDataXMLNode.h"
#import "MJRefresh.h"
#import "PopupView.h"
#import "RecruitmentViewController.h"
#import "CampusRecruitmentViewController.h"

@interface FocusRecruitmentViewController ()<NetWebServiceRequestDelegate, UITableViewDataSource, UITableViewDelegate, PopupViewDelegate>

@property (nonatomic, strong) PopupView *viewNoList;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;
@property (nonatomic, strong) NSMutableArray *arrData;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic) NSInteger page;
@property (nonatomic) NSInteger selectedRow;
@end

@implementation FocusRecruitmentViewController

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
    self.page = 1;
    [self getData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getData {
    [self.loadingView startAnimating];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetPaAttentionByPaMainID" params:[NSDictionary dictionaryWithObjectsAndKeys:[CommonFunc getPaMainId], @"paMainID", [NSString stringWithFormat:@"%ld", (long)self.page], @"pageNo", @"5", @"attentionType", [CommonFunc getCode], @"code", nil] tag:1];
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
    NSString *content = [rowData objectForKey:@"RecruitmentName"];
    float fontSize = 14;
    //宣讲会名称
    CustomLabel *lbCampus = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(10, 10, widthForLabel, 20) content:content size:fontSize color:nil];
    [cell.contentView addSubview:lbCampus];
    //宣讲会时间 日期
    UIColor *dateColor;
    NSDate *endDate = [CommonFunc dateFromString:[rowData objectForKey:@"EndDate"]];
    NSDate *today = [[NSDate alloc] init];
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *tomorrow;
    tomorrow = [today dateByAddingTimeInterval: secondsPerDay];
    NSString * todayString = [[today description] substringToIndex:10];
    NSString * tomorrowString = [[tomorrow description] substringToIndex:10];
    NSString * dateString = [[endDate description] substringToIndex:10];
    if ([dateString isEqualToString:todayString]) {
        content = @"今天";
        dateColor = UIColorWithRGBA(255, 0, 78, 1);
    }
    else if ([dateString isEqualToString:tomorrowString]) {
        content = @"明天";
        dateColor = UIColorWithRGBA(255, 0, 78, 1);
    }
    else {
        content = [CommonFunc stringFromDate:endDate formatType:@"MM-dd"];
        if ([endDate compare:today] == NSOrderedAscending) {
            dateColor = TEXTGRAYCOLOR;
        }
        else {
            dateColor = NAVBARCOLOR;
        }
    }
    fontSize = 14;
    CustomLabel *lbDate = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbCampus), VIEW_BY(lbCampus) + 5, 100, 20) content:content size:fontSize color:dateColor];
    [cell.contentView addSubview:lbDate];
    //宣讲会时间 星期+时分
    content = [NSString stringWithFormat:@"（%@）%@-%@", [CommonFunc getWeek:[rowData objectForKey:@"EndDate"]], [CommonFunc stringFromDateString:[rowData objectForKey:@"BeginDate"] formatType:@"HH:mm"], [CommonFunc stringFromDateString:[rowData objectForKey:@"EndDate"] formatType:@"HH:mm"]];
    fontSize = 12;
    CustomLabel *lbTime = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(lbDate) + 3, VIEW_Y(lbDate), 200, 20) content:content size:fontSize color:TEXTGRAYCOLOR];
    [cell.contentView addSubview:lbTime];
    //宣讲会地点 地区学校
    content = [NSString stringWithFormat:@"[%@] %@", [rowData objectForKey:@"abbr"], [rowData objectForKey:@"PlaceName"]];
    CustomLabel *lbSchool = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbDate), VIEW_BY(lbDate) + 5, widthForLabel - 10, 20) content:content size:fontSize color:nil];
    [cell.contentView addSubview:lbSchool];
    //宣讲会地点 地标图片
    UIImageView *imgMap = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_BX(lbSchool) + 1, VIEW_Y(lbSchool) + 3, 15, 15)];
    [imgMap setImage:[UIImage imageNamed:@"coMap.png"]];
    [cell.contentView addSubview:imgMap];
    [cell setFrame:CGRectMake(0, 0, SCREEN_WIDTH, VIEW_BY(lbSchool) + 10)];
    //关注按钮
    UIButton *btnFavorite = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 83, 0, 80, VIEW_BY(lbSchool))];
    [btnFavorite setTag:indexPath.section];
    [btnFavorite addTarget:self action:@selector(favoriteClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:btnFavorite];
    UIImageView *imgFavorite = [[UIImageView alloc] initWithFrame:CGRectMake(25, VIEW_H(btnFavorite) / 2 - 20, 26, 26)];
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
    if ([[rowData objectForKey:@"IsSchool"] isEqualToString:@"0"]) {
    RecruitmentViewController *recruitmentCtrl = [[RecruitmentViewController alloc] init];
    recruitmentCtrl.recruitmentId = [[rowData objectForKey:@"RecruitmentID"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
    [self.navigationController pushViewController:recruitmentCtrl animated:YES];
    }
    else {
        CampusRecruitmentViewController *recruitmentCtrl = [[CampusRecruitmentViewController alloc] init];
        recruitmentCtrl.recruitmentId = [[rowData objectForKey:@"RecruitmentID"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        [self.navigationController pushViewController:recruitmentCtrl animated:YES];
    }
}

- (void)footerRereshing{
    self.page++;
    [self getData];
}

- (void)favoriteClick:(UIButton *)sender {
    self.selectedRow = sender.tag;
    PopupView *alert = [[PopupView alloc] initWithWarningAlert:self.view title:@"提示" content:@"同学，你确定要取消关注该招聘会吗？" okMsg:@"确定取消关注" cancelMsg:@"我点错啦"];
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
        [self.tableView reloadData];
        [self.tableView footerEndRefreshing];
        [self.viewNoList popupClose];
        if (self.arrData.count == 0) {
            if (self.viewNoList == nil) {
                self.viewNoList = [[PopupView alloc] initWithNoListTips:self.tableView tipsMsg:@"<div style=\"text-align:center; font-size:14px;\"><p>同学，您尚未关注过任何招聘会，去搜索并关注感兴趣的招聘会，果儿会及时为您发送参会提醒！</p></div>"];
            }
            [self.tableView addSubview:self.viewNoList];
        }
    }
    else if (request.tag == 2) {
        self.page = 1;
        [self getData];
    }
}

@end

//
//  LikeListViewController.m
//  wutongguo
//
//  Created by Lucifer on 15-5-4.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//  猜你喜欢

#import "LikeListViewController.h"
#import "CompanyViewController.h"
#import "CpJobDetailViewController.h"
#import "CommonMacro.h"
#import "CustomLabel.h"
#import "CommonFunc.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "GDataXMLNode.h"
#import "PopupView.h"

@interface LikeListViewController () <UITableViewDataSource, UITableViewDelegate, NetWebServiceRequestDelegate>

@property (nonatomic, strong) PopupView *viewNoList;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;
@property (nonatomic, strong) NSArray *arrJobData;
@property (nonatomic, strong) NSArray *arrRegionData;
@property (nonatomic, strong) NSArray *arrMajorData;
@property (nonatomic, strong) UITableView *tableView;
@end

@implementation LikeListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"你的菜儿";
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT) style:UITableViewStyleGrouped];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.view addSubview:self.tableView];
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.view addSubview:self.loadingView];
    [self getData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getData {
    [self.loadingView startAnimating];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetCpBrochureByMajorID" params:
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            @"0", @"majorID",
                            [CommonFunc getPaMainId], @"paMainID",
                            [CommonFunc getCode], @"code", nil] tag:1];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.arrJobData.count;
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
    NSDictionary *jobData = [self.arrJobData objectAtIndex:indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellView"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellView"];
    }
    [cell setSelected:NO];
    for(UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    NSString *content = [jobData objectForKey:@"CpBrochureName"];
    float fontSize = 14;
    //企业按钮
    UIButton *btnCompany = [[UIButton alloc] initWithFrame:CGRectMake(0, 5, SCREEN_WIDTH, 35)];
    [btnCompany setTag:indexPath.section];
    [btnCompany addTarget:self action:@selector(companyClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:btnCompany];
    //企业名称
    CustomLabel *lbCompany = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(10, 0, VIEW_W(btnCompany) - 55, VIEW_H(btnCompany)) content:content size:fontSize color:UIColorWithRGBA(20, 62, 103, 1)];
    [btnCompany addSubview:lbCompany];
    //简章状态
//    UIImageView *imgStatus = [[UIImageView alloc] init];
//    NSInteger brochureStatusType = [CommonFunc getCpBrochureStatus:[jobData objectForKey:@"BrochureStatus"] beginDate:[jobData objectForKey:@"BeginDate"] endDate:[jobData objectForKey:@"EndDate"]];
//    NSString *statusImg = @"";
//    if (brochureStatusType == 2) { //过期
//        statusImg = @"coHasExpired.png";
//        [imgStatus setFrame:CGRectMake(VIEW_BX(lbCompany) + 5, VIEW_Y(lbCompany) + 9, 40, 20)];
//    }
//    else if (brochureStatusType == 3) { //未开始
//        statusImg = @"coNoStart.png";
//        [imgStatus setFrame:CGRectMake(VIEW_BX(lbCompany) + 5, VIEW_Y(lbCompany) + 7, 46, 20)];
//    }
//    else if (brochureStatusType == 1) { //网申中
//        statusImg = @"coHasStart.png";
//        [imgStatus setFrame:CGRectMake(VIEW_BX(lbCompany) + 5, VIEW_Y(lbCompany) + 7, 46, 20)];
//    }
//    else if (brochureStatusType == 4) { //已暂停
//        statusImg = @"coPause.png";
//        [imgStatus setFrame:CGRectMake(VIEW_BX(lbCompany) + 5, VIEW_Y(lbCompany) + 7, 40, 20)];
//    }
//    [imgStatus setImage:[UIImage imageNamed:statusImg]];
//    [btnCompany addSubview:imgStatus];
    //分隔符
    UILabel *lbSeparate = [[UILabel alloc] initWithFrame:CGRectMake(VIEW_X(lbCompany), VIEW_BY(btnCompany) + 5, SCREEN_WIDTH - 20, 0.5)];
    [lbSeparate setBackgroundColor:SEPARATECOLOR];
    [cell.contentView addSubview:lbSeparate];
    //职位按钮
    UIButton *btnJob = [[UIButton alloc] initWithFrame:CGRectMake(0, VIEW_BY(lbSeparate) + 5, SCREEN_WIDTH, 55)];
    [btnJob setTag:indexPath.section];
    [btnJob addTarget:self action:@selector(jobClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:btnJob];
    //职位名称
    content = [jobData objectForKey:@"JobName"];
    fontSize = 15;
    CustomLabel *lbJob = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(10, 5, VIEW_W(btnJob) - 100, 20) content:content size:fontSize color:nil];
    [btnJob addSubview:lbJob];
    //网申起止时间
    content = @"网申起止时间";
    fontSize = 12;
    CustomLabel *lbDateTitle = [[CustomLabel alloc] initWithFrame:CGRectMake(VIEW_W(btnJob) - 90, VIEW_Y(lbJob), 80, VIEW_H(lbJob)) content:content size:fontSize color:TEXTGRAYCOLOR];
    [lbDateTitle setTextAlignment:NSTextAlignmentRight];
    [btnJob addSubview:lbDateTitle];
    content = [NSString stringWithFormat:@"%@-%@", [CommonFunc stringFromDateString:[jobData objectForKey:@"BeginDate"] formatType:@"M月d日"], [CommonFunc stringFromDateString:[jobData objectForKey:@"EndDate"] formatType:@"M月d日"]] ;
    CustomLabel *lbDate = [[CustomLabel alloc] initWithFrame:CGRectMake(VIEW_W(btnJob) - 120, VIEW_BY(lbDateTitle) + 5, 110, VIEW_H(lbJob)) content:content size:fontSize color:NAVBARCOLOR];
    [lbDate setTextAlignment:NSTextAlignmentRight];
    [btnJob addSubview:lbDate];
    //职位信息
    //工作地点
    NSMutableString *jobCity = [[NSMutableString alloc] init];
    NSArray *arrRegion = [CommonFunc getArrayFromArrayWithSelect:self.arrRegionData param:[NSArray arrayWithObject:[NSDictionary dictionaryWithObject:[jobData objectForKey:@"JobID"] forKey:@"JobID"]]];
    for (NSDictionary *oneJobCity in arrRegion) {
        [jobCity appendFormat:@"%@ ", [oneJobCity objectForKey:@"abbr"]];
    }
    //专业
    NSMutableString *jobMajor = [[NSMutableString alloc] init];
    NSArray *arrMajor = [CommonFunc getArrayFromArrayWithSelect:self.arrMajorData param:[NSArray arrayWithObject:[NSDictionary dictionaryWithObject:[jobData objectForKey:@"JobID"] forKey:@"JobID"]]];
    for (NSDictionary *oneJobMajor in arrMajor) {
        [jobMajor appendFormat:@"%@ ", [oneJobMajor objectForKey:@"Name"]];
    }
    content = [NSString stringWithFormat:@"%@ | %@以上 | %@", jobCity, [jobData objectForKey:@"DcDegreeName"], jobMajor];
    CustomLabel *lbJobDetail = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbJob), VIEW_BY(lbJob) + 5, VIEW_W(btnJob) - 130, VIEW_H(lbJob)) content:content size:fontSize color:TEXTGRAYCOLOR];
    [btnJob addSubview:lbJobDetail];
    [cell setFrame:CGRectMake(0, 0, SCREEN_WIDTH, VIEW_BY(btnJob) + 10)];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)companyClick:(UIButton *)sender {
    NSDictionary *jobData = [self.arrJobData objectAtIndex:sender.tag];
    CompanyViewController *companyCtrl = [[CompanyViewController alloc] init];
    companyCtrl.secondId = [jobData objectForKey:@"CpSecondID"];
    companyCtrl.cpBrochureSecondId = [jobData objectForKey:@"CpBrochureSecondID"];
    companyCtrl.tabIndex = 1;
    [self.navigationController pushViewController:companyCtrl animated:YES];
}

- (void)jobClick:(UIButton *)sender {
    NSDictionary *jobData = [self.arrJobData objectAtIndex:sender.tag];
    CpJobDetailViewController *jobCtrl = [[CpJobDetailViewController alloc] init];
    jobCtrl.secondId = [jobData objectForKey:@"JobSecondID"];
    [self.navigationController pushViewController:jobCtrl animated:YES];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    [self.loadingView stopAnimating];
    self.arrJobData = [CommonFunc getArrayFromXml:requestData tableName:@"Table"];
    self.arrRegionData = [CommonFunc getArrayFromXml:requestData tableName:@"tableRegion"];
    self.arrMajorData = [CommonFunc getArrayFromXml:requestData tableName:@"tableMajor"];
    [self.tableView reloadData];
    [self.viewNoList popupClose];
    if (self.arrJobData.count == 0) {
        if (self.viewNoList == nil) {
            self.viewNoList = [[PopupView alloc] initWithNoListTips:self.tableView tipsMsg:@"<div style=\"text-align:center\"><p style=\"font-size:16px;\">抱歉，同学</p><p>没有找到您想要的信息</p></div>"];
        }
        [self.tableView addSubview:self.viewNoList];
    }
}

@end

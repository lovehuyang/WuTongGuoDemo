//
//  CpJobListViewController.m
//  wutongguo
//
//  Created by Lucifer on 15-5-18.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "CpJobListViewController.h"
#import "CpJobDetailViewController.h"
#import "CommonMacro.h"
#import "CommonFunc.h"
#import "CustomLabel.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "GDataXMLNode.h"
#import "PopupView.h"

@interface CpJobListViewController ()<UITableViewDataSource, UITableViewDelegate, NetWebServiceRequestDelegate>

@property (nonatomic, strong) PopupView *viewNoList;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;
@property (nonatomic, strong) NSArray *arrDeptData;
@property (nonatomic, strong) NSArray *arrAllJobData;
@property (nonatomic, strong) NSMutableArray *arrJobData;
@property (strong, nonatomic) UITableView *tableView;
@end

@implementation CpJobListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //定义uitableview
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStyleGrouped];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setScrollEnabled:NO];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    //等待动画
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.view addSubview:self.loadingView];
    //获取数据
    [self getData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getData {
    [self.loadingView startAnimating];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetJobByCpBrochureIDApp" params:[NSDictionary dictionaryWithObjectsAndKeys:self.secondId, @"cpBrochureID", nil] tag:1];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[self.arrJobData objectAtIndex:section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.arrDeptData.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSDictionary *deptData = [self.arrDeptData objectAtIndex:section];
    UIView *viewDept = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    if (section == 0) {
        [viewDept setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
        UIView *viewSeperate = [[UIView alloc] initWithFrame:CGRectMake(0, 10, SCREEN_WIDTH, 0.5)];
        [viewSeperate setBackgroundColor:SEPARATECOLOR];
        [viewDept addSubview:viewSeperate];
        return viewDept;
    }
    [viewDept setBackgroundColor:UIColorWithRGBA(249, 250, 251, 1)];
    UIView *viewSeparateTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, VIEW_W(viewDept), 0.5)];
    [viewSeparateTop setBackgroundColor:SEPARATECOLOR];
    [viewDept addSubview:viewSeparateTop];
    UIView *viewSeparateBottom = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_H(viewDept), VIEW_W(viewDept), 0.5)];
    [viewSeparateBottom setBackgroundColor:SEPARATECOLOR];
    [viewDept addSubview:viewSeparateBottom];
    
    UIView *viewTips = [[UIView alloc] initWithFrame:CGRectMake(20, 10, 5, 20)];
    [viewTips setBackgroundColor:NAVBARCOLOR];
    [viewDept addSubview:viewTips];
    
    CustomLabel *lbDept = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(viewTips) + 15, 10, SCREEN_WIDTH - 35 - VIEW_BX(viewTips), 20) content:[deptData objectForKey:@"CpDeptName"] size:14 color:TEXTGRAYCOLOR];
    [viewDept addSubview:lbDept];
    UIView *viewSeperate = [[UIView alloc] initWithFrame:CGRectMake(0, 40, SCREEN_WIDTH, 0.5)];
    [viewSeperate setBackgroundColor:SEPARATECOLOR];
    [viewDept addSubview:viewSeperate];
    return viewDept;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 10;
    }
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *jobData = [[self.arrJobData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSString *cellIdentify = @"cellView";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentify];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentify];
        CGRect frameCell = cell.contentView.frame;
        frameCell.size.height = 75;
        [cell.contentView setFrame:frameCell];
    }
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    //职位名称
    NSString *content = [jobData objectForKey:@"Name"];
    float fontSize = 15;
    CustomLabel *lbJob = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(10, 15, SCREEN_WIDTH - ([[jobData objectForKey:@"EmployType"] isEqualToString:@"2"] ? 130 : 100), 20) content:content size:fontSize color:nil];
    [cell.contentView addSubview:lbJob];
    if ([[jobData objectForKey:@"EmployType"] isEqualToString:@"2"]) {
        UIImageView *imgPractice = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_BX(lbJob) + 2, 18, 28, 15)];
        [imgPractice setImage:[UIImage imageNamed:@"coPractice.png"]];
        [cell.contentView addSubview:imgPractice];
    }
    //网申起止时间
    content = @"网申起止时间";
    fontSize = 12;
    CustomLabel *lbDateTitle = [[CustomLabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 90, VIEW_Y(lbJob), 80, VIEW_H(lbJob)) content:content size:fontSize color:TEXTGRAYCOLOR];
    [lbDateTitle setTextAlignment:NSTextAlignmentRight];
    [cell.contentView addSubview:lbDateTitle];
    
    content = [NSString stringWithFormat:@"%@-%@", [CommonFunc stringFromDateString:[jobData objectForKey:@"BeginDate"] formatType:@"M月d日"], [CommonFunc stringFromDateString:[jobData objectForKey:@"EndDate"] formatType:@"M月d日"]];
    CustomLabel *lbDate = [[CustomLabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 120, VIEW_BY(lbDateTitle) + 5, 110, VIEW_H(lbJob)) content:content size:fontSize color:NAVBARCOLOR];
    [lbDate setTextAlignment:NSTextAlignmentRight];
    [cell.contentView addSubview:lbDate];
    //职位信息
    content = [NSString stringWithFormat:@"%@ | %@ | %@及以上", ([[jobData objectForKey:@"JobRegion"] length] == 0 ? @"全国" : [jobData objectForKey:@"JobRegion"]), ([[jobData objectForKey:@"JobMajor"] isEqualToString:@"不限"] ? @"专业不限" : [jobData objectForKey:@"JobMajor"]), [jobData objectForKey:@"DegreeName"]];
    CustomLabel *lbJobDetail = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbJob), VIEW_BY(lbJob) + 5, SCREEN_WIDTH - 130, VIEW_H(lbJob)) content:content size:fontSize color:TEXTGRAYCOLOR];
    [cell.contentView addSubview:lbJobDetail];
    //更改cell的高度
    [cell setFrame:CGRectMake(0, 0, SCREEN_WIDTH, VIEW_BY(lbJobDetail) + 15)];
    [cell.contentView addSubview:[[CustomLabel alloc] initSeparate:cell]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *jobData = [[self.arrJobData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    CpJobDetailViewController *jobDetailCtrl = [[CpJobDetailViewController alloc] init];
    jobDetailCtrl.secondId = [jobData objectForKey:@"SecondID"];
    [self.navigationController pushViewController:jobDetailCtrl animated:YES];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1) {
        [self.loadingView stopAnimating];
        self.arrAllJobData = [CommonFunc getArrayFromXml:requestData tableName:@"tblBrochure"];
        self.arrDeptData = [CommonFunc getArrayFromXml:requestData tableName:@"tblOther"];
        self.arrJobData = [[NSMutableArray alloc] init];
        for (NSDictionary *detpData in self.arrDeptData) {
            [self.arrJobData addObject:[CommonFunc getArrayFromArrayWithSelect:self.arrAllJobData param:[NSArray arrayWithObject:[NSDictionary dictionaryWithObject:[detpData objectForKey:@"CpDeptID"] forKey:@"CpDeptID"]]]];
        }
        [self.tableView reloadData];
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"tableViewHeight=%f",self.tableView.contentSize.height);
            CGRect rectTable = self.tableView.frame;
            rectTable.size.height = self.tableView.contentSize.height;
            [self.tableView setFrame:rectTable];
            [self.companyCtrl.arrayViewHeight replaceObjectAtIndex:1 withObject:[NSNumber numberWithFloat:VIEW_BY(self.tableView) + 10]];
        });
        [self.viewNoList popupClose];
        if (self.arrAllJobData.count == 0) {
            if (self.viewNoList == nil) {
                self.viewNoList = [[PopupView alloc] initWithNoListTips:self.tableView tipsMsg:@"<div style=\"text-align:center\"><p>该企业未发布<span style=\"color:#ED7B56\">招聘职位</span></p><p>已罚他三天不准吃饭</p></div>"];
            }
            [self.tableView addSubview:self.viewNoList];
        }
    }
}

@end

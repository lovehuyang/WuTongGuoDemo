//
//  SwitchCampusListViewController.m
//  wutongguo
//
//  Created by Lucifer on 15-5-14.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "SwitchCampusListViewController.h"
#import "CampusCell.h"
#import "CommonMacro.h"
#import "CommonFunc.h"
#import "CustomLabel.h"
#import "NetWebServiceRequest.h"
#import "NetWebServiceRequest2.h"
#import "LoadingAnimationView.h"
#import "GDataXMLNode.h"
#import "MJRefresh.h"
#import "PopupView.h"
#import "CompanyViewController.h"
#import "RecruitmentViewController.h"
#import "CampusRecruitmentViewController.h"

@interface SwitchCampusListViewController () <UITableViewDelegate, UITableViewDataSource, NetWebServiceRequestDelegate>

@property (nonatomic, strong) PopupView *viewNoList;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest2;
@property (nonatomic, strong) LoadingAnimationView *loadingView;
@property (nonatomic, strong) NSMutableArray *arrData;
@property (nonatomic, strong) NSArray *arrCampusData;
@property (nonatomic) NSInteger cellSearchType;
@property BOOL blnExpire; //是否显示过期
@property BOOL hasExpire; //是否有过期
@end

@implementation SwitchCampusListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.blnExpire = false;
    self.hasExpire = false;
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.view addSubview:self.loadingView];
    self.cellSearchType = self.searchType;
    if (self.searchType > 2) {
        self.cellSearchType = self.searchType - 2;
        [self getData];
    }
    else {
        [self getData];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)getData {
    NSString *webServiceName;
    NSDictionary *dictionaryParam;
    if (self.searchType == 2) {
        webServiceName = @"GetRecruitmentByDcSchoolID";
        dictionaryParam = [NSDictionary dictionaryWithObjectsAndKeys:[CommonFunc getPaMainId], @"paMainID", [NSString stringWithFormat:@"%ld", (long)self.schoolId], @"SchoolID", [CommonFunc getCode], @"code", nil];
        self.runningRequest2 = [NetWebServiceRequest2 serviceRequestUrl:webServiceName params:dictionaryParam tag:1];
        [self.runningRequest2 setDelegate:self];
        [self.runningRequest2 startAsynchronous];
    }
    else {
        if (self.searchType == 1) {
            webServiceName = @"GetCpPreachByDcSchoolID";
            dictionaryParam = [NSDictionary dictionaryWithObjectsAndKeys:[CommonFunc getPaMainId], @"paMainID", [NSString stringWithFormat:@"%ld", (long)self.schoolId], @"SchoolID", [CommonFunc getCode], @"code", nil];
        }
        else if (self.searchType == 3) {
            webServiceName = @"GetCpPreachByLocationRegionID";
            dictionaryParam = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"locationRegionID", [CommonFunc getPaMainId], @"paMainID", [CommonFunc getCode], @"code", @"", @"ip", nil];
        }
        else if (self.searchType == 4) {
            webServiceName = @"GetRecruitmentByLocationRegionID";
            dictionaryParam = [NSDictionary dictionaryWithObjectsAndKeys:@"", @"locationRegionID", [CommonFunc getPaMainId], @"paMainID", [CommonFunc getCode], @"code", @"", @"ip", nil];
        }
        self.runningRequest = [NetWebServiceRequest serviceRequestUrl:webServiceName params:dictionaryParam tag:1];
        [self.runningRequest setDelegate:self];
        [self.runningRequest startAsynchronous];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.searchType == 1) {
        return self.arrData.count + (self.hasExpire && !self.blnExpire ? 1 : 0);
    }
    else {
        return self.arrData.count;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CampusCell *cell = (CampusCell *)[self tableView:self.tableView cellForRowAtIndexPath:indexPath];
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
    CampusCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellView"];
    if ((indexPath.section == self.arrData.count) && self.hasExpire && !self.blnExpire && self.searchType == 1) {
        for (UIView *view in cell.contentView.subviews) {
            [view removeFromSuperview];
        }
        UIButton *btnExpire = [[UIButton alloc] initWithFrame:CGRectMake(10, 10, SCREEN_WIDTH - 20, 30)];
        [btnExpire setTitle:@"查看往期宣讲会" forState:UIControlStateNormal];
        [btnExpire.titleLabel setFont:FONT(14)];
        [btnExpire setBackgroundColor:NAVBARCOLOR];
        btnExpire.layer.cornerRadius = 5.0f;
        [btnExpire addTarget:self action:@selector(showExpire:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btnExpire];
    }
    else {
        [cell fillCell:[self.arrData objectAtIndex:indexPath.section] searchType:self.cellSearchType fromSchool:(self.searchType > 2 ? NO : YES) viewController:self];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.cellSearchType == 1) {
        NSDictionary *campusData = [self.arrData objectAtIndex:indexPath.section];
        CompanyViewController *companyCtrl = [[CompanyViewController alloc] init];
        companyCtrl.secondId = [campusData objectForKey:@"CpSecondID"];
        companyCtrl.tabIndex = 2;
        [self.navigationController pushViewController:companyCtrl animated:YES];
    }
    else {
        NSDictionary *recruitmentData = [self.arrData objectAtIndex:indexPath.section];
        if ([[recruitmentData objectForKey:@"IsSchool"] isEqualToString:@"0"]) {
            RecruitmentViewController *recruitmentCtrl = [[RecruitmentViewController alloc] init];
            recruitmentCtrl.recruitmentId = [[recruitmentData objectForKey:(self.searchType == 2 ? @"ID" : @"id")] stringByReplacingOccurrencesOfString:@"-" withString:@""];
            [self.navigationController pushViewController:recruitmentCtrl animated:YES];
        }
        else {
            CampusRecruitmentViewController *recruitmentCtrl = [[CampusRecruitmentViewController alloc] init];
            recruitmentCtrl.recruitmentId = [[recruitmentData objectForKey:(self.searchType == 2 ? @"ID" : @"id")] stringByReplacingOccurrencesOfString:@"-" withString:@""];
            [self.navigationController pushViewController:recruitmentCtrl animated:YES];
        }
    }
}

- (void)showExpire:(UIButton *)sender {
    self.blnExpire = true;
    self.arrData = [self.arrCampusData mutableCopy];
    [self.tableView reloadData];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1) {
        [self.loadingView stopAnimating];
        self.arrData = [[CommonFunc getArrayFromXml:requestData tableName:@"Table"] mutableCopy];
        if (self.searchType == 1) {
            self.arrCampusData = [self.arrData copy];
            [self.arrData removeAllObjects];
            for (int index = 0; index < self.arrCampusData.count; index++) {
                NSDictionary *cpCampusData = [self.arrCampusData objectAtIndex:index];
                NSDate *endDate = [CommonFunc dateFromString:[cpCampusData objectForKey:@"EndDate"]];
                NSDate *today = [[NSDate alloc] init];
                if ([endDate compare:today] == NSOrderedAscending) {
                    continue;
                }
                else {
                    [self.arrData addObject:cpCampusData];
                }
            }
            if (self.arrData.count == 0) {
                self.arrData = [self.arrCampusData mutableCopy];
                self.blnExpire = true;
            }
            else if (self.arrData.count != self.arrCampusData.count) {
                self.hasExpire = true;
            }
        }
        [self.tableView reloadData];
        [self.viewNoList popupClose];
        if (self.arrData.count == 0) {
            if (self.viewNoList == nil) {
                self.viewNoList = [[PopupView alloc] initWithNoListTips:self.tableView tipsMsg:[NSString stringWithFormat:@"<div style=\"text-align:center\"><p style=\"font-size:16px;\">抱歉，同学</p><p>附近没有举办%@记录</p><p>建议您去其他高校看看</p></div>", (self.searchType == 1 || self.searchType == 3 ? @"宣讲会" : @"招聘会")]];
            }
            [self.tableView addSubview:self.viewNoList];
        }
    }
}

- (void)netRequestFinished2:(NetWebServiceRequest2 *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1) {
        [self.loadingView stopAnimating];
        self.arrData = [[CommonFunc getArrayFromXml:requestData tableName:@"Table"] mutableCopy];
        if (self.searchType == 1) {
            self.arrCampusData = [self.arrData copy];
            [self.arrData removeAllObjects];
            for (int index = 0; index < self.arrCampusData.count; index++) {
                NSDictionary *cpCampusData = [self.arrCampusData objectAtIndex:index];
                NSDate *endDate = [CommonFunc dateFromString:[cpCampusData objectForKey:@"EndDate"]];
                NSDate *today = [[NSDate alloc] init];
                if ([endDate compare:today] == NSOrderedAscending) {
                    continue;
                }
                else {
                    [self.arrData addObject:cpCampusData];
                }
            }
            if (self.arrData.count == 0) {
                self.arrData = [self.arrCampusData mutableCopy];
                self.blnExpire = true;
            }
            else if (self.arrData.count != self.arrCampusData.count) {
                self.hasExpire = true;
            }
        }
        [self.tableView reloadData];
        [self.viewNoList popupClose];
        if (self.arrData.count == 0) {
            if (self.viewNoList == nil) {
                self.viewNoList = [[PopupView alloc] initWithNoListTips:self.tableView tipsMsg:[NSString stringWithFormat:@"<div style=\"text-align:center\"><p style=\"font-size:16px;\">抱歉，同学</p><p>附近没有举办%@记录</p><p>建议您去其他高校看看</p></div>", (self.searchType == 1 || self.searchType == 3 ? @"宣讲会" : @"招聘会")]];
            }
            [self.tableView addSubview:self.viewNoList];
        }
    }
}

@end

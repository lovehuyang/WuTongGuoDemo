//
//  RecruitmentListViewController.m
//  wutongguo
//
//  Created by Lucifer on 15-5-14.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "RecruitmentListViewController.h"
#import "SearchViewController.h"
#import "RecruitmentViewController.h"
#import "CampusRecruitmentViewController.h"
#import "CommonMacro.h"
#import "CustomLabel.h"
#import "PopupView.h"
#import "CommonFunc.h"
#import "CampusCell.h"
#import "NetWebServiceRequest.h"
#import "NetWebServiceRequest2.h"
#import "LoadingAnimationView.h"
#import "GDataXMLNode.h"
#import "MJRefresh.h"
#import "Toast+UIView.h"

@interface RecruitmentListViewController () <UITableViewDelegate, UITableViewDataSource, PopupViewDelegate, NetWebServiceRequestDelegate, NetWebServiceRequest2Delegate>

@property (nonatomic, strong) PopupView *viewPopup;
@property (nonatomic, strong) PopupView *viewNoList;
@property (nonatomic, strong) NSString *cityId;
@property (nonatomic, strong) NSString *placeId;
@property (nonatomic, strong) NSString *dateId;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) NetWebServiceRequest2 *runningRequest2;
@property (nonatomic, strong) LoadingAnimationView *loadingView;
@property (nonatomic) NSInteger page;
//@property (nonatomic) BOOL isInit;
@property (nonatomic, strong) NSMutableArray *arrRecruitmentData;
@property (nonatomic, strong) NSMutableArray *arrPlaceData;
@property (nonatomic, strong) NSMutableArray *shareUrlParam;
@end

@implementation RecruitmentListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"招聘会";
//    self.isInit = YES;
    self.viewFilter.layer.borderWidth = 0.5;
    self.viewFilter.layer.borderColor = [SEPARATECOLOR CGColor];
    
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.view addSubview:self.loadingView];
    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
    self.arrRecruitmentData = [[NSMutableArray alloc] init];
    self.arrPlaceData = [[NSMutableArray alloc] init];
    
    self.page = 1;
    self.cityId = [USER_DEFAULT objectForKey:@"regionId"];
    self.lbCity.text = [USER_DEFAULT objectForKey:@"regionName"];
    if (self.keyWord == nil) {
        self.keyWord = @"";
    }
    else {
        self.cityId = @"0";
        self.lbCity.text = @"举办地区";
    }
    //self.cityId = @"0";
    self.placeId = @"0";
    if (self.typeId == nil) {
        self.typeId = @"0";
    }
    else {
        self.lbType.text = @"校园招聘会";
    }
    self.dateId = @"0";
    [self getData];
    //分享
    UIButton *btnShare = [[UIButton alloc] initWithFrame:CGRectMake(31, 0, 25, 25)];
    [btnShare setBackgroundImage:[UIImage imageNamed:@"coShare.png"] forState:UIControlStateNormal];
    [btnShare addTarget:self action:@selector(shareClick) forControlEvents:UIControlEventTouchUpInside];
    //搜索
    UIButton *btnSearch = [[UIButton alloc] initWithFrame:CGRectMake(0, 2, 21, 21)];
    [btnSearch setBackgroundImage:[UIImage imageNamed:@"coSearch.png"] forState:UIControlStateNormal];
    [btnSearch addTarget:self action:@selector(searchClick) forControlEvents:UIControlEventTouchUpInside];
    UIView *viewRightItem = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 25)];
    [viewRightItem addSubview:btnShare];
    [viewRightItem addSubview:btnSearch];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:viewRightItem];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:true];
    [self.viewPopup popupClose];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)searchClick {
    if (self.fromSearch) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        SearchViewController *viewSearch = [self.storyboard instantiateViewControllerWithIdentifier:@"searchView"];
        viewSearch.searchType = 9;
        [self.navigationController pushViewController:viewSearch animated:true];
    }
}

- (void)getData {
    [self.loadingView startAnimating];
    self.runningRequest2 = [NetWebServiceRequest2 serviceRequestUrl:@"GetRecruitmentList" params:[NSDictionary dictionaryWithObjectsAndKeys:[CommonFunc getPaMainId], @"paMainID", self.typeId, @"type", self.cityId, @"dcRegionID", self.placeId, @"placeID", self.dateId, @"dateType", [NSString stringWithFormat:@"%ld", (long)self.page], @"pageNo", [CommonFunc getCode], @"code", @"", @"ip", self.keyWord, @"keyword", nil] tag:1];
    [self.runningRequest2 setDelegate:self];
    [self.runningRequest2 startAsynchronous];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.arrRecruitmentData.count;
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
    [cell fillCell:[self.arrRecruitmentData objectAtIndex:indexPath.section] searchType:2 fromSchool:NO viewController:self];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *recruitmentData = [self.arrRecruitmentData objectAtIndex:indexPath.section];
    if ([[recruitmentData objectForKey:@"IsSchool"] isEqualToString:@"0"]) {
        RecruitmentViewController *recruitmentCtrl = [[RecruitmentViewController alloc] init];
        recruitmentCtrl.recruitmentId = [[recruitmentData objectForKey:@"ID"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        [self.navigationController pushViewController:recruitmentCtrl animated:YES];
    }
    else {
        CampusRecruitmentViewController *recruitmentCtrl = [[CampusRecruitmentViewController alloc] init];
        recruitmentCtrl.recruitmentId = [[recruitmentData objectForKey:@"ID"] stringByReplacingOccurrencesOfString:@"-" withString:@""];
        [self.navigationController pushViewController:recruitmentCtrl animated:YES];
    }
}

- (void)headerRereshing{
    self.page = 1;
    [self getData];
}

- (void)footerRereshing{
    self.page++;
    [self getData];
}

- (IBAction)typeClick:(UIButton *)sender {
    [self.viewPopup popupClose];
    if (sender.tag == 0) {
        self.viewPopup = [[PopupView alloc] initWithArray:sender parentView:self.view array:[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"1", @"id", @"校园招聘会", @"name", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"2", @"id", @"社会招聘会", @"name", nil], nil] required:NO];
        [self.viewPopup setTag:0];
        [self.viewPopup setDefaultWithLv1:self.typeId];
        [self.viewPopup setDelegate:self];
        [self.view.window addSubview:self.viewPopup];
        [self resetFilter];
        [self.arrowType setImage:[UIImage imageNamed:@"coUpArrow.png"]];
        [sender setTag:1];
    }
    else {
        [self.arrowType setImage:[UIImage imageNamed:@"coDownArrow.png"]];
        [sender setTag:0];
    }
}

- (IBAction)cityClick:(UIButton *)sender {
    [self.viewPopup popupClose];
    if (sender.tag == 0) {
        self.viewPopup = [[PopupView alloc] initWithCity:sender parentView:self.view required:NO];
        [self.viewPopup setTag:1];
        [self.viewPopup setDefaultWithLv2:self.cityId type:popupTypeWithRegion];
        [self.viewPopup setDelegate:self];
        [self.view.window addSubview:self.viewPopup];
        [self resetFilter];
        [self.arrowCity setImage:[UIImage imageNamed:@"coUpArrow.png"]];
        [sender setTag:1];
    }
    else {
        [self.arrowCity setImage:[UIImage imageNamed:@"coDownArrow.png"]];
        [sender setTag:0];
    }
}

- (IBAction)placeClick:(UIButton *)sender {
    [self.viewPopup popupClose];
    if (sender.tag == 0) {
        [self resetFilter];
        if (self.arrPlaceData.count == 0) {
            [self.view.window makeToast:@"请先选择举办地区"];
            return;
        }
        self.viewPopup = [[PopupView alloc] initWithArray:sender parentView:self.view array:self.arrPlaceData required:NO];
        [self.viewPopup setTag:2];
        [self.viewPopup setDefaultWithLv1:self.placeId];
        [self.viewPopup setDelegate:self];
        [self.view.window addSubview:self.viewPopup];
        [self.arrowPlace setImage:[UIImage imageNamed:@"coUpArrow.png"]];
        [sender setTag:1];
    }
    else {
        [self.arrowPlace setImage:[UIImage imageNamed:@"coDownArrow.png"]];
        [sender setTag:0];
    }
}

- (IBAction)dateClick:(UIButton *)sender {
    [self.viewPopup popupClose];
    if (sender.tag == 0) {
        self.viewPopup = [[PopupView alloc] initWithArray:sender parentView:self.view array:[CommonFunc getFilterDate] required:NO];
        [self.viewPopup setTag:3];
        [self.viewPopup setDefaultWithLv1:self.dateId];
        [self.viewPopup setDelegate:self];
        [self.view.window addSubview:self.viewPopup];
        [self resetFilter];
        [self.arrowDate setImage:[UIImage imageNamed:@"coUpArrow.png"]];
        [sender setTag:1];
    }
    else {
        [self.arrowDate setImage:[UIImage imageNamed:@"coDownArrow.png"]];
        [sender setTag:0];
    }
}

- (void)itemDidSelected:(id)value {
    NSDictionary *dicValue = (NSDictionary *)value;
    if (self.viewPopup.tag == 0) {
        [self.lbType setText:([dicValue[@"id"] isEqual: @"0"] ? @"招聘会类型" : dicValue[@"name"])];
        self.typeId = dicValue[@"id"];
    }
    else if (self.viewPopup.tag == 1) {
        [self.lbCity setText:([dicValue[@"id"] isEqual: @"0"] ? @"举办地区" : dicValue[@"name"])];
        self.cityId = dicValue[@"id"];
        [self.lbPlace setText:@"举办场馆"];
        self.placeId = @"0";
    }
    else if (self.viewPopup.tag == 2) {
        [self.lbPlace setText:([dicValue[@"id"] isEqual: @"0"] ? @"举办场馆" : dicValue[@"name"])];
        self.placeId = dicValue[@"id"];
    }
    else if (self.viewPopup.tag == 3) {
        [self.lbDate setText:([dicValue[@"id"] isEqual: @"0"] ? @"举办时间" : dicValue[@"name"])];
        self.dateId = dicValue[@"id"];
    }
    [self resetFilter];
    self.page = 1;
    [self getData];
}

- (void)closePopupWhenTapArrow {
    [self resetFilter];
}

- (void)resetFilter {
    [self.arrowCity setImage:[UIImage imageNamed:@"coDownArrow.png"]];
    [self.arrowPlace setImage:[UIImage imageNamed:@"coDownArrow.png"]];
    [self.arrowDate setImage:[UIImage imageNamed:@"coDownArrow.png"]];
    [self.arrowType setImage:[UIImage imageNamed:@"coDownArrow.png"]];
    
    [self.btnCity setTag:0];
    [self.btnPlace setTag:0];
    [self.btnType setTag:0];
    [self.btnDate setTag:0];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    [self.loadingView stopAnimating];
    if (request.tag == 2) {
        NSArray *arrContent = [CommonFunc getArrayFromXml:requestData tableName:@"Table"];
        NSString *shareContent = [[arrContent objectAtIndex:0] objectForKey:@"ContentText"];
        NSString *shareContent2 = [[arrContent objectAtIndex:0] objectForKey:@"ContentText2"];
        NSString *shareTitle = [[arrContent objectAtIndex:0] objectForKey:@"Title"];
        [CommonFunc share:shareTitle content:shareContent url:[NSString stringWithFormat:@"/zhaopinhui/%@", [self.shareUrlParam componentsJoinedByString:@"_"]] view:self.view imageUrl:@"" content2:shareContent2];
    }
}

- (void)netRequestFinished2:(NetWebServiceRequest2 *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    [self.loadingView stopAnimating];
    if (request.tag == 1) {
        if (self.page == 1) {
            [self.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
            [self.arrRecruitmentData removeAllObjects];
        }
        [self.arrRecruitmentData addObjectsFromArray:[CommonFunc getArrayFromXml:requestData tableName:@"dtRm"]];
        [self.tableView reloadData];
        [self.tableView headerEndRefreshing];
        [self.tableView footerEndRefreshing];
        [self.arrPlaceData removeAllObjects];
        NSArray *arrPlace = [CommonFunc getArrayFromXml:requestData tableName:@"dtPlace"];
        for (NSDictionary *placeData in arrPlace) {
            [self.arrPlaceData addObject:[NSDictionary dictionaryWithObjectsAndKeys:[placeData objectForKey:@"ID"], @"id", [placeData objectForKey:@"PlaceName"], @"name", nil]];
        }
        [self.viewNoList popupClose];
        if (self.arrRecruitmentData.count == 0) {
            if (self.viewNoList == nil) {
                self.viewNoList = [[PopupView alloc] initWithNoListTips:self.tableView tipsMsg:@"<div style=\"text-align:center\"><p style=\"font-size:16px;\">抱歉，同学</p><p>当前搜索条件下没有找到您想要的信息</p></div>"];
            }
            [self.tableView addSubview:self.viewNoList];
        }
    }
}

- (void)shareClick {
    self.shareUrlParam = [[NSMutableArray alloc] init];
    if (![self.typeId isEqualToString:@"0"]) {
        [self.shareUrlParam addObject:[NSString stringWithFormat:@"t%@", self.typeId]];
    }
    if (![self.cityId isEqualToString:@"0"]) {
        [self.shareUrlParam addObject:[NSString stringWithFormat:@"r%@", self.cityId]];
    }
    if (![self.placeId isEqualToString:@"0"]) {
        [self.shareUrlParam addObject:[NSString stringWithFormat:@"p%@", self.placeId]];
    }
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetShareTitle" params:[NSDictionary dictionaryWithObjectsAndKeys:@"104", @"pageID", self.shareUrlParam, @"id", nil] tag:2];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

@end

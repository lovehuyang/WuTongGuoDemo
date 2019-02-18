//
//  SearchListViewController.m
//  wutongguo
//
//  Created by Lucifer on 15-5-4.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "JobListViewController.h"
#import "SearchViewController.h"
#import "CompanyViewController.h"
#import "CpJobDetailViewController.h"
#import "CommonMacro.h"
#import "PopupView.h"
#import "CustomLabel.h"
#import "CommonFunc.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "GDataXMLNode.h"
#import "MJRefresh.h"
#import "Toast+UIView.h"
#import "MajorSearchViewController.h"

@interface JobListViewController () <PopupViewDelegate, UITableViewDataSource, UITableViewDelegate, NetWebServiceRequestDelegate>

@property (nonatomic, strong) PopupView *viewPopup;
@property (nonatomic, strong) PopupView *viewNoList;
@property (nonatomic, strong) NSString *cityId;
@property (nonatomic, strong) NSString *industryId;
@property (nonatomic, strong) NSString *companyKindId;
@property (nonatomic, strong) NSString *realCompanyKindId;
@property (nonatomic, strong) NSString *degreeId;
@property (nonatomic, strong) NSString *dateType;
@property (nonatomic, strong) NSString *orderType;
@property (nonatomic, strong) NSString *employType;
@property (nonatomic, strong) NSString *top500;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;
@property (nonatomic) NSInteger page;
@property (nonatomic, strong) NSMutableArray *arrJobData;
@property (nonatomic, strong) NSMutableArray *arrCpBrochureData;
@property (nonatomic, strong) NSMutableArray *arrRegionData;
@property (nonatomic, strong) NSString *shareUrl;
@end

@implementation JobListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.employType = @"0";
    if (self.searchType == 0) {
        self.title = @"招聘简章";
        self.employType = @"1";
    }
    else if (self.searchType == 1) {
        self.title = @"政府招考";
        self.employType = @"3";
    }
    else if (self.searchType == 2) {
        self.title = @"实习";
        self.employType = @"2";
    }
    else if (self.searchType == 7) {
        self.title = @"今日发布";
        self.employType = @"1";
    }
    else if (self.searchType == 8) {
        self.title = @"今日截止";
        self.employType = @"1";
    }
    self.viewFilter.layer.borderWidth = 0.5;
    self.viewFilter.layer.borderColor = [SEPARATECOLOR CGColor];
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.view addSubview:self.loadingView];
    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
    self.arrJobData = [[NSMutableArray alloc] init];
    self.arrCpBrochureData = [[NSMutableArray alloc] init];
    self.arrRegionData = [[NSMutableArray alloc] init];
    self.page = 1;
    self.cityId = @"0";
    self.industryId = @"0";
    self.companyKindId = @"0";
    self.realCompanyKindId = @"0";
    self.degreeId = @"0";
    self.dateType = @"0";
    self.orderType = @"0";
    self.top500 = @"0";
    if (self.majorId == nil) {
        self.majorId = @"0";
    }
    if (self.keyWord == nil || self.keyWord.length == 0) {
        self.keyWord = @"";
    }
    else {
        self.title = [NSString stringWithFormat:@"%@-%@", self.title, self.keyWord];
    }
    if ([self.majorName length] > 0) {
        self.lbMajor.text = self.majorName;
    }
    [self getData];
    //分享
    UIButton *btnShare = [[UIButton alloc] initWithFrame:CGRectMake(31, 0, 25, 25)];
    [btnShare setBackgroundImage:[UIImage imageNamed:@"coShare.png"] forState:UIControlStateNormal];
    [btnShare addTarget:self action:@selector(shareClick) forControlEvents:UIControlEventTouchUpInside];
    //搜索
    UIButton *btnSearch = [[UIButton alloc] initWithFrame:CGRectMake(0, 2, 21, 21)];
    [btnSearch setBackgroundImage:[UIImage imageNamed:@"coSearch.png"] forState:UIControlStateNormal];
    [btnSearch addTarget:self action:@selector(searchClick) forControlEvents:UIControlEventTouchUpInside];
    UIView *viewRightItem = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 21, 25)];
    [viewRightItem setFrame:CGRectMake(0, 0, 60, 25)];
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

- (void)getData {
    NSInteger degree = [self.degreeId intValue];
    NSString *requestMethod = @"GetCpBrochureQlrcNew";
    if (self.searchType == 7) {
        requestMethod = @"GetCpBrochureTodayIssue";
    }
    else if (self.searchType == 8) {
        requestMethod = @"GetCpBrochureTodayEnd";
    }
    [self.loadingView startAnimating];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:requestMethod params:
                           [NSDictionary dictionaryWithObjectsAndKeys:
                            self.cityId, @"regionID",
                            self.industryId, @"industryID",
                            self.realCompanyKindId, @"companyKindID",
                            self.majorId, @"majorID",
                            [NSString stringWithFormat:@"%ld", (long)degree], @"degreeID",
                            self.dateType, @"dateType",
                            self.keyWord, @"keyWord",
                            ([self.orderType isEqualToString:@"0"] ? @"1" : @"2"), @"orderByType",
                            [NSString stringWithFormat:@"%ld", (long)self.page], @"pageNo",
                            self.employType, @"emplyeeType",
                            self.top500, @"qiang", [CommonFunc getPaMainId], @"paMainID", nil] tag:1];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (IBAction)cityClick:(UIButton *)sender {
    [self.viewPopup popupClose];
    if (sender.tag == 0) {
        self.viewPopup = [[PopupView alloc] initWithCity:sender parentView:self.view required:NO];
        [self.viewPopup setTag:0];
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

- (IBAction)industryClick:(UIButton *)sender {
    [self.viewPopup popupClose];
    if (sender.tag == 0) {
        self.viewPopup = [[PopupView alloc] initWithArray:sender parentView:self.view array:[CommonFunc getDataFromDB:@"select * from dcIndustry"] required:NO];
        [self.viewPopup setTag:1];
        [self.viewPopup setDefaultWithLv1:self.industryId];
        [self.viewPopup setDelegate:self];
        [self.view.window addSubview:self.viewPopup];
        [self resetFilter];
        [self.arrowIndustry setImage:[UIImage imageNamed:@"coUpArrow.png"]];
        [sender setTag:1];
    }
    else {
        [self.arrowIndustry setImage:[UIImage imageNamed:@"coDownArrow.png"]];
        [sender setTag:0];
    }
}

- (IBAction)majorClick:(UIButton *)sender {
    MajorSearchViewController *majorSearchCtrl = [[MajorSearchViewController alloc] init];
    majorSearchCtrl.jobListCtrl = self;
    [self.navigationController pushViewController:majorSearchCtrl animated:YES];
    [self.viewPopup popupClose];
//    if (sender.tag == 0) {
//        self.viewPopup = [[PopupView alloc] initWithMajor:sender parentView:self.view required:NO];
//        [self.viewPopup setTag:2];
//        [self.viewPopup setDefaultWithLv2:self.majorId type:popupTypeWithMajor];
//        [self.viewPopup setDelegate:self];
//        [self.view.window addSubview:self.viewPopup];
//        [self resetFilter];
//        [self.arrowMajor setImage:[UIImage imageNamed:@"coUpArrow.png"]];
//        [sender setTag:1];
//    }
//    else {
//        [self.arrowMajor setImage:[UIImage imageNamed:@"coDownArrow.png"]];
//        [sender setTag:0];
//    }
}

- (IBAction)comboClick:(UIButton *)sender {
    [self.viewPopup popupClose];
    if (sender.tag == 0) {
        self.viewPopup = [[PopupView alloc] initWithCombo:sender parentView:self.view IsGov:(self.searchType == 1)];
        [self.viewPopup setTag:3];
        [self.viewPopup setDefaultWithCombo:[NSArray arrayWithObjects:self.orderType, self.companyKindId, self.degreeId, self.dateType, self.top500, nil]];
        [self.viewPopup setDelegate:self];
        [self.view.window addSubview:self.viewPopup];
        [self resetFilter];
        [self.arrowCombo setImage:[UIImage imageNamed:@"coUpArrow.png"]];
        [sender setTag:1];
    }
    else {
        [self.arrowCombo setImage:[UIImage imageNamed:@"coDownArrow.png"]];
        [sender setTag:0];
    }
}

- (void)itemDidSelected:(id)value {
    if (self.viewPopup.tag == 3) { //更多筛选
        NSArray *arrValue = (NSArray *)value;
        self.orderType = [[arrValue objectAtIndex:0] substringFromIndex:1];
        //企业类型赋值
        NSArray *arrCompanyKindId;
        if (self.searchType == 1) {
            arrCompanyKindId = [NSArray arrayWithObjects:@"0", @"7", @"8", @"11", @"12", nil];
        }
        else {
            arrCompanyKindId = [NSArray arrayWithObjects:@"0", @"1", @"2", @"3", @"4", @"7", @"8", @"9", @"10", @"11", @"12", @"100", nil];
        }
        self.companyKindId = [[arrValue objectAtIndex:1] substringFromIndex:1];
        self.realCompanyKindId = [arrCompanyKindId objectAtIndex:[self.companyKindId intValue]];
        self.degreeId = [[arrValue objectAtIndex:2] substringFromIndex:1];
        self.dateType = [[arrValue objectAtIndex:3] substringFromIndex:1];
        self.top500 = [[arrValue objectAtIndex:4] substringFromIndex:1];
    }
    else {
        NSDictionary *dicValue = (NSDictionary *)value;
        if (self.viewPopup.tag == 0) {
            [self.lbCity setText:([dicValue[@"id"] isEqual: @"0"] ? @"工作地点" : dicValue[@"name"])];
            self.cityId = dicValue[@"id"];
        }
        else if (self.viewPopup.tag == 1) {
            [self.lbIndustry setText:([dicValue[@"id"] isEqual: @"0"] ? @"所属行业" : dicValue[@"name"])];
            self.industryId = dicValue[@"id"];
        }
        else if (self.viewPopup.tag == 2) {
            [self.lbMajor setText:([dicValue[@"id"] isEqual: @"0"] ? @"专业要求" : dicValue[@"name"])];
            self.majorId = dicValue[@"id"];
        }
    }
    self.page = 1;
    [self resetFilter];
    [self getData];
}

- (void)closePopupWhenTapArrow {
    [self resetFilter];
}

- (void)resetFilter {
    [self.arrowCity setImage:[UIImage imageNamed:@"coDownArrow.png"]];
    [self.arrowIndustry setImage:[UIImage imageNamed:@"coDownArrow.png"]];
    [self.arrowMajor setImage:[UIImage imageNamed:@"coDownArrow.png"]];
    [self.arrowCombo setImage:[UIImage imageNamed:@"coDownArrow.png"]];
    
    [self.btnCity setTag:0];
    [self.btnIndustry setTag:0];
    [self.btnMajor setTag:0];
    [self.btnCombo setTag:0];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.arrCpBrochureData.count;
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
    for(UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    NSDictionary *cpBrochureData = [self.arrCpBrochureData objectAtIndex:indexPath.section];
    NSString *content = [cpBrochureData objectForKey:@"CpBrochureName"];
    float fontSize = 14;
    float picWidth = 0;
    NSString *top500Img = @"";
    if ([[cpBrochureData objectForKey:@"SalesOut"] length] > 0) {
        top500Img = @"ico_list_sj500.png";
    }
    else if ([[cpBrochureData objectForKey:@"SalesIn"] length] > 0) {
        top500Img = @"ico_list_zg500.png";
    }
    if (top500Img.length > 0) {
        picWidth = picWidth + 65;
    }
    if ([[cpBrochureData objectForKey:@"HasCpPreach"] integerValue] > 0) {
        picWidth = picWidth + 43;
    }
    //企业名称
    CustomLabel *lbCompany = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(10, 10, SCREEN_WIDTH - 20 - picWidth, 20) content:content size:fontSize color:UIColorWithRGBA(20, 62, 103, 1)];
    [cell.contentView addSubview:lbCompany];
    if (top500Img.length > 0) {
        UIImageView *imgTop500 = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_BX(lbCompany) + 2, VIEW_Y(lbCompany) + 2, 63, 16)];
        [imgTop500 setImage:[UIImage imageNamed:top500Img]];
        [cell.contentView addSubview:imgTop500];
    }
    if ([[cpBrochureData objectForKey:@"HasCpPreach"] integerValue] > 0) {
        UIImageView *imgPreach = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_BX(lbCompany) + 2 + (top500Img.length > 0 ? 65 : 0), VIEW_Y(lbCompany) + 2, 41, 16)];
        [imgPreach setImage:[UIImage imageNamed:@"ico_list_preach.png"]];
        [cell.contentView addSubview:imgPreach];
    }
    //简章状态
    NSInteger brochureStatusType = [CommonFunc getCpBrochureStatus:[cpBrochureData objectForKey:@"BrochureStatus"] beginDate:[cpBrochureData objectForKey:@"BeginDate"] endDate:[cpBrochureData objectForKey:@"EndDate"]];
    NSMutableArray *arrJobDetail = [[NSMutableArray alloc] init];
    //职位
    picWidth = 0;
    NSTimeInterval timeInterval = [[CommonFunc dateFromString:[cpBrochureData objectForKey:@"LastModifyDate"]] timeIntervalSinceNow];
    timeInterval = -timeInterval;
    //“新”图标
    if (timeInterval / 3600 < 24) {
        picWidth = picWidth + 14;
        UIImageView *imgNew = [[UIImageView alloc] initWithFrame:CGRectMake(10, VIEW_BY(lbCompany) + 8, 14, 14)];
        [imgNew setImage:[UIImage imageNamed:@"ico_list_new.png"]];
        [cell.contentView addSubview:imgNew];
    }
    //“官方”图标
    if ([[cpBrochureData objectForKey:@"ApplyType"] isEqualToString:@"1"]) {
        picWidth = picWidth + 28;
        UIImageView *imgOfficial = [[UIImageView alloc] initWithFrame:CGRectMake((timeInterval / 3600 < 24 ? 26 : 10), VIEW_BY(lbCompany) + 8, 26, 14)];
        [imgOfficial setImage:[UIImage imageNamed:@"ico_list_guanfang.png"]];
        [cell.contentView addSubview:imgOfficial];
    }
    NSArray *arrJob = [CommonFunc getArrayFromArrayWithSelect:self.arrJobData param:[NSArray arrayWithObject:[NSDictionary dictionaryWithObject:[cpBrochureData objectForKey:@"CpBrochureID"] forKey:@"cpBrochureID"]]];
    for (int i = 0; i < arrJob.count; i++) {
        [arrJobDetail addObject:[[arrJob objectAtIndex:i] objectForKey:@"Name"]];
    }
    content = [arrJobDetail componentsJoinedByString:@" | "];
    CustomLabel *lbJob = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(10 + (picWidth > 0 ? picWidth + 2 : 0), VIEW_BY(lbCompany) + 5, SCREEN_WIDTH - 105 - picWidth, 20) content:content size:fontSize color:TEXTGRAYCOLOR];
    [cell.contentView addSubview:lbJob];
    
    UIImageView *imgRegion = [[UIImageView alloc] initWithFrame:CGRectMake(10, VIEW_BY(lbJob) + 7, 16, 16)];
    [imgRegion setImage:[UIImage imageNamed:@"ico_location_green.png"]];
    [cell.contentView addSubview:imgRegion];
    NSMutableArray *arrRegionDetail = [[NSMutableArray alloc] init];
    NSArray *arrRegion = [CommonFunc getArrayFromArrayWithSelect:self.arrRegionData param:[NSArray arrayWithObject:[NSDictionary dictionaryWithObject:[cpBrochureData objectForKey:@"CpBrochureID"] forKey:@"cpBrochureID"]]];
    for (NSDictionary *region in arrRegion) {
        if (![[region allKeys] containsObject:@"Description"]) {
            [arrRegionDetail removeAllObjects];
            [arrRegionDetail addObject:@"全国"];
            break;
        }
        [arrRegionDetail addObject:[region objectForKey:@"Description"]];
    }
    CustomLabel *lbRegion = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgRegion) + 3, VIEW_Y(imgRegion) - 2, SCREEN_WIDTH - VIEW_W(imgRegion) - 125, 20) content:[arrRegionDetail componentsJoinedByString:@"、"] size:12 color:TEXTGRAYCOLOR];
    [cell.contentView addSubview:lbRegion];
    //网申起止时间
    content = @"网申起止时间";
    fontSize = 12;
    CustomLabel *lbDateTitle = [[CustomLabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 90, VIEW_Y(lbJob), 80, VIEW_H(lbJob)) content:content size:fontSize color:TEXTGRAYCOLOR];
    [lbDateTitle setTextAlignment:NSTextAlignmentRight];
    [cell.contentView addSubview:lbDateTitle];
    content = [NSString stringWithFormat:@"%@-%@", [CommonFunc stringFromDateString:[cpBrochureData objectForKey:@"BeginDate"] formatType:@"M月d日"], [CommonFunc stringFromDateString:[cpBrochureData objectForKey:@"EndDate"] formatType:@"M月d日"]] ;
    CustomLabel *lbDate = [[CustomLabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 120, VIEW_Y(lbRegion), 110, VIEW_H(lbJob)) content:content size:fontSize color:(brochureStatusType == 2 ? TEXTGRAYCOLOR : NAVBARCOLOR)];
    [lbDate setTextAlignment:NSTextAlignmentRight];
    [cell.contentView addSubview:lbDate];
    [cell setFrame:CGRectMake(0, 0, SCREEN_WIDTH, VIEW_BY(imgRegion) + 10)];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *cpBrochureData = [self.arrCpBrochureData objectAtIndex:indexPath.section];
    CompanyViewController *companyCtrl = [[CompanyViewController alloc] init];
    companyCtrl.secondId = [cpBrochureData objectForKey:@"CpSecondID"];
    companyCtrl.cpBrochureSecondId = [cpBrochureData objectForKey:@"SecondID"];
    companyCtrl.tabIndex = 1;
    [self.navigationController pushViewController:companyCtrl animated:YES];
}

- (void)headerRereshing{
    self.page = 1;
    [self getData];
}

- (void)footerRereshing{
    self.page++;
    [self getData];
}

- (void)searchClick {
    if (self.fromSearch) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        SearchViewController *viewSearch = [self.storyboard instantiateViewControllerWithIdentifier:@"searchView"];
        viewSearch.searchType = self.searchType;
        [self.navigationController pushViewController:viewSearch animated:YES];
    }
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    [self.loadingView stopAnimating];
    if (request.tag == 1) {
        if (self.page == 1) {
            [self.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
            [self.arrJobData removeAllObjects];
            [self.arrCpBrochureData removeAllObjects];
            [self.arrRegionData removeAllObjects];
        }
        [self.arrCpBrochureData addObjectsFromArray:[CommonFunc getArrayFromXml:requestData tableName:@"dtCpBrochure"]];
        [self.arrJobData addObjectsFromArray:[CommonFunc getArrayFromXml:requestData tableName:@"dtJob"]];
        [self.arrRegionData addObjectsFromArray:[CommonFunc getArrayFromXml:requestData tableName:@"dtRegion"]];
        [self.tableView reloadData];
        [self.tableView headerEndRefreshing];
        [self.tableView footerEndRefreshing];
        [self.viewNoList popupClose];
        if (self.arrJobData.count == 0) {
            if (self.viewNoList == nil) {
                self.viewNoList = [[PopupView alloc] initWithNoListTips:self.tableView tipsMsg:@"<div style=\"text-align:center\"><p style=\"font-size:16px;\">抱歉，同学</p><p style=\"font-size:14px;\">当前搜索条件下没有找到您想要的信息</p></div>"];
            }
            [self.tableView addSubview:self.viewNoList];
        }
    }
    else if (request.tag == 2) {
        NSArray *arrContent = [CommonFunc getArrayFromXml:requestData tableName:@"Table"];
        NSString *shareContent = [[arrContent objectAtIndex:0] objectForKey:@"ContentText"];
        NSString *shareContent2 = [[arrContent objectAtIndex:0] objectForKey:@"ContentText2"];
        NSString *shareTitle = [[arrContent objectAtIndex:0] objectForKey:@"Title"];
        [CommonFunc share:shareTitle content:shareContent url:self.shareUrl view:self.view imageUrl:@"" content2:shareContent2];
    }
}

- (void)shareClick {
    NSString *shareType = @"";
    NSMutableArray *shareUrlParam = [[NSMutableArray alloc] init];
    if (![self.cityId isEqualToString:@"0"]) {
        [shareUrlParam addObject:[NSString stringWithFormat:@"r%@", self.cityId]];
    }
    if (![self.degreeId isEqualToString:@"0"]) {
        [shareUrlParam addObject:[NSString stringWithFormat:@"d%@", self.degreeId]];
    }
    if (![self.majorId isEqualToString:@"0"]) {
        [shareUrlParam addObject:[NSString stringWithFormat:@"m%@", self.majorId]];
    }
    if (![self.industryId isEqualToString:@"0"]) {
        [shareUrlParam addObject:[NSString stringWithFormat:@"i%@", self.industryId]];
    }
    if (![self.realCompanyKindId isEqualToString:@"0"]) {
        [shareUrlParam addObject:[NSString stringWithFormat:@"c%@", self.realCompanyKindId]];
    }
    if (![self.top500 isEqualToString:@"0"]) {
        [shareUrlParam addObject:[NSString stringWithFormat:@"q%@", self.top500]];
    }
    if (![self.dateType isEqualToString:@"0"]) {
        [shareUrlParam addObject:[NSString stringWithFormat:@"d%@", self.dateType]];
    }
    if (self.searchType == 0) {
        shareType = @"101";
        self.shareUrl = [NSString stringWithFormat:@"/wangshen/%@", [shareUrlParam componentsJoinedByString:@"_"]];
    }
    else if (self.searchType == 1) {
        shareType = @"103";
        self.shareUrl = [NSString stringWithFormat:@"/gongwuyuan/%@", [shareUrlParam componentsJoinedByString:@"_"]];
    }
    else if (self.searchType == 2) {
        shareType = @"105";
        self.shareUrl = [NSString stringWithFormat:@"/shixi/%@", [shareUrlParam componentsJoinedByString:@"_"]];
    }
    else if (self.searchType == 7) {
        shareType = @"210";
        self.shareUrl = [NSString stringWithFormat:@"/wangshentoday/%@", [shareUrlParam componentsJoinedByString:@"_"]];
    }
    else if (self.searchType == 8) {
        shareType = @"211";
        self.shareUrl = [NSString stringWithFormat:@"/wangshentodayend/%@", [shareUrlParam componentsJoinedByString:@"_"]];
    }
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetShareTitle" params:[NSDictionary dictionaryWithObjectsAndKeys:shareType, @"pageID", [shareUrlParam componentsJoinedByString:@"_"], @"id", nil] tag:2];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

@end

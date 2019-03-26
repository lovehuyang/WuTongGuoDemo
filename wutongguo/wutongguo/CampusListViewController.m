//
//  CampusViewController.m
//  wutongguo
//
//  Created by Lucifer on 15-5-14.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "CampusListViewController.h"
#import "SearchViewController.h"
#import "CommonMacro.h"
#import "CustomLabel.h"
#import "PopupView.h"
#import "CommonFunc.h"
#import "CampusCell.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "GDataXMLNode.h"
#import "MJRefresh.h"
#import "Toast+UIView.h"
#import "CompanyViewController.h"

@interface CampusListViewController () <UITableViewDelegate, UITableViewDataSource, PopupViewDelegate, NetWebServiceRequestDelegate>
@property (nonatomic, strong) PopupView *viewPopup;
@property (nonatomic, strong) PopupView *viewNoList;
@property (nonatomic, strong) NSString *cityId;
@property (nonatomic, strong) NSString *schoolId;
@property (nonatomic, strong) NSString *industryId;
@property (nonatomic, strong) NSString *dateId;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;
@property (nonatomic) NSInteger page;
//@property (nonatomic) BOOL isInit;
@property (nonatomic, strong) NSMutableArray *arrCampusData;
@property (nonatomic, strong) NSMutableArray *arrSchoolData;
@property (nonatomic, strong) NSMutableArray *shareUrlParam;
@end

@implementation CampusListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"宣讲会";
//    self.isInit = YES;
    self.viewFilter.layer.borderWidth = 0.5;
    self.viewFilter.layer.borderColor = [SEPARATECOLOR CGColor];
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.view addSubview:self.loadingView];
    [self.tableView addHeaderWithTarget:self action:@selector(headerRereshing)];
    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
    self.arrCampusData = [[NSMutableArray alloc] init];
    self.arrSchoolData = [[NSMutableArray alloc] init];
    self.page = 1;
    self.cityId = @"0";
//    self.cityId = [USER_DEFAULT objectForKey:@"regionId"];
//    self.lbCity.text = [USER_DEFAULT objectForKey:@"regionName"];
    self.schoolId = @"0";
    self.industryId = @"0";
    self.dateId = @"0";
    if (self.keyWord != nil) {
        self.title = [NSString stringWithFormat:@"%@-%@", self.title, self.keyWord];
    }
    else {
        self.keyWord = @"";
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
    
    UIView *viewRightItem = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 25)];
    [viewRightItem addSubview:btnShare];
    [viewRightItem addSubview:btnSearch];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:viewRightItem];
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
    [self.loadingView startAnimating];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetCpPreach" params:[NSDictionary dictionaryWithObjectsAndKeys:[CommonFunc getPaMainId], @"paMainId", self.cityId, @"regionID", self.industryId, @"industryID", self.schoolId, @"schoolID", self.dateId, @"dateType", self.keyWord, @"keyWord", [NSString stringWithFormat:@"%ld", (long)self.page], @"pageNo", [CommonFunc getCode], @"code", @"", @"ip", nil] tag:1];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.arrCampusData.count;
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
    [cell fillCell:[self.arrCampusData objectAtIndex:indexPath.section] searchType:1 fromSchool:NO viewController:self];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *campusData = [self.arrCampusData objectAtIndex:indexPath.section];
    CompanyViewController *companyCtrl = [[CompanyViewController alloc] init];
    companyCtrl.secondId = [campusData objectForKey:@"CpSecondID"];
    companyCtrl.tabIndex = 2;
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
        viewSearch.searchType = 4;
        [self.navigationController pushViewController:viewSearch animated:true];
    }
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

- (IBAction)schoolClick:(UIButton *)sender {
    [self.viewPopup popupClose];
    if (sender.tag == 0) {
        [self resetFilter];
        if (self.arrSchoolData.count == 0) {
            [self.view.window makeToast:@"请先选择宣讲地区"];
            return;
        }
        self.viewPopup = [[PopupView alloc] initWithArray:sender parentView:self.view array:self.arrSchoolData required:NO];
        [self.viewPopup setTag:1];
        [self.viewPopup setDefaultWithLv1:self.schoolId];
        [self.viewPopup setDelegate:self];
        [self.view.window addSubview:self.viewPopup];
        [self.arrowSchool setImage:[UIImage imageNamed:@"coUpArrow.png"]];
        [sender setTag:1];
    }
    else {
        [self.arrowSchool setImage:[UIImage imageNamed:@"coDownArrow.png"]];
        [sender setTag:0];
    }
}

- (IBAction)industryClick:(UIButton *)sender {
    [self.viewPopup popupClose];
    if (sender.tag == 0) {
        self.viewPopup = [[PopupView alloc] initWithArray:sender parentView:self.view array:[CommonFunc getDataFromDB:@"select * from dcIndustry"] required:NO];
        [self.viewPopup setTag:2];
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
        [self.lbCity setText:([dicValue[@"id"] isEqual: @"0"] ? @"宣讲地区" : dicValue[@"name"])];
        self.cityId = dicValue[@"id"];
        [self.lbSchool setText:@"宣讲高校"];
        self.schoolId = @"0";
    }
    else if (self.viewPopup.tag == 1) {
        [self.lbSchool setText:([dicValue[@"id"] isEqual: @"0"] ? @"宣讲高校" : dicValue[@"name"])];
        self.schoolId = dicValue[@"id"];
    }
    else if (self.viewPopup.tag == 2) {
        [self.lbIndustry setText:([dicValue[@"id"] isEqual: @"0"] ? @"所属行业" : dicValue[@"name"])];
        self.industryId = dicValue[@"id"];
    }
    else if (self.viewPopup.tag == 3) {
        [self.lbDate setText:([dicValue[@"id"] isEqual: @"0"] ? @"宣讲时间" : dicValue[@"name"])];
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
    [self.arrowIndustry setImage:[UIImage imageNamed:@"coDownArrow.png"]];
    [self.arrowDate setImage:[UIImage imageNamed:@"coDownArrow.png"]];
    [self.arrowSchool setImage:[UIImage imageNamed:@"coDownArrow.png"]];
    
    [self.btnCity setTag:0];
    [self.btnIndustry setTag:0];
    [self.btnSchool setTag:0];
    [self.btnDate setTag:0];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    [self.loadingView stopAnimating];
    if (request.tag == 1) {
        if (self.page == 1) {
            [self.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
            [self.arrCampusData removeAllObjects];
        }
        [self.arrCampusData addObjectsFromArray:[CommonFunc getArrayFromXml:requestData tableName:@"Table2"]];
        [self.tableView reloadData];
        [self.tableView headerEndRefreshing];
        [self.tableView footerEndRefreshing];
        [self.arrSchoolData removeAllObjects];
        NSArray *arrSchool = [CommonFunc getArrayFromXml:requestData tableName:@"Table1"];
        for (NSDictionary *schoolData in arrSchool) {
            [self.arrSchoolData addObject:[NSDictionary dictionaryWithObjectsAndKeys:[schoolData objectForKey:@"ID"], @"id", [schoolData objectForKey:@"Name"], @"name", nil]];
        }
        [self.viewNoList popupClose];
        if (self.arrCampusData.count == 0) {
//            if (self.isInit) {
//                self.isInit = NO;
//                self.cityId = @"0";
//                self.lbCity.text = @"宣讲地区";
//                [self getData];
//                return;
//            }
            if (self.viewNoList == nil) {
                self.viewNoList = [[PopupView alloc] initWithNoListTips:self.tableView tipsMsg:@"<div style=\"text-align:center\"><p style=\"font-size:16px;\">抱歉，同学</p><p>当前搜索条件下没有找到您想要的信息</p></div>"];
            }
            [self.tableView addSubview:self.viewNoList];
        }
    }
    else if (request.tag == 2) {
        NSArray *arrContent = [CommonFunc getArrayFromXml:requestData tableName:@"Table"];
        NSString *shareContent = [[arrContent objectAtIndex:0] objectForKey:@"ContentText"];
        NSString *shareContent2 = [[arrContent objectAtIndex:0] objectForKey:@"ContentText2"];
        NSString *shareTitle = [[arrContent objectAtIndex:0] objectForKey:@"Title"];
        [CommonFunc share:shareTitle content:shareContent url:[NSString stringWithFormat:@"/xuanjianghui/%@", [self.shareUrlParam componentsJoinedByString:@"_"]] view:self.view imageUrl:@"" content2:shareContent2];
    }
}

- (void)shareClick {
    self.shareUrlParam = [[NSMutableArray alloc] init];
    if (![self.cityId isEqualToString:@"0"]) {
        [self.shareUrlParam addObject:[NSString stringWithFormat:@"r%@", self.cityId]];
    }
    if (![self.schoolId isEqualToString:@"0"]) {
        [self.shareUrlParam addObject:[NSString stringWithFormat:@"s%@", self.schoolId]];
    }
    if (![self.industryId isEqualToString:@"0"]) {
        [self.shareUrlParam addObject:[NSString stringWithFormat:@"i%@", self.industryId]];
    }
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetShareTitle" params:[NSDictionary dictionaryWithObjectsAndKeys:@"102", @"pageID", self.shareUrlParam, @"id", nil] tag:2];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    NSUserDefaults*pushJudge = [NSUserDefaults standardUserDefaults];
    if([[pushJudge objectForKey:@"push"]isEqualToString:@"push"]) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"menu-back"] style:UIBarButtonItemStylePlain target:self action:@selector(rebackToRootViewAction)];
    }else{
        self.navigationItem.leftBarButtonItem=nil;
    }
}
- (void)rebackToRootViewAction {
    NSUserDefaults * pushJudge = [NSUserDefaults standardUserDefaults];
    [pushJudge setObject:@""forKey:@"push"];
    [pushJudge synchronize];//记得立即同步
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end

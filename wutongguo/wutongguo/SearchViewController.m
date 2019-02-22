//
//  SearchViewController.m
//  wutongguo
//
//  Created by Lucifer on 15-5-13.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "SearchViewController.h"
#import "CommonMacro.h"
#import "CommonFunc.h"
#import "CustomLabel.h"
#import "SearchSchoolListViewController.h"
#import "JobListViewController.h"
#import "CampusListViewController.h"
#import "Top500ListViewController.h"
#import "FamousViewController.h"
#import "Toast+UIView.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "GDataXMLNode.h"
#import "RecruitmentListViewController.h"

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate, NetWebServiceRequestDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UITextField *txtSearch;
@property (nonatomic, strong) NSArray *arrSearchData;
@property (nonatomic, strong) NSArray *arrHotData;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;
@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.txtSearch = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 110, 30)];
    [self.txtSearch setDelegate:self];
    [self.txtSearch setFont:[UIFont systemFontOfSize:14]];
    [self.txtSearch setClearButtonMode:UITextFieldViewModeAlways];
    [self.txtSearch setBorderStyle:UITextBorderStyleRoundedRect];
    [self.txtSearch setBackgroundColor:UIColorWithRGBA(1, 219, 168, 1)];
    [self.txtSearch setReturnKeyType:UIReturnKeySearch];
    if (self.searchType == 0 || self.searchType == 7 || self.searchType == 8) { //网申
        [self.txtSearch setPlaceholder:@"请输入公司名称或职位名称"];
    }
    else if (self.searchType == 1) { //政府招考
        [self.txtSearch setPlaceholder:@"请输入公司名称或职位名称"];
    }
    else if (self.searchType == 2) { //实习
        [self.txtSearch setPlaceholder:@"请输入公司名称或职位名称"];
    }
    else if (self.searchType == 3) { //高校搜索
        [self.txtSearch setPlaceholder:@"请输入学校名称"];
    }
    else if (self.searchType == 4) { //宣讲会搜索
        [self.txtSearch setPlaceholder:@"请输入企业名称"];
    }
    else if (self.searchType == 5) { //500强搜索
        [self.txtSearch setPlaceholder:@"请输入企业名称"];
    }
    else if (self.searchType == 6) { //名企搜索
        [self.txtSearch setPlaceholder:@"请输入企业名称"];
    }
    else if (self.searchType == 9) { //招聘会搜索
        [self.txtSearch setPlaceholder:@"请输入高校名称"];
    }
    [self.txtSearch setTextColor:[UIColor whiteColor]];
    [self.txtSearch setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    self.navigationItem.titleView = self.txtSearch;
    UIButton *btnSearch = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [btnSearch setBackgroundImage:[UIImage imageNamed:@"coSearch.png"] forState:UIControlStateNormal];
    [btnSearch addTarget:self action:@selector(searchClick) forControlEvents:UIControlEventTouchUpInside];
    UIView *containerView = [[UIView alloc]initWithFrame:btnSearch.frame];
    [containerView addSubview:btnSearch];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:containerView];
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.view addSubview:self.loadingView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initSearch];
}

- (void)initSearch {
    self.arrSearchData = [CommonFunc getHistoryFromDB:[NSString stringWithFormat:@"select * from searchHistory where searchType=%ld order by researchdate desc", (long)self.searchType]];
    if (self.arrSearchData.count == 0) {
        [self.viewNoHistory setHidden:NO];
        [self.viewHistory setHidden:YES];
        if (self.searchType != 0) {
            [self.lbHot setHidden:YES];
        }
        else {
            [self getHotData];
        }
    }
    else {
        [self.viewNoHistory setHidden:YES];
        [self.viewHistory setHidden:NO];
        [self.tableView reloadData];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrSearchData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 46;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellView"];
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    NSDictionary *searchData = [self.arrSearchData objectAtIndex:indexPath.row];
    UIImageView *imgTips = [[UIImageView alloc] initWithFrame:CGRectMake(30, 18, 10, 10)];
    [imgTips setImage:[UIImage imageNamed:@"coGreenPoint.png"]];
    [cell.contentView addSubview:imgTips];
    CustomLabel *lbWord = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgTips) + 10, 13, SCREEN_WIDTH - VIEW_BX(imgTips) - 30, 20) content:[searchData objectForKey:@"keyword"] size:16 color:[UIColor blackColor]];
    [cell.contentView addSubview:lbWord];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *searchData = [self.arrSearchData objectAtIndex:indexPath.row];
    [self.txtSearch setText:[searchData objectForKey:@"keyword"]];
    [self searchClick];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self searchClick];
    return YES;
}

- (void)searchClick {
    [self.txtSearch resignFirstResponder];
//    if (self.txtSearch.text.length == 0) {
//        [self.view.window makeToast:@"请输入内容"];
//        return;
//    }
    if (self.txtSearch.text.length > 0) {
        NSArray *arrSearchHistory = [CommonFunc getHistoryFromDB:[NSString stringWithFormat:@"select * from searchHistory where keywords='%@' and searchType=%ld", self.txtSearch.text, (long)self.searchType]];
        if (arrSearchHistory.count == 0) {
            [CommonFunc updateFromDB:[NSString stringWithFormat:@"insert into searchHistory(keyWords,reSearchDate,addDate,searchType) values('%@', datetime(CURRENT_TIMESTAMP,'localtime'), datetime(CURRENT_TIMESTAMP,'localtime'), %ld)", self.txtSearch.text, (long)self.searchType]];
        }
        else {
            [CommonFunc updateFromDB:[NSString stringWithFormat:@"update searchHistory set reSearchDate=datetime(CURRENT_TIMESTAMP,'localtime') where keywords=%@", self.txtSearch.text]];
        }
    }
    if (self.searchType == 0 || self.searchType == 1 || self.searchType == 2 || self.searchType == 7 || self.searchType == 8) {
        JobListViewController *jobListCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"jobListView"];
        jobListCtrl.keyWord = self.txtSearch.text;
        jobListCtrl.searchType = self.searchType;
        jobListCtrl.fromSearch = YES;
        [self.navigationController pushViewController:jobListCtrl animated:YES];
    }
    else if (self.searchType == 3) {
        SearchSchoolListViewController *schoolListCtrl = [[SearchSchoolListViewController alloc] init];
        schoolListCtrl.keyWord = self.txtSearch.text;
        [self.navigationController pushViewController:schoolListCtrl animated:YES];
    }
    else if (self.searchType == 4) {
        CampusListViewController *campusListCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"campusListView"];
        campusListCtrl.keyWord = self.txtSearch.text;
        campusListCtrl.fromSearch = YES;
        [self.navigationController pushViewController:campusListCtrl animated:YES];
    }
    else if (self.searchType == 5) {
        Top500ListViewController *top500ListCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"top500ListView"];
        top500ListCtrl.keyWord = self.txtSearch.text;
        top500ListCtrl.fromSearch = YES;
        [self.navigationController pushViewController:top500ListCtrl animated:YES];
    }
    else if (self.searchType == 6) {
        FamousViewController *famousCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"famousListView"];
        famousCtrl.keyWord = self.txtSearch.text;
        famousCtrl.fromSearch = YES;
        [self.navigationController pushViewController:famousCtrl animated:YES];
    }
    else if (self.searchType == 9) {
        RecruitmentListViewController *recruitmentCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"recruitmentListView"];
        recruitmentCtrl.keyWord = self.txtSearch.text;
        recruitmentCtrl.typeId = @"1";
        recruitmentCtrl.fromSearch = YES;
        [self.navigationController pushViewController:recruitmentCtrl animated:YES];
    }
}

- (void)getHotData {
    [self.loadingView startAnimating];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetSiteHotKeyword" params:nil tag:1];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    [self.loadingView stopAnimating];
    if (request.tag == 1) {
        self.arrHotData = [CommonFunc getArrayFromXml:requestData tableName:@"Table"];
        [self fillHot];
    }
}

- (void)fillHot {
    float fltY = VIEW_BY(self.lbHot) + 10;
    float fltX = VIEW_X(self.lbHot);
    float fltMargin = 7;
    float fltWidth = (SCREEN_WIDTH - VIEW_X(self.lbHot) * 2 - fltMargin * 2) / 3;
    float fltHeight = 30;
    for (UIView *view in self.viewNoHistory.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            [view removeFromSuperview];
        }
    }
    for (int i = 0; i < self.arrHotData.count; i++) {
        NSDictionary *hotData = [self.arrHotData objectAtIndex:i];
        if (i % 3 == 0) {
            if (i > 0) {
                fltX = VIEW_X(self.lbHot);
                fltY = fltY + fltHeight + fltMargin;
            }
        }
        else {
            fltX = fltX + fltWidth + fltMargin;
        }
        UIButton *btnHot = [[UIButton alloc] initWithFrame:CGRectMake(fltX, fltY, fltWidth, fltHeight)];
        [btnHot setTitle:[hotData objectForKey:@"KeyWord"] forState:UIControlStateNormal];
        [btnHot setTag:i];
        [btnHot setBackgroundColor:UIColorWithRGBA(184, 237, 219, 1)];
        [btnHot setTitleColor:UIColorWithRGBA(84, 84, 84, 1) forState:UIControlStateNormal];
        [btnHot.titleLabel setFont:FONT(14)];
        [btnHot.layer setMasksToBounds:YES];
        [btnHot.layer setCornerRadius:fltWidth/7];
        [btnHot addTarget:self action:@selector(hotClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.viewNoHistory addSubview:btnHot];
    }
}

- (void)hotClick:(UIView *)sender {
    NSDictionary *hodData = [self.arrHotData objectAtIndex:sender.tag];
    [self.txtSearch setText:[hodData objectForKey:@"KeyWord"]];
    [self searchClick];
}

- (IBAction)clearHistory:(UIButton *)sender {
    [CommonFunc updateFromDB:[NSString stringWithFormat:@"delete from searchHistory where searchType=%ld", (long)self.searchType]];
    [self initSearch];
}

@end

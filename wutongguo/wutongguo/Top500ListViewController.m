//
//  Top500ListViewController.m
//  wutongguo
//
//  Created by Lucifer on 15/5/26.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "Top500ListViewController.h"
#import "SearchViewController.h"
#import "CpBrandViewController.h"
#import "CommonMacro.h"
#import "CommonFunc.h"
#import "CustomLabel.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "GDataXMLNode.h"
#import "MJRefresh.h"
#import "PopupView.h"
#import "UIImageView+WebCache.h"

@interface Top500ListViewController ()<UITableViewDataSource, UITableViewDelegate, NetWebServiceRequestDelegate, PopupViewDelegate>

@property (nonatomic, strong) PopupView *viewPopup;
@property (nonatomic, strong) PopupView *viewNoList;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;
@property (nonatomic) NSInteger page;
@property (nonatomic) NSString *industryId;
@property (nonatomic, strong) NSMutableArray *arrData;
@end

@implementation Top500ListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"500强";
    self.viewFilter.layer.borderWidth = 0.5;
    self.viewFilter.layer.borderColor = [SEPARATECOLOR CGColor];
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.view addSubview:self.loadingView];
    self.page = 1;
    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
    self.arrData = [[NSMutableArray alloc] init];
    self.industryId = @"0";
    if (self.top500TypeId == nil) {
        self.top500TypeId = @"0";
    }
    else {
        if ([self.top500TypeId isEqualToString:@"1"]) {
            [self.lbTop500Type setText:@"财富世界500强"];
        }
        else if ([self.top500TypeId isEqualToString:@"2"]) {
            [self.lbTop500Type setText:@"财富中国500强"];
        }
        else if ([self.top500TypeId isEqualToString:@"3"]) {
            [self.lbTop500Type setText:@"中国企业500强"];
        }
        else if ([self.top500TypeId isEqualToString:@"4"]) {
            [self.lbTop500Type setText:@"中国民营企业500强"];
        }
    }
    self.page = 1;
    if (self.keyWord != nil) {
        self.title = [NSString stringWithFormat:@"%@-%@", self.title, self.keyWord];
        self.top500TypeId = @"0";
        [self.constraintFilterHeight setConstant:1];
        [self.viewFilter setHidden:YES];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:true];
    [self.viewPopup popupClose];
}

- (void)getData {
    [self.loadingView startAnimating];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetCpBrandBySales" params:[NSDictionary dictionaryWithObjectsAndKeys:self.industryId, @"dcIndustryID", self.top500TypeId, @"salesType", self.keyWord, @"keyWord", [NSString stringWithFormat:@"%ld", (long)self.page], @"pageNo", nil] tag:1];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rowCount = ceilf((float)self.arrData.count / 2);
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellView"];
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setBackgroundColor:[UIColor whiteColor]];
    float maxCellHeight = 0;
    for (NSInteger index = indexPath.row * 2; index < (indexPath.row * 2) + 2; index++) {
        if (index == self.arrData.count) {
            break;
        }
        NSDictionary *oneCompanyData = [self.arrData objectAtIndex:index];
        //view + button
        UIView *viewCompany = [[UIView alloc] initWithFrame:CGRectMake((index % 2) * (SCREEN_WIDTH / 2), 0, SCREEN_WIDTH / 2, 80)];
        UIButton *btnCompany = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, VIEW_W(viewCompany), VIEW_H(viewCompany))];
        [btnCompany setTag:index];
        [btnCompany addTarget:self action:@selector(CpBrandClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:viewCompany];
        [viewCompany addSubview:btnCompany];
        //获取logo
        UIImageView *imgLogo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 10, VIEW_W(viewCompany) / 3, (VIEW_W(viewCompany) / 3) * 0.9)];
        //居中显示
        [imgLogo setCenter:CGPointMake(btnCompany.center.x, imgLogo.center.y)];
        if ([[oneCompanyData objectForKey:@"Logo"] length] > 0) {
            NSString *path = [NSString stringWithFormat:@"%d",([[oneCompanyData objectForKey:@"ID"] intValue] / 10000 + 1) * 10000];
            NSInteger lastLength = 6 - path.length;
            for (int i = 0; i < lastLength; i++) {
                path = [NSString stringWithFormat:@"0%@",path];
            }
            path = [NSString stringWithFormat:@"L%@",path];
            path = [NSString stringWithFormat:@"http://down.51rc.com/imagefolder/wutongguo/CpBrand/%@/%@",path,[oneCompanyData objectForKey:@"Logo"]];
            [imgLogo sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:[UIImage imageNamed:@"coNoSchoolLogo.png"]];
        }
        else {
            [imgLogo setImage:[UIImage imageNamed:@"coNoSchoolLogo.png"]];
        }
        [viewCompany addSubview:imgLogo];
        //企业名称的最大宽度
        float widthForLabel = VIEW_W(viewCompany) - ([[oneCompanyData objectForKey:@"IsShen"] isEqualToString:@"0"] ? 20 : 30);
        CustomLabel *lbCompany = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(10, VIEW_BY(imgLogo) + 5, widthForLabel, 20) content:[oneCompanyData objectForKey:@"Name"] size:14 color:nil];
        CGRect frameLbCompany = lbCompany.frame;
        frameLbCompany.origin.x += (widthForLabel - frameLbCompany.size.width) / 2;
        [lbCompany setFrame:frameLbCompany];
        [viewCompany addSubview:lbCompany];
        //网申图标
        if ([[oneCompanyData objectForKey:@"IsShen"] isEqualToString:@"1"]) {
            UIImageView *imgApply = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_BX(lbCompany) + 1, VIEW_Y(lbCompany), 20, 20)];
            [imgApply setImage:[UIImage imageNamed:@"coHasApply.png"]];
            [viewCompany addSubview:imgApply];
        }
        //行业
        CustomLabel *lbIndustry = [[CustomLabel alloc] initWithFrame:CGRectMake(0, VIEW_BY(lbCompany), VIEW_W(viewCompany), 20) content:[oneCompanyData objectForKey:@"DCIndustryName"] size:12 color:TEXTGRAYCOLOR];
        [lbIndustry setTextAlignment:NSTextAlignmentCenter];
        [viewCompany addSubview:lbIndustry];
        //排名
        if (![self.top500TypeId isEqualToString:@"0"]) {
            CustomLabel *lbRank = [[CustomLabel alloc] initWithFrame:CGRectMake((VIEW_W(viewCompany) - 70) / 2, VIEW_BY(lbIndustry), 70, 20) content:[NSString stringWithFormat:@"No.%@", [oneCompanyData objectForKey:@"OrderNo"]] size:12 color:NAVBARCOLOR];
            [lbRank setTextAlignment:NSTextAlignmentCenter];
            [lbRank.layer setBorderColor:[NAVBARCOLOR CGColor]];
            [lbRank.layer setBorderWidth:1];
            [lbRank.layer setCornerRadius:3];
            [viewCompany addSubview:lbRank];
            maxCellHeight = VIEW_BY(lbRank) + 10;
        }
        else {
            maxCellHeight = VIEW_BY(lbIndustry) + 10;
        }
    }
    //加边框
    UIView *borderBottom = [[UIView alloc] initWithFrame:CGRectMake(0, maxCellHeight - 1, SCREEN_WIDTH, 0.5)];
    [borderBottom setBackgroundColor:SEPARATECOLOR];
    [cell.contentView addSubview:borderBottom];
    
    UIView *borderRight = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2, 0, 0.5, maxCellHeight)];
    [borderRight setBackgroundColor:SEPARATECOLOR];
    [cell.contentView  addSubview:borderRight];
    [cell setFrame:CGRectMake(0, 0, SCREEN_WIDTH, maxCellHeight)];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:false];
}

- (void)CpBrandClick:(UIButton *)sender {
    NSDictionary *cpBrandData = [self.arrData objectAtIndex:sender.tag];
    CpBrandViewController *cpBrandCtrl = [[CpBrandViewController alloc] init];
    cpBrandCtrl.secondId = [cpBrandData objectForKey:@"SecondID"];
    cpBrandCtrl.title = @"500强";
    [self.navigationController pushViewController:cpBrandCtrl animated:YES];
}

- (void)searchClick {
    if (self.fromSearch) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        SearchViewController *viewSearch = [self.storyboard instantiateViewControllerWithIdentifier:@"searchView"];
        viewSearch.searchType = 5;
        [self.navigationController pushViewController:viewSearch animated:true];
    }
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1) {
        [self.loadingView stopAnimating];
        if (self.page == 1) {
            [self.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
            [self.arrData removeAllObjects];
        }
        [self.arrData addObjectsFromArray:[CommonFunc getArrayFromXml:requestData tableName:@"dtBrand"]];
        [self.tableView reloadData];
        [self.tableView footerEndRefreshing];
        [self.viewNoList popupClose];
        if (self.arrData.count == 0) {
            if (self.viewNoList == nil) {
                self.viewNoList = [[PopupView alloc] initWithNoListTips:self.tableView tipsMsg:@"<div style=\"text-align:center\"><p style=\"font-size:16px;\">抱歉，同学</p><p>当前条件下没有找到您想要的企业信息</p></div>"];
            }
            [self.tableView addSubview:self.viewNoList];
        }
    }
    else {
        NSArray *arrContent = [CommonFunc getArrayFromXml:requestData tableName:@"Table"];
        NSString *shareContent = [[arrContent objectAtIndex:0] objectForKey:@"ContentText"];
        NSString *shareContent2 = [[arrContent objectAtIndex:0] objectForKey:@"ContentText2"];
        NSString *shareTitle = [[arrContent objectAtIndex:0] objectForKey:@"Title"];
        NSMutableArray *urlParam = [[NSMutableArray alloc] init];
        if (![self.top500TypeId isEqualToString:@"0"]) {
            [urlParam addObject:[NSString stringWithFormat:@"t%@", self.top500TypeId]];
        }
        if (![self.industryId isEqualToString:@"0"]) {
            [urlParam addObject:[NSString stringWithFormat:@"i%@", self.industryId]];
        }
        NSString *url = [NSString stringWithFormat:@"/500qiang/%@", [urlParam componentsJoinedByString:@"_"]];
        [CommonFunc share:shareTitle content:shareContent url:url view:self.view imageUrl:@"" content2:shareContent2];
    }
}

- (void)footerRereshing{
    self.page++;
    [self getData];
}

- (IBAction)industryClick:(UIButton *)sender {
    [self.viewPopup popupClose];
    if (sender.tag == 0) {
        self.viewPopup.noRequired = YES;
        self.viewPopup = [[PopupView alloc] initWithArray:sender parentView:self.view array:[CommonFunc getDataFromDB:@"select * from dcIndustry"] required:NO];
        [self.viewPopup setTag:1];
        [self.viewPopup setDefaultWithLv1:self.industryId];
        [self.viewPopup setDelegate:self];
        [self.view.window addSubview:self.viewPopup];
        [self.viewPopup setDefaultWithLv1:self.industryId];
        [self resetFilter];
        [self.imgIndustry setImage:[UIImage imageNamed:@"coUpArrow.png"]];
        [sender setTag:1];
    }
    else {
        [self.imgIndustry setImage:[UIImage imageNamed:@"coDownArrow.png"]];
        [sender setTag:0];
    }
}

- (IBAction)top500TypeClick:(UIButton *)sender {
    [self.viewPopup popupClose];
    if (sender.tag == 0) {
        self.viewPopup = [[PopupView alloc] initWithArray:sender parentView:self.view array:[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"0", @"id", @"全部", @"name", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"1", @"id", @"财富世界500强", @"name", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"2", @"id", @"财富中国500强", @"name", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"3", @"id", @"中国企业500强", @"name", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"4", @"id", @"中国民营企业500强", @"name", nil], nil] required:YES];
        [self.viewPopup setTag:2];
        [self.viewPopup setDefaultWithLv1:self.top500TypeId];
        [self.viewPopup setDelegate:self];
        [self.view.window addSubview:self.viewPopup];
        [self.viewPopup setDefaultWithLv1:self.top500TypeId];
        [self resetFilter];
        [self.imgTop500Type setImage:[UIImage imageNamed:@"coUpArrow.png"]];
        [sender setTag:1];
    }
    else {
        [self.imgTop500Type setImage:[UIImage imageNamed:@"coDownArrow.png"]];
        [sender setTag:0];
    }
}

- (void)itemDidSelected:(id)value {
    NSDictionary *dicValue = (NSDictionary *)value;
    if (self.viewPopup.tag == 1) {
        [self.lbIndustry setText:([[dicValue objectForKey:@"id"] isEqual: @"0"] ? @"所属行业" : [dicValue objectForKey:@"name"])];
        self.industryId = [dicValue objectForKey:@"id"];
    }
    else if (self.viewPopup.tag == 2) {
        [self.lbTop500Type setText:([[dicValue objectForKey:@"id"] isEqualToString:@"0"] ? @"500强分类" : [dicValue objectForKey:@"name"])];
        self.top500TypeId = [dicValue objectForKey:@"id"];
    }
    [self resetFilter];
    self.page = 1;
    [self getData];
}

- (void)closePopupWhenTapArrow {
    [self resetFilter];
}

- (void)resetFilter {
    [self.imgIndustry setImage:[UIImage imageNamed:@"coDownArrow.png"]];
    [self.imgTop500Type setImage:[UIImage imageNamed:@"coDownArrow.png"]];
    
    [self.btnIndustry setTag:0];
    [self.btnTop500Type setTag:0];
}

- (void)shareClick {
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetShareTitle" params:[NSDictionary dictionaryWithObjectsAndKeys:@"106", @"pageID", @"", @"id", nil] tag:2];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

@end

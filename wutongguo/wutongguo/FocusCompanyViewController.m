//
//  FocusCompanyViewController.m
//  wutongguo
//
//  Created by Lucifer on 15/5/31.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "FocusCompanyViewController.h"
#import "CommonMacro.h"
#import "CommonFunc.h"
#import "CustomLabel.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "GDataXMLNode.h"
#import "MJRefresh.h"
#import "CompanyViewController.h"
#import "PopupView.h"

@interface FocusCompanyViewController ()<NetWebServiceRequestDelegate, UITableViewDataSource, UITableViewDelegate, PopupViewDelegate>

@property (nonatomic, strong) PopupView *viewNoList;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;
@property (nonatomic, strong) NSMutableArray *arrData;
@property (nonatomic, strong) NSMutableArray *arrIndustryData;
@property (nonatomic, strong) NSMutableArray *arrBrochureData;
@property (nonatomic, strong) NSMutableArray *arrCampusData;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic) NSInteger page;
@property (nonatomic) NSInteger selectedRow;
@end

@implementation FocusCompanyViewController

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
    self.arrIndustryData = [[NSMutableArray alloc] init];
    self.arrBrochureData = [[NSMutableArray alloc] init];
    self.arrCampusData = [[NSMutableArray alloc] init];
    self.page = 1;
    [self getData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getData {
    [self.loadingView startAnimating];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetPaAttentionByAppPaMainID" params:[NSDictionary dictionaryWithObjectsAndKeys:[CommonFunc getPaMainId], @"paMainID", [NSString stringWithFormat:@"%ld", (long)self.page], @"pageNo", @"1", @"attentionType", [CommonFunc getCode], @"code", nil] tag:1];
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
    NSDictionary *companyData = [self.arrData objectAtIndex:indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellView"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellView"];
    }
    [cell setSelected:NO];
    for(UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setBackgroundColor:[UIColor whiteColor]];
    CGRect frameCompany = CGRectMake(-0.5, 0, SCREEN_WIDTH + 1, 40);
    UIButton *btnCompany = [[UIButton alloc] initWithFrame:frameCompany];
    [btnCompany setBackgroundColor:UIColorWithRGBA(249, 250, 251, 1)];
    [btnCompany setTag:indexPath.section];
    [btnCompany addTarget:self action:@selector(companyClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnCompany.layer setBorderColor:[SEPARATECOLOR CGColor]];
    [btnCompany.layer setBorderWidth:0.5];
    [cell.contentView addSubview:btnCompany];
    //绿色竖形条
    UIView *viewTips = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 5, 20)];
    [viewTips setBackgroundColor:NAVBARCOLOR];
    [btnCompany addSubview:viewTips];
    float widthForLabel = SCREEN_WIDTH - VIEW_BX(viewTips) - 90;
    //公司名称
    CustomLabel *lbCompany = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(viewTips) + 5, VIEW_Y(viewTips), widthForLabel, 20) content:[companyData objectForKey:@"Name"] size:14 color:UIColorWithRGBA(20, 62, 103, 1)];
    [btnCompany addSubview:lbCompany];
    //行业、企业性质
    NSMutableString *industry = [[NSMutableString alloc] init];
    NSArray *arrIndustry = [CommonFunc getArrayFromArrayWithSelect:self.arrIndustryData param:[NSArray arrayWithObject:[NSDictionary dictionaryWithObject:[companyData objectForKey:@"CpMainID"] forKey:@"CpMainiD"]]];
    for (NSDictionary *oneIndustry in arrIndustry) {
        [industry appendFormat:@"%@ ", [oneIndustry objectForKey:@"Name"]];
    }
    CustomLabel *lbIndustry = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbCompany), VIEW_BY(lbCompany) + 5, widthForLabel, 20) content:[NSString stringWithFormat:@"%@ | %@", [companyData objectForKey:@"DcCompanyKindName"], industry] size:12 color:TEXTGRAYCOLOR];
    [btnCompany addSubview:lbIndustry];
    frameCompany.size.height = VIEW_BY(lbIndustry) + 10;
    [btnCompany setFrame:frameCompany];
    //关注
    UIButton *btnFocus = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 80, 0, 80, VIEW_H(btnCompany))];
    [btnFocus setTag:indexPath.section];
    [btnFocus addTarget:self action:@selector(favoriteClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnCompany addSubview:btnFocus];
    UIImageView *imgFocus = [[UIImageView alloc] initWithFrame:CGRectMake(23, 12, 26, 26)];
    [imgFocus setImage:[UIImage imageNamed:@"coFavorite.png"]];
    [btnFocus addSubview:imgFocus];
    CustomLabel *lbFocus = [[CustomLabel alloc] initWithFrame:CGRectMake(0, VIEW_BY(imgFocus), VIEW_W(btnFocus), 20) content:[NSString stringWithFormat:@"%@关注", [CommonFunc stringFromDateString:[companyData objectForKey:@"AddDate"] formatType:@"yyyy-M-d"]] size:10 color:TEXTGRAYCOLOR];
    [btnFocus addSubview:lbFocus];
    float heightForCell = VIEW_BY(btnCompany);
    //招聘简章
    NSArray *arrCpBrochureDataWithCpMainID = [CommonFunc getArrayFromArrayWithSelect:self.arrBrochureData param:[NSArray arrayWithObject:[NSDictionary dictionaryWithObject:[companyData objectForKey:@"CpMainID"] forKey:@"CpMainID"]]];
    if (arrCpBrochureDataWithCpMainID.count > 0) {
        UIView *viewBrochure = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_BY(btnCompany), SCREEN_WIDTH, 500)];
        [viewBrochure setBackgroundColor:[UIColor whiteColor]];
        //招聘简章前面的小圆点
        UIImageView *imgBrochureTips = [[UIImageView alloc] initWithFrame:CGRectMake(10, 15, 10, 10)];
        [imgBrochureTips setImage:[UIImage imageNamed:@"coEmptyCircle.png"]];
        [viewBrochure addSubview:imgBrochureTips];
        CustomLabel *lbBrochureTitle = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgBrochureTips) + 5, 10, SCREEN_WIDTH - 20, 20) content:@"发布的招聘简章" size:12 color:TEXTGRAYCOLOR];
        [viewBrochure addSubview:lbBrochureTitle];
        float heightForBrochure = VIEW_BY(lbBrochureTitle) + 10;
        for (int index = 0; index < arrCpBrochureDataWithCpMainID.count; index++) {
            NSDictionary *cpBrochureData = [arrCpBrochureDataWithCpMainID objectAtIndex:index];
            //招聘简章按钮
            UIButton *btnBrochure = [[UIButton alloc] initWithFrame:CGRectMake(0, heightForBrochure, VIEW_W(viewBrochure), 30)];
            [btnBrochure setTag:index];
            [btnBrochure setTitle:[NSString stringWithFormat:@"%ld", (long)indexPath.section] forState:UIControlStateNormal];
            [btnBrochure setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
            [btnBrochure addTarget:self action:@selector(brochureClick:) forControlEvents:UIControlEventTouchUpInside];
            [viewBrochure addSubview:btnBrochure];
            //招聘简章标题
            CustomLabel *lbBrochure = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(15, 5, VIEW_W(viewBrochure) - 110, 20) content:[cpBrochureData objectForKey:@"Title"] size:13 color:UIColorWithRGBA(20, 62, 103, 1)];
            [btnBrochure addSubview:lbBrochure];
            //招聘简章时间
            CustomLabel *lbDate = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_W(btnBrochure) - 95, VIEW_Y(lbBrochure), 90, 20) content:[NSString stringWithFormat:@"%@发布", [CommonFunc stringFromDateString:[cpBrochureData objectForKey:@"IssueDate"] formatType:@"yyyy-M-d"]] size:12 color:TEXTGRAYCOLOR];
            [btnBrochure addSubview:lbDate];
            heightForBrochure = VIEW_BY(btnBrochure) + 5;
        }
        //招聘简章高度重置
        CGRect frameBrochure = viewBrochure.frame;
        frameBrochure.size.height = heightForBrochure;
        [viewBrochure setFrame:frameBrochure];
        [cell.contentView addSubview:viewBrochure];
        //cell高度
        heightForCell = VIEW_BY(viewBrochure);
    }
    //宣讲会
    NSArray *arrCampusDataWithCpMainID = [CommonFunc getArrayFromArrayWithSelect:self.arrCampusData param:[NSArray arrayWithObject:[NSDictionary dictionaryWithObject:[companyData objectForKey:@"CpMainID"] forKey:@"CpMainID"]]];
    if (arrCampusDataWithCpMainID.count > 0) {
        UIView *viewSparate;
        if (arrCpBrochureDataWithCpMainID.count > 0) {
            //分割线
            viewSparate = [[UIView alloc] initWithFrame:CGRectMake(10, heightForCell, SCREEN_WIDTH - 20, 0.5)];
            [viewSparate setBackgroundColor:SEPARATECOLOR];
            [cell.contentView addSubview:viewSparate];
        }
        UIView *viewCampus = [[UIView alloc] initWithFrame:CGRectMake(0, (viewSparate == nil ? heightForCell : VIEW_BY(viewSparate)), SCREEN_WIDTH, 500)];
        [viewCampus setBackgroundColor:[UIColor whiteColor]];
        //前面的小圆点
        UIImageView *imgCampusTips = [[UIImageView alloc] initWithFrame:CGRectMake(10, 15, 10, 10)];
        [imgCampusTips setImage:[UIImage imageNamed:@"coEmptyCircle.png"]];
        [viewCampus addSubview:imgCampusTips];
        CustomLabel *lbCampusTitle = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgCampusTips) + 5, 10, SCREEN_WIDTH - 20, 20) content:@"发布的宣讲会" size:12 color:TEXTGRAYCOLOR];
        [viewCampus addSubview:lbCampusTitle];
        float heightForCampus = VIEW_BY(lbCampusTitle) + 5;
        for (int index = 0; index < MIN(arrCampusDataWithCpMainID.count, 2); index++) {
            NSDictionary *campusData = [arrCampusDataWithCpMainID objectAtIndex:index];
            //宣讲会按钮
            CGRect frameCampus = CGRectMake(0, heightForCampus, VIEW_W(viewCampus), 45);
            UIButton *btnCampus = [[UIButton alloc] initWithFrame:frameCampus];
            [btnCampus setTag:indexPath.section];
            [btnCampus addTarget:self action:@selector(campusClick:) forControlEvents:UIControlEventTouchUpInside];
            [viewCampus addSubview:btnCampus];
            //宣讲会时间 日期
            NSDate *today = [[NSDate alloc] init];
            NSDate *endDate = [CommonFunc dateFromString:[campusData objectForKey:@"EndDate"]];
            NSDate *tomorrow;
            UIColor *dateColor;
            NSTimeInterval secondsPerDay = 24 * 60 * 60;
            tomorrow = [today dateByAddingTimeInterval: secondsPerDay];
            NSString *todayString = [[today description] substringToIndex:10];
            NSString *tomorrowString = [[tomorrow description] substringToIndex:10];
            NSString *dateString = [[endDate description] substringToIndex:10];
            NSString *content = @"";
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
            CustomLabel *lbDate = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(15, 5, 100, 20) content:content size:14 color:dateColor];
            [btnCampus addSubview:lbDate];
            //宣讲会时间 星期+时分
            content = [NSString stringWithFormat:@"（%@）%@-%@", [CommonFunc getWeek:[campusData objectForKey:@"EndDate"]], [CommonFunc stringFromDateString:[campusData objectForKey:@"BeginDate"] formatType:@"HH:mm"], [CommonFunc stringFromDateString:[campusData objectForKey:@"EndDate"] formatType:@"HH:mm"]];
            CustomLabel *lbTime = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(lbDate) + 3, VIEW_Y(lbDate), 200, 20) content:content size:12 color:TEXTGRAYCOLOR];
            [btnCampus addSubview:lbTime];
            //宣讲会地点 地区学校
            content = [NSString stringWithFormat:@"[%@] %@", [campusData objectForKey:@"FullName"], [campusData objectForKey:@"SchoolName"]];
            CustomLabel *lbSchool = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbDate), VIEW_BY(lbDate) + 5, 200, 20) content:content size:12 color:nil];
            [btnCampus addSubview:lbSchool];
            //宣讲会地点 地标图片
            UIImageView *imgMap = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_BX(lbSchool) + 1, VIEW_Y(lbSchool) + 3, 15, 15)];
            [imgMap setImage:[UIImage imageNamed:@"coMap.png"]];
            [btnCampus addSubview:imgMap];
            //宣讲会地点 详细地址
            content = [campusData objectForKey:@"Address"];
            CustomLabel *lbAddress = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgMap) + 1, VIEW_Y(lbSchool), SCREEN_WIDTH - VIEW_BX(imgMap) - 10, 20) content:content size:12 color:TEXTGRAYCOLOR];
            [btnCampus addSubview:lbAddress];
            frameCampus.size.height = VIEW_BY(lbAddress) + 5;
            [btnCampus setFrame:frameCampus];
            heightForCampus = VIEW_BY(btnCampus) + 5;
        }
        //宣讲会高度重置
        CGRect frameCampus = viewCampus.frame;
        frameCampus.size.height = heightForCampus;
        [viewCampus setFrame:frameCampus];
        [cell.contentView addSubview:viewCampus];
        //显示查看更多
        if (arrCampusDataWithCpMainID.count > 2) {
            //分割线
            UIView *viewSparateMore = [[UIView alloc] initWithFrame:CGRectMake(10, heightForCampus, SCREEN_WIDTH - 20, 0.5)];
            [viewSparateMore setBackgroundColor:SEPARATECOLOR];
            [viewCampus addSubview:viewSparateMore];
            //查看更多
            UIButton *btnMore = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_X(viewSparateMore), VIEW_BY(viewSparateMore) + 5, VIEW_W(viewSparateMore), 35)];
            [btnMore setTitle:@"查看该企业更多宣讲会…" forState:UIControlStateNormal];
            [btnMore setTitleColor:TEXTGRAYCOLOR forState:UIControlStateNormal];
            [btnMore.titleLabel setFont:FONT(12)];
            [btnMore setTag:indexPath.section];
            [btnMore addTarget:self action:@selector(campusClick:) forControlEvents:UIControlEventTouchUpInside];
            [viewCampus addSubview:btnMore];
            //宣讲会高度重置
            CGRect frameCampus = viewCampus.frame;
            frameCampus.size.height = VIEW_BY(btnMore) + 5;
            [viewCampus setFrame:frameCampus];
            [cell.contentView addSubview:viewCampus];
        }
        //cell高度
        heightForCell = VIEW_BY(viewCampus);
    }
    //更改cell的高度
    [cell setFrame:CGRectMake(0, 0, SCREEN_WIDTH, heightForCell)];
    [cell.contentView addSubview:[[CustomLabel alloc] initSeparate:cell]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)footerRereshing{
    self.page++;
    [self getData];
}

- (void)favoriteClick:(UIButton *)sender {
    self.selectedRow = sender.tag;
    PopupView *alert = [[PopupView alloc] initWithWarningAlert:self.view title:@"提示" content:@"同学，你确定要取消关注该企业吗？" okMsg:@"确定取消关注" cancelMsg:@"我点错啦"];
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
            [self.arrIndustryData removeAllObjects];
            [self.arrBrochureData removeAllObjects];
            [self.arrCampusData removeAllObjects];
        }
        [self.arrData addObjectsFromArray:[CommonFunc getArrayFromXml:requestData tableName:@"Table"]];
        [self.arrIndustryData addObjectsFromArray:[CommonFunc getArrayFromXml:requestData tableName:@"Table1"]];
        [self.arrBrochureData addObjectsFromArray:[CommonFunc getArrayFromXml:requestData tableName:@"Table2"]];
        [self.arrCampusData addObjectsFromArray:[CommonFunc getArrayFromXml:requestData tableName:@"Table3"]];
        [self.tableView reloadData];
        [self.tableView footerEndRefreshing];
        [self.viewNoList popupClose];
        if (self.arrData.count == 0) {
            if (self.viewNoList == nil) {
                self.viewNoList = [[PopupView alloc] initWithNoListTips:self.tableView tipsMsg:@"<div style=\"text-align:center; font-size:14px;\"><p>同学，您尚未关注过任何企业，去搜索并关注感兴趣的企业，果儿会为您推送企业最新校招动态！</p></div>"];
            }
            [self.tableView addSubview:self.viewNoList];
        }
    }
    else if (request.tag == 2) {
        self.page = 1;
        [self getData];
    }
}

- (void)brochureClick:(UIButton *)sender {
    NSDictionary *companyData = [self.arrData objectAtIndex:[sender.titleLabel.text intValue]];
    NSArray *arrCpBrochureDataWithCpMainID = [CommonFunc getArrayFromArrayWithSelect:self.arrBrochureData param:[NSArray arrayWithObject:[NSDictionary dictionaryWithObject:[companyData objectForKey:@"CpMainID"] forKey:@"CpMainID"]]];
    NSDictionary *cpBrochureData = [arrCpBrochureDataWithCpMainID objectAtIndex:sender.tag];
    CompanyViewController *companyCtrl = [[CompanyViewController alloc] init];
    companyCtrl.secondId = [cpBrochureData objectForKey:@"CpSecondID"];
    companyCtrl.cpBrochureSecondId = [cpBrochureData objectForKey:@"SecondID"];
    companyCtrl.tabIndex = 1;
    [self.navigationController pushViewController:companyCtrl animated:YES];
}

- (void)campusClick:(UIButton *)sender {
    NSDictionary *companyData = [self.arrData objectAtIndex:sender.tag];
    CompanyViewController *companyCtrl = [[CompanyViewController alloc] init];
    companyCtrl.secondId = [companyData objectForKey:@"CpSecondID"];
    companyCtrl.tabIndex = 2;
    [self.navigationController pushViewController:companyCtrl animated:YES];
}

- (void)companyClick:(UIButton *)sender {
    NSDictionary *companyData = [self.arrData objectAtIndex:sender.tag];
    CompanyViewController *companyCtrl = [[CompanyViewController alloc] init];
    companyCtrl.secondId = [companyData objectForKey:@"CpSecondID"];
    [self.navigationController pushViewController:companyCtrl animated:YES];
}

@end

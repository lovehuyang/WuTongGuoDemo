//
//  FocusSchoolViewController.m
//  wutongguo
//
//  Created by Lucifer on 15/5/31.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "FocusSchoolViewController.h"
#import "CommonMacro.h"
#import "CommonFunc.h"
#import "CustomLabel.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "GDataXMLNode.h"
#import "MJRefresh.h"
#import "SchoolViewController.h"
#import "PopupView.h"
#import "UIImageView+WebCache.h"
#import "CompanyViewController.h"

@interface FocusSchoolViewController ()<NetWebServiceRequestDelegate, UITableViewDataSource, UITableViewDelegate, PopupViewDelegate>

@property (nonatomic, strong) PopupView *viewNoList;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;
@property (nonatomic, strong) NSMutableArray *arrData;
@property (nonatomic, strong) NSMutableArray *arrRecruitmentData;
@property (nonatomic, strong) NSMutableArray *arrCampusData;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic) NSInteger page;
@property (nonatomic) NSInteger selectedRow;
@end

@implementation FocusSchoolViewController

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
    self.arrRecruitmentData = [[NSMutableArray alloc] init];
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
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetPaAttentionByAppPaMainID" params:[NSDictionary dictionaryWithObjectsAndKeys:[CommonFunc getPaMainId], @"paMainID", [NSString stringWithFormat:@"%ld", (long)self.page], @"pageNo", @"3", @"attentionType", [CommonFunc getCode], @"code", nil] tag:1];
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
    NSDictionary *schoolData = [self.arrData objectAtIndex:indexPath.section];
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
    CGRect frameSchool = CGRectMake(-0.5, 0, SCREEN_WIDTH + 1, 50);
    UIButton *btnSchool = [[UIButton alloc] initWithFrame:frameSchool];
    [btnSchool setBackgroundColor:UIColorWithRGBA(249, 250, 251, 1)];
    [btnSchool setTag:indexPath.section];
    [btnSchool addTarget:self action:@selector(schoolClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnSchool.layer setBorderColor:[SEPARATECOLOR CGColor]];
    [btnSchool.layer setBorderWidth:0.5];
    [cell.contentView addSubview:btnSchool];
    UIImageView *imgSchool = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 44, 40)];
    [imgSchool sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://down.51rc.com/imagefolder/wutongguo/Common/school/%@",[schoolData objectForKey:@"Logo"]]] placeholderImage:[UIImage imageNamed:@"coNoSchoolLogo.png"]];
    [btnSchool addSubview:imgSchool];
    float widthForLabel = SCREEN_WIDTH - VIEW_BX(imgSchool) - 90;
    //公司名称
    CustomLabel *lbSchool = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgSchool) + 5, VIEW_Y(imgSchool), widthForLabel, 40) content:[schoolData objectForKey:@"Name"] size:14 color:UIColorWithRGBA(20, 62, 103, 1)];
    [btnSchool addSubview:lbSchool];
    //关注
    UIButton *btnFocus = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 80, 0, 80, VIEW_H(btnSchool))];
    [btnFocus setTag:indexPath.section];
    [btnFocus addTarget:self action:@selector(favoriteClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnSchool addSubview:btnFocus];
    UIImageView *imgFocus = [[UIImageView alloc] initWithFrame:CGRectMake(23, 3, 26, 26)];
    [imgFocus setImage:[UIImage imageNamed:@"coFavorite.png"]];
    [btnFocus addSubview:imgFocus];
    CustomLabel *lbFocus = [[CustomLabel alloc] initWithFrame:CGRectMake(0, VIEW_BY(imgFocus), VIEW_W(btnFocus), 20) content:[NSString stringWithFormat:@"%@关注", [CommonFunc stringFromDateString:[schoolData objectForKey:@"AddDate"] formatType:@"yyyy-M-d"]] size:10 color:TEXTGRAYCOLOR];
    [btnFocus addSubview:lbFocus];
    float heightForCell = VIEW_BY(btnSchool);
    widthForLabel = SCREEN_WIDTH - 20;
    //招聘会
    NSArray *arrRecruitmentDataWithCpMainID = [CommonFunc getArrayFromArrayWithSelect:self.arrRecruitmentData param:[NSArray arrayWithObject:[NSDictionary dictionaryWithObject:[schoolData objectForKey:@"SchoolID"] forKey:@"SchoolID"]]];
    if (arrRecruitmentDataWithCpMainID.count > 0) {
        UIView *viewRecruitment = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_BY(btnSchool), SCREEN_WIDTH, 500)];
        [viewRecruitment setBackgroundColor:[UIColor whiteColor]];
        //招聘会前面的小圆点
        UIImageView *imgRecruitmentTips = [[UIImageView alloc] initWithFrame:CGRectMake(10, 15, 10, 10)];
        [imgRecruitmentTips setImage:[UIImage imageNamed:@"coEmptyCircle.png"]];
        [viewRecruitment addSubview:imgRecruitmentTips];
        CustomLabel *lbRecruitmentTitle = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgRecruitmentTips) + 5, 10, SCREEN_WIDTH - 20, 20) content:@"发布的招聘会" size:12 color:TEXTGRAYCOLOR];
        [viewRecruitment addSubview:lbRecruitmentTitle];
        float heightForRecruitment = VIEW_BY(lbRecruitmentTitle) + 5;
        for (int index = 0; index < arrRecruitmentDataWithCpMainID.count; index++) {
            NSDictionary *recruitmentData = [arrRecruitmentDataWithCpMainID objectAtIndex:index];
            NSString *content = [recruitmentData objectForKey:@"RecruitmentName"];
            float fontSize = 14;
            CGRect frameRecruitment = CGRectMake(0, heightForRecruitment, VIEW_W(viewRecruitment), 50);
            UIButton *btnRecruitment = [[UIButton alloc] initWithFrame:frameRecruitment];
            [btnRecruitment setTag:indexPath.section];
            [btnRecruitment addTarget:self action:@selector(RecruitmentClick:) forControlEvents:UIControlEventTouchUpInside];
            [viewRecruitment addSubview:btnRecruitment];
            //招聘会名称
            CustomLabel *lbCampus = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(15, 5, widthForLabel, 20) content:content size:fontSize color:nil];
            [btnRecruitment addSubview:lbCampus];
            //招聘会时间 日期
            UIColor *dateColor;
            NSDate *endDate = [CommonFunc dateFromString:[recruitmentData objectForKey:@"EndDate"]];
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
            [btnRecruitment addSubview:lbDate];
            //招聘会时间 星期+时分
            content = [NSString stringWithFormat:@"（%@）%@-%@", [CommonFunc getWeek:[recruitmentData objectForKey:@"EndDate"]], [CommonFunc stringFromDateString:[recruitmentData objectForKey:@"BeginDate"] formatType:@"HH:mm"], [CommonFunc stringFromDateString:[recruitmentData objectForKey:@"EndDate"] formatType:@"HH:mm"]];
            fontSize = 12;
            CustomLabel *lbTime = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(lbDate) + 3, VIEW_Y(lbDate), 200, 20) content:content size:fontSize color:TEXTGRAYCOLOR];
            [btnRecruitment addSubview:lbTime];
            //招聘会地点 地区学校
            content = [NSString stringWithFormat:@"[%@] %@", [recruitmentData objectForKey:@"Abbr"], [recruitmentData objectForKey:@"PlaceName"]];
            CustomLabel *lbSchool = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbDate), VIEW_BY(lbDate) + 5, widthForLabel - 10, 20) content:content size:fontSize color:nil];
            [btnRecruitment addSubview:lbSchool];
            //宣讲会地点 地标图片
            UIImageView *imgMap = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_BX(lbSchool) + 1, VIEW_Y(lbSchool) + 3, 15, 15)];
            [imgMap setImage:[UIImage imageNamed:@"coMap.png"]];
            [btnRecruitment addSubview:imgMap];
            frameRecruitment.size.height = VIEW_BY(lbSchool) + 5;
            [btnRecruitment setFrame:frameRecruitment];
            heightForRecruitment = VIEW_BY(btnRecruitment) + 5;
        }
        //招聘会高度重置
        CGRect frameRecruitment = viewRecruitment.frame;
        frameRecruitment.size.height = heightForRecruitment;
        [viewRecruitment setFrame:frameRecruitment];
        [cell.contentView addSubview:viewRecruitment];
        //cell高度
        heightForCell = VIEW_BY(viewRecruitment);
    }
    //宣讲会
    NSArray *arrCampusDataWithCpMainID = [CommonFunc getArrayFromArrayWithSelect:self.arrCampusData param:[NSArray arrayWithObject:[NSDictionary dictionaryWithObject:[schoolData objectForKey:@"SchoolID"] forKey:@"SchoolID"]]];
    if (arrCampusDataWithCpMainID.count > 0) {
        UIView *viewSparate;
        if (arrRecruitmentDataWithCpMainID.count > 0) {
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
        for (int index = 0; index < MIN(arrCampusDataWithCpMainID.count, 3); index++) {
            NSDictionary *campusData = [arrCampusDataWithCpMainID objectAtIndex:index];
            //宣讲会按钮
            CGRect frameCampus = CGRectMake(0, heightForCampus, VIEW_W(viewCampus), 45);
            UIButton *btnCampus = [[UIButton alloc] initWithFrame:frameCampus];
            [btnCampus setTag:indexPath.section];
            [btnCampus setTitle:[campusData objectForKey:@"CpSecondID"] forState:UIControlStateNormal];
            [btnCampus setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
            [btnCampus addTarget:self action:@selector(campusClick:) forControlEvents:UIControlEventTouchUpInside];
            [viewCampus addSubview:btnCampus];
            //宣讲会名称
            CustomLabel *lbCampus = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(15, 5, widthForLabel, 20) content:[campusData objectForKey:@"CpBrandName"] size:14 color:nil];
            [btnCampus addSubview:lbCampus];
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
            CustomLabel *lbDate = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbCampus), VIEW_BY(lbCampus) + 5, 100, 20) content:content size:14 color:dateColor];
            [btnCampus addSubview:lbDate];
            //宣讲会时间 星期+时分
            content = [NSString stringWithFormat:@"（%@）%@-%@", [CommonFunc getWeek:[campusData objectForKey:@"EndDate"]], [CommonFunc stringFromDateString:[campusData objectForKey:@"BeginDate"] formatType:@"HH:mm"], [CommonFunc stringFromDateString:[campusData objectForKey:@"EndDate"] formatType:@"HH:mm"]];
            CustomLabel *lbTime = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(lbDate) + 3, VIEW_Y(lbDate), 200, 20) content:content size:12 color:TEXTGRAYCOLOR];
            [btnCampus addSubview:lbTime];
            //宣讲会地点 详细地址
            content = [campusData objectForKey:@"Address"];
            CustomLabel *lbAddress = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbDate), VIEW_BY(lbDate) + 5, widthForLabel, 20) content:content size:12 color:TEXTGRAYCOLOR];
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
        if (arrCampusDataWithCpMainID.count > 3) {
            //分割线
            UIView *viewSparateMore = [[UIView alloc] initWithFrame:CGRectMake(10, heightForCampus, SCREEN_WIDTH - 20, 0.5)];
            [viewSparateMore setBackgroundColor:SEPARATECOLOR];
            [viewCampus addSubview:viewSparateMore];
            //查看更多
            UIButton *btnMore = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_X(viewSparateMore), VIEW_BY(viewSparateMore) + 5, VIEW_W(viewSparateMore), 35)];
            [btnMore setTitle:@"查看该学校更多宣讲会…" forState:UIControlStateNormal];
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
    PopupView *alert = [[PopupView alloc] initWithWarningAlert:self.view title:@"提示" content:@"同学，你确定要取消关注该学校吗？" okMsg:@"确定取消关注" cancelMsg:@"我点错啦"];
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
            [self.arrRecruitmentData removeAllObjects];
            [self.arrCampusData removeAllObjects];
        }
        [self.arrData addObjectsFromArray:[CommonFunc getArrayFromXml:requestData tableName:@"Table"]];
        [self.arrRecruitmentData addObjectsFromArray:[CommonFunc getArrayFromXml:requestData tableName:@"Table1"]];
        [self.arrCampusData addObjectsFromArray:[CommonFunc getArrayFromXml:requestData tableName:@"Table2"]];
        [self.tableView reloadData];
        [self.tableView footerEndRefreshing];
        [self.viewNoList popupClose];
        if (self.arrData.count == 0) {
            if (self.viewNoList == nil) {
                self.viewNoList = [[PopupView alloc] initWithNoListTips:self.tableView tipsMsg:@"<div style=\"text-align:center; font-size:14px;\"><p>同学，您尚未关注过任何学校，去搜索并关注感兴趣的学校，果儿会为您推送学校最新宣讲会、招聘会！</p></div>"];
            }
            [self.tableView addSubview:self.viewNoList];
        }
    }
    else if (request.tag == 2) {
        self.page = 1;
        [self getData];
    }
}

- (void)RecruitmentClick:(UIButton *)sender {
    NSDictionary *schoolData = [self.arrData objectAtIndex:sender.tag];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SchoolViewController *schoolCtrl = [storyBoard instantiateViewControllerWithIdentifier:@"schoolView"];
    schoolCtrl.schoolId = [[schoolData objectForKey:@"SchoolID"] intValue];
    schoolCtrl.tabIndex = 1;
    [self.navigationController pushViewController:schoolCtrl animated:YES];
}

- (void)campusClick:(UIButton *)sender {
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    if (sender.titleLabel.text.length > 0) {
        CompanyViewController *companyCtrl = [[CompanyViewController alloc] init];
        companyCtrl.secondId = sender.titleLabel.text;
        companyCtrl.tabIndex = 2;
        [self.navigationController pushViewController:companyCtrl animated:YES];
    }
    else {
        NSDictionary *schoolData = [self.arrData objectAtIndex:sender.tag];
        SchoolViewController *schoolCtrl = [storyBoard instantiateViewControllerWithIdentifier:@"schoolView"];
        schoolCtrl.schoolId = [[schoolData objectForKey:@"SchoolID"] intValue];
        schoolCtrl.tabIndex = 0;
        [self.navigationController pushViewController:schoolCtrl animated:YES];
    }
}

- (void)schoolClick:(UIButton *)sender {
    NSDictionary *schoolData = [self.arrData objectAtIndex:sender.tag];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SchoolViewController *schoolCtrl = [storyBoard instantiateViewControllerWithIdentifier:@"schoolView"];
    schoolCtrl.schoolId = [[schoolData objectForKey:@"SchoolID"] intValue];
    schoolCtrl.tabIndex = 0;
    [self.navigationController pushViewController:schoolCtrl animated:YES];
}

@end

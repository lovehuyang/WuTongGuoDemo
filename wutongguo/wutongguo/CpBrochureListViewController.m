//
//  CpBrochureListViewController.m
//  wutongguo
//
//  Created by Lucifer on 15-5-16.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "CpBrochureListViewController.h"
#import "CpBrochureViewController.h"
#import "CompanyViewController.h"
#import "CpBrandViewController.h"
#import "CommonMacro.h"
#import "CommonFunc.h"
#import "CustomLabel.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "GDataXMLNode.h"
#import "PopupView.h"

@interface CpBrochureListViewController ()<NetWebServiceRequestDelegate>

@property (nonatomic, strong) PopupView *viewNoList;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;
@property (nonatomic, strong) NSArray *arrCpBrochureData;
@property (nonatomic, strong) NSDictionary *cpBrandData;
@property (nonatomic, strong) NSArray *arrOtherCpBrochureData;
@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation CpBrochureListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.view addSubview:self.scrollView];
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.view addSubview:self.loadingView];
    [self getData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)getData {
    [self.loadingView startAnimating];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetCpBrochureByCpMainID" params:[NSDictionary dictionaryWithObjectsAndKeys:self.companySecondId, @"cpMainID", [CommonFunc getPaMainId], @"paMainID", [CommonFunc getCode], @"code", nil] tag:1];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (void)fillData {
    UIView *viewBrochure = [[UIView alloc] initWithFrame:CGRectMake(0, 10, SCREEN_WIDTH, 500)];
    [viewBrochure setBackgroundColor:[UIColor whiteColor]];
    [viewBrochure.layer setBorderColor:[SEPARATECOLOR CGColor]];
    [viewBrochure.layer setBorderWidth:0.5];
    float heightForBrochure = 5;
    if (self.arrCpBrochureData.count == 0) {
        heightForBrochure = 50;
    }
    for (int index = 0; index < self.arrCpBrochureData.count; index++) {
        heightForBrochure = heightForBrochure + 5;
        NSDictionary *cpBrochureData = [self.arrCpBrochureData objectAtIndex:index];
        UIButton *btnBrochure = [[UIButton alloc] initWithFrame:CGRectMake(0, heightForBrochure, VIEW_W(viewBrochure), 55)];
        [btnBrochure setTag:index];
        [btnBrochure addTarget:self action:@selector(brochureClick:) forControlEvents:UIControlEventTouchUpInside];
        [viewBrochure addSubview:btnBrochure];
        CustomLabel *lbBrochure = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(10, 5, VIEW_W(viewBrochure) - 10 - 50, 20) content:[cpBrochureData objectForKey:@"Title"] size:14 color:UIColorWithRGBA(20, 62, 103, 1)];
        [btnBrochure addSubview:lbBrochure];
        //简章状态
        UIImageView *imgStatus = [[UIImageView alloc] init];
        NSInteger brochureStatusType = [CommonFunc getCpBrochureStatus:[cpBrochureData objectForKey:@"BrochureStatus"] beginDate:[cpBrochureData objectForKey:@"BeginDate"] endDate:[cpBrochureData objectForKey:@"EndDate"]];
        NSString *statusImg = @"";
        if (brochureStatusType == 2) { //过期
            statusImg = @"coHasExpired.png";
            [imgStatus setFrame:CGRectMake(VIEW_BX(lbBrochure) + 5, VIEW_Y(lbBrochure) + 2, 40, 20)];
        }
        else if (brochureStatusType == 3) { //未开始
            statusImg = @"coNoStart.png";
            [imgStatus setFrame:CGRectMake(VIEW_BX(lbBrochure) + 5, VIEW_Y(lbBrochure), 46, 20)];
        }
        else if (brochureStatusType == 1) { //网申中
            statusImg = @"coHasStart.png";
            [imgStatus setFrame:CGRectMake(VIEW_BX(lbBrochure) + 5, VIEW_Y(lbBrochure), 46, 20)];
        }
        else if (brochureStatusType == 4) { //已暂停
            statusImg = @"coPause.png";
            [imgStatus setFrame:CGRectMake(VIEW_BX(lbBrochure) + 5, VIEW_Y(lbBrochure), 40, 20)];
        }
        [imgStatus setImage:[UIImage imageNamed:statusImg]];
        [btnBrochure addSubview:imgStatus];
        CustomLabel *lbDate = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbBrochure), VIEW_BY(lbBrochure) + 5, VIEW_W(viewBrochure) - 20, 20) content:[NSString stringWithFormat:@"网申起止时间：%@-%@", [CommonFunc stringFromDateString:[cpBrochureData objectForKey:@"BeginDate"] formatType:@"yyyy年M月d日"], [CommonFunc stringFromDateString:[cpBrochureData objectForKey:@"EndDate"] formatType:@"M月d日"]] size:12 color:TEXTGRAYCOLOR];
        [btnBrochure addSubview:lbDate];
        if (index + 1 < self.arrCpBrochureData.count) {
            UIView *viewSparate = [[UIView alloc] initWithFrame:CGRectMake(15, VIEW_BY(btnBrochure) + 5, SCREEN_WIDTH - 30, 0.5)];
            [viewSparate setBackgroundColor:SEPARATECOLOR];
            [viewBrochure addSubview:viewSparate];
            heightForBrochure = VIEW_BY(viewSparate);
        }
        else {
            heightForBrochure = VIEW_BY(btnBrochure) + 10;
        }
    }
    CGRect frameBrochure = viewBrochure.frame;
    frameBrochure.size.height = heightForBrochure;
    [viewBrochure setFrame:frameBrochure];
    [self.scrollView addSubview:viewBrochure];
    //其他企业
    if (self.arrOtherCpBrochureData.count == 0) {
        //设置scrollview的contentsize
        [self.scrollView setContentSize:CGSizeMake(SCREEN_WIDTH, VIEW_BY(viewBrochure) + 10)];
        return;
    }
    UIView *viewOther = [[UIView alloc] initWithFrame:CGRectMake(VIEW_X(viewBrochure), VIEW_BY(viewBrochure) + 10, VIEW_W(viewBrochure), 80)];
    [viewOther setBackgroundColor:[UIColor whiteColor]];
    [viewOther.layer setBorderColor:[SEPARATECOLOR CGColor]];
    [viewOther.layer setBorderWidth:0.5];
    CustomLabel *lbOtherTitle = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(15, 10, VIEW_W(viewOther) - 15 - 15, 20) content:[NSString stringWithFormat:@"%@旗下其他企业招聘简章", [self.cpBrandData objectForKey:@"Name"]] size:12 color:NAVBARCOLOR];
    [viewOther addSubview:lbOtherTitle];
    float heightForViewOther = VIEW_BY(lbOtherTitle) + 5;
    for (int index = 0; index < MIN(self.arrOtherCpBrochureData.count, 5); index++) {
        NSDictionary *otherCpBrochureData = [self.arrOtherCpBrochureData objectAtIndex:index];
        UIButton *btnOther = [[UIButton alloc] initWithFrame:CGRectMake(0, heightForViewOther + 5, VIEW_W(viewOther), 38)];
        [btnOther setTag:index];
        [btnOther addTarget:self action:@selector(companyClick:) forControlEvents:UIControlEventTouchUpInside];
        [viewOther addSubview:btnOther];
        UIImageView *imgPoint = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_X(lbOtherTitle), 15, 8, 8)];
        [imgPoint setImage:[UIImage imageNamed:@"coGreenPoint.png"]];
        [btnOther addSubview:imgPoint];
        CustomLabel *lbOtherCompany = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgPoint) + 5, 9, VIEW_W(viewOther) - VIEW_BX(imgPoint) - 3, 20) content:[otherCpBrochureData objectForKey:@"Title"] size:13 color:nil];
        [btnOther addSubview:lbOtherCompany];
        if (index + 1 < self.arrOtherCpBrochureData.count) {
            UIView *viewOtherSeparate = [[UIView alloc] initWithFrame:CGRectMake(10, VIEW_BY(btnOther) + 5, VIEW_W(viewOther) - 10 * 2, 0.5)];
            [viewOtherSeparate setBackgroundColor:SEPARATECOLOR];
            [viewOther addSubview:viewOtherSeparate];
            heightForViewOther = VIEW_BY(viewOtherSeparate);
        }
        else {
            heightForViewOther = VIEW_BY(btnOther) + 5;
        }
        
    }
    if (self.arrOtherCpBrochureData.count > 5) {
        //查看更多按钮
        UIButton *btnOtherMore = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 100) / 2, heightForViewOther + 5, 100, 30)];
        [btnOtherMore setTitle:@"查看更多" forState:UIControlStateNormal];
        [btnOtherMore.titleLabel setFont:FONT(14)];
        [btnOtherMore setTitleColor:TEXTGRAYCOLOR forState:UIControlStateNormal];
        [btnOtherMore addTarget:self action:@selector(otherCompany:) forControlEvents:UIControlEventTouchUpInside];
        [viewOther addSubview:btnOtherMore];
        heightForViewOther = VIEW_BY(btnOtherMore) + 5;
    }
    CGRect frameOther = viewOther.frame;
    frameOther.size.height = heightForViewOther;
    [viewOther setFrame:frameOther];
    [self.scrollView addSubview:viewOther];
    [self.scrollView setContentSize:CGSizeMake(SCREEN_WIDTH, VIEW_BY(viewOther) + 10)];
}

- (void)brochureClick:(UIButton *)sender {
    NSDictionary *cpBrochureData = [self.arrCpBrochureData objectAtIndex:sender.tag];
    CompanyViewController *companyCtrl = [[CompanyViewController alloc] init];
    companyCtrl.secondId = self.companySecondId;
    companyCtrl.cpBrochureSecondId = [cpBrochureData objectForKey:@"SecondID"];
    companyCtrl.tabIndex = 1;
    [self.navigationController pushViewController:companyCtrl animated:YES];
}

- (void)companyClick:(UIButton *)sender {
    NSDictionary *otherCompanyData = [self.arrOtherCpBrochureData objectAtIndex:sender.tag];
    CompanyViewController *companyCtrl = [[CompanyViewController alloc] init];
    companyCtrl.secondId = [otherCompanyData objectForKey:@"SecondID"];
    companyCtrl.tabIndex = 1;
    [self.navigationController pushViewController:companyCtrl animated:YES];
}

- (void)otherCompany:(UIButton *)sender {
    CpBrandViewController *cpBrandCtrl = [[CpBrandViewController alloc] init];
    cpBrandCtrl.secondId = [self.cpBrandData objectForKey:@"SecondID"];
    cpBrandCtrl.title = [self.cpBrandData objectForKey:@"Name"];
    [self.navigationController pushViewController:cpBrandCtrl animated:YES];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    [self.loadingView stopAnimating];
    if (request.tag == 1) {
        self.arrCpBrochureData = [CommonFunc getArrayFromXml:requestData tableName:@"dtBrochure"];
        self.cpBrandData = [[CommonFunc getArrayFromXml:requestData tableName:@"dtBrand"] objectAtIndex:0];
        self.arrOtherCpBrochureData = [CommonFunc getArrayFromXml:requestData tableName:@"dtOther"];
        [self fillData];
        [self.viewNoList popupClose];
        if (self.arrCpBrochureData.count == 0) {
            if (self.viewNoList == nil) {
                self.viewNoList = [[PopupView alloc] initWithNoListTips:self.scrollView tipsMsg:@"<div style=\"text-align:center\"><p>该企业未发布招聘简章</p><p>已罚他三天不准吃饭</p></div>"];
            }
            [self.scrollView addSubview:self.viewNoList];
        }
    }
}

@end

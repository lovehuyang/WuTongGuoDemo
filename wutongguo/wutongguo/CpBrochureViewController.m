//
//  CpBrochureViewController.m
//  wutongguo
//
//  Created by Lucifer on 15-5-16.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "CpBrochureViewController.h"
#import "CompanyViewController.h"
#import "CommonMacro.h"
#import "CommonFunc.h"
#import "CustomLabel.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "GDataXMLNode.h"
#import "PopupView.h"
#import "CpJobDetailViewController.h"
#import "CpJobListViewController.h"
#import "CpBrochureListViewController.h"

@interface CpBrochureViewController ()<NetWebServiceRequestDelegate, UIWebViewDelegate>

@property (nonatomic, strong) PopupView *viewNoList;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;
@property (nonatomic, strong) NSArray *arrData;
@property (nonatomic, strong) NSArray *arrCpBrochureData;
@property (nonatomic, strong) UIScrollView *scrollView;
@property float heightForView;
@end

@implementation CpBrochureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
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

- (void)getDetailData {
    if (self.secondId == nil) {
        if (self.arrCpBrochureData.count > 0) {
            self.secondId = [[self.arrCpBrochureData objectAtIndex:0] objectForKey:@"SecondID"];
            self.companyCtrl.cpBrochureSecondId = self.secondId;
            NSMutableArray *arrData = [[NSMutableArray alloc] init];
            for (NSDictionary *oneXml in self.arrCpBrochureData) {
                BOOL blnMatch = YES;
                if ([[oneXml objectForKey:@"SecondID"] isEqualToString:self.secondId]) {
                    blnMatch = NO;
                }
                if (blnMatch) {
                    [arrData addObject:oneXml];
                }
            }
            self.arrCpBrochureData = arrData;
        }
        else {
            [self.viewNoList popupClose];
            if (self.viewNoList == nil) {
                self.viewNoList = [[PopupView alloc] initWithNoListTips:self.view tipsMsg:@"<div style=\"text-align:center\"><p>该企业未发布<span style=\"color:#ED7B56\">招聘简章</span></p><p>已罚他三天不准吃饭</p></div>"];
            }
            [self.view addSubview:self.viewNoList];
            return;
        }
    }
    [self.loadingView startAnimating];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetCpBrochureByID" params:[NSDictionary dictionaryWithObjectsAndKeys:self.secondId, @"cpBrochureID", nil] tag:2];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (void)getData {
    [self.loadingView startAnimating];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetCpBrochureByCpMainID" params:[NSDictionary dictionaryWithObjectsAndKeys:self.companySecondId, @"cpMainID", [CommonFunc getPaMainId], @"paMainID", [CommonFunc getCode], @"code", nil] tag:1];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startSynchronous];
}

- (void)fillData {
    if (self.arrCpBrochureData.count == 0) {
        self.heightForView = self.heightForView + 10;
        [self setParentHeight];
        return;
    }
    UIView *viewBrochure = [[UIView alloc] initWithFrame:CGRectMake(0, self.heightForView, SCREEN_WIDTH, 500)];
    [viewBrochure setBackgroundColor:[UIColor whiteColor]];
    [viewBrochure.layer setBorderColor:[SEPARATECOLOR CGColor]];
    [viewBrochure.layer setBorderWidth:0.5];
    float heightForBrochure = 0;
    UILabel *lbBrochureTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    [lbBrochureTitle setFont:[UIFont systemFontOfSize:14]];
    [lbBrochureTitle setText:@"   该公司其他招聘简章"];
    [lbBrochureTitle setTextColor:NAVBARCOLOR];
    [lbBrochureTitle setBackgroundColor:BGCOLOR];
    [viewBrochure addSubview:lbBrochureTitle];
    UILabel *lbJobTitleSeperate = [[UILabel alloc] initWithFrame:CGRectMake(0, VIEW_BY(lbBrochureTitle), SCREEN_WIDTH, 0.5)];
    [lbJobTitleSeperate setBackgroundColor:SEPARATECOLOR];
    [viewBrochure addSubview:lbJobTitleSeperate];
    heightForBrochure = heightForBrochure + 40;
    int brochureCount = 0;
    for (int index = 0; index < self.arrCpBrochureData.count; index++) {
        if (brochureCount > 2) {
            UIButton *btnMoreBrochure = [[UIButton alloc] initWithFrame:CGRectMake(0, heightForBrochure + 5, SCREEN_WIDTH, 20)];
            [btnMoreBrochure.titleLabel setFont:[UIFont systemFontOfSize:14]];
            [btnMoreBrochure setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btnMoreBrochure setTitle:@"查看更多..." forState:UIControlStateNormal];
            [btnMoreBrochure addTarget:self action:@selector(brochureListClick:) forControlEvents:UIControlEventTouchUpInside];
            [viewBrochure addSubview:btnMoreBrochure];
            heightForBrochure = heightForBrochure + 35;
            break;
        }
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
        brochureCount++;
    }
    CGRect frameBrochure = viewBrochure.frame;
    frameBrochure.size.height = heightForBrochure;
    [viewBrochure setFrame:frameBrochure];
    [self.view addSubview:viewBrochure];
    self.heightForView = VIEW_BY(viewBrochure) + 10;
    [self setParentHeight];
}

- (void)setParentHeight {
    self.heightForView = self.heightForView + 40;
    [self.view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.heightForView)];
    [self.companyCtrl.arrayViewHeight replaceObjectAtIndex:0 withObject:[NSNumber numberWithFloat:self.heightForView]];
    [self.companyCtrl setHeight:0];
}

- (void)fillDetailData {
    NSDictionary *cpBrochureData = [self.arrData objectAtIndex:0];
    //招聘简章标题
    CustomLabel *lbTitle = [[CustomLabel alloc] initWithFixed:CGRectMake(20, 25, SCREEN_WIDTH - 40, 5000) content:[cpBrochureData objectForKey:@"Title"] size:14 color:nil];
    [lbTitle setCenter:CGPointMake(SCREEN_WIDTH / 2, lbTitle.center.y)];
    [lbTitle setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:lbTitle];
    //招聘简章起止时间和状态
    NSString *beginYear = [CommonFunc stringFromDateString:[cpBrochureData objectForKey:@"BeginDate"] formatType:@"yyyy"];
    NSString *endYear = [CommonFunc stringFromDateString:[cpBrochureData objectForKey:@"EndDate"] formatType:@"yyyy"];
    CustomLabel *lbDate = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(0, VIEW_BY(lbTitle) + 3, SCREEN_WIDTH - 40, 20) content:[NSString stringWithFormat:@"网申起止时间：%@-%@", [CommonFunc stringFromDateString:[cpBrochureData objectForKey:@"BeginDate"] formatType:@"yyyy年M月d日"], [CommonFunc stringFromDateString:[cpBrochureData objectForKey:@"EndDate"] formatType:[NSString stringWithFormat:@"%@M月d日", ([beginYear isEqualToString:endYear] ? @"" : @"yyyy年")]]] size:12 color:TEXTGRAYCOLOR];
    [self.view addSubview:lbDate];
    //状态
    NSInteger brochureStatusType = [CommonFunc getCpBrochureStatus:[cpBrochureData objectForKey:@"BrochureStatus"] beginDate:[cpBrochureData objectForKey:@"BeginDate"] endDate:[cpBrochureData objectForKey:@"EndDate"]];
    NSString *brochureStatus = @"";
    UIColor *brochureColor;
    if (brochureStatusType == 2) { //过期
        brochureStatus = @"已截止";
        brochureColor = TEXTGRAYCOLOR;
    }
    else if (brochureStatusType == 3) { //未开始
        brochureStatus = @"未开始";
        brochureColor = [UIColor redColor];
    }
    else if (brochureStatusType == 1) { //网申中
        brochureStatus = @"网申中";
        brochureColor = NAVBARCOLOR;
    }
    else if (brochureStatusType == 4) { //已暂停
        brochureStatus = @"已暂停";
        brochureColor = [UIColor redColor];
    }
    CustomLabel *lbStatus = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(lbDate) + 2, VIEW_Y(lbDate), 300, 20) content:[NSString stringWithFormat:@"（%@）", brochureStatus] size:12 color:brochureColor];
    if (VIEW_BX(lbStatus) > SCREEN_WIDTH) {
        [lbStatus setFrame:CGRectMake(0, VIEW_BY(lbDate) + 2, VIEW_W(lbStatus), VIEW_H(lbStatus))];
        [lbStatus setCenter:CGPointMake(SCREEN_WIDTH / 2, lbStatus.center.y)];
        [lbDate setCenter:CGPointMake(SCREEN_WIDTH / 2, lbDate.center.y)];
    }
    else {
        [lbDate setCenter:CGPointMake(SCREEN_WIDTH / 2 - VIEW_W(lbStatus) / 2, lbDate.center.y)];
        [lbStatus setFrame:CGRectMake(VIEW_BX(lbDate) + 2, VIEW_Y(lbDate), VIEW_W(lbStatus), VIEW_H(lbStatus))];
    }
    [self.view addSubview:lbStatus];
    //分割线
    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(15, VIEW_BY(lbStatus) + 10, SCREEN_WIDTH - 30, 1)];
    [viewSeparate setBackgroundColor:SEPARATECOLOR];
    [self.view addSubview:viewSeparate];
    //简介
    NSString *content = [cpBrochureData objectForKey:@"Detail"];
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, VIEW_BY(viewSeparate) + 10, SCREEN_WIDTH - 0, SCREEN_HEIGHT - (VIEW_BY(viewSeparate) + 10) - TAB_TAB_HEIGHT - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT * 2)];
    [webView setDelegate:self];
    [(UIScrollView *)[webView.subviews objectAtIndex:0] setBounces:NO];
    [webView loadHTMLString:[NSString stringWithFormat:@"<style>body{font-size:12px;}table{border-left:1px solid #000;border-top:1px solid #000; width:100%%} table td{border-right:1px solid #000;border-bottom:1px solid #000;} </style>%@", content] baseURL:nil];
    [self.view addSubview:webView];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    NSString *height_str= [webView stringByEvaluatingJavaScriptFromString: @"document.body.offsetHeight"];
    int height = [height_str intValue];
    webView.frame = CGRectMake(VIEW_X(webView), VIEW_Y(webView), VIEW_W(webView), height + 25);
    self.heightForView = VIEW_BY(webView);
    [self fillData];
}

- (void)jobListClick:(UIButton *)sender {
    NSDictionary *cpBrochureData = [self.arrData objectAtIndex:0];
    CpJobListViewController *jobListCtrl = [[CpJobListViewController alloc] init];
    jobListCtrl.secondId = self.secondId;
    jobListCtrl.title = [cpBrochureData objectForKey:@"CpName"];
    [self.navigationController pushViewController:jobListCtrl animated:YES];
}

- (void)brochureListClick:(UIButton *)sender {
    NSDictionary *cpBrochureData = [self.arrData objectAtIndex:0];
    CpBrochureListViewController *brochureListCtrl = [[CpBrochureListViewController alloc] init];
    brochureListCtrl.companySecondId = self.companySecondId;
    brochureListCtrl.title = [cpBrochureData objectForKey:@"CpName"];
    [self.navigationController pushViewController:brochureListCtrl animated:YES];
}

- (void)brochureClick:(UIButton *)sender {
    NSDictionary *cpBrochureData = [self.arrCpBrochureData objectAtIndex:sender.tag];
    CompanyViewController *companyCtrl = [[CompanyViewController alloc] init];
    companyCtrl.secondId = self.companySecondId;
    companyCtrl.cpBrochureSecondId = [cpBrochureData objectForKey:@"SecondID"];
    companyCtrl.tabIndex = 1;
    [self.navigationController pushViewController:companyCtrl animated:YES];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    [self.loadingView stopAnimating];
    if (request.tag == 1) {
        self.arrCpBrochureData = [CommonFunc getArrayFromXml:requestData tableName:@"dtBrochure"];
        NSMutableArray *arrData = [[NSMutableArray alloc] init];
        for (NSDictionary *oneXml in self.arrCpBrochureData) {
            BOOL blnMatch = YES;
            if ([[oneXml objectForKey:@"SecondID"] isEqualToString:self.secondId]) {
                blnMatch = NO;
            }
            if (blnMatch) {
                [arrData addObject:oneXml];
            }
        }
        self.arrCpBrochureData = arrData;
        [self getDetailData];
    }
    else if (request.tag == 2) {
        [self.loadingView stopAnimating];
        self.arrData = [CommonFunc getArrayFromXml:requestData tableName:@"Table"];
        [self fillDetailData];
    }
}

@end

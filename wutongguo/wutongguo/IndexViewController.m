//
//  IndexViewController.m
//  wutongguo
//
//  Created by Lucifer on 15-5-4.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//  首页页面

#import "IndexViewController.h"
#import "JobListViewController.h"
#import "NetWebServiceRequest.h"
#import "ApplyLogViewController.h"
#import "CommonFunc.h"
#import "CommonMacro.h"
#import "PopupView.h"
#import "LoadingAnimationView.h"
#import "CustomLabel.h"
#import "NoticeListViewController.h"
#import "FocusViewController.h"
#import "LikeListViewController.h"
#import "HelpViewController.h"
#import "UIImageView+WebCache.h"
#import "CompanyViewController.h"
#import "SearchViewController.h"
#import "NewsAnalysisViewController.h"
#import "ApplySpeedUpIntroduceController.h"
@interface IndexViewController () <NetWebServiceRequestDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;
@property (nonatomic, strong) UIScrollView         *viewScroll;
@property (nonatomic, strong) UIScrollView         *viewSwitchImg;
@property (nonatomic, strong) UIPageControl        *pageControl;
@property (nonatomic, strong) NSArray              *arrHeadImage;
@property (nonatomic, strong) UIView               *viewBottom;
@property (nonatomic, strong) UIView               *viewBrochure;
@property (nonatomic, strong) UIView               *viewNewsAnalysis;
@property (nonatomic, strong) NSTimer              *timerImgScroll;
@property (nonatomic, strong) NSArray              *arrJobData;
@property (nonatomic, strong) NSArray              *arrCpBrochureData;
@property (nonatomic, strong) NSArray              *arrRegionData;
@end

@implementation IndexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    //加载动画
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.view addSubview:self.loadingView];
    //导航栏 左边
    UIImageView *imgLogo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 85, 23)];
    [imgLogo setImage:[UIImage imageNamed:@"logo.png"]];
    UIView *tempView = [[UIView alloc]initWithFrame:imgLogo.frame];
    [tempView addSubview:imgLogo];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:tempView];
    //中间
    UIButton *btnSearch = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 200, 30)];
    [btnSearch setBackgroundColor:[UIColor whiteColor]];
    [btnSearch addTarget:self action:@selector(searchClick:) forControlEvents:UIControlEventTouchUpInside];
    btnSearch.layer.cornerRadius = 5.0;
    UIImageView *imgSearch = [[UIImageView alloc] initWithFrame:CGRectMake(10, 5, 20, 20)];
    [imgSearch setImage:[UIImage imageNamed:@"ico_index_search.png"]];
    [btnSearch addSubview:imgSearch];
    CustomLabel *lbSearch = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgSearch) + 5, 0, VIEW_W(btnSearch) - VIEW_BX(imgSearch) - 5, VIEW_H(btnSearch)) content:@"最新校园招聘" size:12 color:TEXTGRAYCOLOR];
    [btnSearch addSubview:lbSearch];
    self.navigationItem.titleView = btnSearch;
    //右边
    UIButton *btnNearby = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 30)];
    [btnNearby addTarget:self action:@selector(nearbyClick) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *imgNearby = [[UIImageView alloc] initWithFrame:CGRectMake(15, 5, 20, 20)];
    [imgNearby setImage:[UIImage imageNamed:@"nearBy.png"]];
    [btnNearby addSubview:imgNearby];
    CustomLabel *lbNearby = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgNearby) + 5, 0, VIEW_W(btnNearby) - VIEW_BX(imgNearby) - 5, VIEW_H(btnNearby)) content:@"周边" size:14 color:[UIColor whiteColor]];
    [btnNearby addSubview:lbNearby];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnNearby];
    //整体ScrollView
    self.viewScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT * 2 - STATUS_BAR_HEIGHT)];
    [self.viewScroll setBounces:NO];
    [self.view addSubview:self.viewScroll];
    //顶部图片切换
    self.viewSwitchImg = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH * 0.315)];
    [self.viewSwitchImg setBackgroundColor:[UIColor grayColor]];
    [self.viewSwitchImg setPagingEnabled:YES];
    [self.viewSwitchImg setShowsHorizontalScrollIndicator:NO];
    [self.viewSwitchImg setShowsVerticalScrollIndicator:NO];
    [self.viewSwitchImg setDelegate:self];
    [self.viewSwitchImg setBounces:NO];
    [self.viewSwitchImg setTag:1];
    [self.viewScroll addSubview:self.viewSwitchImg];
    //中间按钮
    UIView *viewCollection = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_BY(self.viewSwitchImg), SCREEN_WIDTH, 200)];
    [viewCollection setBackgroundColor:[UIColor whiteColor]];
    [self.viewScroll addSubview:viewCollection];
    NSArray *arrText = [[NSArray alloc] initWithObjects:@"今日发布",@"招聘简章",@"宣讲会",@"招聘会",@"今日截止",@"政府招考",@"实习生",@"500强",nil];
    for (NSInteger index = 0; index < arrText.count; index++) {
        UIButton *btnItem = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH / 4) * (index % 4), floor(index / 4) * 100 + (floor(index / 4) == 0 ? 5 : 0), (SCREEN_WIDTH / 4), 100)];
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"menu%ld.png",(long)index + 1]]];
        image.frame = CGRectMake((VIEW_W(btnItem) - 50) / 2, 10, 50, 50);
        [btnItem addSubview:image];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, VIEW_BY(image) + 10, VIEW_W(btnItem), 20)];
        label.text = [NSString stringWithFormat:@"%@",arrText[index]];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:12];
        [btnItem addSubview:label];
        [btnItem setTag:index];
        [btnItem addTarget:self action:@selector(collectionClick:) forControlEvents:UIControlEventTouchUpInside];
        [viewCollection addSubview:btnItem];
    }
    UIView *viewCollectionBottom = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_H(viewCollection) - 0.5, SCREEN_WIDTH, 0.5)];
    [viewCollectionBottom setBackgroundColor:SEPARATECOLOR];
    [viewCollection addSubview:viewCollectionBottom];
    //底部按钮
    self.viewBottom = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_BY(viewCollection) + 10, SCREEN_WIDTH, 100)];
    [self.viewBottom setBackgroundColor:[UIColor whiteColor]];
    [self.viewScroll addSubview:self.viewBottom];
    arrText = [[NSArray alloc] initWithObjects:@"网申记录",@"企业通知",@"我的关注",@"求职加速",nil];
    for (int index = 0; index < arrText.count; index++) {
        UIButton *btnItem = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH / 2) * (index % 2), floor(index / 2) * 50, (SCREEN_WIDTH / 2), 50)];
        [btnItem setTag:index];
        [btnItem addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.viewBottom addSubview:btnItem];
        UIImageView *imgItem = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_W(btnItem) * 0.2, 12, 26, 26)];
        [imgItem setImage:[UIImage imageNamed:[NSString stringWithFormat:@"button%d.png",(index + 1)]]];
        [imgItem setTag:index];
        [btnItem addSubview:imgItem];
        UILabel *lbItem = [[UILabel alloc] initWithFrame:CGRectMake(VIEW_BX(imgItem) + 10, VIEW_Y(imgItem), VIEW_W(btnItem) - VIEW_BX(imgItem) - 15, VIEW_H(imgItem))];
        [lbItem setText:[arrText objectAtIndex:index]];
        [lbItem setFont:FONT(14)];
        [lbItem setTextColor:TEXTGRAYCOLOR];
        [lbItem setTag:index];
        [btnItem addSubview:lbItem];
    }
    UIView *viewTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
    [viewTop setBackgroundColor:SEPARATECOLOR];
    [self.viewBottom addSubview:viewTop];
    UIView *viewVertical = [[UIView alloc] initWithFrame:CGRectMake(VIEW_W(self.viewBottom) / 2, 0, 0.5, VIEW_H(self.viewBottom))];
    [viewVertical setBackgroundColor:SEPARATECOLOR];
    [self.viewBottom addSubview:viewVertical];
    UIView *viewHorizontal = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_H(self.viewBottom) / 2, VIEW_W(self.viewBottom), 0.5)];
    [viewHorizontal setBackgroundColor:SEPARATECOLOR];
    [self.viewBottom addSubview:viewHorizontal];
    UIView *viewBottom = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_H(self.viewBottom) - 0.5, SCREEN_WIDTH, 0.5)];
    [viewBottom setBackgroundColor:SEPARATECOLOR];
    [self.viewBottom addSubview:viewBottom];
    
    //高校查询、行业名企、按专业找工作 图片按钮
    UIView *viewImageButton = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_BY(self.viewBottom) + 10, SCREEN_WIDTH, (SCREEN_WIDTH / 2) * 0.356)];
    [self.viewScroll addSubview:viewImageButton];
    for (int i = 0; i < 3; i++) {
        UIButton *btnImage = [[UIButton alloc] initWithFrame:CGRectMake(i * (VIEW_W(viewImageButton) / 3), 0, (VIEW_W(viewImageButton) / 3), VIEW_H(viewImageButton))];
        [btnImage setImage:[UIImage imageNamed:[NSString stringWithFormat:@"index_imagebutton%d.png", (i + 1)]] forState:UIControlStateNormal];
        [btnImage setTag:i];
        [btnImage addTarget:self action:@selector(imageButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [viewImageButton addSubview:btnImage];
    }
    //最新招聘简章
    self.viewBrochure = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_BY(viewImageButton) + 10, SCREEN_WIDTH, 500)];
    [self.viewBrochure setBackgroundColor:[UIColor whiteColor]];
    [self.viewScroll addSubview:self.viewBrochure];
    
    if ([[USER_DEFAULT objectForKey:@"launchFirst"] length] == 0) {
        HelpViewController *helpCtrl = [[HelpViewController alloc] init];
        [self presentViewController:helpCtrl animated:YES completion:^{
            [USER_DEFAULT setObject:@"1" forKey:@"launchFirst"];
        }];
    }
    if ([CommonFunc checkLogin]) {
        [self getData];
    }
    [self initLocation];
    [self getHeadImage];
    [self getLatestBrochure];
    [self getNewsAnalysis];
    [self.viewScroll setContentSize:CGSizeMake(SCREEN_WIDTH, VIEW_BY(self.viewNewsAnalysis) + 10)];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([[USER_DEFAULT objectForKey:@"registerSuccess"] isEqualToString:@"1"]) {
        [USER_DEFAULT removeObjectForKey:@"registerSuccess"];
        PopupView *viewPopup = [[PopupView alloc] initWithWechatFocus:self.view];
        [self.view.window addSubview:viewPopup];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    if (![CommonFunc checkLogin]) {// 没有登录
        for (UIView *childView in self.viewBottom.subviews) {
            if ([childView isKindOfClass:[UIButton class]]) {
                if (childView.tag == 4) {
                    [childView setTag:3];
                }
                for (UIView *buttonChildView in childView.subviews) {
                    if ([buttonChildView isKindOfClass:[UIImageView class]]) {
                        [(UIImageView *)buttonChildView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"button%ld", (long)(childView.tag + 1)]]];
                    }
                    if ([buttonChildView isKindOfClass:[CustomLabel class]]) {
                        [buttonChildView removeFromSuperview];
                    }
//                    if ([buttonChildView isKindOfClass:[UILabel class]] && childView.tag == 3) {
//                        [(UILabel *)buttonChildView setText:@"按专业找工作"];
//                    }
                }
            }
        }
    }
}

- (void)getData {
    if ([[CommonFunc getPaMainId] length] > 0 && [[CommonFunc getCode] length] == 0) {
        [USER_DEFAULT removeObjectForKey:@"paMainId"];
        [USER_DEFAULT removeObjectForKey:@"code"];
        return;
    }
    [self.loadingView startAnimating];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetMessageCntByPaMainID" params:[NSDictionary dictionaryWithObjectsAndKeys:[CommonFunc getPaMainId], @"paMainID", [CommonFunc getCode], @"code", nil] tag:1];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startSynchronous];
}

- (void)getHeadImage {
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetAdverProjectByType" params:[NSDictionary dictionaryWithObjectsAndKeys:@"10", @"type", nil] tag:2];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startSynchronous];
}

- (void)getLatestBrochure {
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetCpBrochureIndexIos" params:nil tag:7];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startSynchronous];
}

#pragma mark - 网申记录、企业通知、我的关注、求职加速
- (void)buttonClick:(UIButton *)sender {
    if (![CommonFunc checkLogin] && sender.tag <= 3) {
        UIViewController *loginCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"loginView"];
        [self.navigationController pushViewController:loginCtrl animated:YES];
        return;
    }
    if (sender.tag == 0) { //网申记录
        [self clickLog:@"11"];
        ApplyLogViewController *applyLogCtrl = [[ApplyLogViewController alloc] init];
        [self.navigationController pushViewController:applyLogCtrl animated:YES];
    }
    else if (sender.tag == 1) { //企业通知
        [self clickLog:@"12"];
        NoticeListViewController *noticeListCtrl = [[NoticeListViewController alloc] init];
        [self.navigationController pushViewController:noticeListCtrl animated:YES];
    }
    else if (sender.tag == 2) { //我的关注
        [self clickLog:@"13"];
        FocusViewController *focusCtrl = [[FocusViewController alloc] init];
        [self.navigationController pushViewController:focusCtrl animated:YES];
    }
    else if (sender.tag == 3) { //求职加速
        ApplySpeedUpIntroduceController *apvc = [ApplySpeedUpIntroduceController new];
        [self.navigationController pushViewController:apvc animated:YES];
        
        
//        [self clickLog:@"14"];
//        UIViewController *industryCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"majorView"];
//        [self.navigationController pushViewController:industryCtrl animated:YES];
    }
    else if (sender.tag == 4) { //猜你喜欢
        
        ApplySpeedUpIntroduceController *apvc = [ApplySpeedUpIntroduceController new];
        [self.navigationController pushViewController:apvc animated:YES];
//        [self clickLog:@"15"];
//        LikeListViewController *likeListCtrl = [[LikeListViewController alloc] init];
//        [self.navigationController pushViewController:likeListCtrl animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)collectionClick:(UIButton *)sender {
    if (sender.tag == 0) { //今日发布
        [self clickLog:@"3"];
        JobListViewController *jobListCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"jobListView"];
        jobListCtrl.searchType = 7;
        [self.navigationController pushViewController:jobListCtrl animated:YES];
    }
    else if (sender.tag == 1) { //招聘简章
        [self clickLog:@"4"];
        JobListViewController *jobListCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"jobListView"];
        jobListCtrl.searchType = 0;
        [self.navigationController pushViewController:jobListCtrl animated:YES];
    }
    else if (sender.tag == 2) { //宣讲会
        [self clickLog:@"5"];
        UIViewController *campusListCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"campusListView"];
        [self.navigationController pushViewController:campusListCtrl animated:YES];
    }
    else if (sender.tag == 3) { //招聘会
        [self clickLog:@"6"];
        UIViewController *recruitmentListCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"recruitmentListView"];
        [self.navigationController pushViewController:recruitmentListCtrl animated:YES];
    }
    else if (sender.tag == 4) { //今日截止
        [self clickLog:@"7"];
        JobListViewController *jobListCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"jobListView"];
        jobListCtrl.searchType = 8;
        [self.navigationController pushViewController:jobListCtrl animated:YES];
    }
    else if (sender.tag == 5) { //政府招考
        [self clickLog:@"8"];
        JobListViewController *jobListCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"jobListView"];
        jobListCtrl.searchType = 1;
        [self.navigationController pushViewController:jobListCtrl animated:YES];
    }
    else if (sender.tag == 6) { //实习
        [self clickLog:@"9"];
        JobListViewController *jobListCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"jobListView"];
        jobListCtrl.searchType = 2;
        [self.navigationController pushViewController:jobListCtrl animated:YES];
    }
    else if (sender.tag == 7) { //500强
        [self clickLog:@"10"];
        UIViewController *top500ListCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"top500ListView"];
        [self.navigationController pushViewController:top500ListCtrl animated:YES];
    }
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    [self.loadingView stopAnimating];
    if (request.tag == 1) {
        NSDictionary *countData = [[CommonFunc getArrayFromXml:requestData tableName:@"Table"] objectAtIndex:0];
        NSDictionary *noProcessCountData = [[CommonFunc getArrayFromXml:requestData tableName:@"dtNoViewCnt"] objectAtIndex:0];
        for (int i = 0; i < 4; i++) {
            if ([[countData objectForKey:[NSString stringWithFormat:@"Column%d", i + 1]] intValue] > -1) {
                for (UIView *childView in self.viewBottom.subviews) {
                    if ([childView isKindOfClass:[UIButton class]] && childView.tag == i) {
                        if (childView.tag == 3) {
                            [(UIButton *)childView setTag:4];
                        }
                        for (UIView *buttonChildView in childView.subviews) {
                            if ([buttonChildView isKindOfClass:[UILabel class]] && childView.tag == 4) {
//                                [(UILabel *)buttonChildView setText:@"猜你喜欢"];
                                [(UILabel *)buttonChildView setText:@"求职加速"];
                            }
                            if ([buttonChildView isKindOfClass:[UIImageView class]]) {
                                [(UIImageView *)buttonChildView setImage:nil];
                                CustomLabel *lbCount = [[CustomLabel alloc] initWithFrame:CGRectMake(VIEW_X(buttonChildView), VIEW_Y(buttonChildView), 30, VIEW_H(buttonChildView)) content:[countData objectForKey:[NSString stringWithFormat:@"Column%d", i + 1]] size:16 color:NAVBARCOLOR];
                                [lbCount setTextAlignment:NSTextAlignmentCenter];
                                [childView addSubview:lbCount];
                            }
                        }
                    }
                }
            }
        }
        for (int i = 0; i < 3; i++) {
            if ([[noProcessCountData objectForKey:[NSString stringWithFormat:@"Column%d", i + 1]] intValue] > 0) {
                for (UIView *childView in self.viewBottom.subviews) {
                    if ([childView isKindOfClass:[UIButton class]] && childView.tag == i) {
                        CustomLabel *lbNoView = [[CustomLabel alloc] initWithFrame:CGRectMake(VIEW_W(childView) - 50, 22, 6, 6) content:@"" size:12 color:[UIColor whiteColor]];
                        [lbNoView setBackgroundColor:[UIColor redColor]];
                        [lbNoView.layer setMasksToBounds:YES];
                        [lbNoView.layer setCornerRadius:3];
                        [childView addSubview:lbNoView];
                    }
                }
            }
        }
    }
    else if (request.tag == 2) {
        if ([[CommonFunc getArrayFromXml:requestData tableName:@"Table"] count] > 0) {
            self.arrHeadImage = [CommonFunc getArrayFromXml:requestData tableName:@"Table"];
            [self initHeadImg];
        }
    }
    else if (request.tag == 3) {
        NSArray *arrProvince = [result componentsSeparatedByString:@","];
        if (arrProvince.count == 2) {
            [USER_DEFAULT setObject:[arrProvince objectAtIndex:1] forKey:@"regionName"];
            [USER_DEFAULT setObject:[arrProvince objectAtIndex:0] forKey:@"regionId"];
        }
        else {
            [USER_DEFAULT setObject:@"山东" forKey:@"regionName"];
            [USER_DEFAULT setObject:@"32" forKey:@"regionId"];
        }
    }
    else if (request.tag == 4) {
        NSDictionary *cpBrochureData = [[CommonFunc getArrayFromXml:requestData tableName:@"Table"] objectAtIndex:0];
        CompanyViewController *companyCtrl = [[CompanyViewController alloc] init];
        companyCtrl.secondId = [cpBrochureData objectForKey:@"cpSecondID"];
        companyCtrl.cpBrochureSecondId = [cpBrochureData objectForKey:@"SecondID"];
        companyCtrl.tabIndex = 1;
        [self.navigationController pushViewController:companyCtrl animated:YES];
    }
    else if (request.tag == 7) {
        self.arrCpBrochureData = [CommonFunc getArrayFromXml:requestData tableName:@"dtCpBrochure"];
        self.arrJobData = [CommonFunc getArrayFromXml:requestData tableName:@"dtJob"];
        self.arrRegionData = [CommonFunc getArrayFromXml:requestData tableName:@"dtRegion"];
        [self initLatestBrochure];
    }
    else if (request.tag == 8) {
        [self initNewsAnalysis:[CommonFunc getArrayFromXml:requestData tableName:@"newsreport"] arrAnalysisData:[CommonFunc getArrayFromXml:requestData tableName:@"newsAnalysis"]];
    }
}

- (void)initLatestBrochure {
    UIView *viewSeperateTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
    [viewSeperateTop setBackgroundColor:SEPARATECOLOR];
    [self.viewBrochure addSubview:viewSeperateTop];
    UIView *viewLeftLine = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 5, 20)];
    [viewLeftLine setBackgroundColor:NAVBARCOLOR];
    [self.viewBrochure addSubview:viewLeftLine];
    CustomLabel *lbTitle = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(viewLeftLine) + 5, VIEW_Y(viewLeftLine), 300, 20) content:@"最新招聘简章" size:16 color:NAVBARCOLOR];
    [self.viewBrochure addSubview:lbTitle];
    float brochureHeight = VIEW_BY(lbTitle) + 10;
    for (int i = 0; i < self.arrCpBrochureData.count; i++) {
        NSDictionary *cpBrochureData = [self.arrCpBrochureData objectAtIndex:i];
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
        CustomLabel *lbCompany = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(10, brochureHeight, SCREEN_WIDTH - 20 - picWidth, 20) content:content size:fontSize color:UIColorWithRGBA(20, 62, 103, 1)];
        [self.viewBrochure addSubview:lbCompany];
        if (top500Img.length > 0) {
            UIImageView *imgTop500 = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_BX(lbCompany) + 2, VIEW_Y(lbCompany) + 2, 63, 16)];
            [imgTop500 setImage:[UIImage imageNamed:top500Img]];
            [self.viewBrochure addSubview:imgTop500];
        }
        if ([[cpBrochureData objectForKey:@"HasCpPreach"] integerValue] > 0) {
            UIImageView *imgPreach = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_BX(lbCompany) + 2 + (top500Img.length > 0 ? 65 : 0), VIEW_Y(lbCompany) + 2, 41, 16)];
            [imgPreach setImage:[UIImage imageNamed:@"ico_list_preach.png"]];
            [self.viewBrochure addSubview:imgPreach];
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
            picWidth = picWidth + 16;
            UIImageView *imgNew = [[UIImageView alloc] initWithFrame:CGRectMake(10, VIEW_BY(lbCompany) + 7, 16, 16)];
            [imgNew setImage:[UIImage imageNamed:@"ico_list_new.png"]];
            [self.viewBrochure addSubview:imgNew];
        }
        //“官方”图标
        if ([[cpBrochureData objectForKey:@"ApplyType"] isEqualToString:@"1"]) {
            picWidth = picWidth + 31;
            UIImageView *imgOfficial = [[UIImageView alloc] initWithFrame:CGRectMake((timeInterval / 3600 < 24 ? 28 : 10), VIEW_BY(lbCompany) + 7, 29, 16)];
            [imgOfficial setImage:[UIImage imageNamed:@"ico_list_guanfang.png"]];
            [self.viewBrochure addSubview:imgOfficial];
        }
        NSArray *arrJob = [CommonFunc getArrayFromArrayWithSelect:self.arrJobData param:[NSArray arrayWithObject:[NSDictionary dictionaryWithObject:[cpBrochureData objectForKey:@"CpBrochureID"] forKey:@"cpBrochureID"]]];
        for (int i = 0; i < arrJob.count; i++) {
            [arrJobDetail addObject:[[arrJob objectAtIndex:i] objectForKey:@"Name"]];
        }
        content = [arrJobDetail componentsJoinedByString:@" | "];
        CustomLabel *lbJob = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(10 + (picWidth > 0 ? picWidth + 2 : 0), VIEW_BY(lbCompany) + 5, SCREEN_WIDTH - 105 - picWidth, 20) content:content size:fontSize color:TEXTGRAYCOLOR];
        [self.viewBrochure addSubview:lbJob];
        
        UIImageView *imgRegion = [[UIImageView alloc] initWithFrame:CGRectMake(10, VIEW_BY(lbJob) + 7, 16, 16)];
        [imgRegion setImage:[UIImage imageNamed:@"ico_location_green.png"]];
        [self.viewBrochure addSubview:imgRegion];
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
        [self.viewBrochure addSubview:lbRegion];
        //网申起止时间
        content = @"网申起止时间";
        fontSize = 12;
        CustomLabel *lbDateTitle = [[CustomLabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 90, VIEW_Y(lbJob), 80, VIEW_H(lbJob)) content:content size:fontSize color:TEXTGRAYCOLOR];
        [lbDateTitle setTextAlignment:NSTextAlignmentRight];
        [self.viewBrochure addSubview:lbDateTitle];
        content = [NSString stringWithFormat:@"%@-%@", [CommonFunc stringFromDateString:[cpBrochureData objectForKey:@"BeginDate"] formatType:@"M月d日"], [CommonFunc stringFromDateString:[cpBrochureData objectForKey:@"EndDate"] formatType:@"M月d日"]] ;
        CustomLabel *lbDate = [[CustomLabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 120, VIEW_Y(lbRegion), 110, VIEW_H(lbJob)) content:content size:fontSize color:(brochureStatusType == 2 ? TEXTGRAYCOLOR : NAVBARCOLOR)];
        [lbDate setTextAlignment:NSTextAlignmentRight];
        [self.viewBrochure addSubview:lbDate];
        UIButton *btnBrochure = [[UIButton alloc] initWithFrame:CGRectMake(0, brochureHeight, SCREEN_WIDTH, VIEW_BY(imgRegion) - brochureHeight)];
        [btnBrochure setTag:i];
        [btnBrochure addTarget:self action:@selector(brochureClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.viewBrochure addSubview:btnBrochure];
        UIView *viewSeperate = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_BY(imgRegion) + 10, SCREEN_WIDTH, 0.5)];
        [viewSeperate setBackgroundColor:SEPARATECOLOR];
        [self.viewBrochure addSubview:viewSeperate];
        brochureHeight = VIEW_BY(viewSeperate) + 10;
    }
    CGRect frameBrochure = self.viewBrochure.frame;
    frameBrochure.size.height = brochureHeight - 10;
    [self.viewBrochure setFrame:frameBrochure];
}

- (void)searchClick:(id)sender {
    [self clickLog:@"1"];
    SearchViewController *viewSearch = [self.storyboard instantiateViewControllerWithIdentifier:@"searchView"];
    viewSearch.searchType = 0;
    [self.navigationController pushViewController:viewSearch animated:YES];
}

- (void)initLocation {
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetIpPlaceCity" params:[NSDictionary dictionaryWithObject:@"" forKey:@"ip"] tag:3];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startSynchronous];
}

- (void)initHeadImg {
    for (int i = 0; i < self.arrHeadImage.count; i++) {
        NSDictionary *headImageData = [self.arrHeadImage objectAtIndex:i];
        UIImageView *headImgeView = [[UIImageView alloc] initWithFrame:CGRectMake(i * SCREEN_WIDTH, 0, VIEW_W(self.viewSwitchImg), VIEW_H(self.viewSwitchImg))];
        [headImgeView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://down.51rc.com/imagefolder/wutongguo/operational/hpimage/%@", [headImageData objectForKey:@"ImageFile"]]]];
        [headImgeView setTag:i];
        [self.viewSwitchImg addSubview:headImgeView];
        if ([[headImageData objectForKey:@"Url"] length] > 0) {
            headImgeView.userInteractionEnabled = YES;
            UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headImageClick:)];
            [headImgeView addGestureRecognizer:singleTap];
        }
    }
    [self.viewSwitchImg setContentSize:CGSizeMake(SCREEN_WIDTH * self.arrHeadImage.count, VIEW_H(self.viewSwitchImg))];
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, VIEW_BY(self.viewSwitchImg) - 20, 200, 20)];
    [self.pageControl setSelected:NO];
    [self.pageControl setNumberOfPages:self.arrHeadImage.count];
    [self.pageControl setCurrentPage:0];
    [self.pageControl setCurrentPageIndicatorTintColor:NAVBARCOLOR];
    [self.pageControl setPageIndicatorTintColor:[UIColor blackColor]];
    [self.pageControl setCenter:CGPointMake(self.viewSwitchImg.center.x, self.pageControl.center.y)];
    [self.viewScroll addSubview:self.pageControl];
    [self autoScrollImg];
}

- (void)autoScrollImg {
    [self.timerImgScroll invalidate];
    self.timerImgScroll = nil;
    self.timerImgScroll = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(scrollImg) userInfo:nil repeats:YES];
}

- (void)scrollImg {
    NSInteger page = self.pageControl.currentPage + 1;
    if (page == self.arrHeadImage.count) {
        page = 0;
    }
    [self.viewSwitchImg setContentOffset:CGPointMake(page * SCREEN_WIDTH, 0) animated:YES];
}

- (void)headImageClick:(UITapGestureRecognizer *)sender {
    NSDictionary *headImageData = [self.arrHeadImage objectAtIndex:sender.view.tag];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"UpdateAdverProjectClickCountIOS" params:[NSDictionary dictionaryWithObject:[headImageData objectForKey:@"id"] forKey:@"id"] tag:5];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startSynchronous];
    
    NSString *headUrl = [[headImageData objectForKey:@"Url"] lowercaseString];
    if ([headUrl rangeOfString:@"http://m.wutongguo.com/notice"].location != NSNotFound) {
        NSString *brochureSecondId = [[headUrl stringByReplacingOccurrencesOfString:@"http://m.wutongguo.com/notice" withString:@""] stringByReplacingOccurrencesOfString:@".html" withString:@""];
        [self.loadingView startAnimating];
        self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetCpBrochureByID" params:[NSDictionary dictionaryWithObjectsAndKeys:brochureSecondId, @"cpBrochureID", nil] tag:4];
        [self.runningRequest setDelegate:self];
        [self.runningRequest startAsynchronous];
    }
    else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:headUrl]];
    }
}

- (void)imageButtonClick:(UIButton *)sender {
    if (sender.tag == 0) {
        UIViewController *schoolListViewCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"schoolListView"];
        [self.navigationController pushViewController:schoolListViewCtrl animated:YES];
    }
    else if(sender.tag == 1){
        UIViewController *famousViewCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"famousListView"];
        [self.navigationController pushViewController:famousViewCtrl animated:YES];
    }else if (sender.tag == 2){// 按专业找工作
        [self clickLog:@"14"];
        UIViewController *industryCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"majorView"];
        [self.navigationController pushViewController:industryCtrl animated:YES];
    }
}

- (void)brochureClick:(UIButton *)sender {
    NSDictionary *cpBrochureData = [self.arrCpBrochureData objectAtIndex:sender.tag];
    CompanyViewController *companyCtrl = [[CompanyViewController alloc] init];
    companyCtrl.secondId = [cpBrochureData objectForKey:@"CpSecondID"];
    companyCtrl.cpBrochureSecondId = [cpBrochureData objectForKey:@"SecondID"];
    companyCtrl.tabIndex = 1;
    [self.navigationController pushViewController:companyCtrl animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.tag == 1) {
        NSInteger page = scrollView.contentOffset.x / SCREEN_WIDTH;
        [self.pageControl setCurrentPage:page];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView.tag == 1) {
        [self autoScrollImg];
    }
}

- (void)nearbyClick {
    [self clickLog:@"2"];
    UIViewController *nearListCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"nearListView"];
    [self.navigationController pushViewController:nearListCtrl animated:YES];
}

- (void)clickLog:(NSString *)buttonType {
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"InsertAppBtnClickLog" params:[NSDictionary dictionaryWithObjectsAndKeys:@"2", @"SysType", [CommonFunc getDeviceID], @"DeviceID", [CommonFunc getPaMainId], @"pamainID", buttonType, @"dcAppBtnID", nil] tag:6];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (void)getNewsAnalysis {
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetNewsAnalysis" params:nil tag:8];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startSynchronous];
}

- (void)initNewsAnalysis:(NSArray *)arrReportData arrAnalysisData:(NSArray *)arrAnalysisData {
    self.viewNewsAnalysis = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_BY(self.viewBrochure) + 10, SCREEN_WIDTH, 201)];
    [self.viewNewsAnalysis setBackgroundColor:[UIColor whiteColor]];
    [self.viewScroll addSubview:self.viewNewsAnalysis];
    if (arrAnalysisData.count == 0) {
        //return;
    }
    UIView *viewSeperateTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
    [viewSeperateTop setBackgroundColor:SEPARATECOLOR];
    [self.viewNewsAnalysis addSubview:viewSeperateTop];
    UIView *viewLeftLine = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 5, 20)];
    [viewLeftLine setBackgroundColor:NAVBARCOLOR];
    [self.viewNewsAnalysis addSubview:viewLeftLine];
    CustomLabel *lbTitle = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(viewLeftLine) + 5, VIEW_Y(viewLeftLine), 300, 20) content:@"就业大数据" size:16 color:NAVBARCOLOR];
    [self.viewNewsAnalysis addSubview:lbTitle];
    float newAnalysisHeight = VIEW_BY(lbTitle) + 10;
    for (int i = 0; i < arrReportData.count; i++) {
        NSDictionary *reportData = [arrReportData objectAtIndex:i];
        CustomLabel *lbReportTitle = [[CustomLabel alloc] initWithFrame:CGRectMake(10, newAnalysisHeight, VIEW_W(self.viewNewsAnalysis) - 120, 40) content:[reportData objectForKey:@"Title"] size:14 color:UIColorWithRGBA(20, 62, 103, 1)];
        [lbReportTitle setNumberOfLines:2];
        [self.viewNewsAnalysis addSubview:lbReportTitle];
        UIImageView *imgReport = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_W(self.viewNewsAnalysis) - 110, VIEW_Y(lbReportTitle), 100, 66.3)];
        [imgReport setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://down.51rc.com/imagefolder/wutongguo/NewsAnalysis/fileMobileImg/%@", [reportData objectForKey:@"MobileImage"]]]]]];
        [imgReport setBackgroundColor:[UIColor redColor]];
        [self.viewNewsAnalysis addSubview:imgReport];
        CustomLabel *lbReportDate = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbReportTitle), VIEW_BY(lbReportTitle) + 5, VIEW_W(lbReportTitle), 20) content:[NSString stringWithFormat:@"数据报告 %@", [CommonFunc stringFromDateString:[reportData objectForKey:@"RefReshDate"] formatType:@"M-d"]] size:12 color:TEXTGRAYCOLOR];
        [self.viewNewsAnalysis addSubview:lbReportDate];
        UIButton *btnReport = [[UIButton alloc] initWithFrame:CGRectMake(0, VIEW_X(lbReportTitle), SCREEN_WIDTH, VIEW_H(imgReport))];
        [btnReport setTag:[[reportData objectForKey:@"Id"] intValue]];
        [btnReport addTarget:self action:@selector(analysisClick:) forControlEvents:UIControlEventTouchUpInside];
        [btnReport setBackgroundColor:[UIColor clearColor]];
        [self.viewNewsAnalysis addSubview:btnReport];
        newAnalysisHeight = VIEW_BY(imgReport) + 5;
    }
    UIView *viewSeperateMiddle = [[UIView alloc] initWithFrame:CGRectMake(0, newAnalysisHeight, SCREEN_WIDTH, 0.5)];
    [viewSeperateMiddle setBackgroundColor:SEPARATECOLOR];
    [self.viewNewsAnalysis addSubview:viewSeperateMiddle];
    newAnalysisHeight = VIEW_BY(viewSeperateMiddle) + 5;
    for (int i = 0; i < arrAnalysisData.count; i++) {
        NSDictionary *analysisData = [arrAnalysisData objectAtIndex:i];
        UIButton *btnAnalysis = [[UIButton alloc] initWithFrame:CGRectMake(0, newAnalysisHeight, VIEW_W(self.viewNewsAnalysis), 30)];
        [btnAnalysis setTag:[[analysisData objectForKey:@"Id"] intValue]];
        [btnAnalysis addTarget:self action:@selector(analysisClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.viewNewsAnalysis addSubview:btnAnalysis];
        CustomLabel *lbAnalysisTitle = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(10, 5, VIEW_W(btnAnalysis) - 60, 20) content:[analysisData objectForKey:@"Title"] size:12 color:TEXTGRAYCOLOR];
        [btnAnalysis addSubview:lbAnalysisTitle];
        CustomLabel *lbAnalysisDate = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_W(btnAnalysis) - 45, 5, 40, 20) content:[CommonFunc stringFromDateString:[analysisData objectForKey:@"AnnounceDate"] formatType:@"M-d"] size:12 color:TEXTGRAYCOLOR];
        [btnAnalysis addSubview:lbAnalysisDate];
        UIView *viewSeperate = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_BY(btnAnalysis) + 3, SCREEN_WIDTH, 0.5)];
        [viewSeperate setBackgroundColor:SEPARATECOLOR];
        [self.viewNewsAnalysis addSubview:viewSeperate];
        newAnalysisHeight = VIEW_BY(viewSeperate) + 3;
    }
    UIButton *btnMore = [[UIButton alloc] initWithFrame:CGRectMake(0, newAnalysisHeight, SCREEN_WIDTH, 30)];
    [btnMore setTitle:@"查看更多..." forState:UIControlStateNormal];
    [btnMore.titleLabel setFont:FONT(14)];
    [btnMore setTitleColor:TEXTGRAYCOLOR forState:UIControlStateNormal];
    [btnMore addTarget:self action:@selector(reportClick) forControlEvents:UIControlEventTouchUpInside];
    [self.viewNewsAnalysis addSubview:btnMore];
    newAnalysisHeight = VIEW_BY(btnMore);
    CGRect frameViewAnalysis = self.viewNewsAnalysis.frame;
    frameViewAnalysis.size.height = newAnalysisHeight + 10;
    [self.viewNewsAnalysis setFrame:frameViewAnalysis];
}

- (void)analysisClick:(UIButton *)sender {
    NewsAnalysisViewController *newsAnalysisCtrl = [[NewsAnalysisViewController alloc] init];
    newsAnalysisCtrl.newsAnalysisId = sender.tag;
    [self.navigationController pushViewController:newsAnalysisCtrl animated:YES];
}

- (void)reportClick {
    NewsAnalysisViewController *newsAnalysisCtrl = [[NewsAnalysisViewController alloc] init];
    newsAnalysisCtrl.newsAnalysisId = 0;
    [self.navigationController pushViewController:newsAnalysisCtrl animated:YES];
}

@end

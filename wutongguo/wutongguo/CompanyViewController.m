//
//  CompanyViewController.m
//  wutongguo
//
//  Created by Lucifer on 15-5-16.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "CompanyViewController.h"
#import "SCNavTabBarController.h"
#import "CpMainViewController.h"
#import "CpBrochureViewController.h"
#import "CpJobListViewController.h"
#import "CpCampusViewController.h"
#import "CpImageViewController.h"
#import "NetWebServiceRequest.h"
#import "CommonMacro.h"
#import "CommonFunc.h"
#import "CustomLabel.h"
#import "UIImageView+WebCache.h"
#import "MapViewController.h"
#import "Top500ListViewController.h"
#import "CpBrandViewController.h"

@interface CompanyViewController () <UIScrollViewDelegate, NetWebServiceRequestDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) UIScrollView *viewScroll;
@property (nonatomic, strong) UIScrollView *viewContent;
@property (nonatomic, strong) UIView       *viewCpInfo;
@property (nonatomic, strong) UIView       *viewNav;
@property (nonatomic, strong) UIView       *viewItemLine;
@property (nonatomic, strong) UIButton     *btnJob;
@property (nonatomic, strong) NSArray      *itemTitles;
@property (nonatomic, strong) NSArray      *arrIndustryData;
@property (nonatomic, strong) NSDictionary *companyData;
@property (nonatomic, strong) NSDictionary *logoData;
@property (nonatomic, strong) NSDictionary *top500Data;
@property (nonatomic, strong) NSString     *companyTitle;
@property (nonatomic, strong) NSString     *logoUrl;
@property (nonatomic, strong) NSString     *shareUrl;
@property float tabItemWidth;
@end

@implementation CompanyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
    self.arrayViewHeight = [[NSMutableArray alloc] init];
    for (int i = 0; i < 4; i++) {
        [self.arrayViewHeight addObject:[NSNumber numberWithFloat:100.0f]];
    }
    //ScrollView
    self.viewScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.viewScroll setDelegate:self];
    [self.viewScroll setTag:0];
    [self.viewScroll setBounces:NO];
    [self.viewScroll setShowsVerticalScrollIndicator:NO];
    [self.viewScroll setShowsHorizontalScrollIndicator:NO];
    [self.view addSubview:self.viewScroll];
    [self.viewScroll setContentSize:CGSizeMake(SCREEN_WIDTH, 2000)];
    //CpInfo
    self.viewCpInfo = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 175)];
    [self.viewScroll addSubview:self.viewCpInfo];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetCpMainDetailByID" params:[NSDictionary dictionaryWithObjectsAndKeys:self.secondId, @"cpMainID", [CommonFunc getPaMainId], @"paMainID", [CommonFunc getCode], @"code", nil] tag:2];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
    
    [self initNav];
    [self initContent];
    //分享
    UIButton *btnShare = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [btnShare setBackgroundImage:[UIImage imageNamed:@"coShare"] forState:UIControlStateNormal];
    [btnShare addTarget:self action:@selector(shareClick) forControlEvents:UIControlEventTouchUpInside];
    UIView *containerView = [[UIView alloc]initWithFrame:btnShare.frame];
    [containerView addSubview:btnShare];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:containerView];
}

- (void)fillData {
    UIImageView *bgCpInfo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, VIEW_W(self.viewCpInfo), VIEW_H(self.viewCpInfo))];
    [bgCpInfo setImage:[UIImage imageNamed:@"bg_company_top.jpg"]];
    [bgCpInfo setUserInteractionEnabled:YES];
    [self.viewCpInfo addSubview:bgCpInfo];
    UIImageView *imgLogo = [[UIImageView alloc] initWithFrame:CGRectMake(15, NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT + 13, 70, 63.7)];
    [imgLogo.layer setMasksToBounds:YES];
    [imgLogo.layer setCornerRadius:5];
    [bgCpInfo addSubview:imgLogo];
    NSString *path = @"";
    if (self.logoData != nil) {
        path = [NSString stringWithFormat:@"%d",([[self.companyData objectForKey:@"ID"] intValue] / 10000 + 1) * 10000];
        NSInteger lastLength = 6 - path.length;
        for (int i = 0; i < lastLength; i++) {
            path = [NSString stringWithFormat:@"0%@",path];
        }
        path = [NSString stringWithFormat:@"L%@",path];
        path = [NSString stringWithFormat:@"http://down.51rc.com/imagefolder/wutongguo/CP/Logo/%@/%@",path,[self.logoData objectForKey:@"Url"]];
    }
    else if ([[self.companyData objectForKey:@"CpBrandLogo"] length] > 0) {
        path = [NSString stringWithFormat:@"%d",([[self.companyData objectForKey:@"CpBrandID"] intValue] / 10000 + 1) * 10000];
        NSInteger lastLength = 6 - path.length;
        for (int i = 0; i < lastLength; i++) {
            path = [NSString stringWithFormat:@"0%@",path];
        }
        path = [NSString stringWithFormat:@"L%@",path];
        path = [NSString stringWithFormat:@"http://down.51rc.com/imagefolder/wutongguo/CpBrand/%@/%@",path,[self.companyData objectForKey:@"CpBrandLogo"]];
    }
    [imgLogo sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:[UIImage imageNamed:@"coNoSchoolLogo.png"]];
    self.logoUrl = path;
    //公司名称
    CustomLabel *lbCompany = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgLogo) + 10, VIEW_Y(imgLogo) - 10, SCREEN_WIDTH - VIEW_BX(imgLogo) - VIEW_X(imgLogo) - 10, 20) content:[self.companyData objectForKey:@"Name"] size:16 color:nil];
    [bgCpInfo addSubview:lbCompany];
    NSMutableString *industry = [[NSMutableString alloc] init];
    for (NSDictionary *oneIndustry in self.arrIndustryData) {
        [industry appendFormat:@"%@ ", [oneIndustry objectForKey:@"NAME"]];
    }
    CustomLabel *lbCpInfo = [[CustomLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_X(lbCompany), VIEW_BY(lbCompany) + 5, SCREEN_WIDTH - VIEW_X(lbCompany) - 10, 40) content:[NSString stringWithFormat:@"    %@ | %@ | %@ | %@", [self.companyData objectForKey:@"FullName"], [self.companyData objectForKey:@"CompanySizeName"], [self.companyData objectForKey:@"CompanyKindName"], industry] size:14 color:nil];
    [lbCpInfo setFrame:CGRectMake(VIEW_X(lbCpInfo), VIEW_Y(lbCpInfo), VIEW_W(lbCpInfo), 45)];
    NSMutableAttributedString *attributedString = [lbCpInfo.attributedText mutableCopy];
    [attributedString addAttribute:NSForegroundColorAttributeName value:UIColorWithRGBA(0, 148, 223, 1) range:NSMakeRange(4, [[self.companyData objectForKey:@"FullName"] length])];
    [lbCpInfo setAttributedText:attributedString];
    [bgCpInfo addSubview:lbCpInfo];
    UIImageView *imgMap = [[UIImageView alloc] initWithFrame:CGRectMake(0, 1, 14, 14)];
    [imgMap setImage:[UIImage imageNamed:@"schoolMap.png"]];
    [lbCpInfo addSubview:imgMap];
    UIButton *btnMap = [[UIButton alloc] initWithFrame:lbCpInfo.frame];
    if ([[self.companyData objectForKey:@"Lat"] length] > 0) {
        [btnMap addTarget:self action:@selector(mapClick) forControlEvents:UIControlEventTouchUpInside];
    }
    [btnMap setBackgroundColor:[UIColor clearColor]];
    [bgCpInfo addSubview:btnMap];
    //500强
    NSString *top500 = @"";
    int top500Type = 0;
    if ([[self.top500Data objectForKey:@"world"] isEqualToString:@"1"]) {
        top500 = @"世界500强";
        top500Type = 1;
    }
    else if ([[self.top500Data objectForKey:@"china"] isEqualToString:@"1"]) {
        top500 = @"中国500强";
        top500Type = 2;
    }
    else if ([[self.top500Data objectForKey:@"china2"] isEqualToString:@"1"]) {
        top500 = @"企业500强";
        top500Type = 3;
    }
    else if ([[self.top500Data objectForKey:@"china3"] isEqualToString:@"1"]) {
        top500 = @"民营500强";
        top500Type = 4;
    }
    float sectionWidth = VIEW_X(lbCompany);
    if (top500.length > 0) {
        CustomLabel *lbTop500 = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(sectionWidth, VIEW_BY(lbCpInfo) + 5, 200, 20) content:top500 size:14 color:[UIColor whiteColor]];
        [lbTop500 setBackgroundColor:UIColorWithRGBA(146, 113, 197, 1)];
        [lbTop500 setFrame:CGRectMake(VIEW_X(lbTop500), VIEW_Y(lbTop500), VIEW_W(lbTop500) + 6, VIEW_H(lbTop500))];
        [lbTop500 setTextAlignment:NSTextAlignmentCenter];
        [lbTop500.layer setMasksToBounds:YES];
        [lbTop500.layer setCornerRadius:3];
        [bgCpInfo addSubview:lbTop500];
        UIButton *btnTop500 = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_X(lbTop500), VIEW_Y(lbTop500), VIEW_W(lbTop500), VIEW_H(lbTop500))];
        [btnTop500 setBackgroundColor:[UIColor clearColor]];
        [btnTop500 setTag:top500Type];
        [btnTop500 addTarget:self action:@selector(top500Click:) forControlEvents:UIControlEventTouchUpInside];
        [bgCpInfo addSubview:btnTop500];
        sectionWidth = VIEW_BX(lbTop500);
    }
    if ([[self.companyData objectForKey:@"StarLevel"] intValue] > 4) {
        CustomLabel *lbBrand = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(sectionWidth + 2, VIEW_BY(lbCpInfo) + 5, (IS_IPHONE_5 ? 60 : 100), 20) content:[self.companyData objectForKey:@"CpBrandName"] size:14 color:[UIColor whiteColor]];
        [lbBrand setBackgroundColor:UIColorWithRGBA(225, 106, 113, 1)];
        [lbBrand setFrame:CGRectMake(VIEW_X(lbBrand), VIEW_Y(lbBrand), VIEW_W(lbBrand) + 6, VIEW_H(lbBrand))];
        [lbBrand setTextAlignment:NSTextAlignmentCenter];
        [lbBrand.layer setMasksToBounds:YES];
        [lbBrand.layer setCornerRadius:3];
        [bgCpInfo addSubview:lbBrand];
        UIButton *btnBrand = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_X(lbBrand), VIEW_Y(lbBrand), VIEW_W(lbBrand), VIEW_H(lbBrand))];
        [btnBrand setBackgroundColor:[UIColor clearColor]];
        [btnBrand addTarget:self action:@selector(brandClick:) forControlEvents:UIControlEventTouchUpInside];
        [bgCpInfo addSubview:btnBrand];
        CustomLabel *lbBrandTitle = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(lbBrand) + 2, VIEW_Y(lbBrand), 200, 20) content:@"旗下" size:14 color:nil];
        [bgCpInfo addSubview:lbBrandTitle];
        sectionWidth = VIEW_BX(lbBrandTitle);
    }
    //关注按钮
    NSInteger IsAttention = [[self.top500Data objectForKey:@"IsAttention"] integerValue];
    UIButton *btnAttention = [[UIButton alloc] initWithFrame:CGRectMake(sectionWidth + 2, VIEW_BY(lbCpInfo) + 5, 52.3, 20)];
    [btnAttention setBackgroundImage:[UIImage imageNamed:@"img_company_Attention.png"] forState:UIControlStateNormal];
    [btnAttention addTarget:self action:@selector(favoriteClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnAttention setTitle:(IsAttention == 1 ? @"已关注" : @"+关注") forState:UIControlStateNormal];
    [btnAttention.titleLabel setFont:FONT(12)];
    [btnAttention setTag:IsAttention];
    [bgCpInfo addSubview:btnAttention];
}

- (void)top500Click:(UIButton *)sender {
    Top500ListViewController *top500ListCtrl = [[UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]] instantiateViewControllerWithIdentifier:@"top500ListView"];
    top500ListCtrl.top500TypeId = [NSString stringWithFormat:@"%ld", (long)sender.tag];
    [self.navigationController pushViewController:top500ListCtrl animated:YES];
}

- (void)brandClick:(UIButton *)sender {
    CpBrandViewController *cpBrandCtrl = [[CpBrandViewController alloc] init];
    cpBrandCtrl.secondId = [self.companyData objectForKey:@"CpBrandID"];
    cpBrandCtrl.title = @"名企";
    [self.navigationController pushViewController:cpBrandCtrl animated:YES];
}

- (void)initNav {
    self.viewNav = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_BY(self.viewCpInfo), SCREEN_WIDTH, NAVIGATION_BAR_HEIGHT)];
    [self.viewNav setBackgroundColor:BGCOLOR];
    self.itemTitles = @[@"招聘简章", @"招聘职位", @"宣讲会", @"企业形象"];
    self.tabItemWidth = VIEW_W(self.viewNav) / [self.itemTitles count];
    for (NSInteger index = 0; index < [self.itemTitles count]; index++)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(self.tabItemWidth * index, DOT_COORDINATE, self.tabItemWidth, NAVIGATION_BAR_HEIGHT);
        [button setTitle:self.itemTitles[index] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:14]];
        if (index == 0) {
            [button setTitleColor:UIColorWithRGBA(0.0f, 192.0f, 111.0f, 1.0f) forState:UIControlStateNormal];
        }
        else {
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
        [button setTag:index];
        [button addTarget:self action:@selector(itemPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.viewNav addSubview:button];
    }
    self.viewItemLine = [[UIView alloc] initWithFrame:CGRectMake(0.0f, NAVIGATION_BAR_HEIGHT - 3.0f, self.tabItemWidth, 3.0f)];
    self.viewItemLine.backgroundColor = NAVBARCOLOR;
    [self.viewNav addSubview:self.viewItemLine];
    UIView *viewNavSeparate = [[UIView alloc] initWithFrame:CGRectMake(0.0f, NAVIGATION_BAR_HEIGHT - 0.5f, VIEW_W(self.viewNav), 0.5f)];
    viewNavSeparate.backgroundColor = SEPARATECOLOR;
    [self.viewNav addSubview:viewNavSeparate];
    [self.viewScroll addSubview:self.viewNav];
}

- (void)initContent {
    self.viewContent = [[UIScrollView alloc] initWithFrame:CGRectMake(0, VIEW_BY(self.viewNav), SCREEN_WIDTH, SCREEN_HEIGHT - VIEW_BY(self.viewNav))];
    [self.viewContent setContentSize:CGSizeMake(SCREEN_WIDTH * [self.itemTitles count], self.viewContent.frame.size.height)];
    [self.viewContent setDelegate:self];
    [self.viewContent setTag:1];
    [self.viewContent setBounces:NO];
    [self.viewContent setPagingEnabled:YES];
    [self.viewScroll addSubview:self.viewContent];
    [self.viewScroll bringSubviewToFront:self.viewNav];
    
    CpBrochureViewController *cpBrochureCtrl = [[CpBrochureViewController alloc] init];
    cpBrochureCtrl.companySecondId = self.secondId;
    cpBrochureCtrl.secondId = self.cpBrochureSecondId;
    cpBrochureCtrl.companyCtrl = self;
    [self addChildViewController:cpBrochureCtrl];
    [self.viewContent addSubview:cpBrochureCtrl.view];
    self.btnJob = [[UIButton alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - VIEW_BY(self.viewNav) - 40, VIEW_W(self.viewContent), 40)];
    [self.btnJob setBackgroundColor:NAVBARCOLOR];
    [self.btnJob setTitle:@"查看招聘职位" forState:UIControlStateNormal];
    [self.btnJob.titleLabel setFont:FONT(14)];
    [self.btnJob setTag:1];
    [self.btnJob addTarget:self action:@selector(itemPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.viewContent addSubview:self.btnJob];
    
    CpJobListViewController *cpJobListCtrl = [[CpJobListViewController alloc] init];
    cpJobListCtrl.secondId = self.cpBrochureSecondId;
    cpJobListCtrl.companyCtrl = self;
    CGRect frameThis = cpJobListCtrl.view.frame;
    frameThis.origin.x = SCREEN_WIDTH;
    [cpJobListCtrl.view setFrame:frameThis];
    [self addChildViewController:cpJobListCtrl];
    [self.viewContent addSubview:cpJobListCtrl.view];
    
    CpCampusViewController *cpCampusCtrl = [[CpCampusViewController alloc] init];
    cpCampusCtrl.companySecondId = self.secondId;
    cpCampusCtrl.companyCtrl = self;
    frameThis = cpCampusCtrl.view.frame;
    frameThis.origin.x = SCREEN_WIDTH * 2;
    [cpCampusCtrl.view setFrame:frameThis];
    [self addChildViewController:cpCampusCtrl];
    [self.viewContent addSubview:cpCampusCtrl.view];
    
    CpImageViewController *cpImageCtrl = [[CpImageViewController alloc] init];
    cpImageCtrl.secondId = self.secondId;
    cpImageCtrl.companyCtrl = self;
    frameThis = cpImageCtrl.view.frame;
    frameThis.origin.x = SCREEN_WIDTH * 3;
    [cpImageCtrl.view setFrame:frameThis];
    [self addChildViewController:cpImageCtrl];
    [self.viewContent addSubview:cpImageCtrl.view];
}

- (void)setHeight:(NSInteger)index {
    float heightForContent = MAX(SCREEN_HEIGHT - VIEW_BY(self.viewNav), [[self.arrayViewHeight objectAtIndex:index] floatValue]);
    CGRect frameContent = self.viewContent.frame;
    frameContent.size.height = heightForContent;
    [self.viewContent setFrame:frameContent];
    
    CGSize sizeContent = self.viewContent.contentSize;
    sizeContent.height = heightForContent;
    [self.viewContent setContentSize:sizeContent];
    
    CGSize sizeScroll = self.viewScroll.contentSize;
    sizeScroll.height = VIEW_BY(self.viewContent);
    [self.viewScroll setContentSize:sizeScroll];
//    if (self.viewScroll.contentOffset.y > VIEW_BY(self.viewCpInfo) - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT) {
//        [self.viewScroll setContentOffset:CGPointMake(self.viewScroll.contentOffset.x, 0)];
//    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.tabIndex == 2) {
        [self.viewContent setContentOffset:CGPointMake(SCREEN_WIDTH * self.tabIndex, 0)];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.viewScroll setContentOffset:CGPointMake(self.viewScroll.contentOffset.x, self.viewScroll.contentOffset.y + 1)];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:NULL forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setAlpha:1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.tag == 0) {
        if (scrollView.contentOffset.y <= (VIEW_BY(self.viewCpInfo) - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT)) {
            CGRect frameNavTab = self.viewNav.frame;
            frameNavTab.origin.y = VIEW_BY(self.viewCpInfo);
            [self.viewNav setFrame:frameNavTab];
            if (scrollView.contentOffset.y <= 30.0f) {
                [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
                [self.navigationController.navigationBar setShadowImage:[UIImage new]];
                [self.navigationController.navigationBar setAlpha:1];
            }
            else {
                [self.navigationController.navigationBar setBackgroundImage:NULL forBarMetrics:UIBarMetricsDefault];
                [self.navigationController.navigationBar setAlpha:scrollView.contentOffset.y / (VIEW_BY(self.viewCpInfo) - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT)];
            }
            self.title = @"";
        }
        else {
            CGRect frameNavTab = self.viewNav.frame;
            frameNavTab.origin.y = scrollView.contentOffset.y + NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT;
            [self.viewNav setFrame:frameNavTab];
            [self.navigationController.navigationBar setAlpha:1.0f];
            self.title = self.companyTitle;
        }
        CGRect frameBtnJob = self.btnJob.frame;
        frameBtnJob.origin.y = SCREEN_HEIGHT - VIEW_BY(self.viewCpInfo) - NAVIGATION_BAR_HEIGHT - 40 + scrollView.contentOffset.y;
        [self.btnJob setFrame:frameBtnJob];
    }
    else if (scrollView.tag == 1) {
        NSInteger currentIndex = scrollView.contentOffset.x / SCREEN_WIDTH;
        NSLog(@"currentIndex=%ld",(long)currentIndex);
        for (UIView *childView in self.viewNav.subviews) {
            if ([childView isKindOfClass:[UIButton class]] && childView.tag == currentIndex) {
                [self itemChanged:(UIButton *)childView];
            }
        }
    }
}

- (void)shareClick {
    NSString *shareType = @"";
    NSString *shareId = @"";
    if (self.tabIndex == 0) {
        self.shareUrl = [NSString stringWithFormat:@"/notice%@.html", self.cpBrochureSecondId];
        shareType = @"202";
        shareId = self.cpBrochureSecondId;
    }
    else if (self.tabIndex == 1) {
        self.shareUrl = [NSString stringWithFormat:@"/joblist%@.html", self.cpBrochureSecondId];
        shareType = @"209";
        shareId = self.cpBrochureSecondId;
    }
    else if (self.tabIndex == 2) {
        self.shareUrl = [NSString stringWithFormat:@"/preach%@.html", self.secondId];
        shareType = @"204";
        shareId = self.secondId;
    }
    else if (self.tabIndex == 3) {
        self.shareUrl = [NSString stringWithFormat:@"/image%@.html", self.secondId];
        shareType = @"205";
        shareId = self.secondId;
    }
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetShareTitle" params:[NSDictionary dictionaryWithObjectsAndKeys:shareType, @"pageID", shareId, @"id", nil] tag:1];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1) {
        NSArray *arrContent = [CommonFunc getArrayFromXml:requestData tableName:@"Table"];
        NSString *shareContent = [[arrContent objectAtIndex:0] objectForKey:@"ContentText"];
        NSString *shareContent2 = [[arrContent objectAtIndex:0] objectForKey:@"ContentText2"];
        NSString *shareTitle = [[arrContent objectAtIndex:0] objectForKey:@"Title"];
        [CommonFunc share:shareTitle content:shareContent url:self.shareUrl view:self.view imageUrl:self.logoUrl content2:shareContent2];
    }
    else if (request.tag == 2) {
        self.companyData = [[CommonFunc getArrayFromXml:requestData tableName:@"Table"] objectAtIndex:0];
        self.companyTitle = [self.companyData objectForKey:@"Name"];
        NSArray *arrLogoData = [CommonFunc getArrayFromXml:requestData tableName:@"Table1"];
        if (arrLogoData.count > 0) {
            self.logoData = [arrLogoData objectAtIndex:0];
        }
        self.arrIndustryData = [CommonFunc getArrayFromXml:requestData tableName:@"Table2"];
        self.top500Data = [[CommonFunc getArrayFromXml:requestData tableName:@"Table3"] objectAtIndex:0];
        [self fillData];
    }
}

- (void)itemPressed:(UIButton *)sender {
    [self.viewContent setContentOffset:CGPointMake(SCREEN_WIDTH * sender.tag, 0)];
    self.tabIndex = sender.tag;
}

- (void)itemChanged:(UIButton *)sender {
    [self setHeight:sender.tag];
    for (UIView *childView in self.viewNav.subviews) {
        if ([childView isKindOfClass:[UIButton class]]) {
            [(UIButton *)childView setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
    }
    [sender setTitleColor:NAVBARCOLOR forState:UIControlStateNormal];
    [UIView animateWithDuration:0.2f animations:^{
        self.viewItemLine.frame = CGRectMake(self.tabItemWidth * sender.tag, self.viewItemLine.frame.origin.y, self.viewItemLine.frame.size.width, self.viewItemLine.frame.size.height);
    }];
}

- (void)favoriteClick:(UIButton *)sender {
    if (![CommonFunc checkLogin]) {
        UIViewController *loginCtrl = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"loginView"];
        [self.navigationController pushViewController:loginCtrl animated:true];
        return;
    }
    if (sender.tag == 0) {
        [sender setTitle:@"已关注" forState:UIControlStateNormal];
        [sender setTag:1];
        UIImageView *imgFavoriteAnimate = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"coBigHeart.png"]];
        imgFavoriteAnimate.center = self.view.window.center;
        [imgFavoriteAnimate setFrame:CGRectMake((SCREEN_WIDTH - 100) / 2, SCREEN_HEIGHT, 100, 80)];
        [self.view.window addSubview:imgFavoriteAnimate];
        [UIView animateWithDuration:0.6 animations:^{
            imgFavoriteAnimate.center = self.view.window.center;
            [imgFavoriteAnimate setFrame:CGRectMake(VIEW_X(imgFavoriteAnimate), VIEW_Y(imgFavoriteAnimate) - 30, VIEW_W(imgFavoriteAnimate), VIEW_H(imgFavoriteAnimate))];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 animations:^{
                imgFavoriteAnimate.center = self.view.window.center;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:1 animations:^{
                    [imgFavoriteAnimate setFrame:CGRectMake(VIEW_X(imgFavoriteAnimate), VIEW_Y(imgFavoriteAnimate), SCREEN_HEIGHT, (SCREEN_HEIGHT * 4) / 5)];
                    imgFavoriteAnimate.center = self.view.window.center;
                    [imgFavoriteAnimate setAlpha:0];
                } completion:^(BOOL finished) {
                    [imgFavoriteAnimate removeFromSuperview];
                }];
            }];
        }];
        self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"InsertPaAttention" params:[NSDictionary dictionaryWithObjectsAndKeys:[CommonFunc getPaMainId], @"paMainID", @"1", @"attentionType", [self.companyData objectForKey:@"ID"], @"attentionID", [CommonFunc getCode], @"code", nil] tag:3];
        [self.runningRequest setDelegate:self];
        [self.runningRequest startAsynchronous];
        [USER_DEFAULT setValue:@"0" forKey:@"attentionType"];
    }
    else {
        [sender setTitle:@"+关注" forState:UIControlStateNormal];
        [sender setTag:0];
        self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"DeletePaAttention" params:[NSDictionary dictionaryWithObjectsAndKeys:[CommonFunc getPaMainId], @"paMainID", @"1", @"attentionType", [self.companyData objectForKey:@"ID"], @"attentionID", [CommonFunc getCode], @"code", nil] tag:4];
        [self.runningRequest setDelegate:self];
        [self.runningRequest startAsynchronous];
    }
}

- (void)mapClick {
    MapViewController *mapCtrl = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"mapView"];
    mapCtrl.lat = [[self.companyData objectForKey:@"Lat"] floatValue];
    mapCtrl.lng = [[self.companyData objectForKey:@"Lng"] floatValue];
    mapCtrl.mapTitle = [self.companyData objectForKey:@"Name"];
    mapCtrl.mapAddress = [self.companyData objectForKey:@"Address"];
    [self.navigationController pushViewController:mapCtrl animated:YES];
}

@end

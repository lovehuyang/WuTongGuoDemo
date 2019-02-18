//
//  CpMainViewController.m
//  wutongguo
//
//  Created by Lucifer on 15-5-16.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "CpMainViewController.h"
#import "CompanyViewController.h"
#import "CpBrandViewController.h"
#import "CommonMacro.h"
#import "CustomLabel.h"
#import "CommonFunc.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "GDataXMLNode.h"
#import "UIImageView+WebCache.h"
#import "MapViewController.h"

@interface CpMainViewController ()<NetWebServiceRequestDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;
@property (nonatomic, strong) NSDictionary *companyData;
@property (nonatomic, strong) NSArray *arrIndustryData;
@property (nonatomic, strong) NSDictionary *logoData;
@property (nonatomic, strong) NSDictionary *top500Data;
@property (nonatomic, strong) NSArray *arrOtherCompanyData;

@property (nonatomic, strong) UIView *viewDetail;
@property (nonatomic, strong) UILabel *lbDescription;
@property (nonatomic, strong) UIView *viewSeparate;
@property (nonatomic, strong) UIView *viewOther;
@property (strong, nonatomic) UIScrollView *scrollView;
@end

@implementation CpMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - TAB_TAB_HEIGHT - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT)];
    [self.view addSubview:self.scrollView];
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.view addSubview:self.loadingView];
    [self getData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)getData {
    [self.loadingView startAnimating];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetCpMainDetailByID" params:[NSDictionary dictionaryWithObjectsAndKeys:self.secondId, @"cpMainID", [CommonFunc getPaMainId], @"paMainID", [CommonFunc getCode], @"code", nil] tag:1];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (void)fillData {
    //公司名称view
    UIView *viewCompany = [[UIView alloc] initWithFrame:CGRectMake(-1, -1, SCREEN_WIDTH + 2, 70)];
    [viewCompany setBackgroundColor:[UIColor whiteColor]];
    [viewCompany.layer setBorderColor:[SEPARATECOLOR CGColor]];
    [viewCompany.layer setBorderWidth:0.5];
    //公司Logo
    UIImageView *imgCompany = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 55, 50)];
    if (self.logoData != nil) {
        NSString *path = [NSString stringWithFormat:@"%d",([[self.companyData objectForKey:@"ID"] intValue] / 10000 + 1) * 10000];
        NSInteger lastLength = 6 - path.length;
        for (int i = 0; i < lastLength; i++) {
            path = [NSString stringWithFormat:@"0%@",path];
        }
        path = [NSString stringWithFormat:@"L%@",path];
        path = [NSString stringWithFormat:@"http://down.51rc.com/imagefolder/wutongguo/CP/Logo/%@/%@",path,[self.logoData objectForKey:@"Url"]];
        [imgCompany sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:[UIImage imageNamed:@"coNoSchoolLogo.png"]];
    }
    else {
        [imgCompany setImage:[UIImage imageNamed:@"coNoSchoolLogo.png"]];
    }
    [viewCompany addSubview:imgCompany];
    //公司名称
    UIView *viewCompanyTitle = [[UIView alloc] initWithFrame:CGRectMake(VIEW_BX(imgCompany) + 5, 15, SCREEN_WIDTH - VIEW_BX(imgCompany) - 45, 100)];
    [viewCompany addSubview:viewCompanyTitle];
    CustomLabel *lbCompany = [[CustomLabel alloc] initWithFixed:CGRectMake(0, 0, VIEW_W(viewCompanyTitle), 100) content:[self.companyData objectForKey:@"Name"] size:14 color:nil];
    [viewCompanyTitle addSubview:lbCompany];
    NSString *top500Img = @"";
    if ([[self.top500Data objectForKey:@"world"] isEqualToString:@"1"]) {
        top500Img = @"coWorldTop500.png";
    }
    else if ([[self.top500Data objectForKey:@"china"] isEqualToString:@"1"]) {
        top500Img = @"coChinaTop500.png";
    }
    //公司名称每行的内容 用来计算最后一行的宽度，方便文字后面加500强图片
    NSArray *arrCompanyRow = [CommonFunc getSeparatedLinesFromLabel:lbCompany];
    CGSize sizeLastRow = LABEL_SIZE([arrCompanyRow objectAtIndex:arrCompanyRow.count - 1], SCREEN_WIDTH - VIEW_BX(imgCompany) - 40, 20, 14);
    CGPoint pointLast = CGPointMake(VIEW_X(lbCompany) + sizeLastRow.width + 2, VIEW_BY(lbCompany) - sizeLastRow.height + 2);
    float viewCompanyHeight = VIEW_BY(lbCompany);
    if (top500Img.length > 0) {
        UIImageView *imgTop500 = [[UIImageView alloc] initWithFrame:CGRectMake(pointLast.x, pointLast.y, 55, 16)];
        [imgTop500 setImage:[UIImage imageNamed:top500Img]];
        //如果加上500强图标之后过长，放到下一行显示
        if (VIEW_BX(imgTop500) > VIEW_W(viewCompanyTitle)) {
            CGRect frame500 = imgTop500.frame;
            frame500.origin.x = VIEW_X(lbCompany);
            frame500.origin.y = VIEW_BY(lbCompany) + 3;
            [imgTop500 setFrame:frame500];
        }
        [viewCompanyTitle addSubview:imgTop500];
        pointLast = CGPointMake(VIEW_BX(imgTop500) + 2, VIEW_Y(imgTop500));
        viewCompanyHeight = VIEW_BY(imgTop500);
    }
    if ([[self.companyData objectForKey:@"StarLevel"] intValue] > 4) {
        CustomLabel *lbBrand = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(pointLast.x, pointLast.y, 300, 16) content:[NSString stringWithFormat:@"%@ 旗下", [self.companyData objectForKey:@"CpBrandName"]] size:11 color:UIColorWithRGBA(28, 64, 101, 1)];
        [lbBrand setFrame:CGRectMake(lbBrand.frame.origin.x, lbBrand.frame.origin.y, lbBrand.frame.size.width + 5, lbBrand.frame.size.height)];
        [lbBrand setTextAlignment:NSTextAlignmentCenter];
        [lbBrand.layer setBorderWidth:1];
        [lbBrand.layer setBorderColor:[SEPARATECOLOR CGColor]];
        [lbBrand.layer setCornerRadius:3];
        //如果加上品牌之后过长，放到下一行显示
        if (VIEW_BX(lbBrand) > VIEW_W(viewCompanyTitle)) {
            CGRect framelbBrand = lbBrand.frame;
            framelbBrand.origin.x = VIEW_X(lbCompany);
            framelbBrand.origin.y = pointLast.y + 18;
            [lbBrand setFrame:framelbBrand];
        }
        [viewCompanyTitle addSubview:lbBrand];
        viewCompanyHeight = VIEW_BY(lbBrand);
    }
    [viewCompanyTitle setFrame:CGRectMake(viewCompanyTitle.frame.origin.x, viewCompanyTitle.frame.origin.y, viewCompanyTitle.frame.size.width, viewCompanyHeight)];
    if (VIEW_BY(imgCompany) > VIEW_BY(viewCompanyTitle)) {
        viewCompanyHeight = VIEW_BY(imgCompany) + 10;
        [viewCompanyTitle setCenter:CGPointMake(viewCompanyTitle.center.x, imgCompany.center.y)];
    }
    else {
        viewCompanyHeight = VIEW_BY(viewCompanyTitle) + 10;
        [imgCompany setCenter:CGPointMake(imgCompany.center.x, viewCompanyTitle.center.y)];
    }
    [viewCompany setFrame:CGRectMake(-1, -1, SCREEN_WIDTH + 2, viewCompanyHeight)];
    //关注按钮
    NSInteger IsAttention = [[self.top500Data objectForKey:@"IsAttention"] integerValue];
    UIButton *btnFocus = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_W(viewCompany) - 40, VIEW_Y(imgCompany), 30, VIEW_H(imgCompany))];
    [btnFocus setBackgroundColor:[UIColor whiteColor]];
    [btnFocus addTarget:self action:@selector(favoriteClick:) forControlEvents:UIControlEventTouchUpInside];
    [viewCompany addSubview:btnFocus];
    UIImageView *imgFocus = [[UIImageView alloc] initWithFrame:CGRectMake(5, 7, 20, 20)];
    [imgFocus setImage:[UIImage imageNamed:(IsAttention == 1 ? @"coFavorite.png" : @"coUnFavorite.png")]];
    [btnFocus addSubview:imgFocus];
    CustomLabel *lbFocus = [[CustomLabel alloc] initWithFrame:CGRectMake(VIEW_X(imgFocus) - 4.5, VIEW_BY(imgFocus), 30, 20) content:(IsAttention == 1 ? @"已关注" : @"关注") size:10 color:(IsAttention == 1 ? UIColorWithRGBA(255, 12, 92, 1) : NAVBARCOLOR)];
    [lbFocus setTextAlignment:NSTextAlignmentCenter];
    [btnFocus addSubview:lbFocus];
    [self.scrollView addSubview:viewCompany];
    
    //公司详细信息
    self.viewDetail = [[UIView alloc] initWithFrame:CGRectMake(VIEW_X(viewCompany), VIEW_BY(viewCompany) + 10, VIEW_W(viewCompany), 500)];
    [self.viewDetail setBackgroundColor:[UIColor whiteColor]];
    [self.viewDetail.layer setBorderColor:[SEPARATECOLOR CGColor]];
    [self.viewDetail.layer setBorderWidth:0.5];
    //所在地区
    float fontSize = 13;
    float heightForSpacing = 10;
    CustomLabel *lbAddressTitle = [[CustomLabel alloc] initWithFixed:CGRectMake(VIEW_X(imgCompany), 10, 100, 20) content:@"所在地区：" size:fontSize color:TEXTGRAYCOLOR];
    [self.viewDetail addSubview:lbAddressTitle];
    CustomLabel *lbAddress = [[CustomLabel alloc] initWithFixed:CGRectMake(VIEW_BX(lbAddressTitle), VIEW_Y(lbAddressTitle), VIEW_W(self.viewDetail) - VIEW_BX(lbAddressTitle) - 15, 200) content:[self.companyData objectForKey:@"FullName"] size:fontSize color:nil];
    [self.viewDetail addSubview:lbAddress];
    if ([[self.companyData objectForKey:@"Lat"] length] > 0) {
        //所在地区每行的内容 用来计算最后一行的宽度，方便文字后面加地图图标
        UIButton *btnMap = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_BX(lbAddress) + 3, VIEW_Y(lbAddress), 50, VIEW_H(lbAddress))];
        [btnMap addTarget:self action:@selector(mapClick) forControlEvents:UIControlEventTouchUpInside];
        [self.viewDetail addSubview:btnMap];
        UIImageView *imgMap = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, VIEW_H(btnMap), VIEW_H(btnMap))];
        [imgMap setImage:[UIImage imageNamed:@"schoolMap.png"]];
        [btnMap addSubview:imgMap];
        CustomLabel *lbMap = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgMap), VIEW_Y(imgMap), 50, VIEW_H(imgMap)) content:@"查看地图" size:12 color:UIColorWithRGBA(68, 93, 169, 1)];
        [btnMap addSubview:lbMap];
    }
    //企业类型
    CustomLabel *lbKindTitle = [[CustomLabel alloc] initWithFixed:CGRectMake(VIEW_X(lbAddressTitle), VIEW_BY(lbAddress) + heightForSpacing, 100, 20) content:@"企业类型：" size:fontSize color:TEXTGRAYCOLOR];
    [self.viewDetail addSubview:lbKindTitle];
    CustomLabel *lbKind = [[CustomLabel alloc] initWithFixed:CGRectMake(VIEW_BX(lbKindTitle), VIEW_Y(lbKindTitle), VIEW_W(self.viewDetail) - VIEW_BX(lbKindTitle) - 15, 20) content:[self.companyData objectForKey:@"CompanyKindName"] size:fontSize color:nil];
    [self.viewDetail addSubview:lbKind];
    //企业规模
    CustomLabel *lbSizeTitle = [[CustomLabel alloc] initWithFixed:CGRectMake(VIEW_X(lbKindTitle), VIEW_BY(lbKind) + heightForSpacing, 100, 20) content:@"企业规模：" size:fontSize color:TEXTGRAYCOLOR];
    [self.viewDetail addSubview:lbSizeTitle];
    CustomLabel *lbSize = [[CustomLabel alloc] initWithFixed:CGRectMake(VIEW_BX(lbSizeTitle), VIEW_Y(lbSizeTitle), VIEW_W(self.viewDetail) - VIEW_BX(lbSizeTitle) - 15, 20) content:[self.companyData objectForKey:@"CompanySizeName"] size:fontSize color:nil];
    [self.viewDetail addSubview:lbSize];
    //所属行业
    NSMutableString *industry = [[NSMutableString alloc] init];
    for (NSDictionary *oneIndustry in self.arrIndustryData) {
        [industry appendFormat:@"%@ ", [oneIndustry objectForKey:@"NAME"]];
    }
    CustomLabel *lbIndustryTitle = [[CustomLabel alloc] initWithFixed:CGRectMake(VIEW_X(lbSizeTitle), VIEW_BY(lbSize) + heightForSpacing, 100, 20) content:@"所属行业：" size:fontSize color:TEXTGRAYCOLOR];
    [self.viewDetail addSubview:lbIndustryTitle];
    CustomLabel *lbIndustry = [[CustomLabel alloc] initWithFixed:CGRectMake(VIEW_BX(lbIndustryTitle), VIEW_Y(lbIndustryTitle), VIEW_W(self.viewDetail) - VIEW_BX(lbIndustryTitle) - 15, 200) content:industry size:fontSize color:nil];
    [self.viewDetail addSubview:lbIndustry];
    Boolean hasUrl = [[self.companyData objectForKey:@"HomePage"] length] > 0;
    //企业主页
    CustomLabel *lbUrl;
    if (hasUrl) {
        CustomLabel *lbUrlTitle = [[CustomLabel alloc] initWithFixed:CGRectMake(VIEW_X(lbIndustryTitle), VIEW_BY(lbIndustry) + heightForSpacing, 100, 20) content:@"企业官网：" size:fontSize color:TEXTGRAYCOLOR];
        [self.viewDetail addSubview:lbUrlTitle];
        lbUrl = [[CustomLabel alloc] initWithFixed:CGRectMake(VIEW_BX(lbUrlTitle), VIEW_Y(lbUrlTitle), VIEW_W(self.viewDetail) - VIEW_BX(lbUrlTitle) - 15, 200) content:[self.companyData objectForKey:@"HomePage"] size:fontSize color:nil];
        [lbUrl setLineBreakMode:NSLineBreakByCharWrapping];
        [self.viewDetail addSubview:lbUrl];
    }
    //企业简介
    NSString *content = [self.companyData objectForKey:@"ContentText"];
    self.lbDescription = [[CustomLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_X(lbAddressTitle), VIEW_BY((hasUrl ? lbUrl : lbIndustry)) + heightForSpacing, VIEW_W(self.viewDetail) - VIEW_X(lbAddressTitle) - 15, 2000) content:content size:fontSize color:nil];
    [self.viewDetail addSubview:self.lbDescription];
    //是否显示查看更多
    float maxDescriptionHeight = 120;
    if (self.lbDescription.frame.size.height > maxDescriptionHeight) {
        //添加分割线
        self.viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(VIEW_X(lbAddressTitle), VIEW_Y(self.lbDescription) + maxDescriptionHeight + heightForSpacing, VIEW_W(self.viewDetail) - VIEW_X(lbAddressTitle) - 15, 0.5)];
        [self.viewSeparate setBackgroundColor:SEPARATECOLOR];
        [self.viewDetail addSubview:self.viewSeparate];
        //查看更多按钮
        UIButton *btnMore = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 100) / 2, VIEW_BY(self.viewSeparate) + 5, 100, 30)];
        [btnMore setTitle:@"查看更多" forState:UIControlStateNormal];
        [btnMore.titleLabel setFont:FONT(fontSize)];
        [btnMore setTitleColor:TEXTGRAYCOLOR forState:UIControlStateNormal];
        [btnMore setTag:self.lbDescription.frame.size.height + 5];
        [btnMore addTarget:self action:@selector(expandDescription:) forControlEvents:UIControlEventTouchUpInside];
        [btnMore setContentEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
        [self.viewDetail addSubview:btnMore];
        //查看更多图标
        UIImageView *imgExpand = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_W(btnMore) - 25, 7, 16, 16)];
        [imgExpand setImage:[UIImage imageNamed:@"coExpand.png"]];
        [btnMore addSubview:imgExpand];
        //企业简介收起
        CGRect frameDescription = self.lbDescription.frame;
        frameDescription.size.height = maxDescriptionHeight;
        [self.lbDescription setFrame:frameDescription];
        //viewDetail高度计算
        CGRect frameDetail = self.viewDetail.frame;
        frameDetail.size.height = VIEW_BY(btnMore) + 10;
        [self.viewDetail setFrame:frameDetail];
    }
    else {
        //viewDetail高度计算
        CGRect frameDetail = self.viewDetail.frame;
        frameDetail.size.height = VIEW_BY(self.lbDescription) + 10;
        [self.viewDetail setFrame:frameDetail];
    }
    [self.scrollView addSubview:self.viewDetail];
    [self getOtherCompanyData];
}

- (void)getOtherCompanyData {
    [self.loadingView startAnimating];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetCpMainByCpBrandID" params:[NSDictionary dictionaryWithObjectsAndKeys:[self.companyData objectForKey:@"SecondID"], @"cpMainID", [self.companyData objectForKey:@"CpBrandSecondID"], @"cpBrandID", nil] tag:2];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (void)fillOtherCompany {
    if (self.arrOtherCompanyData.count == 0) {
        //设置scrollview的contentsize
        [self.scrollView setContentSize:CGSizeMake(SCREEN_WIDTH, VIEW_BY(self.viewDetail) + 10)];
        return;
    }
    float fontSize = 13;
    //其他企业
    self.viewOther = [[UIView alloc] initWithFrame:CGRectMake(VIEW_X(self.viewDetail), VIEW_BY(self.viewDetail) + 10, VIEW_W(self.viewDetail), 80)];
    [self.viewOther setBackgroundColor:[UIColor whiteColor]];
    [self.viewOther.layer setBorderColor:[SEPARATECOLOR CGColor]];
    [self.viewOther.layer setBorderWidth:0.5];
    CustomLabel *lbOtherTitle = [[CustomLabel alloc] initWithFixed:CGRectMake(15, 10, VIEW_W(self.viewOther) - 15 - 15, 500) content:[NSString stringWithFormat:@"%@旗下其他企业", [self.companyData objectForKey:@"CpBrandName"]] size:fontSize color:NAVBARCOLOR];
    [self.viewOther addSubview:lbOtherTitle];
    float heightForViewOther = VIEW_BY(lbOtherTitle) + 5;
    for (int index = 0; index < MIN(self.arrOtherCompanyData.count, 5); index++) {
        NSDictionary *otherCompanyData = [self.arrOtherCompanyData objectAtIndex:index];
        UIButton *btnOther = [[UIButton alloc] initWithFrame:CGRectMake(0, heightForViewOther + 5, SCREEN_WIDTH, 38)];
        [btnOther addTarget:self action:@selector(companyClick:) forControlEvents:UIControlEventTouchUpInside];
        [btnOther setTag:index];
        [self.viewOther addSubview:btnOther];
        UIImageView *imgPoint = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_X(lbOtherTitle), 15, 8, 8)];
        [imgPoint setImage:[UIImage imageNamed:@"coGreenPoint.png"]];
        [btnOther addSubview:imgPoint];
        CustomLabel *lbOtherCompany = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgPoint) + 5, 9, VIEW_W(self.viewOther) - VIEW_BX(imgPoint) - 3, 20) content:[otherCompanyData objectForKey:@"Name"] size:fontSize color:nil];
        [btnOther addSubview:lbOtherCompany];
        UIView *viewOtherSeparate = [[UIView alloc] initWithFrame:CGRectMake(10, VIEW_BY(btnOther) + 5, VIEW_W(self.viewOther) - 10 * 2, 0.5)];
        [viewOtherSeparate setBackgroundColor:SEPARATECOLOR];
        [self.viewOther addSubview:viewOtherSeparate];
        heightForViewOther = VIEW_BY(viewOtherSeparate);
    }
    if (self.arrOtherCompanyData.count > 0) {
        //查看更多按钮
        UIButton *btnOtherMore = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 100) / 2, heightForViewOther + 10, 100, 30)];
        [btnOtherMore setTitle:@"查看更多" forState:UIControlStateNormal];
        [btnOtherMore.titleLabel setFont:FONT(14)];
        [btnOtherMore setTitleColor:TEXTGRAYCOLOR forState:UIControlStateNormal];
        [btnOtherMore addTarget:self action:@selector(otherCompany:) forControlEvents:UIControlEventTouchUpInside];
        [self.viewOther addSubview:btnOtherMore];
        heightForViewOther = VIEW_BY(btnOtherMore) + 10;
    }
    //设置viewOther高度
    CGRect frameOther = self.viewOther.frame;
    frameOther.size.height = heightForViewOther;
    [self.viewOther setFrame:frameOther];
    [self.scrollView addSubview:self.viewOther];
    //设置scrollview的contentsize
    [self.scrollView setContentSize:CGSizeMake(SCREEN_WIDTH, VIEW_BY(self.viewOther) + 10)];
}

- (void)expandDescription:(UIButton *)sender {
    //企业简介展开
    CGRect frameDescription = self.lbDescription.frame;
    frameDescription.size.height = sender.tag;
    [self.lbDescription setFrame:frameDescription];
    //viewDetail高度计算
    CGRect frameDetail = self.viewDetail.frame;
    frameDetail.size.height = VIEW_BY(self.lbDescription) + 10;
    [self.viewDetail setFrame:frameDetail];
    [sender removeFromSuperview];
    [self.viewSeparate removeFromSuperview];
    //viewOther重新计算y
    CGRect frameOther = self.viewOther.frame;
    frameOther.origin.y = VIEW_BY(self.viewDetail) + 10;
    [self.viewOther setFrame:frameOther];
    //设置scrollview的contentsize
    if (self.arrOtherCompanyData.count > 0) {
        [self.scrollView setContentSize:CGSizeMake(SCREEN_WIDTH, VIEW_BY(self.viewOther) + 10)];
    }
    else {
        [self.scrollView setContentSize:CGSizeMake(SCREEN_WIDTH, VIEW_BY(self.viewDetail) + 10)];
    }
}

- (void)otherCompany:(UIButton *)sender {
    CpBrandViewController *cpBrandCtrl = [[CpBrandViewController alloc] init];
    cpBrandCtrl.secondId = [self.companyData objectForKey:@"CpBrandSecondID"];
    cpBrandCtrl.title = [self.companyData objectForKey:@"CpBrandName"];
    [self.navigationController pushViewController:cpBrandCtrl animated:YES];
}

- (void)companyClick:(UIButton *)sender {
    NSDictionary *otherCompanyData = [self.arrOtherCompanyData objectAtIndex:sender.tag];
    CompanyViewController *companyCtrl = [[CompanyViewController alloc] init];
    companyCtrl.secondId = [otherCompanyData objectForKey:@"SecondID"];
    [self.navigationController pushViewController:companyCtrl animated:true];
}

- (void)favoriteClick:(UIButton *)sender {
    if (![CommonFunc checkLogin]) {
        UIViewController *loginCtrl = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"loginView"];
        [self.navigationController pushViewController:loginCtrl animated:true];
        return;
    }
    NSInteger IsAttention = [[self.top500Data objectForKey:@"IsAttention"] integerValue];
    if (IsAttention == 0) {
        for (UIView *view in sender.subviews) {
            if ([view isKindOfClass:[UIImageView class]]) {
                [(UIImageView *)view setImage:[UIImage imageNamed:@"coFavorite.png"]];
            }
            else if ([view isKindOfClass:[UILabel class]]) {
                [(UILabel *)view setText:@"已关注"];
                [(UILabel *)view setTextColor:UIColorWithRGBA(255, 12, 92, 1)];
            }
        }
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
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    [self.loadingView stopAnimating];
    if (request.tag == 1) {
        self.companyData = [[CommonFunc getArrayFromXml:requestData tableName:@"Table"] objectAtIndex:0];
        self.parentCtrl.title = [self.companyData objectForKey:@"Name"];
        NSArray *arrLogoData = [CommonFunc getArrayFromXml:requestData tableName:@"Table1"];
        if (arrLogoData.count > 0) {
            self.logoData = [arrLogoData objectAtIndex:0];
        }
        self.arrIndustryData = [CommonFunc getArrayFromXml:requestData tableName:@"Table2"];
        self.top500Data = [[CommonFunc getArrayFromXml:requestData tableName:@"Table3"] objectAtIndex:0];
        [self fillData];
    }
    else if (request.tag == 2) {
        self.arrOtherCompanyData = [CommonFunc getArrayFromXml:requestData tableName:@"Table"];
        [self fillOtherCompany];
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

//
//  CpJobDetailViewController.m
//  wutongguo
//
//  Created by Lucifer on 15-5-19.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "CpJobDetailViewController.h"
#import "CommonMacro.h"
#import "CommonFunc.h"
#import "CustomLabel.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "GDataXMLNode.h"
#import "PopupView.h"
#import "Toast+UIView.h"
#import "CompanyViewController.h"
#import "LoginViewController.h"
#import "ApplyFormViewController.h"

@interface CpJobDetailViewController ()<NetWebServiceRequestDelegate, PopupViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;
@property (nonatomic, strong) NSDictionary *jobData;
@property (nonatomic, strong) NSDictionary *cpBrochureData;
@property (nonatomic, strong) NSArray *arrRegion;
@property (nonatomic, strong) NSArray *arrMajor;
@property (nonatomic, strong) UIView *viewApplyPopup;
@property (nonatomic, strong) NSString *applyUrl;
@end

@implementation CpJobDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:BGCOLOR];
    // Do any additional setup after loading the view.
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT - 5)];
    [self.view addSubview:self.scrollView];
    //等待动画
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.view addSubview:self.loadingView];
    
    //分享
    UIButton *btnShare = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [btnShare setBackgroundImage:[UIImage imageNamed:@"coShare"] forState:UIControlStateNormal];
    [btnShare addTarget:self action:@selector(shareClick) forControlEvents:UIControlEventTouchUpInside];
    UIView *containerView = [[UIView alloc]initWithFrame:btnShare.frame];
    [containerView addSubview:btnShare];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:containerView];
    
    //获取数据
    [self getData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([[USER_DEFAULT objectForKey:@"willApplyJob"] isEqualToString:@"1"]) {
        [USER_DEFAULT removeObjectForKey:@"willApplyJob"];
        [self applyClick];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)brochureClick:(UIButton *)sender {
    CompanyViewController *companyCtrl = [[CompanyViewController alloc] init];
    companyCtrl.secondId = [self.cpBrochureData objectForKey:@"CpSecondID"];
    companyCtrl.cpBrochureSecondId = [self.cpBrochureData objectForKey:@"CpBrochureSecondID"];
    companyCtrl.tabIndex = 1;
    [self.navigationController pushViewController:companyCtrl animated:YES];
}

- (void)getData {
    [self.loadingView startAnimating];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetJobByID" params:[NSDictionary dictionaryWithObjectsAndKeys:self.secondId, @"jobID", [CommonFunc getPaMainId], @"paMainID", [CommonFunc getCode], @"code", nil] tag:1];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (void)fillData {
    self.title = [self.jobData objectForKey:@"Name"];
    NSInteger brochureStatusType = [CommonFunc getCpBrochureStatus:[self.cpBrochureData objectForKey:@"BrochureStatus"] beginDate:[self.cpBrochureData objectForKey:@"BeginDate"] endDate:[self.cpBrochureData objectForKey:@"EndDate"]];
    NSString *brochureStatus = @"";
    NSString *jobStatus = @"";
    if ([[self.jobData objectForKey:@"JobStatus"] isEqualToString:@"1"]) {
        jobStatus = @"职位已暂停";
    }
    if (brochureStatusType == 2) { //过期
        brochureStatus = @"已截止";
    }
    else if (brochureStatusType == 3) { //未开始
        brochureStatus = @"未开始";
    }
    else if (brochureStatusType == 4) { //已暂停
        brochureStatus = @"已暂停";
    }
    //立即网申按钮
    UIButton *btnApply = [[UIButton alloc] initWithFrame:CGRectMake(10, VIEW_BY(self.scrollView) + 5, SCREEN_WIDTH - 20, TAB_TAB_HEIGHT - 10)];
    if (brochureStatus.length > 0) {
        [btnApply setBackgroundColor:UIColorWithRGBA(202, 199, 204, 1)];
        [btnApply setTitle:[NSString stringWithFormat:@"网申%@", brochureStatus] forState:UIControlStateNormal];
    }
    else if (jobStatus.length > 0) {
        [btnApply setBackgroundColor:UIColorWithRGBA(202, 199, 204, 1)];
        [btnApply setTitle:jobStatus forState:UIControlStateNormal];
    }
    else {
        [btnApply setBackgroundColor:NAVBARCOLOR];
        [btnApply addTarget:self action:@selector(applyClick) forControlEvents:UIControlEventTouchUpInside];
        [btnApply setTitle:([[self.cpBrochureData objectForKey:@"ApplyType"] isEqualToString:@"2"] ? @"网申入口" : @"立即网申") forState:UIControlStateNormal];
    }
    [btnApply setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnApply.titleLabel setFont:FONT(14)];
    [btnApply.layer setMasksToBounds:YES];
    [btnApply.layer setCornerRadius:5];
    [self.view addSubview:btnApply];
    //职位名称
    UIView *viewCompany = [[UIView alloc] initWithFrame:CGRectMake(-0.5, 0, SCREEN_WIDTH + 1, 50)];
    [viewCompany setBackgroundColor:[UIColor whiteColor]];
    CustomLabel *lbCompany = [[CustomLabel alloc] initWithFixed:CGRectMake(20, 15, VIEW_W(viewCompany) - 80, 200) content:[self.jobData objectForKey:@"Name"] size:14 color:nil];
    [viewCompany addSubview:lbCompany];
    CGRect frameViewCompany = viewCompany.frame;
    frameViewCompany.size.height = VIEW_BY(lbCompany) + 15;
    [viewCompany setFrame:frameViewCompany];
    [viewCompany.layer setBorderColor:[SEPARATECOLOR CGColor]];
    [viewCompany.layer setBorderWidth:0.5];
    //职位名称前面图标
    UIView *viewTips = [[UIView alloc] initWithFrame:CGRectMake(VIEW_X(lbCompany) - 10, VIEW_Y(lbCompany), 5, VIEW_H(lbCompany))];
    [viewTips setBackgroundColor:NAVBARCOLOR];
    [viewCompany addSubview:viewTips];
    //关注按钮
    NSInteger IsAttention = [[self.jobData objectForKey:@"IsAttention"] integerValue];
    UIButton *btnFocus = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_W(viewCompany) - 40, (VIEW_H(viewCompany) - 40) / 2, 30, 40)];
    [btnFocus setBackgroundColor:[UIColor whiteColor]];
    [btnFocus addTarget:self action:@selector(favoriteClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnFocus setTag:IsAttention];
    [viewCompany addSubview:btnFocus];
    UIImageView *imgFocus = [[UIImageView alloc] initWithFrame:CGRectMake(5, 3, 20, 20)];
    [imgFocus setImage:[UIImage imageNamed:(IsAttention == 1 ? @"coFavorite.png" : @"coUnFavorite.png")]];
    [btnFocus addSubview:imgFocus];
    CustomLabel *lbFocus = [[CustomLabel alloc] initWithFrame:CGRectMake(VIEW_X(imgFocus) - 10, VIEW_BY(imgFocus), 40, 20) content:(IsAttention == 1 ? @"已关注" : @"关注") size:12 color:(IsAttention == 1 ? UIColorWithRGBA(255, 12, 92, 1) : NAVBARCOLOR)];
    [lbFocus setTextAlignment:NSTextAlignmentCenter];
    [btnFocus addSubview:lbFocus];
    [self.scrollView addSubview:viewCompany];
    //职位详情
    float heightForSpacing = 10;
    UIView *viewDetail = [[UIView alloc] initWithFrame:CGRectMake(VIEW_X(viewCompany), VIEW_BY(viewCompany) + heightForSpacing, VIEW_W(viewCompany), 500)];
    [viewDetail setBackgroundColor:[UIColor whiteColor]];
    NSString *content = @"";
    float fontSize = 12;
    //招聘简章
    UIButton *btnBrochure = [[UIButton alloc] initWithFrame:CGRectMake(0, heightForSpacing, SCREEN_WIDTH, 40)];
    [btnBrochure addTarget:self action:@selector(brochureClick:) forControlEvents:UIControlEventTouchUpInside];
    [viewDetail addSubview:btnBrochure];
    CustomLabel *lbBrochure = [[CustomLabel alloc] initWithFixed:CGRectMake(20, 5, SCREEN_WIDTH - 40, 20) content:[self.cpBrochureData objectForKey:@"Name"] size:14 color:UIColorWithRGBA(20, 62, 103, 1)];
    [btnBrochure addSubview:lbBrochure];
    
    content = [NSString stringWithFormat:@"[网申起止时间：%@-%@]", [CommonFunc stringFromDateString:[self.cpBrochureData objectForKey:@"BeginDate"] formatType:@"M月d日"], [CommonFunc stringFromDateString:[self.cpBrochureData objectForKey:@"EndDate"] formatType:@"M月d日"]];
    CustomLabel *lbBrochureDate = [[CustomLabel alloc] initWithFixed:CGRectMake(VIEW_X(lbBrochure), VIEW_BY(lbBrochure) + heightForSpacing, SCREEN_WIDTH - VIEW_X(lbBrochure) * 2, 20) content:content size:fontSize color:TEXTGRAYCOLOR];
    [btnBrochure addSubview:lbBrochureDate];
    
    CGRect frameBtnBrochure = btnBrochure.frame;
    frameBtnBrochure.size.height = VIEW_BY(lbBrochureDate) + 5;
    [btnBrochure setFrame:frameBtnBrochure];
    
    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_BY(btnBrochure) + heightForSpacing, SCREEN_WIDTH, 0.5)];
    [viewSeparate setBackgroundColor:SEPARATECOLOR];
    [viewDetail addSubview:viewSeparate];
    
    //招聘人数
    content = [self.jobData objectForKey:@"NeedNumber"];
    if ([content isEqualToString:@"0"]) {
        content = @"若干";
    }
    else {
        content = [NSString stringWithFormat:@"%@人", content];
    }
    CustomLabel *lbEmployTitle = [[CustomLabel alloc] initWithFixed:CGRectMake(20, VIEW_BY(viewSeparate) + heightForSpacing, 100, 20) content:@"招聘人数：" size:fontSize color:TEXTGRAYCOLOR];
    [viewDetail addSubview:lbEmployTitle];
    CustomLabel *lbEmploy = [[CustomLabel alloc] initWithFixed:CGRectMake(VIEW_BX(lbEmployTitle), VIEW_Y(lbEmployTitle), VIEW_W(viewDetail) - VIEW_BX(lbEmployTitle) - 15, 200) content:content size:fontSize color:nil];
    [viewDetail addSubview:lbEmploy];
    //学历要求
    CustomLabel *lbEducationTitle = [[CustomLabel alloc] initWithFixed:CGRectMake(VIEW_X(lbEmployTitle), VIEW_BY(lbEmploy) + heightForSpacing, 100, 20) content:@"学历要求：" size:fontSize color:TEXTGRAYCOLOR];
    [viewDetail addSubview:lbEducationTitle];
    CustomLabel *lbEducation = [[CustomLabel alloc] initWithFixed:CGRectMake(VIEW_BX(lbEducationTitle), VIEW_Y(lbEducationTitle), VIEW_W(viewDetail) - VIEW_BX(lbEducationTitle) - 15, 200) content:[NSString stringWithFormat:@"%@及以上", [self.jobData objectForKey:@"DegreeName"]] size:fontSize color:nil];
    [viewDetail addSubview:lbEducation];
    //工作性质
    if ([[self.jobData objectForKey:@"EmployType"] isEqualToString:@"1"]) {
        content = @"全职";
    }
    else {
        content = @"实习";
    }
    CustomLabel *lbEmployTypeTitle = [[CustomLabel alloc] initWithFixed:CGRectMake(VIEW_X(lbEmployTitle), VIEW_BY(lbEducation) + heightForSpacing, 100, 20) content:@"工作性质：" size:fontSize color:TEXTGRAYCOLOR];
    [viewDetail addSubview:lbEmployTypeTitle];
    CustomLabel *lbEmployType = [[CustomLabel alloc] initWithFixed:CGRectMake(VIEW_BX(lbEmployTypeTitle), VIEW_Y(lbEmployTypeTitle), VIEW_W(viewDetail) - VIEW_BX(lbEmployTypeTitle) - 15, 200) content:content size:fontSize color:nil];
    [viewDetail addSubview:lbEmployType];
    //工作地点
    NSMutableString *jobCity = [[NSMutableString alloc] init];
    for (NSDictionary *oneJobCity in self.arrRegion) {
        [jobCity appendFormat:@"%@ ", [oneJobCity objectForKey:@"FullName"]];
    }
    if (jobCity.length == 0) {
        [jobCity appendString:@"全国"];
    }
    CustomLabel *lbCityTitle = [[CustomLabel alloc] initWithFixed:CGRectMake(VIEW_X(lbEmployTitle), VIEW_BY(lbEmployType) + heightForSpacing, 100, 20) content:@"工作地点：" size:fontSize color:TEXTGRAYCOLOR];
    [viewDetail addSubview:lbCityTitle];
    CustomLabel *lbCity = [[CustomLabel alloc] initWithFixed:CGRectMake(VIEW_BX(lbCityTitle), VIEW_Y(lbCityTitle), VIEW_W(viewDetail) - VIEW_BX(lbCityTitle) - 15, 200) content:jobCity size:fontSize color:nil];
    [viewDetail addSubview:lbCity];
    //专业要求
    CustomLabel *lbMajorTitle = [[CustomLabel alloc] initWithFixed:CGRectMake(VIEW_X(lbEmployTitle), VIEW_BY(lbCity) + heightForSpacing, 100, 20) content:@"专业要求：" size:fontSize color:TEXTGRAYCOLOR];
    [viewDetail addSubview:lbMajorTitle];
    UIView *viewMajor = [[UIView alloc] initWithFrame:CGRectMake(VIEW_BX(lbMajorTitle), VIEW_Y(lbMajorTitle) - 1, VIEW_W(viewDetail) - VIEW_BX(lbCityTitle) - 15, 500)];
    float yForMajor = 0;
    float xForMajor = 0;
    for (NSInteger index = 0; index < self.arrMajor.count; index++) {
        CustomLabel *lbMajor = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(xForMajor, yForMajor, VIEW_W(viewMajor), 20) content:[NSString stringWithFormat:@"  %@  ", [[self.arrMajor objectAtIndex:index] objectForKey:@"Name"]] size:fontSize color:nil];
        [lbMajor.layer setBorderWidth:0.5];
        [lbMajor.layer setBorderColor:[SEPARATECOLOR CGColor]];
        //总长度大于view的宽度，另起一行显示
        if (lbMajor.frame.size.width + xForMajor > VIEW_W(viewMajor)) {
            xForMajor = 0;
            yForMajor = yForMajor + 25;
            CGRect framelbMajor = lbMajor.frame;
            framelbMajor.origin.x = xForMajor;
            framelbMajor.origin.y = yForMajor;
            [lbMajor setFrame:framelbMajor];
        }
        xForMajor = VIEW_BX(lbMajor) + 5;
        [viewMajor addSubview:lbMajor];
    }
    //计算viewMajor的高度
    CGRect frameMajor = viewMajor.frame;
    frameMajor.size.height = yForMajor + 20;
    [viewMajor setFrame:frameMajor];
    [viewDetail addSubview:viewMajor];
    //计算viewDetail的高度
    CGRect frameDetail = viewDetail.frame;
    frameDetail.size.height = VIEW_BY(viewMajor) + 10;
    [viewDetail setFrame:frameDetail];
    [self.scrollView addSubview:viewDetail];
    [viewDetail.layer setBorderColor:[SEPARATECOLOR CGColor]];
    [viewDetail.layer setBorderWidth:0.5];
    float heightForView = VIEW_BY(viewDetail);
    content = [self.jobData objectForKey:@"ContentText"];
    if ([content length] > 0) {
        //职位描述
        UIView *viewDescription = [[UIView alloc] initWithFrame:CGRectMake(VIEW_X(viewDetail), heightForView + heightForSpacing, VIEW_W(viewDetail), 500)];
        [viewDescription setBackgroundColor:[UIColor whiteColor]];
        //职位描述标题
        UIImageView *imgDescription = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_X(lbEmployTitle), heightForSpacing + 5, 10, 10)];
        [imgDescription setImage:[UIImage imageNamed:@"coEmptyCircle.png"]];
        [viewDescription addSubview:imgDescription];
        CustomLabel *lbDescriptionTitle = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgDescription) + 3, heightForSpacing, 100, 20) content:@"职位描述：" size:fontSize color:TEXTGRAYCOLOR];
        [viewDescription addSubview:lbDescriptionTitle];
        //职位描述正文
        CustomLabel *lbDescription = [[CustomLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_X(lbDescriptionTitle), VIEW_BY(lbDescriptionTitle) + heightForSpacing, VIEW_W(viewDescription) - VIEW_X(lbDescriptionTitle) * 2, 2000) content:content size:fontSize color:nil];
        [viewDescription addSubview:lbDescription];
        //设置viewDescription的高
        CGRect frameDescription = viewDescription.frame;
        frameDescription.size.height = VIEW_BY(lbDescription) + heightForSpacing;
        [viewDescription setFrame:frameDescription];
        [self.scrollView addSubview:viewDescription];
        [viewDescription.layer setBorderColor:[SEPARATECOLOR CGColor]];
        [viewDescription.layer setBorderWidth:0.5];
        heightForView = VIEW_BY(viewDescription);
    }
    //设置scrollView的contentsize
    [self.scrollView setContentSize:CGSizeMake(VIEW_W(self.scrollView), heightForView)];
}

- (void)favoriteClick:(UIButton *)sender {
    if (![CommonFunc checkLogin]) {
        UIViewController *loginCtrl = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"loginView"];
        [self.navigationController pushViewController:loginCtrl animated:true];
        return;
    }
    if (sender.tag == 0) {
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
        self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"InsertPaAttention" params:[NSDictionary dictionaryWithObjectsAndKeys:[CommonFunc getPaMainId], @"paMainID", @"2", @"attentionType", [self.jobData objectForKey:@"id"], @"attentionID", [CommonFunc getCode], @"code", nil] tag:3];
        [self.runningRequest setDelegate:self];
        [self.runningRequest startAsynchronous];
        [USER_DEFAULT setValue:@"1" forKey:@"attentionType"];
    }
    else {
        for (UIView *view in sender.subviews) {
            if ([view isKindOfClass:[UIImageView class]]) {
                [(UIImageView *)view setImage:[UIImage imageNamed:@"coUnFavoriteBlue.png"]];
            }
            else if ([view isKindOfClass:[CustomLabel class]]) {
                [(CustomLabel *)view setText:@"关注"];
                [(CustomLabel *)view setTextColor:UIColorWithRGBA(0, 148, 223, 1)];
            }
        }
        [sender setTag:0];
        self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"DeletePaAttention" params:[NSDictionary dictionaryWithObjectsAndKeys:[CommonFunc getPaMainId], @"paMainID", @"2", @"attentionType", [self.jobData objectForKey:@"id"], @"attentionID", [CommonFunc getCode], @"code", nil] tag:7];
        [self.runningRequest setDelegate:self];
        [self.runningRequest startAsynchronous];
    }
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    [self.loadingView stopAnimating];
    if (request.tag == 1) {
        NSArray *arrJobData = [CommonFunc getArrayFromXml:requestData tableName:@"Table1"];
        self.jobData = [arrJobData objectAtIndex:0];
        NSArray *arrCpBrochureData = [CommonFunc getArrayFromXml:requestData tableName:@"Table"];
        self.cpBrochureData = [arrCpBrochureData objectAtIndex:0];
        self.arrRegion = [CommonFunc getArrayFromXml:requestData tableName:@"Table2"];
        self.arrMajor = [CommonFunc getArrayFromXml:requestData tableName:@"Table3"];
        //填充数据
        self.applyUrl = [self.cpBrochureData objectForKey:@"ApplyUrl"];
        [self fillData];
    }
    else if (request.tag == 2) {
        //-1 不存在 ；-2职位已暂停；-3简章可能未发布、已截止、已暂停 ；-4 简章未开始 ；-5已申请；-6超过最大申请数；1成功
        if ([result isEqualToString:@"1"]) {
            [self applySuccess:YES];
        }
        else if ([result isEqualToString:@"-1"]) {
            [self.view.window makeToast:@"申请失败，该职位不存在"];
        }
        else if ([result isEqualToString:@"-2"]) {
            [self.view.window makeToast:@"申请失败，该职位已暂停"];
        }
        else if ([result isEqualToString:@"-3"]) {
            [self.view.window makeToast:@"申请失败，该职位所属的招聘简章或未发布或已截止或已暂停"];
        }
        else if ([result isEqualToString:@"-4"]) {
            [self.view.window makeToast:@"申请失败，该职位所属的招聘简章未开始"];
        }
        else if ([result isEqualToString:@"-5"]) {
            [self applySuccess:NO];
        }
        else if ([result isEqualToString:@"-6"]) {
            [self.view.window makeToast:@"申请失败，超过该招聘简章下职位的最大申请数"];
        }
        else if ([result isEqualToString:@"-7"]) {
            [self.view.window makeToast:@"该职位已申请过"];
        }
        else {
            [self.view.window makeToast:@"申请失败"];
        }
    }
    else if (request.tag == 4) {
        if ([result isEqualToString:@"-10"]) {
            UIViewController *paInfoCtrl = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"paInfoView"];
            UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:paInfoCtrl];
            [self.navigationController presentViewController:navCtrl animated:YES completion:nil];
        }
        else {
            PopupView *alert = [[PopupView alloc] initWithWarningAlert:self.view title:@"提示" content:[NSString stringWithFormat:@"同学，您需要到我们%@指定网站上去申请", [self.cpBrochureData objectForKey:@"CpName"]] okMsg:@"现在就去" cancelMsg:@"再看看"];
            [alert setDelegate:self];
            [self.view.window addSubview:alert];
        }
    }
    else if (request.tag == 5) {
        if ([result isEqualToString:@"-10"]) {
            UIViewController *paInfoCtrl = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"paInfoView"];
            UINavigationController *navCtrl = [[UINavigationController alloc] initWithRootViewController:paInfoCtrl];
            [self.navigationController presentViewController:navCtrl animated:YES completion:nil];
        }
        else {
            PopupView *alert = [[PopupView alloc] initWithOtherApplyAlert:self.view content:[self.cpBrochureData objectForKey:@"ApplyWay"] okMsg:@"知道啦"];
//            PopupView *alert = [[PopupView alloc] initWithOtherApplyAlert:self.view content:@"已经将该职位放到您“关注的职位”中，需要您在电脑端登录梧桐果完成网申！" okMsg:@"知道啦"];
            [alert setDelegate:self];
            [self.view.window addSubview:alert];
        }
    }
    else if (request.tag == 6) {
        NSArray *arrContent = [CommonFunc getArrayFromXml:requestData tableName:@"Table"];
        NSString *shareContent = [[arrContent objectAtIndex:0] objectForKey:@"ContentText"];
        NSString *shareContent2 = [[arrContent objectAtIndex:0] objectForKey:@"ContentText2"];
        NSString *shareTitle = [[arrContent objectAtIndex:0] objectForKey:@"Title"];
        [CommonFunc share:shareTitle content:shareContent url:[NSString stringWithFormat:@"/job%@.html", self.secondId] view:self.view imageUrl:@"" content2:shareContent2];
    }
}

- (void)applySuccess:(BOOL)first {
    ApplyFormViewController *applyFormCtrl = [[ApplyFormViewController alloc] init];
    applyFormCtrl.jobId = [self.jobData objectForKey:@"id"];
    [self.navigationController pushViewController:applyFormCtrl animated:YES];
}

- (void)applyClick {
    NSString *applyType = [self.cpBrochureData objectForKey:@"ApplyType"];
    if (![CommonFunc checkLogin]) {
        LoginViewController *loginCtrl = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"loginView"];
        loginCtrl.fromJobApply = YES;
        [self.navigationController pushViewController:loginCtrl animated:true];
        return;
    }
    if ([applyType isEqualToString:@"1"]) {
        [self.loadingView startAnimating];
        self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"InsertApplyFormMainPart" params:[NSDictionary dictionaryWithObjectsAndKeys:[self.jobData objectForKey:@"id"], @"jobID", [CommonFunc getPaMainId], @"paMainID", [self.cpBrochureData objectForKey:@"CpBrochureIDID"], @"cpBrochureID", [CommonFunc getCode], @"code", nil] tag:2];
        [self.runningRequest setDelegate:self];
        [self.runningRequest startAsynchronous];
    }
    else if ([applyType isEqualToString:@"2"]) {
        self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"InsertPaApplyLog" params:[NSDictionary dictionaryWithObjectsAndKeys:[CommonFunc getPaMainId], @"paMainID", self.secondId, @"JobID", [CommonFunc getCode], @"code", nil] tag:4];
        [self.runningRequest setDelegate:self];
        [self.runningRequest startAsynchronous];
    }
    else if ([applyType isEqualToString:@"3"]) {
        self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"InsertPaApplyLog" params:[NSDictionary dictionaryWithObjectsAndKeys:[CommonFunc getPaMainId], @"paMainID", self.secondId, @"JobID", [CommonFunc getCode], @"code", nil] tag:5];
        [self.runningRequest setDelegate:self];
        [self.runningRequest startSynchronous];
        
        self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"InsertPaAttention" params:[NSDictionary dictionaryWithObjectsAndKeys:[CommonFunc getPaMainId], @"paMainID", @"2", @"attentionType", [self.jobData objectForKey:@"id"], @"attentionID", [CommonFunc getCode], @"code", nil] tag:3];
        [self.runningRequest setDelegate:self];
        [self.runningRequest startSynchronous];
    }
}

- (void)popupAlerConfirm {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.applyUrl]];
}

- (void)applyOtherWay {
    //背景
    self.viewApplyPopup = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.viewApplyPopup setBackgroundColor:UIColorWithRGBA(0, 0, 0, 0.6)];
    [self.view.window addSubview:self.viewApplyPopup];
    //显示框
    UIImageView *viewOtherWay = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 20, (SCREEN_WIDTH - 20) * 0.65)];
    [viewOtherWay setImage:[UIImage imageNamed:@"coApplyWay.png"]];
    [viewOtherWay setUserInteractionEnabled:YES];
    [viewOtherWay setCenter:self.viewApplyPopup.center];
    [viewOtherWay.layer setCornerRadius:5];
    [self.viewApplyPopup addSubview:viewOtherWay];
    //关闭按钮
    UIButton *btnClose = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_W(viewOtherWay) * 0.75, VIEW_H(viewOtherWay) * 0.11, VIEW_W(viewOtherWay) * 0.2, VIEW_H(viewOtherWay) * 0.17)];
    [btnClose addTarget:self action:@selector(closeApplyTips) forControlEvents:UIControlEventTouchUpInside];
    [viewOtherWay addSubview:btnClose];
    //文字
    NSString *content = [self.cpBrochureData objectForKey:@"ApplyWay"];
    CustomLabel *lbTips = [[CustomLabel alloc] initWithFrame:CGRectMake(20, VIEW_H(viewOtherWay) / 2, VIEW_W(viewOtherWay) - 40, VIEW_H(viewOtherWay) / 2) content:content size:12 color:nil];
    [lbTips setNumberOfLines:0];
    NSMutableAttributedString *attrContent = [[NSMutableAttributedString alloc] initWithString:content];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:7];
    [paragraphStyle setLineBreakMode:NSLineBreakByCharWrapping];
    [attrContent addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [content length])];
    [lbTips setAttributedText:attrContent];
    [viewOtherWay addSubview:lbTips];
    [lbTips sizeToFit];
    //显示动画
    [self.viewApplyPopup setAlpha:0];
    [UIView animateWithDuration:0.5 animations:^{
        [self.viewApplyPopup setAlpha:1];
    }];
}

- (void)closeApplyTips {
    [UIView animateWithDuration:0.5 animations:^{
        [self.viewApplyPopup setAlpha:0];
    } completion:^(BOOL finished) {
        [self.viewApplyPopup removeFromSuperview];
    }];
}

- (void)shareClick {
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetShareTitle" params:[NSDictionary dictionaryWithObjectsAndKeys:@"203", @"pageID", self.secondId, @"id", nil] tag:6];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

@end

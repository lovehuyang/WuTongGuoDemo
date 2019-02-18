//
//  CpCampusViewController.m
//  wutongguo
//
//  Created by Lucifer on 15-5-16.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "CpCampusViewController.h"
#import "SchoolViewController.h"
#import "CompanyViewController.h"
#import "CpBrandViewController.h"
#import "VideoViewController.h"
#import "CommonMacro.h"
#import "CommonFunc.h"
#import "CustomLabel.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "GDataXMLNode.h"
#import "PopupView.h"

@interface CpCampusViewController ()<NetWebServiceRequestDelegate>

@property (nonatomic, strong) PopupView *viewNoList;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;
@property (nonatomic, strong) NSMutableArray *arrCpCampusData;
@property (nonatomic, strong) NSDictionary *cpBrandData;
@property (nonatomic, strong) NSArray *arrOtherCpCampusData;
@property BOOL blnExpire;
@end

@implementation CpCampusViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.view addSubview:self.loadingView];
    self.blnExpire = false;
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
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetCpPreachByCpMainID" params:[NSDictionary dictionaryWithObjectsAndKeys:[CommonFunc getPaMainId], @"paMainID", self.companySecondId, @"cpMainID", [CommonFunc getCode], @"code", nil] tag:1];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (void)fillData {
    UIView *viewCampus = [[UIView alloc] initWithFrame:CGRectMake(0, 10, SCREEN_WIDTH, 500)];
    float heightForCampus = 5;
    if (self.arrCpCampusData.count == 0) {
        self.viewNoList = [[PopupView alloc] initWithNoListTips:viewCampus tipsMsg:@"<div style=\"text-align:center\"><p>该企业未发布宣讲会信息</p><p>已罚他三天不准吃饭</p></div>"];
        [viewCampus addSubview:self.viewNoList];
        heightForCampus = VIEW_BY(self.viewNoList) + 10;
    }
    else {
        [self.viewNoList popupClose];
        [viewCampus setBackgroundColor:[UIColor whiteColor]];
        [viewCampus.layer setBorderColor:[SEPARATECOLOR CGColor]];
        [viewCampus.layer setBorderWidth:0.5];
    }
    NSMutableArray *arrShowCampusData = [[NSMutableArray alloc] init];
    if (self.blnExpire) {
        arrShowCampusData = self.arrCpCampusData;
    }
    else {
        for (int index = 0; index < self.arrCpCampusData.count; index++) {
            NSDictionary *cpCampusData = [self.arrCpCampusData objectAtIndex:index];
            NSDate *endDate = [CommonFunc dateFromString:[cpCampusData objectForKey:@"EndDate"]];
            NSDate *today = [[NSDate alloc] init];
            if ([endDate compare:today] == NSOrderedAscending) {
                continue;
            }
            else {
                [arrShowCampusData addObject:cpCampusData];
            }
        }
        if (arrShowCampusData.count == 0) {
            arrShowCampusData = self.arrCpCampusData;
            self.blnExpire = true;
        }
    }
    for (int index = 0; index < arrShowCampusData.count; index++) {
        NSDictionary *cpCampusData = [arrShowCampusData objectAtIndex:index];
        NSDate *endDate = [CommonFunc dateFromString:[cpCampusData objectForKey:@"EndDate"]];
        NSDate *today = [[NSDate alloc] init];
        heightForCampus = heightForCampus + 5;
        UIButton *btnCampus = [[UIButton alloc] initWithFrame:CGRectMake(0, heightForCampus, VIEW_W(viewCampus) - 55, 55)];
        [btnCampus setTag:index];
        //        [btnCampus addTarget:self action:@selector(CampusClick:) forControlEvents:UIControlEventTouchUpInside];
        [viewCampus addSubview:btnCampus];
        NSString *content = @"";
        float fontSize = 16;
        //宣讲会时间 日期
        UIColor *dateColor;
        NSTimeInterval secondsPerDay = 24 * 60 * 60;
        NSDate *tomorrow;
        tomorrow = [today dateByAddingTimeInterval: secondsPerDay];
        NSString * todayString = [[today description] substringToIndex:10];
        NSString * tomorrowString = [[tomorrow description] substringToIndex:10];
        NSString * dateString = [[endDate description] substringToIndex:10];
        if ([dateString isEqualToString:todayString] && [endDate compare:today] == NSOrderedDescending) {
            content = @"今天";
            dateColor = UIColorWithRGBA(255, 0, 78, 1);
        }
        else if ([dateString isEqualToString:tomorrowString]) {
            content = @"明天";
            dateColor = UIColorWithRGBA(255, 0, 78, 1);
        }
        else {
            content = [CommonFunc stringFromDate:endDate formatType:@"M-d"];
            int endYear = [[CommonFunc stringFromDate:endDate formatType:@"yyyy"] intValue];
            int nowYear = [[CommonFunc stringFromDate:today formatType:@"yyyy"] intValue];
            if (endYear < nowYear) {
                content = [CommonFunc stringFromDate:endDate formatType:@"yyyy-M-d"];
            }
            if ([endDate compare:today] == NSOrderedAscending) {
                dateColor = TEXTGRAYCOLOR;
            }
            else {
                dateColor = NAVBARCOLOR;
            }
        }
        fontSize = 14;
        CustomLabel *lbDate = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(10, 5, 100, 20) content:content size:fontSize color:dateColor];
        [btnCampus addSubview:lbDate];
        //宣讲会时间 星期+时分
        content = [NSString stringWithFormat:@"（%@）%@-%@", [CommonFunc getWeek:[cpCampusData objectForKey:@"EndDate"]], [CommonFunc stringFromDateString:[cpCampusData objectForKey:@"BeginDate"] formatType:@"HH:mm"], [CommonFunc stringFromDateString:[cpCampusData objectForKey:@"EndDate"] formatType:@"HH:mm"]];
        fontSize = 12;
        CustomLabel *lbTime = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(lbDate), VIEW_Y(lbDate), 200, 20) content:content size:fontSize color:TEXTGRAYCOLOR];
        [btnCampus addSubview:lbTime];
        
        //宣讲会地点 地区学校 宣讲会地点 详细地址
        NSString *address = [cpCampusData objectForKey:@"AddRess"];
        if ([address isEqualToString:@"待定"]) {
            address = @"详细地点待定";
        }
        content = [NSString stringWithFormat:@"[%@] %@ %@", [cpCampusData objectForKey:@"FullName"], [cpCampusData objectForKey:@"SchoolName"], address];
        CustomLabel *lbSchool = [[CustomLabel alloc] initWithFixed:CGRectMake(VIEW_X(lbDate), VIEW_BY(lbDate) + 5, SCREEN_WIDTH - 70, 200) content:content size:fontSize color:nil];
        [btnCampus addSubview:lbSchool];
        [btnCampus setFrame:CGRectMake(0, heightForCampus, VIEW_W(viewCampus) - 55, VIEW_BY(lbSchool) + 5)];
        //过期的不显示关注按钮
        if ([endDate compare:today] == NSOrderedAscending) {
            CustomLabel *lbFavorite = [[CustomLabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 50, heightForCampus + VIEW_H(btnCampus) / 2 - 10, 40, 20) content:@"已举办" size:12 color:TEXTGRAYCOLOR];
            [lbFavorite setTextAlignment:NSTextAlignmentCenter];
            [viewCampus addSubview:lbFavorite];
            
            if ([[cpCampusData objectForKey:@"Url"] length] > 0) {
                CGRect framelbFavorite = lbFavorite.frame;
                framelbFavorite.origin.y = framelbFavorite.origin.y - 10;
                [lbFavorite setFrame:framelbFavorite];
                UIButton *btnVideo = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_X(lbFavorite) - 15, VIEW_BY(lbFavorite) + 3, 60, 30)];
                [btnVideo setTag:[[cpCampusData objectForKey:@"ID"] intValue]];
                [btnVideo addTarget:self action:@selector(videoClick:) forControlEvents:UIControlEventTouchUpInside];
                [viewCampus addSubview:btnVideo];
                UIImageView *imgVideo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 5, 16, 10)];
                [imgVideo setImage:[UIImage imageNamed:@"coCampusVideo.png"]];
                [btnVideo addSubview:imgVideo];
                CustomLabel *lbVideo = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgVideo) + 2, 0, 200, 20) content:@"现场视频" size:10 color:UIColorWithRGBA(1, 104, 183, 1)];
                [btnVideo addSubview:lbVideo];
            }
        }
        else if ([dateString isEqualToString:todayString] && [endDate compare:today] == NSOrderedDescending) {
            CustomLabel *lbFavorite = [[CustomLabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 50, heightForCampus + VIEW_H(btnCampus) / 2 - 10, 40, 20) content:@"进行中" size:12 color:NAVBARCOLOR];
            [lbFavorite setTextAlignment:NSTextAlignmentCenter];
            [viewCampus addSubview:lbFavorite];
        }
        else {
            //关注按钮
            NSInteger IsAttention = [[cpCampusData objectForKey:@"IsAttention"] integerValue];
            UIButton *btnFavorite = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 40, heightForCampus + VIEW_H(btnCampus) / 2 - 23, 30, 45)];
            [btnFavorite setTag:index];
            [btnFavorite addTarget:self action:@selector(favoriteClick:) forControlEvents:UIControlEventTouchUpInside];
            [viewCampus addSubview:btnFavorite];
            UIImageView *imgFavorite = [[UIImageView alloc] initWithFrame:CGRectMake(0, 3, 25, 25)];
            [imgFavorite setImage:[UIImage imageNamed:(IsAttention == 1 ? @"coFavorite.png" : @"coUnFavorite.png")]];
            [btnFavorite addSubview:imgFavorite];
            CustomLabel *lbFavorite = [[CustomLabel alloc] initWithFrame:CGRectMake(-8, VIEW_BY(imgFavorite) + 2, 41, 20) content:(IsAttention == 1 ? @"已关注" : @"关注") size:12 color:(IsAttention == 1 ? UIColorWithRGBA(255, 12, 92, 1) : NAVBARCOLOR)];
            [lbFavorite setTextAlignment:NSTextAlignmentCenter];
            [btnFavorite addSubview:lbFavorite];
        }
        if (index + 1 < self.arrCpCampusData.count) {
            UIView *viewSparate = [[UIView alloc] initWithFrame:CGRectMake(15, VIEW_BY(btnCampus) + 5, SCREEN_WIDTH - 30, 0.5)];
            [viewSparate setBackgroundColor:SEPARATECOLOR];
            [viewCampus addSubview:viewSparate];
            heightForCampus = VIEW_BY(viewSparate);
        }
        else {
            heightForCampus = VIEW_BY(btnCampus) + 10;
        }
    }
    if (arrShowCampusData.count != self.arrCpCampusData.count && !self.blnExpire) {
        UIButton *btnExpire = [[UIButton alloc] initWithFrame:CGRectMake(10, heightForCampus, SCREEN_WIDTH - 20, 30)];
        [btnExpire setTitle:@"查看往期宣讲会" forState:UIControlStateNormal];
        [btnExpire.titleLabel setFont:FONT(14)];
        [btnExpire setBackgroundColor:NAVBARCOLOR];
        btnExpire.layer.cornerRadius = 5.0f;
        [btnExpire addTarget:self action:@selector(showExpire:) forControlEvents:UIControlEventTouchUpInside];
        [viewCampus addSubview:btnExpire];
        heightForCampus = VIEW_BY(btnExpire) + 10;
    }
    CGRect frameCampus = viewCampus.frame;
    frameCampus.size.height = heightForCampus;
    [viewCampus setFrame:frameCampus];
    [self.view addSubview:viewCampus];
    float heightForView = VIEW_BY(viewCampus) + 10;
    //其他企业
    if (self.arrOtherCpCampusData.count > 0) {
        UIView *viewOther = [[UIView alloc] initWithFrame:CGRectMake(VIEW_X(viewCampus), VIEW_BY(viewCampus) + 10, VIEW_W(viewCampus), 80)];
        [viewOther setBackgroundColor:[UIColor whiteColor]];
        [viewOther.layer setBorderColor:[SEPARATECOLOR CGColor]];
        [viewOther.layer setBorderWidth:0.5];
        CustomLabel *lbOtherTitle = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(15, 10, VIEW_W(viewOther) - 15 - 15, 20) content:[NSString stringWithFormat:@"%@旗下其他企业宣讲会", [self.cpBrandData objectForKey:@"CpBrandName"]] size:12 color:NAVBARCOLOR];
        [viewOther addSubview:lbOtherTitle];
        float heightForViewOther = VIEW_BY(lbOtherTitle) + 5;
        for (int index = 0; index < MIN(self.arrOtherCpCampusData.count, 5); index++) {
            NSDictionary *otherCpCampusData = [self.arrOtherCpCampusData objectAtIndex:index];
            UIButton *btnOther = [[UIButton alloc] initWithFrame:CGRectMake(0, heightForViewOther + 5, VIEW_W(viewOther), 38)];
            [btnOther setTag:index];
            [btnOther addTarget:self action:@selector(companyClick:) forControlEvents:UIControlEventTouchUpInside];
            [viewOther addSubview:btnOther];
            UIImageView *imgPoint = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_X(lbOtherTitle), 15, 8, 8)];
            [imgPoint setImage:[UIImage imageNamed:@"coGreenPoint.png"]];
            [btnOther addSubview:imgPoint];
            CustomLabel *lbOtherCompany = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgPoint) + 5, 9, VIEW_W(viewOther) - VIEW_BX(imgPoint) - 3, 20) content:[otherCpCampusData objectForKey:@"Name"] size:13 color:nil];
            [btnOther addSubview:lbOtherCompany];
            if (index + 1 < self.arrOtherCpCampusData.count) {
                UIView *viewOtherSeparate = [[UIView alloc] initWithFrame:CGRectMake(10, VIEW_BY(btnOther) + 5, VIEW_W(viewOther) - 10 * 2, 0.5)];
                [viewOtherSeparate setBackgroundColor:SEPARATECOLOR];
                [viewOther addSubview:viewOtherSeparate];
                heightForViewOther = VIEW_BY(viewOtherSeparate);
            }
            else {
                heightForViewOther = VIEW_BY(btnOther) + 5;
            }
        }
        if (self.arrOtherCpCampusData.count > 5) {
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
        [self.view addSubview:viewOther];
        heightForView = VIEW_BY(viewOther) + 10;
    }
    [self.companyCtrl.arrayViewHeight replaceObjectAtIndex:2 withObject:[NSNumber numberWithFloat:heightForView]];
    if (self.blnExpire) {
        [self.companyCtrl setHeight:2];
    }
}

- (void)showExpire:(UIButton *)sender {
    self.blnExpire = true;
    [sender removeFromSuperview];
    for (UIView *view in self.view.subviews) {
        [view removeFromSuperview];
    }
    [self fillData];
}

- (void)CampusClick:(UIButton *)sender {
    NSDictionary *cpCampusData = [self.arrCpCampusData objectAtIndex:sender.tag];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SchoolViewController *schoolCtrl = [storyBoard instantiateViewControllerWithIdentifier:@"schoolView"];
    schoolCtrl.schoolId = [[cpCampusData objectForKey:@"SchoolID"] integerValue];
    [self.navigationController pushViewController:schoolCtrl animated:YES];
}

- (void)companyClick:(UIButton *)sender {
    NSDictionary *otherCompanyData = [self.arrOtherCpCampusData objectAtIndex:sender.tag];
    CompanyViewController *companyCtrl = [[CompanyViewController alloc] init];
    companyCtrl.secondId = [otherCompanyData objectForKey:@"SecondID"];
    companyCtrl.tabIndex = 2;
    [self.navigationController pushViewController:companyCtrl animated:YES];
}

- (void)otherCompany:(UIButton *)sender {
    CpBrandViewController *cpBrandCtrl = [[CpBrandViewController alloc] init];
    cpBrandCtrl.secondId = [self.cpBrandData objectForKey:@"CpBrandSecondID"];
    cpBrandCtrl.title = [self.cpBrandData objectForKey:@"CpBrandName"];
    [self.navigationController pushViewController:cpBrandCtrl animated:YES];
}

- (void)favoriteClick:(UIButton *)sender {
    if (![CommonFunc checkLogin]) {
        UIViewController *loginCtrl = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"loginView"];
        [self.navigationController pushViewController:loginCtrl animated:true];
        return;
    }
    NSMutableDictionary *cpCampusData = [self.arrCpCampusData objectAtIndex:sender.tag];
    NSInteger IsAttention = [[cpCampusData objectForKey:@"IsAttention"] integerValue];
    if (IsAttention == 0) {
        [cpCampusData setValue:@"1" forKeyPath:@"IsAttention"];
        [self.arrCpCampusData replaceObjectAtIndex:sender.tag withObject:cpCampusData];
        for (UIView *view in sender.subviews) {
            if ([view isKindOfClass:[UIImageView class]]) {
                [(UIImageView *)view setImage:[UIImage imageNamed:@"coFavorite.png"]];
            }
            else if ([view isKindOfClass:[UILabel class]]) {
                [(UILabel *)view setText:@"已关注"];
                [(UILabel *)view setTextColor:UIColorWithRGBA(255, 12, 92, 1)];
            }
        }
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
        self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"InsertPaAttention" params:[NSDictionary dictionaryWithObjectsAndKeys:[CommonFunc getPaMainId], @"paMainID", @"4", @"attentionType", [cpCampusData objectForKey:@"ID"], @"attentionID", [CommonFunc getCode], @"code", nil] tag:2];
        [self.runningRequest setDelegate:self];
        [self.runningRequest startAsynchronous];
        [USER_DEFAULT setValue:@"3" forKey:@"attentionType"];
    }
    else {
        [cpCampusData setValue:@"0" forKeyPath:@"IsAttention"];
        [self.arrCpCampusData replaceObjectAtIndex:sender.tag withObject:cpCampusData];
        for (UIView *view in sender.subviews) {
            if ([view isKindOfClass:[UIImageView class]]) {
                [(UIImageView *)view setImage:[UIImage imageNamed:@"coUnFavorite.png"]];
            }
            else if ([view isKindOfClass:[UILabel class]]) {
                [(UILabel *)view setText:@"关注"];
                [(UILabel *)view setTextColor:NAVBARCOLOR];
            }
        }
        self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"DeletePaAttention" params:[NSDictionary dictionaryWithObjectsAndKeys:[CommonFunc getPaMainId], @"paMainID", @"4", @"attentionType", [cpCampusData objectForKey:@"ID"], @"attentionID", [CommonFunc getCode], @"code", nil] tag:3];
        [self.runningRequest setDelegate:self];
        [self.runningRequest startAsynchronous];
    }
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    [self.loadingView stopAnimating];
    if (request.tag == 1) {
        self.arrCpCampusData = [[CommonFunc getArrayFromXml:requestData tableName:@"dtPreach"] mutableCopy];
        self.cpBrandData = [[CommonFunc getArrayFromXml:requestData tableName:@"dtBrand"] objectAtIndex:0];
        self.arrOtherCpCampusData = [CommonFunc getArrayFromXml:requestData tableName:@"dtOther"];
        [self fillData];
    }
}

- (void)videoClick:(UIButton *)sender {
    VideoViewController *videoCtrl = [[VideoViewController alloc] init];
    videoCtrl.title = @"现场视频";
    videoCtrl.url = [NSString stringWithFormat:@"http://m.wutongguo.com/cpfront/video/%ld_1?fromApp=1", (long)sender.tag];
    [self.navigationController pushViewController:videoCtrl animated:YES];
}

@end

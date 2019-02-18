//
//  SchoolViewController.m
//  wutongguo
//
//  Created by Lucifer on 15-5-15.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "SchoolViewController.h"
#import "SwitchCampusListViewController.h"
#import "SCNavTabBarController.h"
#import "CommonMacro.h"
#import "CommonFunc.h"
#import "CustomLabel.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "GDataXMLNode.h"
#import "SCNavTabBar.h"
#import "MapViewController.h"

@interface SchoolViewController ()<NetWebServiceRequestDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;
@property (nonatomic, strong) NSDictionary *schoolData;
@end

@implementation SchoolViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.view addSubview:self.loadingView];
    self.title = @"高校";
    //切换标签
    SwitchCampusListViewController *campusCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"switchCampusListView"];
    campusCtrl.title = @"宣讲会";
    campusCtrl.searchType = 1;
    campusCtrl.schoolId = self.schoolId;
    SwitchCampusListViewController *recruitmentCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"switchCampusListView"];
    recruitmentCtrl.title = @"招聘会";
    recruitmentCtrl.searchType = 2;
    recruitmentCtrl.schoolId = self.schoolId;
    SCNavTabBarController *navTabCtrl = [[SCNavTabBarController alloc] init];
    navTabCtrl.subViewControllers = @[campusCtrl, recruitmentCtrl];
    navTabCtrl.customHeight = self.viewSchool.frame.size.height + 10;
    navTabCtrl.scrollEnabled = YES;
    [navTabCtrl addParentView:self.viewContent viewController:self];
    navTabCtrl.navTabBarIndex = self.tabIndex;
    //增加透明度
    for (UIView *view in navTabCtrl.view.subviews) {
        if ([view isKindOfClass:[SCNavTabBar class]]) {
            for (UIView *childView in view.subviews) {
                if ([childView isKindOfClass:[UIScrollView class]]) {
                    [childView setBackgroundColor:UIColorWithRGBA(240.0f, 245.0f, 245.0f, 0.6f)];
                }
            }
        }
    }
    //分享
    UIButton *btnShare = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [btnShare setBackgroundImage:[UIImage imageNamed:@"coShare.png"] forState:UIControlStateNormal];
    [btnShare addTarget:self action:@selector(shareClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnShare];
    [self getData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getData {
    [self.loadingView startAnimating];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetDcSchoolByPaMainID" params:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld", (long)self.schoolId], @"id", [CommonFunc getPaMainId], @"paMainID", [CommonFunc getCode], @"code", nil] tag:1];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (void)fillSchool {
    //self.title = [self.schoolData objectForKey:@"Name"];
    //30左右间距 60左侧照片宽 15照片与viewSchool间距
    float widthForViewSchool = SCREEN_WIDTH - 30 - 60 - 15;
    NSInteger schoolRank = [[self.schoolData objectForKey:@"SchoolRank"] integerValue];
    NSInteger schoolType = 0;
    if ([[self.schoolData objectForKey:@"SchoolType"] isEqualToString:@"1"]) {
        schoolType = 985;
    }
    else if ([[self.schoolData objectForKey:@"SchoolType"] isEqualToString:@"2"]) {
        schoolType = 211;
    }
    float widthForLabelSchool;
    if (schoolRank > 0 && schoolType > 0) {
        widthForLabelSchool = widthForViewSchool - 60;
    }
    else if (schoolRank > 0) {
        widthForLabelSchool = widthForViewSchool - 35;
    }
    else if (schoolType > 0) {
        widthForLabelSchool = widthForViewSchool - 25;
    }
    else {
        widthForLabelSchool = widthForViewSchool;
    }
    //学校名称
    CustomLabel *lbSchool = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(0, 0, widthForLabelSchool, 35) content:[self.schoolData objectForKey:@"Name"] size:14 color:nil];
    [self.viewSchool addSubview:lbSchool];
    CustomLabel *lbQS;
    if (schoolRank > 0) {
        lbQS = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(lbSchool) + 3, lbSchool.center.y - 8, 35, 16) content:[NSString stringWithFormat:@" QS %ld ", (long)schoolRank] size:8 color:UIColorWithRGBA(255, 99, 127, 1)];
        [lbQS.layer setBorderColor:[UIColorWithRGBA(255, 99, 127, 1) CGColor]];
        [lbQS.layer setBorderWidth:1];
        [lbQS.layer setCornerRadius:7];
        [self.viewSchool addSubview:lbQS];
    }
    //学校类别 985 211
    CustomLabel *lbType;
    if (schoolType > 0) {
        lbType = [[CustomLabel alloc] initWithFixedHeight:CGRectMake((schoolRank > 0 ? VIEW_BX(lbQS) : VIEW_BX(lbSchool)) + 3, lbSchool.center.y - 8, 35, 16) content:[NSString stringWithFormat:@"%ld", (long)schoolType] size:10 color:UIColorWithRGBA(3, 194, 245, 1)];
        [lbType setTextAlignment:NSTextAlignmentCenter];
        [lbType.layer setBorderColor:[UIColorWithRGBA(3, 194, 245, 1) CGColor]];
        [lbType.layer setBorderWidth:1];
        [lbType.layer setCornerRadius:7];
        CGRect frameType = lbType.frame;
        frameType.size.width = 25;
        [lbType setFrame:frameType];
        [self.viewSchool addSubview:lbType];
    }
    NSString *majorType = @"";
    NSArray *arrMajorType = [CommonFunc getMajorType];
    for (NSDictionary *dicMajorType in arrMajorType) {
        if ([[dicMajorType objectForKey:@"id"] isEqualToString:[self.schoolData objectForKey:@"MajorType"]]) {
            majorType = [dicMajorType objectForKey:@"name"];
            break;
        }
    }
    //学校专业类别
    CustomLabel *lbMajor = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbSchool), VIEW_BY(lbSchool) + 3, widthForViewSchool, 20) content:[NSString stringWithFormat:@"%@院校", majorType] size:12 color:TEXTGRAYCOLOR];
    [self.viewSchool addSubview:lbMajor];
    //学校地址
    CustomLabel *lbAddress = [[CustomLabel alloc] initWithFixed:CGRectMake(VIEW_X(lbSchool), VIEW_BY(lbMajor) + 3, widthForViewSchool - 52, 35) content:[self.schoolData objectForKey:@"Address"] size:12 color:TEXTGRAYCOLOR];
    [self.viewSchool addSubview:lbAddress];
    //查看地图
    if ([[self.schoolData objectForKey:@"Lng"] length] > 0) {
        UIButton *btnMap = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_BX(lbAddress) + 5, lbAddress.center.y - 10, 60, 20)];
        [btnMap addTarget:self action:@selector(mapClick) forControlEvents:UIControlEventTouchUpInside];
        [self.viewSchool addSubview:btnMap];
        UIImageView *imgMap = [[UIImageView alloc] initWithFrame:CGRectMake(3, 5, 10, 10)];
        [imgMap setImage:[UIImage imageNamed:@"schoolMap.png"]];
        [btnMap addSubview:imgMap];
        UILabel *lbMap = [[UILabel alloc] initWithFrame:CGRectMake(VIEW_BX(imgMap), 2, 43, 16)];
        [lbMap setText:@"查看地图"];
        [lbMap setFont:FONT(10)];
        [btnMap setBackgroundColor:[UIColor whiteColor]];
        [btnMap.layer setMasksToBounds:YES];
        [btnMap.layer setBorderColor:[NAVBARCOLOR CGColor]];
        [btnMap.layer setBorderWidth:0.5];
        [btnMap addSubview:lbMap];
    }
    //logo
    if ([[self.schoolData objectForKey:@"Logo"] length] > 0) {
        [self.imgLogo setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://down.51rc.com/imagefolder/wutongguo/Common/school/%@",[self.schoolData objectForKey:@"Logo"]]]]]];
    }
    //关注按钮
    if ([[self.schoolData objectForKey:@"IsAttention"] isEqualToString:@"1"]) {
        [self.btnFocus setTag:1];
        [self.btnFocus setTitle:@"已关注" forState:UIControlStateNormal];
    }
    else {
        [self.btnFocus setTag:0];
    }
    
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1) {
        [self.loadingView stopAnimating];
        NSArray *arrData = [CommonFunc getArrayFromXml:requestData tableName:@"Table"];
        self.schoolData = [arrData objectAtIndex:0];
        [self fillSchool];
    }
    else if (request.tag == 2) {
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
    }
    else if (request.tag == 3) {
        NSArray *arrContent = [CommonFunc getArrayFromXml:requestData tableName:@"Table"];
        NSString *shareContent = [[arrContent objectAtIndex:0] objectForKey:@"ContentText"];
        NSString *shareContent2 = [[arrContent objectAtIndex:0] objectForKey:@"ContentText2"];
        NSString *shareTitle = [[arrContent objectAtIndex:0] objectForKey:@"Title"];
        [CommonFunc share:shareTitle content:shareContent url:[NSString stringWithFormat:@"http://www.wutongguo.com/univ%ld.html", (long)self.schoolId] view:self.view imageUrl:@"" content2:shareContent2];
    }
}

- (IBAction)focusClick:(UIButton *)sender {
    if (![CommonFunc checkLogin]) {
        UIViewController *loginCtrl = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"loginView"];
        [self.navigationController pushViewController:loginCtrl animated:true];
        return;
    }
    if (sender.tag == 0) {
        [sender setTitle:@"已关注" forState:UIControlStateNormal];
        self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"InsertPaAttention" params:[NSDictionary dictionaryWithObjectsAndKeys:[CommonFunc getPaMainId], @"paMainID", @"3", @"attentionType", [self.schoolData objectForKey:@"id"], @"attentionID", [CommonFunc getCode], @"code", nil] tag:2];
        [self.runningRequest setDelegate:self];
        [self.runningRequest startAsynchronous];
        [sender setTag:1];
        [USER_DEFAULT setValue:@"2" forKey:@"attentionType"];
    }
}

- (void)mapClick {
    MapViewController *mapCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"mapView"];
    mapCtrl.lng = [[self.schoolData objectForKey:@"Lng"] floatValue];
    mapCtrl.lat = [[self.schoolData objectForKey:@"Lat"] floatValue];
    mapCtrl.mapAddress = [self.schoolData objectForKey:@"Address"];
    mapCtrl.mapTitle = [self.schoolData objectForKey:@"Name"];
    [self.navigationController pushViewController:mapCtrl animated:YES];
}

- (void)shareClick {
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetShareTitle" params:[NSDictionary dictionaryWithObjectsAndKeys:@"208", @"pageID", [NSString stringWithFormat:@"%ld", (long)self.schoolId], @"id", nil] tag:3];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

@end

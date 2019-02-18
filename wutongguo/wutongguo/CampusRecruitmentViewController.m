//
//  CampusRecruitmentViewController.m
//  wutongguo
//
//  Created by Lucifer on 15/5/31.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "CampusRecruitmentViewController.h"
#import "CommonMacro.h"
#import "CommonFunc.h"
#import "CustomLabel.h"
#import "NetWebServiceRequest.h"
#import "NetWebServiceRequest2.h"
#import "LoadingAnimationView.h"
#import "GDataXMLNode.h"
#import "UIImageView+WebCache.h"
#import "MapViewController.h"

@interface CampusRecruitmentViewController ()<NetWebServiceRequestDelegate, NetWebServiceRequest2Delegate, UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) NetWebServiceRequest2 *runningRequest2;
@property (nonatomic, strong) LoadingAnimationView *loadingView;
@property (nonatomic, strong) NSDictionary *recruitmentData;
@property (nonatomic) float heightForView;
@property (nonatomic, strong) UIView *viewPhoto;
@property (nonatomic, strong) UIView *viewBrief;
@property (nonatomic, strong) UIScrollView *scrollPhoto;
@property (nonatomic, strong) UIPageControl *pagePhoto;
@end

@implementation CampusRecruitmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"招聘会详情";
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.view addSubview:self.scrollView];
    //等待动画
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.view addSubview:self.loadingView];
    //分享
    UIButton *btnShare = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [btnShare setBackgroundImage:[UIImage imageNamed:@"coShare.png"] forState:UIControlStateNormal];
    [btnShare addTarget:self action:@selector(shareClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnShare];
    //获取数据
    [self getData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getData {
    [self.loadingView startAnimating];
    self.runningRequest2 = [NetWebServiceRequest2 serviceRequestUrl:@"GetRectuitmentByID" params:[NSDictionary dictionaryWithObjectsAndKeys:self.recruitmentId, @"RecruitmentID", [CommonFunc getPaMainId], @"PaMainID", nil] tag:1];
    [self.runningRequest2 setDelegate:self];
    [self.runningRequest2 startAsynchronous];
}

- (void)fillData {
    [self fillDetail];
    [self fillBrief];
    [self.scrollView setContentSize:CGSizeMake(SCREEN_WIDTH, self.heightForView + 10)];
}

- (void)fillBrief {
    NSString *content = [self.recruitmentData objectForKey:@"Description"];
    if ([content length] == 0) {
        return;
    }
    //招聘会详情
    float heightForSpacing = 15;
    CGRect frameBrief = CGRectMake(-0.5, self.heightForView + heightForSpacing, SCREEN_WIDTH + 1, 50);
    self.viewBrief = [[UIView alloc] initWithFrame:frameBrief];
    [self.viewBrief setBackgroundColor:[UIColor whiteColor]];
    [self.scrollView addSubview:self.viewBrief];
    //标题
    CustomLabel *lbTitle = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(20, 10, VIEW_W(self.viewBrief) - 20, 20) content:@"招聘会详情" size:14 color:TEXTGRAYCOLOR];
    [self.viewBrief addSubview:lbTitle];
    UIView *viewTitleTips = [[UIView alloc] initWithFrame:CGRectMake(10, VIEW_Y(lbTitle), 5, VIEW_H(lbTitle))];
    [viewTitleTips setBackgroundColor:NAVBARCOLOR];
    [self.viewBrief addSubview:viewTitleTips];
    //详情
    CustomLabel *lbBrief = [[CustomLabel alloc] initWithFixed:CGRectMake(10, VIEW_BY(lbTitle) + heightForSpacing, VIEW_W(self.viewBrief) - 20, 2000) content:content size:13 color:nil];
    [lbBrief setNumberOfLines:0];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithData:[content dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    [lbBrief setAttributedText:attrString];
    [lbBrief sizeToFit];
    //[lbBrief setCenter:CGPointMake(self.center.x, lbBrief.center.y)];
    [self.viewBrief addSubview:lbBrief];
    //设置高度
    frameBrief.size.height = VIEW_BY(lbBrief) + heightForSpacing;
    [self.viewBrief setFrame:frameBrief];
    [self.viewBrief.layer setBorderColor:[SEPARATECOLOR CGColor]];
    [self.viewBrief.layer setBorderWidth:0.5];
    self.heightForView = VIEW_BY(self.viewBrief);
}

- (void)fillDetail {
    //招聘会名称
    UIView *viewRecruitment = [[UIView alloc] initWithFrame:CGRectMake(-0.5, 0, SCREEN_WIDTH + 1, 50)];
    [viewRecruitment setBackgroundColor:[UIColor whiteColor]];
    CustomLabel *lbRecruitment = [[CustomLabel alloc] initWithFixed:CGRectMake(10, 15, VIEW_W(viewRecruitment) - 70, 200) content:[NSString stringWithFormat:@"%@ 阅读次数：%@", [self.recruitmentData objectForKey:@"Name"], [self.recruitmentData objectForKey:@"ViewNumber"]] size:16 color:nil];
    [lbRecruitment setNumberOfLines:0];
    NSMutableAttributedString *attrRecruitment = [[NSMutableAttributedString alloc] initWithString:lbRecruitment.text];
    NSRange rangRecruitment = NSMakeRange(lbRecruitment.text.length - ([[self.recruitmentData objectForKey:@"ViewNumber"] length] + 5), [[self.recruitmentData objectForKey:@"ViewNumber"] length] + 5);
    [attrRecruitment addAttribute:NSForegroundColorAttributeName value:TEXTGRAYCOLOR range:rangRecruitment];
    [attrRecruitment addAttribute:NSFontAttributeName value:FONT(12) range:rangRecruitment];
    [lbRecruitment setAttributedText:attrRecruitment];
    [lbRecruitment sizeToFit];
    [viewRecruitment addSubview:lbRecruitment];
    CGRect frameViewRecruitment = viewRecruitment.frame;
    frameViewRecruitment.size.height = VIEW_BY(lbRecruitment) + 15;
    [viewRecruitment setFrame:frameViewRecruitment];
    [viewRecruitment.layer setBorderColor:[SEPARATECOLOR CGColor]];
    [viewRecruitment.layer setBorderWidth:0.5];
    //关注按钮
    NSInteger IsAttention = [[self.recruitmentData objectForKey:@"IsAttention"] integerValue];
    UIButton *btnFocus = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_W(viewRecruitment) - 40, (VIEW_H(viewRecruitment) - 40) / 2, 30, 40)];
    [btnFocus setBackgroundColor:[UIColor whiteColor]];
    [btnFocus addTarget:self action:@selector(favoriteClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnFocus setTag:IsAttention];
    [viewRecruitment addSubview:btnFocus];
    UIImageView *imgFocus = [[UIImageView alloc] initWithFrame:CGRectMake(5, 3, 20, 20)];
    [imgFocus setImage:[UIImage imageNamed:(IsAttention == 1 ? @"coFavorite.png" : @"coUnFavorite.png")]];
    [btnFocus addSubview:imgFocus];
    CustomLabel *lbFocus = [[CustomLabel alloc] initWithFrame:CGRectMake(VIEW_X(imgFocus) - 10, VIEW_BY(imgFocus), 40, 20) content:(IsAttention == 1 ? @"已关注" : @"关注") size:10 color:(IsAttention == 1 ? UIColorWithRGBA(255, 12, 92, 1) : NAVBARCOLOR)];
    [lbFocus setTextAlignment:NSTextAlignmentCenter];
    [btnFocus addSubview:lbFocus];
    [self.scrollView addSubview:viewRecruitment];
    //招聘会详情
    float heightForSpacing = 15;
    UIView *viewDetail = [[UIView alloc] initWithFrame:CGRectMake(VIEW_X(viewRecruitment), VIEW_BY(viewRecruitment) + heightForSpacing, VIEW_W(viewRecruitment), 500)];
    [viewDetail setBackgroundColor:[UIColor whiteColor]];
    //基本信息标题
    CustomLabel *lbDetail = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(20, 10, VIEW_W(viewDetail) - 20, 20) content:@"基本信息" size:14 color:TEXTGRAYCOLOR];
    [viewDetail addSubview:lbDetail];
    UIView *viewDetailTips = [[UIView alloc] initWithFrame:CGRectMake(10, VIEW_Y(lbDetail), 5, VIEW_H(lbDetail))];
    [viewDetailTips setBackgroundColor:NAVBARCOLOR];
    [viewDetail addSubview:viewDetailTips];
    //举办场馆
    NSString *content = [self.recruitmentData objectForKey:@"SchoolName"];
    float fontSize = 13;
    CustomLabel *lbPlaceTitle = [[CustomLabel alloc] initWithFixed:CGRectMake(10, VIEW_BY(lbDetail) + heightForSpacing, 100, 20) content:@"举办学校：" size:fontSize color:TEXTGRAYCOLOR];
    [viewDetail addSubview:lbPlaceTitle];
    CGRect frameLbPlace = CGRectMake(VIEW_BX(lbPlaceTitle), VIEW_Y(lbPlaceTitle), VIEW_W(viewDetail) - VIEW_BX(lbPlaceTitle) - 5, 200);
    CustomLabel *lbPlace = [[CustomLabel alloc] initWithFixed:frameLbPlace content:content size:fontSize color:nil];
    [viewDetail addSubview:lbPlace];
    float heightForDetail = VIEW_BY(lbPlace);
    //查看地图
    if ([[self.recruitmentData objectForKey:@"SchoolLng"] length] > 0) {
        //所在地区每行的内容 用来计算最后一行的宽度，方便文字后面加地图图标
        NSArray *arrAddressRow = [CommonFunc getSeparatedLinesFromLabel:lbPlace];
        CGSize sizeLastRowPlace = LABEL_SIZE([arrAddressRow objectAtIndex:arrAddressRow.count - 1], frameLbPlace.size.width, 20, fontSize);
        CGRect framBtnMap = CGRectMake(VIEW_X(lbPlace) + sizeLastRowPlace.width + 3, VIEW_BY(lbPlace) - sizeLastRowPlace.height, sizeLastRowPlace.height + 30, sizeLastRowPlace.height);
        UIButton *btnMap = [[UIButton alloc] initWithFrame:framBtnMap];
        if (VIEW_BY(btnMap) > frameLbPlace.size.width) {
            framBtnMap.origin.x = VIEW_X(lbPlace);
            framBtnMap.origin.y = VIEW_BY(lbPlace) + 2;
            [btnMap setFrame:framBtnMap];
        }
        [btnMap addTarget:self action:@selector(mapClick) forControlEvents:UIControlEventTouchUpInside];
        [viewDetail addSubview:btnMap];
        UIImageView *imgMap = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, btnMap.frame.size.height, btnMap.frame.size.height)];
        [imgMap setImage:[UIImage imageNamed:@"schoolMap.png"]];
        [btnMap addSubview:imgMap];
        CustomLabel *lbMap = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgMap), 0, 50, VIEW_H(btnMap)) content:@"查看地图" size:10 color:nil];
        [btnMap addSubview:lbMap];
        heightForDetail = VIEW_BY(btnMap);
    }
    //具体地点
    CustomLabel *lbAddressTitle = [[CustomLabel alloc] initWithFixed:CGRectMake(VIEW_X(lbPlaceTitle), heightForDetail + heightForSpacing, 100, 20) content:@"具体地点：" size:fontSize color:TEXTGRAYCOLOR];
    [viewDetail addSubview:lbAddressTitle];
    CustomLabel *lbAddress = [[CustomLabel alloc] initWithFixed:CGRectMake(VIEW_BX(lbAddressTitle), VIEW_Y(lbAddressTitle), VIEW_W(viewDetail) - VIEW_BX(lbAddressTitle) - 15, 200) content:[self.recruitmentData objectForKey:@"SchoolAddress"] size:fontSize color:nil];
    [viewDetail addSubview:lbAddress];
    //举办时间
    content = [NSString stringWithFormat:@"%@（%@）%@-%@", [CommonFunc stringFromDateString:[self.recruitmentData objectForKey:@"BeginDate"] formatType:@"yyyy年M月d日"], [CommonFunc getWeek:[self.recruitmentData objectForKey:@"EndDate"]], [CommonFunc stringFromDateString:[self.recruitmentData objectForKey:@"BeginDate"] formatType:@"HH:mm"], [CommonFunc stringFromDateString:[self.recruitmentData objectForKey:@"EndDate"] formatType:@"HH:mm"]];
    CustomLabel *lbDateTitle = [[CustomLabel alloc] initWithFixed:CGRectMake(VIEW_X(lbPlaceTitle), VIEW_BY(lbAddress) + heightForSpacing, 100, 20) content:@"举办时间：" size:fontSize color:TEXTGRAYCOLOR];
    [viewDetail addSubview:lbDateTitle];
    CustomLabel *lbDate = [[CustomLabel alloc] initWithFixed:CGRectMake(VIEW_BX(lbDateTitle), VIEW_Y(lbDateTitle), VIEW_W(viewDetail) - VIEW_BX(lbDateTitle) - 15, 200) content:content size:fontSize color:nil];
    [viewDetail addSubview:lbDate];
    heightForDetail = VIEW_BY(lbDate);
    //计算viewDetail的高度
    CGRect frameDetail = viewDetail.frame;
    frameDetail.size.height = heightForDetail + 15;
    [viewDetail setFrame:frameDetail];
    [self.scrollView addSubview:viewDetail];
    [viewDetail.layer setBorderColor:[SEPARATECOLOR CGColor]];
    [viewDetail.layer setBorderWidth:0.5];
    self.heightForView = VIEW_BY(viewDetail);
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
        self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"InsertPaAttention" params:[NSDictionary dictionaryWithObjectsAndKeys:[CommonFunc getPaMainId], @"paMainID", @"6", @"attentionType", [self.recruitmentData objectForKey:@"Id"], @"attentionID", [CommonFunc getCode], @"code", nil] tag:2];
        [self.runningRequest setDelegate:self];
        [self.runningRequest startAsynchronous];
        [USER_DEFAULT setValue:@"4" forKey:@"attentionType"];
    }
    else {
        for (UIView *view in sender.subviews) {
            if ([view isKindOfClass:[UIImageView class]]) {
                [(UIImageView *)view setImage:[UIImage imageNamed:@"coUnFavorite.png"]];
            }
            else if ([view isKindOfClass:[UILabel class]]) {
                [(UILabel *)view setText:@"关注"];
                [(UILabel *)view setTextColor:NAVBARCOLOR];
            }
        }
        [sender setTag:0];
        self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"DeletePaAttention" params:[NSDictionary dictionaryWithObjectsAndKeys:[CommonFunc getPaMainId], @"paMainID", @"6", @"attentionType", self.recruitmentId, @"attentionID", [CommonFunc getCode], @"code", nil] tag:2];
        [self.runningRequest setDelegate:self];
        [self.runningRequest startAsynchronous];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger page = self.scrollPhoto.contentOffset.x / SCREEN_WIDTH;
    [self.pagePhoto setCurrentPage:page];
}

- (void)photoScroll:(UIButton *)sender {
    NSInteger page = self.scrollPhoto.contentOffset.x / SCREEN_WIDTH;
    NSInteger maxPage = self.scrollPhoto.contentSize.width / SCREEN_WIDTH - 1;
    if (sender.tag == 0) {
        if (page == 0) {
            return;
        }
        [self.scrollPhoto setContentOffset:CGPointMake(SCREEN_WIDTH * (page - 1), 0) animated:YES];
    }
    else {
        if (page == maxPage) {
            return;
        }
        [self.scrollPhoto setContentOffset:CGPointMake(SCREEN_WIDTH * (page + 1), 0) animated:YES];
    }
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
       finishedInfoToResult:(NSString *)result
               responseData:(GDataXMLDocument *)requestData {
    [self.loadingView stopAnimating];
    if (request.tag == 3) {
        NSArray *arrContent = [CommonFunc getArrayFromXml:requestData tableName:@"Table"];
        NSString *shareContent = [[arrContent objectAtIndex:0] objectForKey:@"ContentText"];
        NSString *shareContent2 = [[arrContent objectAtIndex:0] objectForKey:@"ContentText2"];
        NSString *shareTitle = [[arrContent objectAtIndex:0] objectForKey:@"Title"];
        [CommonFunc share:shareTitle content:shareContent url:[NSString stringWithFormat:@"http://www.wutongguo.com/xiaoyuanzhaopinhui/%@.html", self.recruitmentId] view:self.view imageUrl:@"" content2:shareContent2];
    }
}

- (void)netRequestFinished2:(NetWebServiceRequest2 *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    [self.loadingView stopAnimating];
    if (request.tag == 1) {
        self.recruitmentData = [[CommonFunc getArrayFromXml:requestData tableName:@"Table"] objectAtIndex:0];
        //填充数据
        [self fillData];
    }
}

- (void)shareClick {
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetShareTitle" params:[NSDictionary dictionaryWithObjectsAndKeys:@"217", @"pageID", self.recruitmentId, @"id", nil] tag:3];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (void)mapClick {
    MapViewController *mapCtrl = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"mapView"];
    mapCtrl.lng = [[self.recruitmentData objectForKey:@"Lng"] floatValue];
    mapCtrl.lat = [[self.recruitmentData objectForKey:@"Lat"] floatValue];
    mapCtrl.mapAddress = [self.recruitmentData objectForKey:@"Address"];
    mapCtrl.mapTitle = [self.recruitmentData objectForKey:@"PlaceName"];
    [self.navigationController pushViewController:mapCtrl animated:YES];
}

@end

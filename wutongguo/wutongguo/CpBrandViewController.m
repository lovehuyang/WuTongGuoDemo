//
//  CpBrandViewController.m
//  wutongguo
//
//  Created by Lucifer on 15/5/27.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "CpBrandViewController.h"
#import "CommonMacro.h"
#import "CommonFunc.h"
#import "CustomLabel.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "GDataXMLNode.h"
#import "UIImageView+WebCache.h"
#import "CompanyViewController.h"

@interface CpBrandViewController ()<UITableViewDataSource, UITableViewDelegate, NetWebServiceRequestDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;
@property (nonatomic, strong) NSArray *arrCpBrandData;
@property (nonatomic, strong) NSMutableArray *arrCompanyData;
@end

@implementation CpBrandViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStyleGrouped];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.view addSubview:self.tableView];
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.view addSubview:self.loadingView];
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
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetCpBrandById" params:[NSDictionary dictionaryWithObjectsAndKeys:self.secondId, @"id", [CommonFunc getPaMainId], @"paMainID", [CommonFunc getCode], @"code", nil] tag:1];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.arrCompanyData.count;
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
    NSDictionary *companyData = [self.arrCompanyData objectAtIndex:indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellView"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellView"];
    }
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setBackgroundColor:[UIColor whiteColor]];
    UIButton *btnCompany = [[UIButton alloc] initWithFrame:CGRectMake(-0.5, 0, SCREEN_WIDTH + 1, 40)];
    [btnCompany setTag:indexPath.section];
    [btnCompany setBackgroundColor:UIColorWithRGBA(251, 252, 252, 1)];
    [btnCompany addTarget:self action:@selector(companyClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnCompany.layer setBorderColor:[SEPARATECOLOR CGColor]];
    [btnCompany.layer setBorderWidth:0.5];
    [cell.contentView addSubview:btnCompany];
    //绿色竖形条
    UIView *viewTips = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 5, 20)];
    [viewTips setBackgroundColor:NAVBARCOLOR];
    [btnCompany addSubview:viewTips];
    //公司名称
    CustomLabel *lbCompany = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(viewTips) + 5, VIEW_Y(viewTips), SCREEN_WIDTH - VIEW_BX(viewTips) - 65, 20) content:[companyData objectForKey:@"CpName"] size:14 color:UIColorWithRGBA(20, 62, 103, 1)];
    [btnCompany addSubview:lbCompany];
    //关注
    NSInteger IsAttention = [[companyData objectForKey:@"IsAttention"] integerValue];
    UIButton *btnFocus = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60, 0, 60, VIEW_H(btnCompany))];
    [btnFocus setTag:indexPath.section];
    [btnFocus addTarget:self action:@selector(favoriteClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnCompany addSubview:btnFocus];
    UIImageView *imgFocus = [[UIImageView alloc] initWithFrame:CGRectMake(0, 12, 16, 16)];
    [imgFocus setImage:[UIImage imageNamed:(IsAttention == 1 ? @"coFavorite.png" : @"coUnFavorite.png")]];
    [btnFocus addSubview:imgFocus];
    CustomLabel *lbFocus = [[CustomLabel alloc] initWithFrame:CGRectMake(VIEW_BX(imgFocus) + 2, 10, 40, 20) content:(IsAttention == 1 ? @"已关注" : @"关注") size:12 color:(IsAttention == 1 ? UIColorWithRGBA(255, 12, 92, 1) : NAVBARCOLOR)];
    [btnFocus addSubview:lbFocus];
    float heightForCell = VIEW_BY(btnCompany);
    if (![[companyData objectForKey:@"CpBrochureCnt"] isEqualToString:@"0"] || ![[companyData objectForKey:@"CpPreachCnt"] isEqualToString:@"0"]) {
        UIButton *btnCpBrochure = [[UIButton alloc] initWithFrame:CGRectMake(0, heightForCell, SCREEN_WIDTH / 2, 40)];
        [btnCpBrochure setTag:indexPath.section];
        [btnCpBrochure setBackgroundColor:[UIColor clearColor]];
        [btnCpBrochure addTarget:self action:@selector(brochureClick:) forControlEvents:UIControlEventTouchUpInside];
        //添加文字
        UIView *viewCpBrochure = [[UIView alloc] initWithFrame:CGRectMake(0, heightForCell + 10, VIEW_W(btnCpBrochure), 20)];
        [cell.contentView addSubview:viewCpBrochure];
        CustomLabel *lbCpBrochureTitle = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(0, 0, VIEW_W(btnCpBrochure), 20) content:@"招聘简章" size:12 color:nil];
        [viewCpBrochure addSubview:lbCpBrochureTitle];
        CustomLabel *lbCpBrochureCount = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(lbCpBrochureTitle) + 3, 0, VIEW_W(btnCpBrochure), 20) content:[companyData objectForKey:@"CpBrochureCnt"] size:14 color:NAVBARCOLOR];
        [viewCpBrochure addSubview:lbCpBrochureCount];
        CustomLabel *lbCpBrochureUnit = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(lbCpBrochureCount) + 3, 0, VIEW_W(btnCpBrochure), 20) content:@"篇" size:12 color:nil];
        [viewCpBrochure addSubview:lbCpBrochureUnit];
        CGRect frameViewCpBrochure = viewCpBrochure.frame;
        frameViewCpBrochure.size.width = VIEW_BX(lbCpBrochureUnit);
        if ([[companyData objectForKey:@"IsShen"] isEqualToString:@"1"]) {
            UIImageView *imgShen = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_BX(lbCpBrochureUnit) + 2, 2, 16, 16)];
            [imgShen setImage:[UIImage imageNamed:@"coHasApply.png"]];
            [viewCpBrochure addSubview:imgShen];
            frameViewCpBrochure.size.width = VIEW_BX(imgShen);
        }
        frameViewCpBrochure.origin.x = (VIEW_W(btnCpBrochure) - frameViewCpBrochure.size.width) / 2;
        [viewCpBrochure setFrame:frameViewCpBrochure];
        [cell.contentView addSubview:btnCpBrochure];
        
        UILabel *lbSeperate = [[UILabel alloc] initWithFrame:CGRectMake(VIEW_BX(btnCpBrochure), VIEW_Y(btnCpBrochure), 0.5, VIEW_H(btnCpBrochure))];
        [lbSeperate setBackgroundColor:SEPARATECOLOR];
        [cell.contentView addSubview:lbSeperate];
        UIButton *btnCampus = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_BX(lbSeperate), VIEW_Y(btnCpBrochure), VIEW_W(btnCpBrochure), VIEW_H(btnCpBrochure))];
        [btnCampus setTag:indexPath.section];
        [btnCampus setBackgroundColor:[UIColor clearColor]];
        [btnCampus addTarget:self action:@selector(campusClick:) forControlEvents:UIControlEventTouchUpInside];
        //添加文字
        UIView *viewCampus = [[UIView alloc] initWithFrame:CGRectMake(0, heightForCell + 10, VIEW_W(btnCampus), 20)];
        [cell.contentView addSubview:viewCampus];
        CustomLabel *lbCampusTitle = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(0, 0, VIEW_W(btnCampus), 20) content:@"宣讲会" size:12 color:nil];
        [viewCampus addSubview:lbCampusTitle];
        CustomLabel *lbCampusCount = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(lbCampusTitle) + 3, 0, VIEW_W(btnCampus), 20) content:[companyData objectForKey:@"CpPreachCnt"] size:14 color:NAVBARCOLOR];
        [viewCampus addSubview:lbCampusCount];
        CustomLabel *lbCampusUnit = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(lbCampusCount) + 3, 0, VIEW_W(btnCampus), 20) content:@"场" size:12 color:nil];
        [viewCampus addSubview:lbCampusUnit];
        CGRect frameViewCampus = viewCampus.frame;
        frameViewCampus.size.width = VIEW_BX(lbCampusUnit);
        if ([[companyData objectForKey:@"IsXuan"] isEqualToString:@"1"]) {
            UIImageView *imgShen = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_BX(lbCampusUnit) + 2, 2, 16, 16)];
            [imgShen setImage:[UIImage imageNamed:@"coHasCampus.png"]];
            [viewCampus addSubview:imgShen];
            frameViewCampus.size.width = VIEW_BX(imgShen);
        }
        frameViewCampus.origin.x = VIEW_W(btnCpBrochure) + (VIEW_W(btnCampus) - frameViewCampus.size.width) / 2;
        [viewCampus setFrame:frameViewCampus];
        [cell.contentView addSubview:btnCampus];
        heightForCell = VIEW_BY(btnCpBrochure);
    }
    //更改cell的高度
    [cell setFrame:CGRectMake(0, 0, SCREEN_WIDTH, heightForCell)];
    [cell.contentView addSubview:[[CustomLabel alloc] initSeparate:cell]];
    return cell;
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    [self.loadingView stopAnimating];
    if (request.tag == 1) {
        self.arrCpBrandData = [CommonFunc getArrayFromXml:requestData tableName:@"Table"];
        self.arrCompanyData = [[CommonFunc getArrayFromXml:requestData tableName:@"Table1"] mutableCopy];
        [self fillCpBrand];
    }
    else if (request.tag == 3) {
        NSArray *arrContent = [CommonFunc getArrayFromXml:requestData tableName:@"Table"];
        NSString *shareContent = [[arrContent objectAtIndex:0] objectForKey:@"ContentText"];
        NSString *shareContent2 = [[arrContent objectAtIndex:0] objectForKey:@"ContentText2"];
        NSString *shareTitle = [[arrContent objectAtIndex:0] objectForKey:@"Title"];
        [CommonFunc share:shareTitle content:shareContent url:[NSString stringWithFormat:@"http://www.wutongguo.com/brand%@.html", self.secondId] view:self.view imageUrl:@"" content2:shareContent2];
    }
}

- (void)fillCpBrand {
    NSDictionary *cpBrandData = [self.arrCpBrandData objectAtIndex:0];
    UIView *viewCpBrand = [[UIView alloc] initWithFrame:CGRectMake(-0.5, STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH + 1, 300)];
    [viewCpBrand.layer setBorderColor:[SEPARATECOLOR CGColor]];
    [viewCpBrand.layer setBorderWidth:0.5];
    [viewCpBrand setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:viewCpBrand];
    //品牌Logo
    UIImageView *imgBrandLogo = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 45, 45 * 0.9)];
    if ([[cpBrandData objectForKey:@"Logo"] length] > 0) {
        NSString *path = [NSString stringWithFormat:@"%d",([[cpBrandData objectForKey:@"ID"] intValue] / 10000 + 1) * 10000];
        NSInteger lastLength = 6 - path.length;
        for (int i = 0; i < lastLength; i++) {
            path = [NSString stringWithFormat:@"0%@",path];
        }
        path = [NSString stringWithFormat:@"L%@",path];
        path = [NSString stringWithFormat:@"http://down.51rc.com/imagefolder/wutongguo/CpBrand/%@/%@",path,[cpBrandData objectForKey:@"Logo"]];
        [imgBrandLogo sd_setImageWithURL:[NSURL URLWithString:path] placeholderImage:[UIImage imageNamed:@"coNoSchoolLogo.png"]];
    }
    else {
        [imgBrandLogo setImage:[UIImage imageNamed:@"coNoSchoolLogo.png"]];
    }
    [viewCpBrand addSubview:imgBrandLogo];
    CustomLabel *lbCpBrand = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgBrandLogo) + 5, 10, VIEW_W(viewCpBrand) - VIEW_BX(imgBrandLogo) - 10, 20) content:[cpBrandData objectForKey:@"Name"] size:16 color:nil];
    [viewCpBrand addSubview:lbCpBrand];
    //500强图标
    NSInteger top500Count = 0;
    if ([[cpBrandData objectForKey:@"SalesOut"] length] > 0) {
        top500Count++;
    }
    if ([[cpBrandData objectForKey:@"SalesIn"] length] > 0) {
        top500Count++;
    }
    if ([[cpBrandData objectForKey:@"SalesC"] length] > 0) {
        top500Count++;
    }
    if ([[cpBrandData objectForKey:@"SalesCM"] length] > 0) {
        top500Count++;
    }
    NSInteger imgX = (top500Count > 2 ? VIEW_X(lbCpBrand) : VIEW_BX(lbCpBrand) + 2);
    NSInteger imgY = (top500Count > 2 ? VIEW_BY(lbCpBrand) + 2 : VIEW_Y(lbCpBrand) + 2);;
    NSString *top500Img = @"";
    if ([[cpBrandData objectForKey:@"SalesOut"] length] > 0) {
        top500Img = @"coWorldTop500.png";
        UIImageView *imgTop500 = [[UIImageView alloc] initWithFrame:CGRectMake(imgX, imgY, 55, 16)];
        [imgTop500 setImage:[UIImage imageNamed:top500Img]];
        [viewCpBrand addSubview:imgTop500];
        imgX = VIEW_BX(imgTop500) + 3;
    }
    if ([[cpBrandData objectForKey:@"SalesIn"] length] > 0) {
        top500Img = @"coChinaTop500.png";
        UIImageView *imgTop500 = [[UIImageView alloc] initWithFrame:CGRectMake(imgX, imgY, 55, 16)];
        [imgTop500 setImage:[UIImage imageNamed:top500Img]];
        [viewCpBrand addSubview:imgTop500];
        imgX = VIEW_BX(imgTop500) + 3;
    }
    if ([[cpBrandData objectForKey:@"SalesC"] length] > 0) {
        top500Img = @"coChinaCTop500.png";
        UIImageView *imgTop500 = [[UIImageView alloc] initWithFrame:CGRectMake(imgX, imgY, 75, 16)];
        [imgTop500 setImage:[UIImage imageNamed:top500Img]];
        [viewCpBrand addSubview:imgTop500];
        imgX = VIEW_BX(imgTop500) + 3;
    }
    if ([[cpBrandData objectForKey:@"SalesCM"] length] > 0) {
        top500Img = @"coChinaCMTop500.png";
        UIImageView *imgTop500 = [[UIImageView alloc] initWithFrame:CGRectMake(imgX, imgY, 75, 16)];
        [imgTop500 setImage:[UIImage imageNamed:top500Img]];
        [viewCpBrand addSubview:imgTop500];
    }
    //所属行业
    CustomLabel *lbIndustry = [[CustomLabel alloc] initWithFixed:CGRectMake(VIEW_X(lbCpBrand), (top500Img.length > 0 ? VIEW_BY(lbCpBrand) + 20 : VIEW_BY(lbCpBrand) + 5), VIEW_W(viewCpBrand) - VIEW_BX(imgBrandLogo) - 10, 100) content:[cpBrandData objectForKey:@"IndustryName"] size:12 color:TEXTGRAYCOLOR];
    [viewCpBrand addSubview:lbIndustry];
    //重新计算view的高度
    CGRect frameView = viewCpBrand.frame;
    frameView.size.height = VIEW_BY(lbIndustry) + 10;
    [viewCpBrand setFrame:frameView];
    //品牌logo居中
    [imgBrandLogo setCenter:CGPointMake(imgBrandLogo.center.x, VIEW_H(viewCpBrand) / 2)];
    //重新计算table的高度
    CGRect frameTable = self.tableView.frame;
    frameTable.origin.y = VIEW_BY(viewCpBrand);
    frameTable.size.height = SCREEN_HEIGHT - frameTable.origin.y;
    [self.tableView setFrame:frameTable];
    //加载table
    [self.tableView reloadData];
}

- (void)favoriteClick:(UIButton *)sender {
    if (![CommonFunc checkLogin]) {
        UIViewController *loginCtrl = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"loginView"];
        [self.navigationController pushViewController:loginCtrl animated:true];
        return;
    }
    NSMutableDictionary *companyData = [self.arrCompanyData objectAtIndex:sender.tag];
    NSInteger IsAttention = [[companyData objectForKey:@"IsAttention"] integerValue];
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
        self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"InsertPaAttention" params:[NSDictionary dictionaryWithObjectsAndKeys:[CommonFunc getPaMainId], @"paMainID", @"1", @"attentionType", [companyData objectForKey:@"CpMainID"], @"attentionID", [CommonFunc getCode], @"code", nil] tag:2];
        [self.runningRequest setDelegate:self];
        [self.runningRequest startAsynchronous];
        [USER_DEFAULT setValue:@"0" forKey:@"attentionType"];
        IsAttention = 1;
    }
    else {
        for (UIView *view in sender.subviews) {
            if ([view isKindOfClass:[UIImageView class]]) {
                [(UIImageView *)view setImage:[UIImage imageNamed:@"coUnFavorite.png"]];
            }
            else if ([view isKindOfClass:[CustomLabel class]]) {
                [(CustomLabel *)view setText:@"关注"];
                [(CustomLabel *)view setTextColor:NAVBARCOLOR];
            }
        }
        self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"DeletePaAttention" params:[NSDictionary dictionaryWithObjectsAndKeys:[CommonFunc getPaMainId], @"paMainID", @"1", @"attentionType", [companyData objectForKey:@"CpMainID"], @"attentionID", [CommonFunc getCode], @"code", nil] tag:2];
        [self.runningRequest setDelegate:self];
        [self.runningRequest startAsynchronous];
        IsAttention = 0;
    }
    [companyData setValue:[NSString stringWithFormat:@"%ld", (long)IsAttention] forKey:@"IsAttention"];
    [self.arrCompanyData replaceObjectAtIndex:sender.tag withObject:companyData];
}

- (void)brochureClick:(UIButton *)sender {
    NSDictionary *companyData = [self.arrCompanyData objectAtIndex:sender.tag];
    CompanyViewController *companyCtrl = [[CompanyViewController alloc] init];
    companyCtrl.secondId = [companyData objectForKey:@"CpSecondID"];
    companyCtrl.tabIndex = 1;
    [self.navigationController pushViewController:companyCtrl animated:YES];
}

- (void)campusClick:(UIButton *)sender {
    NSDictionary *companyData = [self.arrCompanyData objectAtIndex:sender.tag];
    CompanyViewController *companyCtrl = [[CompanyViewController alloc] init];
    companyCtrl.secondId = [companyData objectForKey:@"CpSecondID"];
    companyCtrl.tabIndex = 2;
    [self.navigationController pushViewController:companyCtrl animated:YES];
}

- (void)companyClick:(UIButton *)sender {
    NSDictionary *companyData = [self.arrCompanyData objectAtIndex:sender.tag];
    CompanyViewController *companyCtrl = [[CompanyViewController alloc] init];
    companyCtrl.secondId = [companyData objectForKey:@"CpSecondID"];
    [self.navigationController pushViewController:companyCtrl animated:YES];
}

- (void)shareClick {
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetShareTitle" params:[NSDictionary dictionaryWithObjectsAndKeys:@"206", @"pageID", self.secondId, @"id", nil] tag:3];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

@end

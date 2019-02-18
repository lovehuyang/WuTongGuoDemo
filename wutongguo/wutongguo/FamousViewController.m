//
//  FamousViewController.m
//  wutongguo
//
//  Created by Lucifer on 15/5/26.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "FamousViewController.h"
#import "SearchViewController.h"
#import "CpBrandViewController.h"
#import "CommonMacro.h"
#import "CommonFunc.h"
#import "CustomLabel.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "GDataXMLNode.h"
#import "MJRefresh.h"
#import "PopupView.h"

@interface FamousViewController ()<UITableViewDataSource, UITableViewDelegate, NetWebServiceRequestDelegate, PopupViewDelegate>

@property (nonatomic, strong) PopupView *viewPopup;
@property (nonatomic, strong) PopupView *viewNoList;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;
@property (nonatomic) NSInteger page;
@property (nonatomic) NSString *industryId;
@property (nonatomic) BOOL isInit;
@property (nonatomic, strong) NSMutableArray *arrData;
@end

@implementation FamousViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"行业名企";
    self.isInit = YES;
    self.viewFilter.layer.borderWidth = 0.5;
    self.viewFilter.layer.borderColor = [SEPARATECOLOR CGColor];
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.view addSubview:self.loadingView];
    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
    self.arrData = [[NSMutableArray alloc] init];
    self.industryId = @"0";
    self.page = 1;
    if (self.keyWord == nil) {
        self.keyWord = @"";
    }
    else {
        self.title = [NSString stringWithFormat:@"%@-%@", self.title, self.keyWord];
        [self.constraintFilterHeight setConstant:1];
        [self.viewFilter setHidden:YES];
    }
    [self getData];
    //分享
    UIButton *btnShare = [[UIButton alloc] initWithFrame:CGRectMake(31, 0, 25, 25)];
    [btnShare setBackgroundImage:[UIImage imageNamed:@"coShare.png"] forState:UIControlStateNormal];
    [btnShare addTarget:self action:@selector(shareClick) forControlEvents:UIControlEventTouchUpInside];
    //搜索
    UIButton *btnSearch = [[UIButton alloc] initWithFrame:CGRectMake(0, 2, 21, 21)];
    [btnSearch setBackgroundImage:[UIImage imageNamed:@"coSearch.png"] forState:UIControlStateNormal];
    [btnSearch addTarget:self action:@selector(searchClick) forControlEvents:UIControlEventTouchUpInside];
    UIView *viewRightItem = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 60, 25)];
    [viewRightItem addSubview:btnShare];
    [viewRightItem addSubview:btnSearch];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:viewRightItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self.keyWord isEqualToString:@""] && self.isInit) {
        [self industryClick:self.btnIndustry];
        self.isInit = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:true];
    [self.viewPopup popupClose];
}

- (void)getData {
    [self.loadingView startAnimating];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetCpBrandByDcIndustryId" params:[NSDictionary dictionaryWithObjectsAndKeys:self.industryId, @"dcIndustryID", self.keyWord, @"keyWord", [NSString stringWithFormat:@"%ld", (long)self.page], @"pageNo", nil] tag:1];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rowCount = ceilf((float)self.arrData.count / 2);
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellView"];
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setBackgroundColor:[UIColor whiteColor]];
    [cell setBackgroundColor:[UIColor whiteColor]];
    if (indexPath.row % 2 == 1) {
        [cell setBackgroundColor:GRAYCELLCOLOR];
    }
    float maxCellHeight = 0;
    for (NSInteger index = indexPath.row * 2; index < (indexPath.row * 2) + 2; index++) {
        if (index == self.arrData.count) {
            break;
        }
        NSDictionary *oneCompanyData = [self.arrData objectAtIndex:index];
        //view + button
        UIView *viewCompany = [[UIView alloc] initWithFrame:CGRectMake((index % 2) * (SCREEN_WIDTH / 2), 0, SCREEN_WIDTH / 2, 80)];
        UIButton *btnCompany = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, VIEW_W(viewCompany), VIEW_H(viewCompany))];
        [btnCompany setTag:index];
        [btnCompany addTarget:self action:@selector(CpBrandClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:viewCompany];
        [viewCompany addSubview:btnCompany];
        //企业名称的最大宽度
        float widthForLabel = VIEW_W(viewCompany) - 20;
        CustomLabel *lbCompany = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(10, 10, widthForLabel, 20) content:[oneCompanyData objectForKey:@"Name"] size:16 color:nil];
        [viewCompany addSubview:lbCompany];
        //500强图标
        NSString *top500Img = @"";
        if ([[oneCompanyData objectForKey:@"SalesOut"] length] > 0) {
            top500Img = @"coWorldTop500.png";
        }
        else if ([[oneCompanyData objectForKey:@"SalesIn"] length] > 0) {
            top500Img = @"coChinaTop500.png";
        }
        else if ([[oneCompanyData objectForKey:@"SalesC"] length] > 0) {
            top500Img = @"coChinaCTop500.png";
        }
        else if ([[oneCompanyData objectForKey:@"SalesCM"] length] > 0) {
            top500Img = @"coChinaCMTop500.png";
        }
        float heightForCell = VIEW_BY(lbCompany);
        UIImageView *imgTop500;
        if (top500Img.length > 0) {
            imgTop500 = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_BX(lbCompany) + 3, VIEW_Y(lbCompany) + 2, ([top500Img rangeOfString:@"ChinaC"].location == NSNotFound ? 55 : 75), 16)];
            [imgTop500 setImage:[UIImage imageNamed:top500Img]];
            if (VIEW_BX(imgTop500) > VIEW_W(viewCompany)) {
                CGRect frameImgTop500 = imgTop500.frame;
                frameImgTop500.origin.x = VIEW_X(lbCompany);
                frameImgTop500.origin.y = VIEW_BY(lbCompany) + 5;
                [imgTop500 setFrame:frameImgTop500];
            }
            [viewCompany addSubview:imgTop500];
            heightForCell = VIEW_BY(imgTop500);
        }
        //网申图标
        if ([[oneCompanyData objectForKey:@"IsShen"] isEqualToString:@"1"]) {
            UIImageView *imgApply = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_BX((top500Img.length > 0 ? imgTop500 : lbCompany)) + 1, VIEW_Y((top500Img.length > 0 ? imgTop500 : lbCompany)), 17, 17)];
            [imgApply setImage:[UIImage imageNamed:@"coHasApply.png"]];
            if (VIEW_BX(imgApply) > VIEW_W(viewCompany)) {
                CGRect frameImgApply = imgApply.frame;
                frameImgApply.origin.x = VIEW_X(lbCompany);
                frameImgApply.origin.y = VIEW_BY(lbCompany) + 5;
                [imgApply setFrame:frameImgApply];
            }
            [viewCompany addSubview:imgApply];
            heightForCell = VIEW_BY(imgApply);
        }
        //行业
        CustomLabel *lbIndustry = [[CustomLabel alloc] initWithFrame:CGRectMake(10, heightForCell + 5, widthForLabel, 20) content:[oneCompanyData objectForKey:@"DCIndustryName"] size:14 color:TEXTGRAYCOLOR];
        [viewCompany addSubview:lbIndustry];
        heightForCell = VIEW_BY(lbIndustry) + 10;
        //重新计算高度
        CGRect frameViewCompany = viewCompany.frame;
        frameViewCompany.size.height = heightForCell;
        [viewCompany setFrame:frameViewCompany];
        CGRect frameBtnCompany = btnCompany.frame;
        frameBtnCompany.size.height = heightForCell;
        [btnCompany setFrame:frameBtnCompany];
        if (maxCellHeight < heightForCell) {
            maxCellHeight = heightForCell;
        }
    }
    //加边框
    UIView *borderBottom = [[UIView alloc] initWithFrame:CGRectMake(0, maxCellHeight - 1, SCREEN_WIDTH, 0.5)];
    [borderBottom setBackgroundColor:SEPARATECOLOR];
    [borderBottom setTag:99];
    [cell.contentView addSubview:borderBottom];
    UIView *borderRight = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2, 0, 0.5, maxCellHeight)];
    [borderRight setBackgroundColor:SEPARATECOLOR];
    [borderRight setTag:99];
    [cell.contentView  addSubview:borderRight];
    //根据cell高度重新调整
    for (UIView *view in cell.contentView.subviews) {
        if (view.frame.size.height < maxCellHeight && view.tag != 99) {
            for (UIView *childView in view.subviews) {
                if ([childView isKindOfClass:[UIButton class]]) {
                    CGRect frameChildView = childView.frame;
                    frameChildView.size.height = maxCellHeight;
                    [childView setFrame:frameChildView];
                }
                else {
                    CGRect frameChildView = childView.frame;
                    frameChildView.origin.y += (maxCellHeight - view.frame.size.height) / 2;
                    [childView setFrame:frameChildView];
                }
            }
            CGRect frameView = view.frame;
            frameView.size.height = maxCellHeight;
            [view setFrame:frameView];
        }
    }
    [cell setFrame:CGRectMake(0, 0, SCREEN_WIDTH, maxCellHeight)];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:false];
}

- (void)CpBrandClick:(UIButton *)sender {
    NSDictionary *cpBrandData = [self.arrData objectAtIndex:sender.tag];
    CpBrandViewController *cpBrandCtrl = [[CpBrandViewController alloc] init];
    cpBrandCtrl.secondId = [cpBrandData objectForKey:@"SecondID"];
    cpBrandCtrl.title = @"名企";
    [self.navigationController pushViewController:cpBrandCtrl animated:YES];
}

- (void)searchClick {
    if (self.fromSearch) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else {
        SearchViewController *viewSearch = [self.storyboard instantiateViewControllerWithIdentifier:@"searchView"];
        viewSearch.searchType = 6;
        [self.navigationController pushViewController:viewSearch animated:true];
    }
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1) {
        [self.loadingView stopAnimating];
        if (self.page == 1) {
            [self.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
            [self.arrData removeAllObjects];
        }
        [self.arrData addObjectsFromArray:[CommonFunc getArrayFromXml:requestData tableName:@"dtBrand"]];
        [self.tableView reloadData];
        [self.tableView footerEndRefreshing];
        [self.viewNoList popupClose];
        if (self.arrData.count == 0) {
            if (self.viewNoList == nil) {
                self.viewNoList = [[PopupView alloc] initWithNoListTips:self.tableView tipsMsg:@"<div style=\"text-align:center\"><p style=\"font-size:16px;\">抱歉，同学</p><p>当前条件下没有找到您想要的企业信息</p></div>"];
            }
            [self.tableView addSubview:self.viewNoList];
        }
    }
    else if (request.tag == 2) {
        NSArray *arrContent = [CommonFunc getArrayFromXml:requestData tableName:@"Table"];
        NSString *shareContent = [[arrContent objectAtIndex:0] objectForKey:@"ContentText"];
        NSString *shareContent2 = [[arrContent objectAtIndex:0] objectForKey:@"ContentText2"];
        NSString *shareTitle = [[arrContent objectAtIndex:0] objectForKey:@"Title"];
        NSMutableArray *urlParam = [[NSMutableArray alloc] init];
        if (![self.industryId isEqualToString:@"0"]) {
            [urlParam addObject:[NSString stringWithFormat:@"i%@", self.industryId]];
        }
        NSString *url = [NSString stringWithFormat:@"/mingqi/%@", [urlParam componentsJoinedByString:@"_"]];
        [CommonFunc share:shareTitle content:shareContent url:url view:self.view imageUrl:@"" content2:shareContent2];
    }
}

- (void)footerRereshing{
    self.page++;
    [self getData];
}

- (IBAction)industryClick:(UIButton *)sender {
    [self.viewPopup popupClose];
    if (sender.tag == 0) {
        self.viewPopup.noRequired = YES;
        self.viewPopup = [[PopupView alloc] initWithArray:sender parentView:self.view array:[CommonFunc getDataFromDB:@"select * from dcIndustry"] required:NO];
        [self.viewPopup setTag:1];
        [self.viewPopup setDefaultWithLv1:self.industryId];
        [self.viewPopup setDelegate:self];
        [self.view.window addSubview:self.viewPopup];
        [self.viewPopup setDefaultWithLv1:self.industryId];
        [self resetFilter];
        [self.imgIndustry setImage:[UIImage imageNamed:@"coUpArrow.png"]];
        [sender setTag:1];
    }
    else {
        [self.imgIndustry setImage:[UIImage imageNamed:@"coDownArrow.png"]];
        [sender setTag:0];
    }
}

- (void)itemDidSelected:(id)value {
    NSDictionary *dicValue = (NSDictionary *)value;
    if (self.viewPopup.tag == 1) {
        [self.lbIndustry setText:([[dicValue objectForKey:@"id"] isEqual: @"0"] ? @"所属行业" : [dicValue objectForKey:@"name"])];
        self.industryId = [dicValue objectForKey:@"id"];
    }
    [self resetFilter];
    self.page = 1;
    [self getData];
}

- (void)closePopupWhenTapArrow {
    [self resetFilter];
}

- (void)resetFilter {
    [self.imgIndustry setImage:[UIImage imageNamed:@"coDownArrow.png"]];
    [self.btnIndustry setTag:0];
}

- (void)shareClick {
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetShareTitle" params:[NSDictionary dictionaryWithObjectsAndKeys:@"107", @"pageID", @"", @"id", nil] tag:2];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

@end

//
//  SearchSchoolListViewController.m
//  wutongguo
//
//  Created by Lucifer on 15/5/25.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "SearchSchoolListViewController.h"
#import "SchoolViewController.h"
#import "CommonMacro.h"
#import "CommonFunc.h"
#import "CustomLabel.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "GDataXMLNode.h"
#import "MJRefresh.h"
#import "PopupView.h"

@interface SearchSchoolListViewController ()<UITableViewDataSource, UITableViewDelegate, NetWebServiceRequestDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) PopupView *viewPopup;
@property (nonatomic, strong) PopupView *viewNoList;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;
@property (nonatomic) NSInteger page;
@property (nonatomic, strong) NSMutableArray *arrData;
@end

@implementation SearchSchoolListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:self.tableView];
    self.title = [NSString stringWithFormat:@"%@-%@", @"高校", self.keyWord];
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.view addSubview:self.loadingView];
    self.page = 1;
    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
    self.arrData = [[NSMutableArray alloc] init];
    [self getData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:true];
    [self.viewPopup popupClose];
}

- (void)getData {
    [self.loadingView startAnimating];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetDcSchoolByRegionID" params:[NSDictionary dictionaryWithObjectsAndKeys:@"0", @"regionID", @"0", @"majorType", self.keyWord, @"keyWord", [NSString stringWithFormat:@"%ld", (long)self.page], @"pageNo", nil] tag:1];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rowCount = ceilf((float)self.arrData.count / 2);
    return rowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellView"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellView"];
    }
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setBackgroundColor:[UIColor whiteColor]];
    if (indexPath.row % 2 == 1) {
        [cell setBackgroundColor:GRAYCELLCOLOR];
    }
    float maxCellHeight = 0;
    for (NSInteger index = indexPath.row * 2; index < (indexPath.row * 2) + 2; index++) {
        if (index == self.arrData.count) {
            break;
        }
        NSDictionary *oneSchoolData = [self.arrData objectAtIndex:index];
        //文字+图标view
        UIView *viewSchool = [[UIView alloc] initWithFrame:CGRectMake((index % 2) * (SCREEN_WIDTH / 2), 0, SCREEN_WIDTH / 2, 46)];
        
        UIButton *btnSchool = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, VIEW_W(viewSchool), VIEW_H(viewSchool))];
        [btnSchool setTag:[[oneSchoolData objectForKey:@"ID"] intValue]];
        [btnSchool addTarget:self action:@selector(schoolClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:viewSchool];
        [viewSchool addSubview:btnSchool];
        //学校名称的最大宽度
        float widthForLabel = VIEW_W(viewSchool) - 20;
        CustomLabel *lbSchool = [[CustomLabel alloc] initWithFixed:CGRectMake(10, 13, widthForLabel, 100) content:[oneSchoolData objectForKey:@"Name"] size:14 color:nil];
        [lbSchool setNumberOfLines:0];
        //整个view的高度，也就是要修改的button的高度 默认
        float heightForView = VIEW_BY(lbSchool) + 13;
        //有宣讲会或者招聘会
        if ([[oneSchoolData objectForKey:@"IsRm"] isEqualToString:@"1"] || [[oneSchoolData objectForKey:@"IsCampus"] isEqualToString:@"1"]) {
            //学校名称后面加图标
            NSArray *arrCompanyRow = [CommonFunc getSeparatedLinesFromLabel:lbSchool];
            CGSize sizeLastRow = LABEL_SIZE([arrCompanyRow objectAtIndex:arrCompanyRow.count - 1], widthForLabel, 20, 14);
            UIImageView *imgCampus;
            if ([[oneSchoolData objectForKey:@"IsCampus"] isEqualToString:@"1"]) {
                imgCampus = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_X(lbSchool) + sizeLastRow.width + 2, VIEW_BY(lbSchool) - sizeLastRow.height + 0.5, sizeLastRow.height, sizeLastRow.height)];
                [imgCampus setImage:[UIImage imageNamed:@"coHasCampus.png"]];
                //超过宽度，另起一行
                if (sizeLastRow.width + VIEW_W(imgCampus) > widthForLabel) {
                    CGRect frameCampus = imgCampus.frame;
                    frameCampus.origin.x = VIEW_X(lbSchool);
                    frameCampus.origin.y = VIEW_BY(lbSchool);
                    [imgCampus setFrame:frameCampus];
                    heightForView = heightForView + VIEW_H(imgCampus);
                }
                [viewSchool addSubview:imgCampus];
            }
            if ([[oneSchoolData objectForKey:@"IsRm"] isEqualToString:@"1"]) {
                UIImageView *imgRm;
                if (imgCampus == nil) {
                    imgRm = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_X(lbSchool) + sizeLastRow.width + 2, VIEW_BY(lbSchool) - sizeLastRow.height + 0.5, sizeLastRow.height, sizeLastRow.height)];
                }
                else {
                    imgRm = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_BX(imgCampus) + 2, VIEW_Y(imgCampus), sizeLastRow.height, sizeLastRow.height)];
                }
                [imgRm setImage:[UIImage imageNamed:@"coHasRm.png"]];
                //超过宽度，另起一行
                if ((imgCampus == nil ? sizeLastRow.width : VIEW_BX(imgCampus)) + VIEW_W(imgRm) > widthForLabel) {
                    CGRect frameRm = imgRm.frame;
                    frameRm.origin.x = VIEW_X(lbSchool);
                    frameRm.origin.y = VIEW_BY(lbSchool);
                    [imgRm setFrame:frameRm];
                    heightForView = heightForView + VIEW_H(imgCampus);
                }
                [viewSchool addSubview:imgRm];
            }
        }
        //重新计算高度
        CGRect frameViewSchool = viewSchool.frame;
        frameViewSchool.size.height = heightForView;
        [viewSchool setFrame:frameViewSchool];
        CGRect frameBtnSchool = btnSchool.frame;
        frameBtnSchool.size.height = heightForView;
        [btnSchool setFrame:frameBtnSchool];
        [viewSchool addSubview:lbSchool];
        if (heightForView > maxCellHeight) {
            maxCellHeight = heightForView;
        }
    }
    //加边框
    UIView *borderBottom = [[UIView alloc] initWithFrame:CGRectMake(0, maxCellHeight - 0.5, SCREEN_WIDTH, 0.5)];
    [borderBottom setBackgroundColor:SEPARATECOLOR];
    [borderBottom setTag:99];
    [cell.contentView addSubview:borderBottom];
    
    UIView *borderRight = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2, 0, 0.5, maxCellHeight)];
    [borderRight setBackgroundColor:SEPARATECOLOR];
    [borderRight setTag:99];
    [cell.contentView addSubview:borderRight];
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

- (void)schoolClick:(UIButton *)sender {
    SchoolViewController *schoolCtrl = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"schoolView"];
    schoolCtrl.schoolId = sender.tag;
    [self.navigationController pushViewController:schoolCtrl animated:true];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    [self.loadingView stopAnimating];
    if (self.page == 1) {
        [self.arrData removeAllObjects];
    }
    [self.arrData addObjectsFromArray:[CommonFunc getArrayFromXml:requestData tableName:@"dtSchool"]];
    [self.tableView reloadData];
    [self.tableView footerEndRefreshing];
    [self.viewNoList popupClose];
    if (self.arrData.count == 0) {
        if (self.viewNoList == nil) {
            self.viewNoList = [[PopupView alloc] initWithNoListTips:self.tableView tipsMsg:@"<div style=\"text-align:center;\"><p style=\"font-size:16px;\">抱歉，同学</p><p>当前搜索条件下没有找到您想要的高校信息</p></div>"];
        }
        [self.tableView addSubview:self.viewNoList];
    }
}

- (void)footerRereshing{
    self.page++;
    [self getData];
}

@end

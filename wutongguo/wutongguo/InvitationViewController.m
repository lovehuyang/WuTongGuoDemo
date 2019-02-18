//
//  InvitationViewController.m
//  wutongguo
//
//  Created by Lucifer on 15/5/31.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "InvitationViewController.h"
#import "CommonMacro.h"
#import "CommonFunc.h"
#import "CustomLabel.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "GDataXMLNode.h"
#import "MJRefresh.h"
#import "CpJobDetailViewController.h"
#import "PopupView.h"

@interface InvitationViewController ()<NetWebServiceRequestDelegate, UITableViewDataSource, UITableViewDelegate, PopupViewDelegate>

@property (nonatomic, strong) PopupView *viewNoList;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;
@property (nonatomic, strong) NSMutableArray *arrData;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic) NSInteger page;
@property (nonatomic) NSInteger selectedRow;
@end

@implementation InvitationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //列表
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT) style:UITableViewStyleGrouped];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.view addSubview:self.tableView];
    //等待动画
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.view addSubview:self.loadingView];
    //[self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
    self.arrData = [[NSMutableArray alloc] init];
    self.page = 1;
    [self getData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getData {
    [self.loadingView startAnimating];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"CvInvit" params:[NSDictionary dictionaryWithObjectsAndKeys:[CommonFunc getPaMainId], @"paMainID", [CommonFunc getCode], @"code", nil] tag:1];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.arrData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellView"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellView"];
    }
    [cell setSelected:NO];
    for(UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    NSDictionary *rowData = [self.arrData objectAtIndex:indexPath.section];
    float widthForLabel = SCREEN_WIDTH - 95;
    //职位名称
    CustomLabel *lbJobName = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(10, 10, widthForLabel, 20) content:[rowData objectForKey:@"JobName"] size:14 color:UIColorWithRGBA(20, 62, 103, 1)];
    [cell.contentView addSubview:lbJobName];
    //招聘简章状态
    UIImageView *imgStatus = [[UIImageView alloc] init];
    NSInteger brochureStatusType = [CommonFunc getCpBrochureStatus:[rowData objectForKey:@"BrochureStatus"] beginDate:@"2017-1-1" endDate:[rowData objectForKey:@"EndDate"]];
    NSString *statusImg = @"";
    if (brochureStatusType == 2) { //过期
        statusImg = @"coHasExpired.png";
        [imgStatus setFrame:CGRectMake(VIEW_BX(lbJobName) + 3, VIEW_Y(lbJobName) - 2, 46, 23)];
    }
    else if (brochureStatusType == 3) { //未开始
        statusImg = @"coNoStart.png";
        [imgStatus setFrame:CGRectMake(VIEW_BX(lbJobName) + 3, VIEW_Y(lbJobName), 46, 20)];
    }
    else if (brochureStatusType == 4) { //已暂停
        statusImg = @"coPause.png";
        [imgStatus setFrame:CGRectMake(VIEW_BX(lbJobName) + 3, VIEW_Y(lbJobName) - 2, 46, 23)];
    }
    else if (brochureStatusType == 1) { //网申中
        statusImg = @"coHasStart.png";
        [imgStatus setFrame:CGRectMake(VIEW_BX(lbJobName) + 3, VIEW_Y(lbJobName), 46, 20)];
    }
    [imgStatus setImage:[UIImage imageNamed:statusImg]];
    [cell.contentView addSubview:imgStatus];
    //招聘简章
    CustomLabel *lbBrochure = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbJobName), VIEW_BY(lbJobName) + 7, widthForLabel, 20) content:[rowData objectForKey:@"Title"] size:13 color:nil];
    [cell.contentView addSubview:lbBrochure];
    //工作地点
    CustomLabel *lbJobPlace = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbJobName), VIEW_BY(lbBrochure) + 6, widthForLabel, 20) content:[NSString stringWithFormat:@"工作地点：%@", [rowData objectForKey:@"jobRegion"]] size:12 color:TEXTGRAYCOLOR];
    [cell.contentView addSubview:lbJobPlace];
    //网申时间
    CustomLabel *lbDate = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbJobPlace), VIEW_BY(lbJobPlace) + 5, widthForLabel, 20) content:[NSString stringWithFormat:@"邀请时间：%@", [CommonFunc stringFromDateString:[rowData objectForKey:@"AddDate"] formatType:@"YYYY年M月d日"]] size:12 color:TEXTGRAYCOLOR];
    [cell.contentView addSubview:lbDate];
    [cell setFrame:CGRectMake(0, 0, SCREEN_WIDTH, VIEW_BY(lbDate) + 10)];
    //关注按钮
    BOOL HasAttention = ([[rowData objectForKey:@"HasAttention"] length] > 0);
    UIButton *btnFavorite = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 83, 0, 80, VIEW_BY(lbDate))];
    [btnFavorite setTag:(HasAttention ? 1 : 0)];
    [btnFavorite setTitle:[NSString stringWithFormat:@"%ld", (long)indexPath.section] forState:UIControlStateNormal];
    [btnFavorite setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    [btnFavorite addTarget:self action:@selector(favoriteClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:btnFavorite];
    UIImageView *imgFavorite = [[UIImageView alloc] initWithFrame:CGRectMake(27, VIEW_H(btnFavorite) / 2 - 13, 26, 26)];
    [imgFavorite setImage:[UIImage imageNamed:(HasAttention ? @"coFavorite.png" : @"coUnFavoriteBlue.png")]];
    [btnFavorite addSubview:imgFavorite];
    CustomLabel *lbFavorite = [[CustomLabel alloc] initWithFrame:CGRectMake(0, VIEW_BY(imgFavorite) + 2, VIEW_W(btnFavorite), 20) content:(HasAttention ? @"已关注" : @"关注") size:10 color:(HasAttention ? UIColorWithRGBA(255, 12, 92, 1) : UIColorWithRGBA(0, 148, 223, 1))];
    [lbFavorite setNumberOfLines:2];
    [lbFavorite setTextAlignment:NSTextAlignmentCenter];
    [btnFavorite addSubview:lbFavorite];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *rowData = [self.arrData objectAtIndex:indexPath.section];
    CpJobDetailViewController *jobCtrl = [[CpJobDetailViewController alloc] init];
    jobCtrl.secondId = [rowData objectForKey:@"SecondID"];
    [self.navigationController pushViewController:jobCtrl animated:YES];
}

- (void)footerRereshing{
    self.page++;
    [self getData];
}

- (void)favoriteClick:(UIButton *)sender {
    NSDictionary *rowData = [self.arrData objectAtIndex:[sender.titleLabel.text intValue]];
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
        self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"InsertPaAttention" params:[NSDictionary dictionaryWithObjectsAndKeys:[CommonFunc getPaMainId], @"paMainID", @"2", @"attentionType", [rowData objectForKey:@"jobID"], @"attentionID", [CommonFunc getCode], @"code", nil] tag:3];
        [self.runningRequest setDelegate:self];
        [self.runningRequest startAsynchronous];
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
        self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"DeletePaAttention" params:[NSDictionary dictionaryWithObjectsAndKeys:[CommonFunc getPaMainId], @"paMainID", @"2", @"attentionType", [rowData objectForKey:@"jobID"], @"attentionID", [CommonFunc getCode], @"code", nil] tag:3];
        [self.runningRequest setDelegate:self];
        [self.runningRequest startAsynchronous];
    }
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    [self.loadingView stopAnimating];
    if (request.tag == 1) {
        if (self.page == 1) {
            [self.tableView setContentOffset:CGPointMake(0, 0) animated:NO];
            [self.arrData removeAllObjects];
        }
        [self.arrData addObjectsFromArray:[CommonFunc getArrayFromXml:requestData tableName:@"Table"]];
        [self.tableView reloadData];
        [self.tableView footerEndRefreshing];
        [self.viewNoList popupClose];
        if (self.arrData.count == 0) {
            if (self.viewNoList == nil) {
                self.viewNoList = [[PopupView alloc] initWithNoListTips:self.tableView tipsMsg:@"<div style=\"text-align:center; font-size:14px;\"><p>同学，您尚未收到过任何应聘邀请，去搜索并关注感兴趣的职位，果儿会为您推送职位最新动态！</p></div>"];
            }
            [self.tableView addSubview:self.viewNoList];
        }
//        self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"UpdateNewMessageByPaMainID" params:[NSDictionary dictionaryWithObjectsAndKeys:[USER_DEFAULT objectForKey:@"paMainId"], @"paMainID", @"3", @"type", [USER_DEFAULT objectForKey:@"code"], @"code", nil] tag:3];
//        [self.runningRequest setDelegate:self];
//        [self.runningRequest startAsynchronous];
    }
    else if (request.tag == 2) {
        self.page = 1;
        [self getData];
    }
}

@end

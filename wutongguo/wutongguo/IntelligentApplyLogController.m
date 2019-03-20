//
//  IntelligentApplyLogController.m
//  wutongguo
//
//  Created by Lucifer on 2019/3/20.
//  Copyright © 2019年 Lucifer. All rights reserved.
//

#import "IntelligentApplyLogController.h"
#import "CommonMacro.h"
#import "CommonFunc.h"
#import "CustomButton.h"
#import "CustomLabel.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "GDataXMLNode.h"
#import "MJRefresh.h"
#import "PopupView.h"
#import "CompanyViewController.h"
#import "CpJobDetailViewController.h"
#import "ApplyFormViewController.h"

@interface IntelligentApplyLogController ()<UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, NetWebServiceRequestDelegate>
@property (strong, nonatomic) UITableView *tbView;
@property (nonatomic, strong) PopupView *viewNoList;
@property (nonatomic, strong) UIView *viewProcess;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;
@property (nonatomic) NSInteger page;
@property (nonatomic, strong) NSMutableArray *arrCompanyData;
@property (nonatomic, strong) NSMutableArray *arrJobData;
@property (nonatomic, strong) NSMutableArray *arrProcessData;
@property (nonatomic, strong) NSMutableArray *arrProcessDateData;
@property (nonatomic, strong) NSMutableArray *arrJobCityData;
@property (nonatomic, strong) NSMutableArray *arrJobRecommendData;
@property (nonatomic, strong) UIButton *btnProcess;
@property (nonatomic) float contentHeight;
@end

@implementation IntelligentApplyLogController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.tbView];
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.view addSubview:self.loadingView];
    self.page = 1;
    [self.tbView addFooterWithTarget:self action:@selector(footerRereshing)];
    self.arrCompanyData = [[NSMutableArray alloc] init];
    self.arrJobData = [[NSMutableArray alloc] init];
    self.arrProcessData = [[NSMutableArray alloc] init];
    self.arrProcessDateData = [[NSMutableArray alloc] init];
    self.arrJobCityData = [[NSMutableArray alloc] init];
    self.arrJobRecommendData = [[NSMutableArray alloc] init];
    [self getData];
}

- (UITableView *)tbView{
    if (!_tbView) {
        
        _tbView = [[UITableView alloc]initWithFrame:CGRectMake(0,10, SCREEN_WIDTH, SCREEN_HEIGHT - HEIGHT_STATUS_NAV - 44 - 10) style:UITableViewStylePlain];
        _tbView.delegate =self;
        _tbView.dataSource = self;
        _tbView.tableFooterView = [UIView new];
    }
    return _tbView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)getData {
    [self.loadingView startAnimating];
    
    NSDictionary *paramDict = [NSDictionary dictionaryWithObjectsAndKeys:[USER_DEFAULT objectForKey:@"paMainId"], @"paMainID", [NSString stringWithFormat:@"%ld", (long)self.page], @"pageNo", [USER_DEFAULT objectForKey:@"code"], @"code", nil];
    self.runningRequest = [NetWebServiceRequest cvServiceRequestUrl:@"GetApplyFormLogSmartByPaMainID" params:paramDict tag:1];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.arrCompanyData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *oneData = [self.arrCompanyData objectAtIndex:indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellView2"];
    if(cell == nil){
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellView2"];
    }
    for(UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    UIView *viewContent = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 90)];
    //标题
    UIButton *btnTitle = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
    [btnTitle setBackgroundColor:UIColorWithRGBA(248, 250, 250, 1)];
    [btnTitle setTag:indexPath.section];
    [btnTitle addTarget:self action:@selector(brochureClick:) forControlEvents:UIControlEventTouchUpInside];
    UIView *imgTitle = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 5, 20)];
    [imgTitle setBackgroundColor:UIColorWithRGBA(0, 192, 111, 1)];
    [btnTitle addSubview:imgTitle];
    CustomLabel *topSeperate = [[CustomLabel alloc] initSeparate:btnTitle];
    [topSeperate setFrame:CGRectMake(topSeperate.frame.origin.x, 0, topSeperate.frame.size.width, topSeperate.frame.size.height)];
    [btnTitle addSubview:topSeperate];
    [btnTitle addSubview:[[CustomLabel alloc] initSeparate:btnTitle]];
    
    NSString *content = [oneData objectForKey:@"CompanyName"];
    float fontSize = 15;
    CustomLabel *lbCompany = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgTitle) + 10, VIEW_Y(imgTitle), SCREEN_WIDTH - (VIEW_BX(imgTitle) + 20), 20) content:content size:fontSize color:nil];
    [btnTitle addSubview:lbCompany];
    
    content = [oneData objectForKey:@"CpBrochureName"];
    fontSize = 14;
    CustomLabel *lbTitle = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbCompany), VIEW_BY(lbCompany) + 5, 300, 20) content:content size:fontSize color:TEXTGRAYCOLOR];
    [btnTitle addSubview:lbTitle];
    [viewContent addSubview:btnTitle];
    //职位
    NSArray *arrJob = [CommonFunc getArrayFromArrayWithSelect:self.arrJobData param:[NSArray arrayWithObject:[NSDictionary dictionaryWithObject:[oneData objectForKey:@"CpBrochureID"] forKey:@"CpBrochureID"]]];
    UIView *viewJob = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_BY(btnTitle), SCREEN_WIDTH, 50)];
    float wishHeight = 1;
    for (NSDictionary *oneJob in arrJob) {
        wishHeight = wishHeight + 10;
        UIImageView *imgWish = [[UIImageView alloc] initWithFrame:CGRectMake(13, wishHeight, 0, 20)];
        if (index > 0) {
            [imgWish setFrame:CGRectMake(13, wishHeight, 50, 20)];
            [imgWish setImage:[UIImage imageNamed:@"ucWishArrow.png"]];
            [imgWish setBackgroundColor:[UIColor clearColor]];
            [viewJob addSubview:imgWish];
            
            content = [NSString stringWithFormat:@"%@志愿", [oneJob objectForKey:@"WishNo"]];
            fontSize = 12;
            CustomLabel *lbWish = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(18, VIEW_Y(imgWish), 40, 20) content:content size:fontSize color:TEXTGRAYCOLOR];
            [viewJob addSubview:lbWish];
        }
        
        content = [oneJob objectForKey:@"JobName"];
        fontSize = 14;
        CustomLabel *lbJob = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgWish) + (VIEW_BX(imgWish) == VIEW_X(imgWish) ? 0 : 5), VIEW_Y(imgWish), 200, 20) content:content size:fontSize color:UIColorWithRGBA(0, 52, 98, 1)];
        [viewJob addSubview:lbJob];
        UIButton *btnModify = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 100, VIEW_Y(lbJob), 90, 20)];
        [btnModify setTitle:[oneJob objectForKey:@"JobID"] forState:UIControlStateNormal];
        [btnModify.titleLabel setTextColor:[UIColor clearColor]];
        [btnModify addTarget:self action:@selector(modifyClick:) forControlEvents:UIControlEventTouchUpInside];
        CustomLabel *lbModify = [[CustomLabel alloc] initWithFrame:CGRectMake(0, 5, VIEW_W(btnModify), VIEW_H(btnModify)) content:@"修改申请表" size:12 color:UIColorWithRGBA(240, 169, 13, 1)];
        [lbModify setTextAlignment:NSTextAlignmentCenter];
        [btnModify addSubview:lbModify];
        [viewJob addSubview:btnModify];
        //网申进程按钮
        CustomButton *btnProcess = [[CustomButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 100, VIEW_BY(imgWish) + 15, 90, 30)];
        [btnProcess setTitle:[oneJob objectForKey:@"ID"] forState:UIControlStateNormal];
        [btnProcess setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        [btnProcess setTag:0];
        [btnProcess addTarget:self action:@selector(processClick:) forControlEvents:UIControlEventTouchUpInside];
        //网申进程文字
        content = @"网申进程";
        fontSize = 12;
        BOOL hasViewed = !([[oneJob objectForKey:@"ProcessViewDate"] length] == 0 && [[oneJob objectForKey:@"ProcessCount"] intValue] > 0);
        CustomLabel *labelProcess = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(13, 0, 50, 29) content:content size:fontSize color:(hasViewed ? NAVBARCOLOR : UIColorWithRGBA(230, 0, 18, 1))];
        [btnProcess addSubview:labelProcess];
        //网申进程箭头
        if (hasViewed) {
            UIImageView *imgProcess = [[UIImageView alloc] initWithFrame:CGRectMake(65, 12, 12, 6)];
            [imgProcess setImage:[UIImage imageNamed:@"coDownArrow.png"]];
            [btnProcess addSubview:imgProcess];
        }
        else {
            UIImageView *imgProcess = [[UIImageView alloc] initWithFrame:CGRectMake(65, 9, 12, 12)];
            [imgProcess setImage:[UIImage imageNamed:@"ucNotViewProcess.png"]];
            [btnProcess addSubview:imgProcess];
        }
        
        [viewJob addSubview:btnProcess];
        //机构
        content = [NSString stringWithFormat:@"机构：%@", [oneJob objectForKey:@"CpDeptName"]];
        fontSize = 12;
        CustomLabel *labelDept = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(imgWish), VIEW_Y(btnProcess) - 10, VIEW_X(btnProcess) - VIEW_X(imgWish) - 10, 20) content:content size:fontSize color:TEXTGRAYCOLOR];
        [viewJob addSubview:labelDept];
        //工作地点
        NSArray *arrJobCity = [CommonFunc getArrayFromArrayWithSelect:self.arrJobCityData param:[NSArray arrayWithObject:[NSDictionary dictionaryWithObject:[oneJob objectForKey:@"JobID"] forKey:@"JobID"]]];
        NSMutableString *jobCity = [[NSMutableString alloc] init];
        for (NSDictionary *oneJobCity in arrJobCity) {
            [jobCity appendFormat:@"%@ ", [oneJobCity objectForKey:@"FullName"]];
        }
        content = [NSString stringWithFormat:@"工作地点：%@", jobCity];
        CustomLabel *labelWorkPlace = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(imgWish), VIEW_BY(labelDept), VIEW_X(btnProcess) - VIEW_X(imgWish) - 10, 20) content:content size:fontSize color:TEXTGRAYCOLOR];
        [viewJob addSubview:labelWorkPlace];
        UIButton *btnJob = [[UIButton alloc] initWithFrame:CGRectMake(0, wishHeight - 5, VIEW_X(btnProcess) - 20, VIEW_BY(labelWorkPlace))];
        [btnJob setTag:indexPath.section];
        [btnJob setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        [btnJob setTitle:[oneJob objectForKey:@"JobSecondID"] forState:UIControlStateNormal];
        [btnJob addTarget:self action:@selector(jobClick:) forControlEvents:UIControlEventTouchUpInside];
        [viewJob addSubview:btnJob];
        wishHeight = VIEW_BY(labelWorkPlace);
    }
    //重新计算志愿高度
    CGRect frameJob = viewJob.frame;
    frameJob.size.height = wishHeight;
    [viewJob setFrame:frameJob];
    [viewContent addSubview:viewJob];
    //重新计算cell内容高度
    CGRect frameContent = viewContent.frame;
    frameContent.size.height = VIEW_BY(viewJob) + 10;
    [viewContent setFrame:frameContent];
    [viewContent addSubview:[[CustomLabel alloc] initSeparate:viewContent]];
    [cell.contentView addSubview:viewContent];
    [cell setFrame:CGRectMake(0, 0, SCREEN_WIDTH, viewContent.frame.size.height)];
    return cell;
}

- (void)modifyClick:(UIButton *)sender {
    ApplyFormViewController *applyFormCtrl = [[ApplyFormViewController alloc] init];
    applyFormCtrl.jobId = sender.titleLabel.text;
    [self.navigationController pushViewController:applyFormCtrl animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView:self.tbView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (void)processClick:(UIButton *)button {
    if (self.contentHeight == 0) {
        self.contentHeight = self.tbView.contentSize.height;
    }
    [UIView animateWithDuration:0.5 animations:^{
        [self.tbView setContentSize:CGSizeMake(self.tbView.contentSize.width, self.contentHeight)];
    }];
    UIImageView *imgProcess;
    UILabel *lbProcess;
    for (UIView *view in button.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            imgProcess = (UIImageView *)view;
        }
        if ([view isKindOfClass:[CustomLabel class]]) {
            lbProcess = (CustomLabel *)view;
        }
    }
    if (button.tag == 0) {
        [imgProcess setFrame:CGRectMake(65, 12, 12, 6)];
        [lbProcess setTextColor:NAVBARCOLOR];
        [imgProcess setImage:[UIImage imageNamed:@"coUpArrow.png"]];
        [button setTag:1];
        [self showProcess:button];
    }
    else {
        [imgProcess setImage:[UIImage imageNamed:@"coDownArrow.png"]];
        [button setTag:0];
        [self closeProcess];
    }
    //上个没关闭又点击一个，需要把上一个的箭头改为收回
    if (self.btnProcess != button) {
        UIImageView *imgProcessPrev;
        for (UIView *viewPrev in self.btnProcess.subviews) {
            if ([viewPrev isKindOfClass:[UIImageView class]]) {
                imgProcessPrev = (UIImageView *)viewPrev;
            }
        }
        [imgProcessPrev setImage:[UIImage imageNamed:@"coDownArrow.png"]];
        [self.btnProcess setTag:0];
        self.btnProcess = button;
    }
}

- (void)showProcess:(UIButton *)button {
    CGRect rectButton = [button convertRect:button.bounds toView:self.tbView];
    if (self.viewProcess == nil) {
        self.viewProcess = [[UIView alloc] init];
        [self.viewProcess setBackgroundColor:UIColorWithRGBA(238, 250, 246, 1)];
    }
    else {
        for (UIView *view in self.viewProcess.subviews) {
            [view removeFromSuperview];
        }
    }
    [self.viewProcess setFrame:CGRectMake(0, rectButton.origin.y + rectButton.size.height + 18, SCREEN_WIDTH, 1)];
    NSDictionary *jobData = [[CommonFunc getArrayFromArrayWithSelect:self.arrJobData param:[NSArray arrayWithObject:[NSDictionary dictionaryWithObject:button.titleLabel.text forKey:@"ID"]]] objectAtIndex:0];
    [jobData setValue:@"1" forKey:@"ProcessViewDate"];
    NSArray *processData = [CommonFunc getArrayFromArrayWithSelect:self.arrProcessData param:[NSArray arrayWithObject:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%@", [jobData objectForKey:@"CpBrochureID"]] forKey:@"CpBrochureID"]]];
    BOOL blnApply = [[jobData objectForKey:@"ApplyStatus"] isEqualToString:@"1"];
    //左侧竖线
    UIView *viewLeftLine = [[UIView alloc] initWithFrame:CGRectMake(18, 25, 2, 300)];
    [viewLeftLine setBackgroundColor:UIColorWithRGBA(179, 239, 219, 1)];
    [self.viewProcess addSubview:viewLeftLine];
    //前面小圆点
    UIImageView *imgApplyTips = [[UIImageView alloc] initWithFrame:CGRectMake(14, 20, 10, 10)];
    [imgApplyTips setImage:[UIImage imageNamed:(blnApply ? @"coEmptyCircle.png" : @"coCircle.png")]];
    [self.viewProcess addSubview:imgApplyTips];
    //流程名称
    CustomLabel *lbApply = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgApplyTips) + 5, VIEW_Y(imgApplyTips) - VIEW_H(imgApplyTips) / 2, SCREEN_WIDTH / 2 - VIEW_BX(imgApplyTips) - 20, 20) content:@"" size:12 color:nil];
    [self.viewProcess addSubview:lbApply];
    //状态
    UIColor *waitingColor = UIColorWithRGBA(252, 173, 0, 1);
    UIImageView *imgApplyStatus = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2, VIEW_Y(lbApply), 20, 20)];
    [imgApplyStatus setImage:[UIImage imageNamed:(blnApply ? @"coSuccess.png" : @"coWaiting.png")]];
    [self.viewProcess addSubview:imgApplyStatus];
    CustomLabel *lbApplyStatus;
    if (blnApply) {
        lbApplyStatus = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgApplyStatus) + 5, VIEW_Y(lbApply), 300, 20) content:@"申请成功" size:12 color:NAVBARCOLOR];
    }
    else {
        lbApplyStatus = [[CustomLabel alloc] initWithFixed:CGRectMake(VIEW_BX(imgApplyStatus) + 5, VIEW_Y(lbApply), SCREEN_WIDTH - VIEW_BX(imgApplyStatus) - 10, 50) content:@"未提交申请，需要去电脑端完成申请表" size:12 color:waitingColor];
    }
    [self.viewProcess addSubview:lbApplyStatus];
    if (blnApply) {
        CustomLabel *lbProcessDate = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(SCREEN_WIDTH - 70, VIEW_Y(lbApply), 300, 20) content:[CommonFunc stringFromDateString:[jobData objectForKey:@"CreateDate"] formatType:@"yyyy-M-d"] size:12 color:TEXTGRAYCOLOR];
        [self.viewProcess addSubview:lbProcessDate];
    }
    float heightForProcess = VIEW_BY(lbApply);
    BOOL blnPassed = YES;
    int i = 0;
    for (NSDictionary *oneProcess in processData) {
        BOOL blnCurrentProcess = [[oneProcess objectForKey:@"ID"] isEqualToString:[jobData objectForKey:@"CpProcessID"]];
        if (blnCurrentProcess) {
            blnPassed = NO;
        }
        //前面小圆点
        UIImageView *imgTips = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_X(imgApplyTips), heightForProcess + 25, 10, 10)];
        [imgTips setImage:[UIImage imageNamed:(blnPassed ? @"coEmptyCircle.png" : @"coGrayCircle.png")]];
        [self.viewProcess addSubview:imgTips];
        //流程名称
        CustomLabel *lbProcess = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgTips) + 5, VIEW_Y(imgTips) - VIEW_H(imgTips) / 2, SCREEN_WIDTH / 2 - VIEW_BX(imgTips) - 20, 20) content:[oneProcess objectForKey:@"Name"] size:12 color:nil];
        [self.viewProcess addSubview:lbProcess];
        //如果是当前流程，将前面的点弄大一些
        if (blnApply) {
            if (blnCurrentProcess) {
                [imgTips setImage:[UIImage imageNamed:@"coCircle.png"]];
                [imgTips setFrame:CGRectMake(VIEW_X(imgTips) - 1, VIEW_Y(imgTips) - 1, 12, 12)];
            }
            //状态
            if (blnCurrentProcess || blnPassed) {
                UIImageView *imgStatus = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2, VIEW_Y(lbProcess), 20, 20)];
                [imgStatus setImage:[UIImage imageNamed:(blnCurrentProcess ? @"coWaiting.png" : @"coSuccess.png")]];
                [self.viewProcess addSubview:imgStatus];
                CustomLabel *lbStatus;
                NSArray *arrRecommendLog = [CommonFunc getArrayFromArrayWithSelect:self.arrJobRecommendData param:[NSArray arrayWithObject:[NSDictionary dictionaryWithObject:[jobData objectForKey:@"ID"] forKey:@"ApplyFormLogID"]]];
                if (arrRecommendLog.count > 0 && blnCurrentProcess) {
                    NSDictionary *oneRecommendLog = [arrRecommendLog objectAtIndex:0];
                    lbStatus = [[CustomLabel alloc] initWithFixed:CGRectMake(VIEW_BX(imgStatus) + 5, VIEW_Y(lbProcess), SCREEN_WIDTH - VIEW_BX(imgStatus) - 10, 50) content:[NSString stringWithFormat:@"该申请表已推荐至“%@”", [oneRecommendLog objectForKey:@"JobName"]] size:12 color:(blnCurrentProcess ? waitingColor : NAVBARCOLOR)];
                    [imgStatus setImage:[UIImage imageNamed:@"coNotPass.png"]];
                }
                else {
                    NSString *applyFormStatus = @"";
                    UIColor *colorApplyFormStatus;
                    if (blnPassed) {
                        applyFormStatus = @"已通过";
                        colorApplyFormStatus = NAVBARCOLOR;
                    }
                    else {
                        if ([[jobData objectForKey:@"IsEnd"] isEqualToString:@"true"]) {
                            if (i == processData.count - 1) {
                                applyFormStatus = @"已录用";
                                colorApplyFormStatus = NAVBARCOLOR;
                                [imgStatus setImage:[UIImage imageNamed:@"coSuccess.png"]];
                            }
                            else {
                                applyFormStatus = @"未通过";
                                colorApplyFormStatus = UIColorWithRGBA(230, 0, 18, 1);
                                [imgStatus setImage:[UIImage imageNamed:@"coNotPass.png"]];
                            }
                        }
                        else {
                            applyFormStatus = @"未处理";
                            colorApplyFormStatus = waitingColor;
                        }
                    }
                    lbStatus = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgStatus) + 5, VIEW_Y(lbProcess), 300, 20) content:applyFormStatus size:12 color:colorApplyFormStatus];
                }
                [self.viewProcess addSubview:lbStatus];
                if ([lbStatus.text rangeOfString:@"推荐"].location == NSNotFound) {
                    NSArray *processDate = [CommonFunc getArrayFromArrayWithSelect:self.arrProcessDateData param:[NSArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:[jobData objectForKey:@"ID"], @"ApplyFormLogID", [oneProcess objectForKey:@"ID"], @"CpProcessIDPrev", nil]]];
                    if (processDate.count > 0) {
                        if (i > 0 && i < processData.count - 1 && blnCurrentProcess && [[jobData objectForKey:@"IsEnd"] isEqualToString:@"false"]) {
                            
                        }
                        else {
                            CustomLabel *lbProcessDate = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(SCREEN_WIDTH - 70, VIEW_Y(lbProcess), 300, 20) content:[CommonFunc stringFromDateString:[[processDate objectAtIndex:0] objectForKey:@"AddDate"] formatType:@"yyyy-M-d"] size:12 color:TEXTGRAYCOLOR];
                            [self.viewProcess addSubview:lbProcessDate];
                        }
                    }
                }
            }
        }
        heightForProcess = VIEW_BY(lbProcess);
        i++;
    }
    CGRect frameLeftLine = viewLeftLine.frame;
    frameLeftLine.size.height = heightForProcess - VIEW_Y(viewLeftLine) - 10;
    [viewLeftLine setFrame:frameLeftLine];
    //重新设置高
    CGRect frameProcess = self.viewProcess.frame;
    frameProcess.size.height = heightForProcess + 15;
    [self.viewProcess setFrame:frameProcess];
    //上边框
    UIView *viewTopSeparate = [[UIView alloc] initWithFrame:CGRectMake(0, 0, VIEW_W(self.viewProcess), 0.5)];
    [viewTopSeparate setBackgroundColor:SEPARATECOLOR];
    [self.viewProcess addSubview:viewTopSeparate];
    //展开箭头
    UIImageView *imgArrow = [[UIImageView alloc] initWithFrame:CGRectMake(rectButton.origin.x + VIEW_W(button) / 2 - 20, -7.5, 19, 8)];
    [imgArrow setImage:[UIImage imageNamed:@"ucApplyArrow.png"]];
    [imgArrow setBackgroundColor:UIColorWithRGBA(238, 250, 246, 1)];
    [self.viewProcess addSubview:imgArrow];
    //下边框
    UIView *viewBottomSeparate = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_H(self.viewProcess) - 0.5, VIEW_W(self.viewProcess), 0.5)];
    [viewBottomSeparate setBackgroundColor:SEPARATECOLOR];
    [self.viewProcess addSubview:viewBottomSeparate];
    //添加至view
    self.viewProcess.alpha = 0;
    [self.tbView addSubview:self.viewProcess];
    [UIView animateWithDuration:0.5 animations:^{
        self.viewProcess.alpha = 1;
        if (self.tbView.contentOffset.y + self.view.frame.size.height < VIEW_BY(self.viewProcess)) {
            [self.tbView setContentOffset:CGPointMake(0, VIEW_BY(self.viewProcess) - self.view.frame.size.height)];
        }
    } completion:^(BOOL finished) {
        if (VIEW_BY(self.viewProcess) > self.tbView.contentSize.height) {
            [self.tbView setContentSize:CGSizeMake(self.tbView.contentSize.width, VIEW_BY(self.viewProcess))];
        }
    }];
}

- (void) closeProcess {
    [UIView animateWithDuration:0.5 animations:^{
        self.viewProcess.alpha = 0;
    } completion:^(BOOL finished) {
        [self.viewProcess removeFromSuperview];
    }];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    [self.loadingView stopAnimating];
    if (request.tag == 1) {
        if(self.page == 1){
            [self.arrCompanyData removeAllObjects];
            [self.arrJobData removeAllObjects];
            [self.arrProcessData removeAllObjects];
            [self.arrProcessDateData removeAllObjects];
            [self.arrJobCityData removeAllObjects];
            [self.arrJobRecommendData removeAllObjects];
        }
        [self.arrCompanyData addObjectsFromArray:[CommonFunc getArrayFromXml:requestData tableName:@"dtBrochure"]];
        [self.arrJobData addObjectsFromArray:[CommonFunc getArrayFromXml:requestData tableName:@"dtLog"]];
        [self.arrProcessData addObjectsFromArray:[CommonFunc getArrayFromXml:requestData tableName:@"dtProcess"]];
        [self.arrProcessDateData addObjectsFromArray:[CommonFunc getArrayFromXml:requestData tableName:@"dtDate"]];
        [self.arrJobCityData addObjectsFromArray:[CommonFunc getArrayFromXml:requestData tableName:@"Table7"]];
        [self.arrJobRecommendData addObjectsFromArray:[CommonFunc getArrayFromXml:requestData tableName:@"dtRecommendLog"]];
        [self.tbView footerEndRefreshing];
        [self.tbView reloadData];
        [self.viewNoList popupClose];
        if (self.arrCompanyData.count == 0) {
            if (self.viewNoList == nil) {
                self.viewNoList = [[PopupView alloc] initWithNoListTips:self.tbView tipsMsg:@"<div style=\"text-align:center\"><p>同学，您暂无网申记录</p><p>果儿邀请您现在就去网申吧！</p></div>"];
            }
            [self.tbView addSubview:self.viewNoList];
        }
        self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"UpdateNewMessageByPaMainID" params:[NSDictionary dictionaryWithObjectsAndKeys:[USER_DEFAULT objectForKey:@"paMainId"], @"paMainID", @"1", @"type", [USER_DEFAULT objectForKey:@"code"], @"code", nil] tag:2];
        [self.runningRequest setDelegate:self];
        [self.runningRequest startAsynchronous];
    }
}

- (void)footerRereshing {
    self.page++;
    [self getData];
}

- (void)brochureClick:(UIButton *)sender {
    NSDictionary *companyData = [self.arrCompanyData objectAtIndex:sender.tag];
    CompanyViewController *companyCtrl = [[CompanyViewController alloc] init];
    companyCtrl.secondId = [companyData objectForKey:@"CpSecondID"];
    companyCtrl.cpBrochureSecondId = [companyData objectForKey:@"SecondID"];
    companyCtrl.tabIndex = 1;
    [self.navigationController pushViewController:companyCtrl animated:YES];
}

- (void)jobClick:(UIButton *)sender {
    CpJobDetailViewController *jobCtrl = [[CpJobDetailViewController alloc] init];
    jobCtrl.secondId = sender.titleLabel.text;;
    [self.navigationController pushViewController:jobCtrl animated:true];
}

@end

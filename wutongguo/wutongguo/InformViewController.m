//
//  InformViewController.m
//  wutongguo
//
//  Created by Lucifer on 15/6/2.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "InformViewController.h"
#import "CommonMacro.h"
#import "CommonFunc.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "GDataXMLNode.h"
#import "CustomLabel.h"
#import "UIImageView+WebCache.h"
#import "PopupView.h"
#import "MJRefresh.h"
#import "FocusViewController.h"
#import "CompanyViewController.h"
#import "CpJobDetailViewController.h"

@interface InformViewController ()<NetWebServiceRequestDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) PopupView *viewNoList;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *arrData;
@property (nonatomic, strong) NSString *photoUrl;
@property (nonatomic) NSInteger page;
@end

@implementation InformViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"网站消息";
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:self.tableView];
    [self.tableView addFooterWithTarget:self action:@selector(footerRereshing)];
    self.page = 1;
    self.arrData = [[NSMutableArray alloc] init];
    //等待动画
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.view addSubview:self.loadingView];
    [self getData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getData {
    [self.loadingView startAnimating];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetPaInform" params:[NSDictionary dictionaryWithObjectsAndKeys:[CommonFunc getPaMainId], @"paMainID", [CommonFunc getCode], @"code", [NSString stringWithFormat:@"%ld", (long)self.page], @"PageNo", nil] tag:1];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellView"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellView"];
    }
    for(UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setBackgroundColor:[UIColor clearColor]];
    NSDictionary *informData = [self.arrData objectAtIndex:indexPath.row];
    CGRect frameInform = CGRectMake(60, 10, SCREEN_WIDTH - 70, 300);
    UIView *viewInform = [[UIView alloc] initWithFrame:frameInform];
    [viewInform setBackgroundColor:[UIColor whiteColor]];
    [viewInform.layer setCornerRadius:5];
    [cell.contentView addSubview:viewInform];
    CGRect frameLabel = CGRectMake(10, 10, VIEW_W(viewInform) - 20 , 200);
    //问答图标
    if ([[informData objectForKey:@"MsgType"] isEqualToString:@"2"] || [[informData objectForKey:@"MsgType"] isEqualToString:@"3"]) {
        UIImageView *imgFeedback = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 20, 18)];
        [imgFeedback setImage:[UIImage imageNamed:([[informData objectForKey:@"MsgType"] isEqualToString:@"2"] ? @"coQuestion.png" : @"coAsk.png")]];
        [viewInform addSubview:imgFeedback];
        frameLabel.origin.x = VIEW_BX(imgFeedback) + 5;
        frameLabel.size.width = VIEW_W(viewInform) - VIEW_BX(imgFeedback) - 15;
    }
    NSString *addDate = [CommonFunc stringFromDateString:[informData objectForKey:@"AddDate"] formatType:@"yyyy-M-d"];
    CustomLabel *lbInform = [[CustomLabel alloc] initWithFixed:frameLabel content:[NSString stringWithFormat:@"%@  %@", [informData objectForKey:@"Title"], addDate] size:13 color:nil];
    NSMutableAttributedString *attrInform = [[NSMutableAttributedString alloc] initWithString:lbInform.text];
    [attrInform addAttribute:NSForegroundColorAttributeName value:TEXTGRAYCOLOR range:NSMakeRange(lbInform.text.length - addDate.length, addDate.length)];
    [attrInform addAttribute:NSFontAttributeName value:FONT(12) range:NSMakeRange(lbInform.text.length - addDate.length, addDate.length)];
    [lbInform setAttributedText:attrInform];
    [lbInform sizeToFit];
    [viewInform addSubview:lbInform];
    UIView *lastView = lbInform;
    if ([[informData objectForKey:@"MsgType"] isEqualToString:@"1"]) { //网站消息
        if ([[informData objectForKey:@"Type"] isEqualToString:@"1"]) { //文本消息
            CustomLabel *lbContent = [[CustomLabel alloc] initWithFixed:CGRectMake(VIEW_X(lbInform), VIEW_BY(lbInform) + 10, VIEW_W(viewInform) - 20, 2000) content:[informData objectForKey:@"Content"] size:12 color:nil];
            [viewInform addSubview:lbContent];
            lastView = lbContent;
        }
        else {
            [attrInform addAttribute:NSForegroundColorAttributeName value:UIColorWithRGBA(28, 64, 101, 1) range:NSMakeRange(0, lbInform.text.length - addDate.length)];
            [lbInform setAttributedText:attrInform];
        }
    }
    //设置位置高度
    frameInform.size.height = VIEW_BY(lastView) + 10;
    if ([[informData objectForKey:@"MsgType"] isEqualToString:@"2"]) {
        frameInform.origin.x = 10;
    }
    [viewInform setFrame:frameInform];
    //头像
    if ([[informData objectForKey:@"MsgType"] isEqualToString:@"2"]) {
        UIImageView *imgPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 50, VIEW_Y(viewInform), 40, 40)];
        if (self.photoUrl.length > 0) {
            [imgPhoto sd_setImageWithURL:[NSURL URLWithString:self.photoUrl] placeholderImage:[UIImage imageNamed:@"ucNoPhoto.png"]];
        }
        else {
            [imgPhoto setImage:[UIImage imageNamed:@"ucNoPhoto.png"]];
        }
        [imgPhoto.layer setMasksToBounds:YES];
        [imgPhoto.layer setCornerRadius:VIEW_W(imgPhoto) / 2];
        [imgPhoto.layer setBorderColor:[SEPARATECOLOR CGColor]];
        [imgPhoto.layer setBorderWidth:1];
        [cell.contentView addSubview:imgPhoto];
        //箭头
        UIImageView *imgArrow = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_BX(viewInform) - 1, VIEW_Y(viewInform) + 10, 10, 10)];
        [imgArrow setImage:[UIImage imageNamed:@"coInformArrow.png"]];
        [cell.contentView addSubview:imgArrow];
    }
    else {
        UIImageView *imgPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(10, VIEW_Y(viewInform), 40, 40)];
        [imgPhoto setImage:[UIImage imageNamed:@"loginTitle.png"]];
        [cell.contentView addSubview:imgPhoto];
        //箭头
        UIImageView *imgArrow = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_X(viewInform) - 9, VIEW_Y(viewInform) + 10, 10, 10)];
        [imgArrow setImage:[UIImage imageNamed:@"coInformArrowLeft.png"]];
        [cell.contentView addSubview:imgArrow];
    }
    [cell setFrame:CGRectMake(0, 0, SCREEN_WIDTH, VIEW_BY(viewInform) + 20)];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *informData = [self.arrData objectAtIndex:indexPath.row];
    if ([[informData objectForKey:@"MsgType"] isEqualToString:@"1"] && [[informData objectForKey:@"Type"] isEqualToString:@"2"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"同学，需要去电脑端查看该条通知内容。" delegate:self cancelButtonTitle:@"知道啦" otherButtonTitles:nil, nil];
        [alert show];
    }
    else if ([[informData objectForKey:@"MsgType"] integerValue] > 1000) {
        if ([[informData objectForKey:@"Link"] length] > 0) {
            NSString *url = [[informData objectForKey:@"Link"] lowercaseString];
            if ([url rangeOfString:@"http://m.wutongguo.com/notice"].location != NSNotFound) {
                NSString *brochureSecondId = [[url stringByReplacingOccurrencesOfString:@"http://m.wutongguo.com/notice" withString:@""] stringByReplacingOccurrencesOfString:@".html" withString:@""];
                [self.loadingView startAnimating];
                self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetCpBrochureByID" params:[NSDictionary dictionaryWithObjectsAndKeys:brochureSecondId, @"cpBrochureID", nil] tag:2];
                [self.runningRequest setDelegate:self];
                [self.runningRequest startAsynchronous];
            }
            else if ([url rangeOfString:@"http://m.wutongguo.com/preach"].location != NSNotFound) {
                NSString *companySecondId = [[url stringByReplacingOccurrencesOfString:@"http://m.wutongguo.com/preach" withString:@""] stringByReplacingOccurrencesOfString:@".html" withString:@""];
                CompanyViewController *companyCtrl = [[CompanyViewController alloc] init];
                companyCtrl.secondId = companySecondId;
                companyCtrl.tabIndex = 2;
                [self.navigationController pushViewController:companyCtrl animated:YES];
            }
            else if ([url rangeOfString:@"http://m.wutongguo.com/job"].location != NSNotFound) {
                NSString *jobSecondId = [[url stringByReplacingOccurrencesOfString:@"http://m.wutongguo.com/job" withString:@""] stringByReplacingOccurrencesOfString:@".html" withString:@""];
                CpJobDetailViewController *jobDetailCtrl = [[CpJobDetailViewController alloc] init];
                jobDetailCtrl.secondId = jobSecondId;
                [self.navigationController pushViewController:jobDetailCtrl animated:YES];
            }
        }
        else if ([[informData objectForKey:@"MsgType"] integerValue] < 1013) {
            NSInteger msgType = [[informData objectForKey:@"MsgType"] integerValue];
            FocusViewController *focusCtrl = [[FocusViewController alloc] init];
            if (msgType == 1002 || msgType == 1009 || msgType == 1010) {
                focusCtrl.navTabBarIndex = 3;
            }
            else if (msgType == 1005 || msgType == 1006) {
                focusCtrl.navTabBarIndex = 1;
            }
            else if (msgType == 1007 || msgType == 1008) {
                focusCtrl.navTabBarIndex = 2;
            }
            else if (msgType == 1011 || msgType == 1012) {
                focusCtrl.navTabBarIndex = 4;
            }
            [self.navigationController pushViewController:focusCtrl animated:YES];
        }
    }
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    [self.loadingView stopAnimating];
    if (request.tag == 1) {
        [self.arrData addObjectsFromArray:[CommonFunc getArrayFromXml:requestData tableName:@"Table"]];
        NSArray *arrPhoto = [CommonFunc getArrayFromXml:requestData tableName:@"dtPhoto"];
        NSString *path;
        if ([arrPhoto count] > 0) {
            path = [NSString stringWithFormat:@"%d",([[USER_DEFAULT objectForKey:@"paMainId"] intValue] / 100000 + 1) * 100000];
            NSInteger lastLength = 9 - path.length;
            for (int i = 0; i < lastLength; i++) {
                path = [NSString stringWithFormat:@"0%@",path];
            }
            path = [NSString stringWithFormat:@"L%@",path];
            path = [NSString stringWithFormat:@"http://down.51rc.com/imagefolder/wutongguo/Photo/%@/Processed/%@", path, [[arrPhoto objectAtIndex:0] objectForKey:@"Photo"]];
        }
        self.photoUrl = path;
        [self.viewNoList popupClose];
        [self.tableView footerEndRefreshing];
        if (self.arrData.count == 0) {
            if (self.viewNoList == nil) {
                self.viewNoList = [[PopupView alloc] initWithNoListTips:self.tableView tipsMsg:@""];
            }
            [self.tableView addSubview:self.viewNoList];
        }
        else {
            [self.tableView reloadData];
        }
    }
    else if (request.tag == 2) {
        NSDictionary *cpBrochureData = [[CommonFunc getArrayFromXml:requestData tableName:@"Table"] objectAtIndex:0];
        CompanyViewController *companyCtrl = [[CompanyViewController alloc] init];
        companyCtrl.secondId = [cpBrochureData objectForKey:@"cpSecondID"];
        companyCtrl.cpBrochureSecondId = [cpBrochureData objectForKey:@"SecondID"];
        companyCtrl.tabIndex = 0;
        [self.navigationController pushViewController:companyCtrl animated:YES];
    }
}

- (void)footerRereshing {
    self.page++;
    [self getData];
}

@end

//
//  SettingViewController.m
//  wutongguo
//
//  Created by Lucifer on 15-5-11.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "SettingViewController.h"
#import "CommonMacro.h"
#import "CommonFunc.h"
#import "CustomLabel.h"
#import "Toast+UIView.h"
#import <ShareSDK/ShareSDK.h>
#import "PopupView.h"
#import "HelpViewController.h"
#import "JPUSHService.h"
#import "NetWebServiceRequest.h"

@interface SettingViewController () <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, PopupViewDelegate, NetWebServiceRequestDelegate>

@property (nonatomic, strong) NSArray *arrTitle;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"设置";
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.arrTitle = @[@"新手帮助", @"关于我们", @"触屏版", @"退出账号"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrTitle.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellView" forIndexPath:indexPath];
    UIImageView *imgButton = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 25, 25)];
    [imgButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"ucSetting%ld.png", (long)(indexPath.row + 2)]]];
    [cell.contentView addSubview:imgButton];
    
    CustomLabel *lbTitle = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgButton) + 10, VIEW_Y(imgButton) + 3, 100, 20) content:self.arrTitle[indexPath.row] size:14 color:nil];
    [cell.contentView addSubview:lbTitle];
    
    if (indexPath.row == 3) {
        CustomLabel *lbUrl = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(lbTitle) + 10, VIEW_Y(lbTitle), 300, 20) content:@"m.wutongguo.com" size:12 color:TEXTGRAYCOLOR];
        [cell.contentView addSubview:lbUrl];
    }
    UIImageView *imgArrow = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 30, 15, 8, 15)];
    [imgArrow setImage:[UIImage imageNamed:@"coLeftArrow.png"]];
    [cell.contentView addSubview:imgArrow];
    [cell.contentView addSubview:[[CustomLabel alloc] initSeparate:cell.contentView]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        HelpViewController *helpCtrl = [[HelpViewController alloc] init];
        [self presentViewController:helpCtrl animated:YES completion:nil];
    }
    else if (indexPath.row == 1) {
        UIViewController *aboutUsCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"aboutUsView"];
        [self.navigationController pushViewController:aboutUsCtrl animated:YES];
    }
    else if (indexPath.row == 2) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://m.wutongguo.com"]]; 
    }
    else if (indexPath.row == 3) {
        if (![CommonFunc checkLogin]) {
            [self.view.window makeToast:@"您尚未登录"];
            return;
        }
        PopupView *alert = [[PopupView alloc] initWithWarningAlert:self.view title:@"提示" content:@"同学，您要残忍的退出吗？" okMsg:@"果断退出" cancelMsg:@"点错啦"];
        [alert setDelegate:self];
        [self.view addSubview:alert];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 46;
}

- (void)popupAlerConfirm {
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"DeletePaIOSBind" params:[NSDictionary dictionaryWithObjectsAndKeys:[CommonFunc getPaMainId], @"paMainID", [JPUSHService registrationID], @"uniqueID", [CommonFunc getCode], @"code", nil] tag:1];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
    [USER_DEFAULT removeObjectForKey:@"paMainId"];
    [USER_DEFAULT removeObjectForKey:@"code"];
    [ShareSDK cancelAuthorize:SSDKPlatformTypeAny];
    [self.view.window makeToast:@"账号已退出"];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];

}
@end

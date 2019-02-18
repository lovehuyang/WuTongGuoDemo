//
//  BindLoginViewController.m
//  wutongguo
//
//  Created by Lucifer on 15/6/4.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "BindLoginViewController.h"
#import "RegisterViewController.h"
#import "NetWebServiceRequest.h"
#import "GDataXMLNode.h"
#import "Toast+UIView.h"
#import "CommonMacro.h"
#import "LoadingAnimationView.h"
#import "CommonFunc.h"
#import "IndexViewController.h"
#import "UserCenterViewController.h"

@interface BindLoginViewController ()<NetWebServiceRequestDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;
@property (nonatomic) NSString *paMainId;
@end
Class object_getClass(id object);
@implementation BindLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.btnLogin.layer setMasksToBounds:true];
    [self.btnLogin.layer setCornerRadius:2];
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.view addSubview:self.loadingView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)secretClick:(UIButton *)sender {
    if (sender.tag == 0) {
        [self.txtPassword setSecureTextEntry:false];
        [sender setImage:[UIImage imageNamed:@"psdShow.png"] forState:UIControlStateNormal];
        [sender setTag:1];
    }
    else {
        [self.txtPassword setSecureTextEntry:true];
        [sender setImage:[UIImage imageNamed:@"psdHide.png"] forState:UIControlStateNormal];
        [sender setTag:0];
    }
}

- (IBAction)loginClick:(id)sender {
    //隐藏键盘
    [self.txtUsername resignFirstResponder];
    [self.txtPassword resignFirstResponder];
    if (self.txtUsername.text.length == 0) {
        [self.view.window makeToast:@"请输入用户名"];
        return;
    }
    else if (self.txtPassword.text.length == 0) {
        [self.view.window makeToast:@"请输入密码"];
        return;
    }
    [self.loadingView startAnimating];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"Login" params:[NSDictionary dictionaryWithObjectsAndKeys:@"0", @"autoLogin", @"", @"browser", self.txtUsername.text, @"userName", [CommonFunc passwordProcess:self.txtPassword.text], @"passWord", @"", @"ip", nil] tag:1];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (void)didReceiveRegDate:(NSString *)result {
    NSString *realCode = @"";
    realCode = [realCode stringByAppendingFormat:@"%@%@%@%@%@",
                [result substringWithRange:NSMakeRange(11,2)],
                [result substringWithRange:NSMakeRange(0,4)],
                [result substringWithRange:NSMakeRange(14,2)],
                [result substringWithRange:NSMakeRange(8,2)],
                [result substringWithRange:NSMakeRange(5,2)]];
    realCode = [CommonFunc MD5:[NSString stringWithFormat:@"%lld", ([realCode longLongValue] + [self.paMainId longLongValue])]];
    NSUserDefaults *userDefaults = USER_DEFAULT;
    [userDefaults setValue:self.paMainId forKey:@"paMainId"];
    [userDefaults setValue:realCode forKey:@"code"];
    //获取用户名
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetPaMainInfoByID" params:[NSDictionary dictionaryWithObjectsAndKeys:self.paMainId, @"paMainID", realCode, @"code", nil] tag:3];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1) {
        if ([result intValue] > 0) {
            self.paMainId = result;
            self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetPaAddDate" params:[NSDictionary dictionaryWithObjectsAndKeys:self.paMainId, @"paMainID", nil] tag:2];
            [self.runningRequest setDelegate:self];
            [self.runningRequest startAsynchronous];
        }
        else {
            [self.loadingView stopAnimating];
            [self.view.window makeToast:@"用户名密码错误"];
        }
    }
    else if (request.tag == 2) {
        [self didReceiveRegDate:result];
    }
    else if (request.tag == 3) {
        NSArray *arrPa = [CommonFunc getArrayFromXml:requestData tableName:@"Table"];
        [USER_DEFAULT setValue:arrPa[0][@"Email"] forKey:@"Email"];
        [USER_DEFAULT setValue:arrPa[0][@"Mobile"] forKey:@"Mobile"];
        [USER_DEFAULT setValue:@"1" forKey:@"willBind"];
        [self.view.window makeToast:@"绑定成功"];
        self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"InsertPaLoginContact" params:[NSDictionary dictionaryWithObjectsAndKeys:[CommonFunc getPaMainId], @"paMainID", self.openId, @"openID", self.contactType, @"contactType", @"2", @"loginType", [CommonFunc getCode], @"code", self.unionId, @"UnionID", nil] tag:4];
        [self.runningRequest setDelegate:self];
        [self.runningRequest startAsynchronous];
    }
    else if (request.tag == 4) {
        //判断跳转到哪 如果是会员中心或者首页，跳回，并显示关注微信。其他的从哪进入跳回哪
        if (self.fromJobApply) {
            [USER_DEFAULT setValue:@"1" forKey:@"willApplyJob"];
            [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:(self.navigationController.viewControllers.count - 3)] animated:YES];
        }
        else if (object_getClass(self.navigationController.viewControllers[0]) == [IndexViewController class] || object_getClass(self.navigationController.viewControllers[0]) == [UserCenterViewController class]) {
            [USER_DEFAULT setObject:@"1" forKey:@"registerSuccess"];
            [self.navigationController popToRootViewControllerAnimated:true];
        }
        else {
            [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:(self.navigationController.viewControllers.count - 3)] animated:YES];
        }
    }
}

@end

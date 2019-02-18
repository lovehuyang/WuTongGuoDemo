//
//  GetPsdStepOneViewController.m
//  wutongguo
//
//  Created by Lucifer on 15-5-8.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "GetPsdStepOneViewController.h"
#import "GetPsdStepTwoViewController.h"
#import "NetWebServiceRequest.h"
#import "CommonMacro.h"
#import "CommonFunc.h"
#import "Toast+UIView.h"
#import "LoadingAnimationView.h"

@interface GetPsdStepOneViewController ()<NetWebServiceRequestDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *mobile;
@end

@implementation GetPsdStepOneViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"取回密码";
    [self.btnGetCode.layer setCornerRadius:3];
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.view addSubview:self.loadingView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)getCodeClick:(id)sender {
    [self hideKeyboard];
    NSString *userName = self.txtUsername.text;
    if (userName.length == 0) {
        [self.view.window makeToast:@"请输入手机号或电子邮箱"];
        return;
    }
    if ([CommonFunc checkMobileValid:userName]) {
        self.mobile = userName;
        self.email = @"";
    }
    else if ([CommonFunc checkEmailValid:userName]) {
        self.email = userName;
        self.mobile = @"";
    }
    else {
        [self.view.window makeToast:@"请输入有效的手机号或电子邮箱"];
        return;
    }
    [self.loadingView startAnimating];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetPassword" params:[NSDictionary dictionaryWithObjectsAndKeys:self.email, @"email", self.mobile, @"mobile", @"", @"ip", nil] tag:1];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    [self.loadingView stopAnimating];
    //获取验证码
    if (request.tag == 1) {
        if ([result isEqualToString:@"3"]) {
            [self.view.window makeToast:@"该邮箱或手机号没有注册个人用户"];
            return;
        }
        else if ([result isEqualToString:@"4"]) {
            [self.view.window makeToast:@"您今天已经取回密码5次了，请查看您的邮箱，如果还没有收到，请明天继续取回密码。"];
            return;
        }
        else if ([result isEqualToString:@"5"]) {
            [self.view.window makeToast:@"您的IP今天已经取回密码20次了，请查看您的邮箱或手机，如果还没有收到，请明天继续取回密码。"];
            return;
        }
        else if ([result isEqualToString:@"6"]) {
            [self.view.window makeToast:@"您今天已经使用该手机号取回密码3次了，请明天继续取回密码。"];
            return;
        }
        else if (result.length > 2) {
            NSString *codeType = @"";
            if ([result rangeOfString:@":"].location != NSNotFound) {
                codeType = [result substringToIndex:[result rangeOfString:@":"].location];
                result = [result substringFromIndex:[result rangeOfString:@":"].location + 1];
            }
            if ([[codeType lowercaseString] isEqualToString:@"mobile"]) {
                [self.view.window makeToast:[NSString stringWithFormat:@"验证码已发送至手机%@，请注意查收", self.txtUsername.text]];
            }
            else {
                [self.view.window makeToast:[NSString stringWithFormat:@"验证码已发送至邮箱%@，请注意查收", self.txtUsername.text]];
            }
            GetPsdStepTwoViewController *step2View = [self.storyboard instantiateViewControllerWithIdentifier:@"getPsdStepTwoView"];
            step2View.uniqueId = result;
            step2View.email = self.email;
            step2View.mobile = self.mobile;
            [self.navigationController pushViewController:step2View animated:true];
        }
        else {
            [self.view.window makeToast:@"获取验证码失败"];
            return;
        }
    }
}

- (void)hideKeyboard
{
    [self.txtUsername resignFirstResponder];
}

@end

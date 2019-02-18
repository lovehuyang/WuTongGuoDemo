//
//  MobileModifyViewController.m
//  wutongguo
//
//  Created by Lucifer on 15-5-10.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "MobileModifyViewController.h"
#import "NetWebServiceRequest.h"
#import "CommonMacro.h"
#import "CommonFunc.h"
#import "Toast+UIView.h"
#import "LoadingAnimationView.h"

@interface MobileModifyViewController ()<NetWebServiceRequestDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;
@property (nonatomic) NSInteger secondSend;
@end

@implementation MobileModifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.btnSave.layer setMasksToBounds:true];
    [self.btnSave.layer setCornerRadius:2];
    [self.btnCode.layer setMasksToBounds:true];
    [self.btnCode.layer setCornerRadius:2];
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.view addSubview:self.loadingView];
    self.secondSend = 180;
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

- (IBAction)getCode:(UIButton *)sender {
    [self hideKeyboard];
    NSString *mobile = self.txtMobile.text;
    if (mobile.length == 0) {
        [self.view.window makeToast:@"请输入手机号"];
        return;
    }
    if (![CommonFunc checkMobileValid:mobile]) {
        [self.view.window makeToast:@"请输入有效的手机号"];
        return;
    }
    [self.loadingView startAnimating];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"UpdateMobileCheckCode" params:[NSDictionary dictionaryWithObjectsAndKeys:self.txtMobile.text, @"mobile", [USER_DEFAULT objectForKey:@"paMainId"], @"paMainID", [USER_DEFAULT objectForKey:@"code"], @"code", @"", @"ip", nil] tag:1];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (IBAction)saveClick:(id)sender {
    [self hideKeyboard];
    if (self.txtPassword.text.length == 0) {
        [self.view.window makeToast:@"请输入密码"];
        return;
    }
    else if (self.txtMobile.text.length == 0) {
        [self.view.window makeToast:@"请输入手机号"];
        return;
    }
    else if (self.txtCode.text.length == 0) {
        [self.view.window makeToast:@"请输入验证码"];
        return;
    }
    else if ([CommonFunc checkPasswordValid:self.txtPassword.text] == NO) {
        [self.view.window makeToast:@"密码格式错误，8-20个字符，区分大小写"];
        return;
    }
    else if ([CommonFunc checkPasswordIncludeChinese:self.txtPassword.text]) {
        [self.view.window makeToast:@"密码中不能输入中文符号或汉字"];
        return;
    }
    else if ([CommonFunc checkMobileValid:self.txtMobile.text] == NO) {
        [self.view.window makeToast:@"手机号格式错误"];
        return;
    }
    [self.loadingView startAnimating];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"UpdatePamainByMobile" params:[NSDictionary dictionaryWithObjectsAndKeys:[USER_DEFAULT objectForKey:@"paMainId"], @"paMainID", self.txtMobile.text, @"mobile", self.txtCode.text, @"verifyCode", [CommonFunc passwordProcess:self.txtPassword.text], @"password", [USER_DEFAULT objectForKey:@"code"], @"code", @"", @"ip", nil] tag:2];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (void)hideKeyboard {
    [self.txtCode resignFirstResponder];
    [self.txtMobile resignFirstResponder];
    [self.txtPassword resignFirstResponder];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    [self.loadingView stopAnimating];
    if (request.tag == 1) {
        if ([result isEqualToString:@"1"]) {
            [self.btnCode setEnabled:false];
            [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(setTimer:) userInfo:nil repeats:YES];
        }
        else if ([result isEqualToString:@"-2"]) {
            [self.view.window makeToast:@"该手机号已经过认证"];
            return;
        }
        else if ([result isEqualToString:@"-3"]) {
            [self.view.window makeToast:@"该手机号已经过认证"];
            return;
        }
        else if ([result isEqualToString:@"-4"]) {
            [self.view.window makeToast:@"验证码发送失败"];
            return;
        }
        else if ([result isEqualToString:@"-5"]) {
            [self.view.window makeToast:@"获取验证码失败"];
            return;
        }
        else {
            [self.view.window makeToast:@"获取验证码失败"];
            return;
        }
    }
    else if (request.tag == 2) {
        if ([result isEqualToString:@"1"]) {
            [self.view.window makeToast:@"手机号修改成功"];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if ([result isEqualToString:@"2"]) {
            [self.view.window makeToast:@"验证码错误"];
        }
        else {
            [self.view.window makeToast:@"密码错误"];
        }
    }
}

- (void)setTimer:(NSTimer *)timer {
    if (self.secondSend == 0) {
        [self.btnCode setEnabled:true];
        [self.btnCode setTitle:@"获取验证码" forState:UIControlStateNormal];
        [timer invalidate];
        self.secondSend = 180;
        return;
    }
    [self.btnCode setTitle:[NSString stringWithFormat:@"%lds后重试",(long)self.secondSend] forState:UIControlStateDisabled];
    self.secondSend--;
}

@end

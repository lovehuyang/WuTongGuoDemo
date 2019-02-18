//
//  MobileRegViewController.m
//  wutongguo
//
//  Created by Lucifer on 15-5-6.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "MobileRegViewController.h"
#import "IndexViewController.h"
#import "UserCenterViewController.h"
#import "NetWebServiceRequest.h"
#import "CommonMacro.h"
#import "CommonFunc.h"
#import "Toast+UIView.h"
#import "LoadingAnimationView.h"
#import "AgreementViewController.h"

@interface MobileRegViewController ()<NetWebServiceRequestDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;
@property (nonatomic) NSInteger secondSend;
@property (nonatomic) NSString *paMainId;
@end
Class object_getClass(id object);
@implementation MobileRegViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.btnRegister.layer setMasksToBounds:true];
    [self.btnRegister.layer setCornerRadius:2];
    [self.btnCode.layer setMasksToBounds:true];
    [self.btnCode.layer setCornerRadius:2];
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.view addSubview:self.loadingView];
    self.secondSend = 180;
    if (self.openId != nil) {
        [self.viewBottom setHidden:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)getMobileCode:(UIButton *)sender {
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
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetMobileCheckCode" params:[NSDictionary dictionaryWithObjectsAndKeys:mobile, @"strMobile", @"", @"ip", nil] tag:1];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (IBAction)secretClick:(UIButton *)sender {
    if (sender.tag == 0) {
        [self.txtPassword setSecureTextEntry:false];
        [self.txtConfirm setSecureTextEntry:false];
        [sender setImage:[UIImage imageNamed:@"psdShow.png"] forState:UIControlStateNormal];
        [sender setTag:1];
    }
    else {
        [self.txtPassword setSecureTextEntry:true];
        [self.txtConfirm setSecureTextEntry:true];
        [sender setImage:[UIImage imageNamed:@"psdHide.png"] forState:UIControlStateNormal];
        [sender setTag:0];
    }
}

- (IBAction)agreeClick:(UIButton *)sender {
    if (sender.tag == 0) {
        [self.imgAgree setImage:[UIImage imageNamed:@"regChecked.png"]];
        [sender setTag:1];
    }
    else {
        [self.imgAgree setImage:[UIImage imageNamed:@"regUnChecked.png"]];
        [sender setTag:0];
    }
}

- (IBAction)loginClick:(id)sender {
    UIViewController *loginView = [self.storyboard instantiateViewControllerWithIdentifier:@"loginView"];
    [self.navigationController pushViewController:loginView animated:true];
}

- (IBAction)registerClick:(UIButton *)sender {
    [self hideKeyboard];
    if (self.txtMobile.text.length == 0) {
        [self.view.window makeToast:@"请输入手机号"];
        return;
    }
    else if (self.txtPassword.text.length == 0) {
        [self.view.window makeToast:@"请输入密码"];
        return;
    }
    else if (self.txtConfirm.text.length == 0) {
        [self.view.window makeToast:@"请输入确认密码"];
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
    else if (![self.txtPassword.text isEqual:self.txtConfirm.text]) {
        [self.view.window makeToast:@"密码和确认密码不一致"];
        return;
    }
    else if (self.btnAgree.tag == 0) {
        [self.view.window makeToast:@"请同意用户注册协议"];
        return;
    }
    else if ([CommonFunc checkMobileValid:self.txtMobile.text] == NO) {
        [self.view.window makeToast:@"手机号格式错误"];
        return;
    }
    [self.loadingView startAnimating];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"RegisterMobile" params:[NSDictionary dictionaryWithObjectsAndKeys:self.txtMobile.text, @"mobile", self.txtCode.text, @"mobileCheckCode", [CommonFunc passwordProcess:self.txtPassword.text], @"password", @"5", @"registermod", @"", @"ip", nil] tag:2];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    //获取验证码
    if (request.tag == 1) {
        [self.loadingView stopAnimating];
        if ([result isEqualToString:@"1"]) {
            [self.btnCode setEnabled:false];
            [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(setTimer:) userInfo:nil repeats:YES];
        }
        else if ([result isEqualToString:@"0"]) {
            [self.view.window makeToast:@"该手机号当天获取验证码次数大于4次"];
        }
        else if ([result isEqualToString:@"-1"]) {
            [self.view.window makeToast:@"同一个ip一天内手机号注册超过20个"];
        }
        else if ([result isEqualToString:@"-2"]) {
            [self.view.window makeToast:@"该手机号60天内认证过"];
        }
        else if ([result isEqualToString:@"-4"]) {
            [self.view.window makeToast:@"手机号已存在，请登录或取回密码"];
        }
        else {
            [self.view.window makeToast:@"获取验证码失败"];
            return;
        }
    }
    else if (request.tag == 2) {
        if ([result intValue] > 0) {
            self.paMainId = result;
            self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetPaAddDate" params:[NSDictionary dictionaryWithObjectsAndKeys:self.paMainId, @"paMainID", nil] tag:3];
            [self.runningRequest setDelegate:self];
            [self.runningRequest startAsynchronous];
        }
        else if ([result intValue] == 0) {
            [self.loadingView stopAnimating];
            [self.view.window makeToast:@"验证码错误"];
        }
        else {
            [self.loadingView stopAnimating];
            [self.view.window makeToast:@"注册失败"];
        }
    }
    else if (request.tag == 3) {
        [self.loadingView stopAnimating];
        [self didReceiveRegDate:result];
    }
    else if (request.tag == 4) {
        NSArray *arrPa = [CommonFunc getArrayFromXml:requestData tableName:@"Table"];
        [USER_DEFAULT setObject:arrPa[0][@"Email"] forKey:@"Email"];
        if (self.openId != NULL) {
            self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"InsertPaLoginContact" params:[NSDictionary dictionaryWithObjectsAndKeys:[CommonFunc getPaMainId], @"paMainID", self.openId, @"openID", self.contactType, @"contactType", @"2", @"loginType", [CommonFunc getCode], @"code", self.unionId, @"UnionID", nil] tag:5];
            [self.runningRequest setDelegate:self];
            [self.runningRequest startAsynchronous];
        }
        else {
            [self popViewController];
        }
    }
    else if (request.tag == 5) {
        [self popViewController];
    }
}

- (void)popViewController {
    //判断跳转到哪 如果是会员中心或者首页，跳回，并显示关注微信。其他的从哪进入跳回哪
    if (self.fromJobApply) {
        [USER_DEFAULT setValue:@"1" forKey:@"willApplyJob"];
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:(self.navigationController.viewControllers.count - 3)] animated:YES];
        [self.view.window makeToast:@"注册成功"];
    }
    else if (object_getClass(self.navigationController.viewControllers[0]) == [IndexViewController class] || object_getClass(self.navigationController.viewControllers[0]) == [UserCenterViewController class]) {
        [USER_DEFAULT setObject:@"1" forKey:@"registerSuccess"];
        [self.navigationController popToRootViewControllerAnimated:true];
    }
    else {
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:(self.navigationController.viewControllers.count - 3)] animated:YES];
        [self.view.window makeToast:@"注册成功"];
    }
}

- (void)didReceiveRegDate:(NSString *)result
{
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
    [userDefaults setValue:self.txtMobile.text forKey:@"Mobile"];
    [userDefaults setValue:realCode forKey:@"code"];
    //获取用户名
    [self.loadingView startAnimating];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetPaMainInfoByID" params:[NSDictionary dictionaryWithObjectsAndKeys:self.paMainId, @"paMainID", realCode, @"code", nil] tag:4];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (void)setTimer:(NSTimer *)timer
{
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

- (void)hideKeyboard
{
    [self.txtCode resignFirstResponder];
    [self.txtMobile resignFirstResponder];
    [self.txtPassword resignFirstResponder];
    [self.txtConfirm resignFirstResponder];
}

- (IBAction)agreementClick:(id)sender {
    AgreementViewController *agreementCtrl = [[AgreementViewController alloc] init];
    [self.navigationController pushViewController:agreementCtrl animated:YES];
}

@end

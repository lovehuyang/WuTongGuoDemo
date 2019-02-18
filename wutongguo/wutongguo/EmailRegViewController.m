//
//  EmailRegViewController.m
//  wutongguo
//
//  Created by Lucifer on 15-5-6.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "EmailRegViewController.h"
#import "NetWebServiceRequest.h"
#import "GDataXMLNode.h"
#import "Toast+UIView.h"
#import "IndexViewController.h"
#import "UserCenterViewController.h"
#import "CommonMacro.h"
#import "CommonFunc.h"
#import "LoadingAnimationView.h"
#import "AgreementViewController.h"
#import "CpJobDetailViewController.h"

@interface EmailRegViewController ()<NetWebServiceRequestDelegate, UITextFieldDelegate>

@property (nonatomic, strong) LoadingAnimationView *loadingView;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic) NSString *paMainId;
@end
Class object_getClass(id object);
@implementation EmailRegViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.btnRegister.layer setMasksToBounds:true];
    [self.btnRegister.layer setCornerRadius:2];
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.view addSubview:self.loadingView];
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

- (IBAction)registerClick:(id)sender {
    //隐藏键盘
    [self.txtEmail resignFirstResponder];
    [self.txtPassword resignFirstResponder];
    [self.txtConfirm resignFirstResponder];
    if (self.txtEmail.text.length == 0) {
        [self.view.window makeToast:@"请输入邮箱"];
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
    else if (![CommonFunc checkPasswordValid:self.txtPassword.text]) {
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
    else if ([CommonFunc checkEmailValid:self.txtEmail.text] == NO) {
        [self.view.window makeToast:@"邮箱格式错误"];
        return;
    }
    [self.loadingView startAnimating];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"RegisterEmail" params:[NSDictionary dictionaryWithObjectsAndKeys:self.txtEmail.text, @"email", [CommonFunc passwordProcess:self.txtPassword.text], @"password", @"5", @"registermod", @"", @"ip", nil] tag:1];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (IBAction)loginClick:(id)sender {
    UIViewController *loginView = [self.storyboard instantiateViewControllerWithIdentifier:@"loginView"];
    [self.navigationController pushViewController:loginView animated:true];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1) { //注册
        if ([result intValue] > 0) {
            self.paMainId = result;
            self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetPaAddDate" params:[NSDictionary dictionaryWithObjectsAndKeys:self.paMainId, @"paMainID", nil] tag:2];
            [self.runningRequest setDelegate:self];
            [self.runningRequest startAsynchronous];
        }
        else if ([result intValue] == -2) {
            [self.loadingView stopAnimating];
            [self.view.window makeToast:@"邮箱已存在，请登录或取回密码"];
        }
        else {
            [self.loadingView stopAnimating];
            [self.view.window makeToast:@"注册失败"];
        }
    }
    else if (request.tag == 2) {
        [self.loadingView stopAnimating];
        [self didReceiveRegDate:result];
    }
    else if (request.tag == 3) {
        [USER_DEFAULT setObject:@"1" forKey:@"registerSuccess"];
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 3] animated:true];
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
    [userDefaults setValue:self.txtEmail.text forKey:@"Email"];
    [userDefaults setValue:@"" forKey:@"Mobile"];
    [userDefaults setValue:realCode forKey:@"code"];
    if (self.openId != NULL) {
        self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"InsertPaLoginContact" params:[NSDictionary dictionaryWithObjectsAndKeys:[CommonFunc getPaMainId], @"paMainID", self.openId, @"openID", self.contactType, @"contactType", @"2", @"loginType", [CommonFunc getCode], @"code", self.unionId, @"UnionID", nil] tag:3];
        [self.runningRequest setDelegate:self];
        [self.runningRequest startAsynchronous];
    }
    else {
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
}

- (IBAction)agreementClick:(id)sender {
    AgreementViewController *agreementCtrl = [[AgreementViewController alloc] init];
    [self.navigationController pushViewController:agreementCtrl animated:YES];
}

@end

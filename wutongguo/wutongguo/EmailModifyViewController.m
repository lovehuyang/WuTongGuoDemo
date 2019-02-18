//
//  EmailModifyViewController.m
//  wutongguo
//
//  Created by Lucifer on 15-5-10.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "EmailModifyViewController.h"
#import "NetWebServiceRequest.h"
#import "CommonMacro.h"
#import "CommonFunc.h"
#import "Toast+UIView.h"
#import "LoadingAnimationView.h"

@interface EmailModifyViewController ()<NetWebServiceRequestDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;
@end

@implementation EmailModifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.btnSave.layer setMasksToBounds:true];
    [self.btnSave.layer setCornerRadius:2];
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

- (IBAction)saveClick:(id)sender {
    [self.txtPassword resignFirstResponder];
    [self.txtEmail resignFirstResponder];
    if (self.txtPassword.text.length == 0) {
        [self.view.window makeToast:@"请输入密码"];
        return;
    }
    else if (self.txtEmail.text.length == 0) {
        [self.view.window makeToast:@"请输入邮箱"];
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
    else if ([CommonFunc checkEmailValid:self.txtEmail.text] == NO) {
        [self.view.window makeToast:@"邮箱格式错误"];
        return;
    }
    [self.loadingView startAnimating];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"UpdateUserName" params:[NSDictionary dictionaryWithObjectsAndKeys:[USER_DEFAULT objectForKey:@"paMainId"], @"paMainID", self.txtEmail.text, @"Username", [CommonFunc passwordProcess:self.txtPassword.text], @"Password", [USER_DEFAULT objectForKey:@"code"], @"code", nil] tag:1];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    [self.loadingView stopAnimating];
    if ([result isEqualToString:@"1"]) {
        [self.view.window makeToast:@"邮箱修改成功"];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if ([result isEqualToString:@"11"]) {
        [self.view.window makeToast:@"该邮箱已经被使用，修改失败"];
    }
    else {
        [self.view.window makeToast:@"密码错误"];
    }
}

@end

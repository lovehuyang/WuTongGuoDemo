//
//  PasswordModifyViewController.m
//  wutongguo
//
//  Created by Lucifer on 15-5-10.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "PasswordModifyViewController.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "Toast+UIView.h"
#import "CommonFunc.h"
#import "CommonMacro.h"

@interface PasswordModifyViewController ()<NetWebServiceRequestDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;
@end

@implementation PasswordModifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.btnSave.layer setMasksToBounds:YES];
    [self.btnSave.layer setCornerRadius:2];
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.view addSubview:self.loadingView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)secretClick:(UIButton *)sender {
    if (sender.tag == 0) {
        [self.txtOldPassword setSecureTextEntry:false];
        [self.txtPassword setSecureTextEntry:false];
        [self.txtConfirm setSecureTextEntry:false];
        [sender setImage:[UIImage imageNamed:@"psdShow.png"] forState:UIControlStateNormal];
        [sender setTag:1];
    }
    else {
        [self.txtOldPassword setSecureTextEntry:true];
        [self.txtPassword setSecureTextEntry:true];
        [self.txtConfirm setSecureTextEntry:true];
        [sender setImage:[UIImage imageNamed:@"psdHide.png"] forState:UIControlStateNormal];
        [sender setTag:0];
    }
}

- (IBAction)saveClick:(id)sender {
    [self.txtOldPassword resignFirstResponder];
    [self.txtConfirm resignFirstResponder];
    [self.txtPassword resignFirstResponder];
    if (self.txtOldPassword.text.length == 0) {
        [self.view.window makeToast:@"请输入原密码"];
        return;
    }
    else if (self.txtPassword.text.length == 0) {
        [self.view.window makeToast:@"请输入新密码"];
        return;
    }
    else if (self.txtConfirm.text.length == 0) {
        [self.view.window makeToast:@"请输入确认密码"];
        return;
    }
    else if ([CommonFunc checkPasswordValid:self.txtOldPassword.text] == NO) {
        [self.view.window makeToast:@"原密码格式错误"];
        return;
    }
    else if ([CommonFunc checkPasswordIncludeChinese:self.txtOldPassword.text]) {
        [self.view.window makeToast:@"原密码中不能输入中文符号或汉字"];
        return;
    }
    else if ([CommonFunc checkPasswordValid:self.txtPassword.text] == NO) {
        [self.view.window makeToast:@"新密码格式错误，8-20个字符，区分大小写"];
        return;
    }
    else if ([CommonFunc checkPasswordIncludeChinese:self.txtPassword.text]) {
        [self.view.window makeToast:@"新密码中不能输入中文符号或汉字"];
        return;
    }
    else if (![self.txtPassword.text isEqual:self.txtConfirm.text]) {
        [self.view.window makeToast:@"新密码和确认密码不一致"];
        return;
    }
    [self.loadingView startAnimating];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"UpdatePassword" params:[NSDictionary dictionaryWithObjectsAndKeys:[USER_DEFAULT objectForKey:@"paMainId"], @"paMainID", [CommonFunc passwordProcess:self.txtPassword.text], @"Password", [CommonFunc passwordProcess:self.txtOldPassword.text], @"passwordOld", [USER_DEFAULT objectForKey:@"code"], @"code", @"", @"ip", nil] tag:1];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    [self.loadingView stopAnimating];
    if ([result isEqualToString:@"1"]) {
        [self.view.window makeToast:@"密码修改成功"];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if ([result isEqualToString:@"0"]) {
        [self.view.window makeToast:@"原密码错误"];
    }
    else {
        [self.view.window makeToast:@"密码修改失败"];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end

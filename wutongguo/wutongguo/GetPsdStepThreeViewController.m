//
//  GetPsdStepThreeViewController.m
//  wutongguo
//
//  Created by Lucifer on 15-5-8.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "GetPsdStepThreeViewController.h"
#import "NetWebServiceRequest.h"
#import "CommonMacro.h"
#import "CommonFunc.h"
#import "Toast+UIView.h"
#import "LoadingAnimationView.h"

@interface GetPsdStepThreeViewController ()<NetWebServiceRequestDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;
@end

@implementation GetPsdStepThreeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"取回密码";
    [self.btnReset.layer setCornerRadius:3];
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.view addSubview:self.loadingView];
    [self.lbUserName setText:self.userName];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)resetClick:(id)sender {
    [self hideKeyboard];
    if (self.txtPassword.text.length == 0) {
        [self.view.window makeToast:@"请输入密码"];
        return;
    }
    else if (self.txtConfirm.text.length == 0) {
        [self.view.window makeToast:@"请输入确认密码"];
        return;
    }
    else if (![self.txtPassword.text isEqualToString:self.txtConfirm.text]) {
        [self.view.window makeToast:@"两次输入的密码不一致"];
        return;
    }
    [self.loadingView startAnimating];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"ResetPassword" params:[NSDictionary dictionaryWithObjectsAndKeys:self.paMainId, @"paMainID", [CommonFunc passwordProcess:self.txtPassword.text], @"Password", self.paCode, @"code", @"", @"ip", nil] tag:1];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (void)hideKeyboard
{
    [self.txtPassword resignFirstResponder];
    [self.txtConfirm resignFirstResponder];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    [self.loadingView stopAnimating];
    if ([result isEqualToString:@"1"]) {
        [self.view.window makeToast:@"密码重置成功"];
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 4] animated:true];
    }
    else {
        [self.view.window makeToast:@"密码修改失败"];
        return;
    }
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

@end

//
//  FeedbackViewController.m
//  wutongguo
//
//  Created by Lucifer on 15/6/1.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "FeedbackViewController.h"
#import "CommonMacro.h"
#import "CommonFunc.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "GDataXMLNode.h"
#import "Toast+UIView.h"

@interface FeedbackViewController ()<UITextFieldDelegate, UITextViewDelegate, NetWebServiceRequestDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;
@end

@implementation FeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"我要反馈";
    [self.btnSubmit.layer setCornerRadius:5];
    [self.viewContent setFrame:CGRectMake(-0.5, self.viewContent.frame.origin.y, SCREEN_WIDTH + 1, self.viewContent.frame.size.height)];
    [self.viewContent.layer setBorderColor:[SEPARATECOLOR CGColor]];
    [self.viewContent.layer setBorderWidth:0.5];
    
    [self.viewLink setFrame:CGRectMake(-0.5, self.viewLink.frame.origin.y, SCREEN_WIDTH + 1, self.viewLink.frame.size.height)];
    [self.viewLink.layer setBorderColor:[SEPARATECOLOR CGColor]];
    [self.viewLink.layer setBorderWidth:0.5];
    
    UIView *viewSeperate = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_BY(self.lbName) + 10, SCREEN_WIDTH, 0.5)];
    [viewSeperate setBackgroundColor:SEPARATECOLOR];
    [self.viewLink addSubview:viewSeperate];
    
    UIView *viewSeperate2 = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_BY(self.lbMobile) + 10, SCREEN_WIDTH, 0.5)];
    [viewSeperate2 setBackgroundColor:SEPARATECOLOR];
    [self.viewLink addSubview:viewSeperate2];
    //等待动画
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.view addSubview:self.loadingView];
    if ([CommonFunc checkLogin]) {
        [self getData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)getData {
    [self.loadingView startAnimating];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetPaMainInfoByID" params:[NSDictionary dictionaryWithObjectsAndKeys:[CommonFunc getPaMainId], @"paMainID", [CommonFunc getCode], @"code", nil] tag:1];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frameView = self.view.frame;
        frameView.origin.y = MIN(SCREEN_HEIGHT - VIEW_BY(self.btnSubmit) - KEYBOARD_HEIGHT, 0);
        [self.view setFrame:frameView];
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frameView = self.view.frame;
        frameView.origin.y = 0;
        [self.view setFrame:frameView];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"])  {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (IBAction)feedbackClick:(UIButton *)sender {
    if (self.txtContent.text.length == 0) {
        [self.view.window makeToast:@"请输入反馈内容"];
        return;
    }
    else if (self.txtName.text.length == 0) {
        [self.view.window makeToast:@"请输入姓名"];
        return;
    }
    else if (self.txtMobile.text.length == 0) {
        [self.view.window makeToast:@"请输入手机号"];
        return;
    }
    else if (self.txtEmail.text.length == 0) {
        [self.view.window makeToast:@"请输入邮箱"];
        return;
    }
    else if (self.txtContent.text.length > 200) {
        [self.view.window makeToast:@"反馈内容不能超过200个字符"];
        return;
    }
    else if (self.txtName.text.length > 6) {
        [self.view.window makeToast:@"姓名只能输入6个字符"];
        return;
    }
    else if (![CommonFunc checkMobileValid:self.txtMobile.text]) {
        [self.view.window makeToast:@"请输入有效的手机号"];
        return;
    }
    else if (![CommonFunc checkEmailValid:self.txtEmail.text]) {
        [self.view.window makeToast:@"请输入有效的手机号"];
        return;
    }
    [self.loadingView startAnimating];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"InsertPaFeedBack" params:[NSDictionary dictionaryWithObjectsAndKeys:[CommonFunc getPaMainId], @"paMainID", self.txtName.text, @"name", self.txtMobile.text, @"mobile", self.txtEmail.text, @"email", self.txtContent.text, @"remark", [CommonFunc getCode], @"code", nil] tag:2];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    [self.loadingView stopAnimating];
    if (request.tag == 1) {
        NSDictionary *paMainData = [[CommonFunc getArrayFromXml:requestData tableName:@"Table"] objectAtIndex:0];
        self.txtEmail.text = [paMainData objectForKey:@"Email"];
        self.txtMobile.text = [paMainData objectForKey:@"Mobile"];
        self.txtName.text = [paMainData objectForKey:@"Name"];
    }
    else if (request.tag == 2) {
        [self.view.window makeToast:@"反馈成功"];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

@end

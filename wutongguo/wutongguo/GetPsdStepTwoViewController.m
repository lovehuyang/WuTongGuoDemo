//
//  GetPsdStepTwoViewController.m
//  wutongguo
//
//  Created by Lucifer on 15-5-8.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "GetPsdStepTwoViewController.h"
#import "GetPsdStepThreeViewController.h"
#import "NetWebServiceRequest.h"
#import "CommonMacro.h"
#import "CommonFunc.h"
#import "Toast+UIView.h"
#import "LoadingAnimationView.h"

@interface GetPsdStepTwoViewController ()<NetWebServiceRequestDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;
@end

@implementation GetPsdStepTwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"取回密码";
    [self.btnCheckCode.layer setCornerRadius:3];
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.view addSubview:self.loadingView];
    if (self.mobile.length > 0) {
        [self.lbUsername setText:@"您的手机号"];
        [self.lbValue setText:self.mobile];
    }
    else if (self.email.length > 0) {
        [self.lbUsername setText:@"您的电子邮件"];
        [self.lbValue setText:self.email];
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

- (IBAction)nextClick:(id)sender {
    [self.txtCode resignFirstResponder];
    if (self.txtCode.text.length == 0) {
        [self.view.window makeToast:@"请输入验证码"];
        return;
    }
    [self.loadingView startAnimating];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetPaGetPasswordLogByVerifyCode" params:[NSDictionary dictionaryWithObjectsAndKeys:self.uniqueId, @"uniqueId", self.txtCode.text, @"verifyCode", nil] tag:1];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    [self.loadingView stopAnimating];
    NSArray *arrPaMain = [CommonFunc getArrayFromXml:requestData tableName:@"Table"];
    if (arrPaMain.count == 0) {
        [self.view.window makeToast:@"验证码错误"];
        return;
    }
    NSDictionary *paMainData = [arrPaMain objectAtIndex:0];
    NSString *regDate = [paMainData objectForKey:@"PaAddDate"];
    NSString *realCode = @"";
    realCode = [realCode stringByAppendingFormat:@"%@%@%@%@%@",
                [regDate substringWithRange:NSMakeRange(11,2)],
                [regDate substringWithRange:NSMakeRange(0,4)],
                [regDate substringWithRange:NSMakeRange(14,2)],
                [regDate substringWithRange:NSMakeRange(8,2)],
                [regDate substringWithRange:NSMakeRange(5,2)]];
    realCode = [CommonFunc MD5:[NSString stringWithFormat:@"%lld", ([realCode longLongValue] + [[paMainData objectForKey:@"PaMainID"] longLongValue])]];
    GetPsdStepThreeViewController *step3View = [self.storyboard instantiateViewControllerWithIdentifier:@"getPsdStepThreeView"];
    step3View.paMainId = [paMainData objectForKey:@"PaMainID"];
    step3View.paCode = realCode;
    step3View.userName = [NSString stringWithFormat:@"%@%@", self.email, self.mobile];
    [self.navigationController pushViewController:step3View animated:true];
}

@end

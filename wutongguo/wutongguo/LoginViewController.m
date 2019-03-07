//
//  LoginViewController.m
//  wutongguo
//
//  Created by Lucifer on 15-5-6.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "NetWebServiceRequest.h"
#import "GDataXMLNode.h"
#import "Toast+UIView.h"
#import "CommonMacro.h"
#import "LoadingAnimationView.h"
#import "CommonFunc.h"
#import <ShareSDK/ShareSDK.h>
#import "BindPaMainViewController.h"
#import "RegisterViewController.h"
#import <ShareSDK/ShareSDK.h>
#import "WXApi.h"
#import <TencentOpenAPI/QQApiInterface.h>
#import "CompanySideViewController.h"

@interface LoginViewController ()<NetWebServiceRequestDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;
@property (nonatomic, strong) NSString *paMainId;
@property (nonatomic, strong) NSString *openId;
@property (nonatomic, strong) NSString *unionId;
@property (nonatomic) NSInteger contactType;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"登录";
    
    [self.btnLogin.layer setMasksToBounds:true];
    [self.btnLogin.layer setCornerRadius:2];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.view addSubview:self.loadingView];
    [ShareSDK cancelAuthorize:SSDKPlatformTypeAny];
    if (![WXApi isWXAppInstalled] || ![WXApi isWXAppSupportApi]) {
        [self.btnWechatLogin setHidden:YES];
        [self.constantQQLogin setConstant:0];
        [self.viewBottom setHidden:NO];
        [self.viewBottomWithWechat setHidden:YES];
    }
    else {
        [self.viewBottom setHidden:YES];
        [self.viewBottomWithWechat setHidden:NO];
    }
//    if (![QQApi isQQInstalled] || ![QQApi isQQSupportApi]) {
//        [self.btnQQLogin setHidden:YES];
//        [self.constantWechatLogin setConstant:0];
//    }
    if (self.constantQQLogin.constant == 0 && self.constantWechatLogin.constant == 0) {
        [self.viewThirdLogin setHidden:YES];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.fromWechatRegister) {
        [self wechatLogin];
    }
    else {
        [self.loadingView stopAnimating];
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
        [sender setImage:[UIImage imageNamed:@"psdShow.png"] forState:UIControlStateNormal];
        [sender setTag:1];
    }
    else {
        [self.txtPassword setSecureTextEntry:true];
        [sender setImage:[UIImage imageNamed:@"psdHide.png"] forState:UIControlStateNormal];
        [sender setTag:0];
    }
}

- (IBAction)registerClick:(id)sender {
    RegisterViewController *registerCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"registerView"];
    registerCtrl.fromJobApply = self.fromJobApply;
    [self.navigationController pushViewController:registerCtrl animated:true];
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
    NSString *loginFrom = @"21";
    if ([CommonFunc checkMobileValid:self.txtUsername.text]) {
        loginFrom = @"22";
    }
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"LoginNew" params:[NSDictionary dictionaryWithObjectsAndKeys:@"0", @"autoLogin", @"", @"browser", self.txtUsername.text, @"userName", [CommonFunc passwordProcess:self.txtPassword.text], @"passWord", @"", @"ip", loginFrom, @"loginFrom", nil] tag:1];
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
        [self genPaMainCode:result];
        [self getPaMainInfo];
    }
    else if (request.tag == 3) {
        NSArray *arrPa = [CommonFunc getArrayFromXml:requestData tableName:@"Table"];
        if (arrPa.count == 0) {
            [self.view makeToast:@"登录失败"];
            return;
        }
        NSDictionary *paData = [arrPa objectAtIndex:0];
        [USER_DEFAULT setValue:paData[@"Email"] forKey:@"Email"];
        [USER_DEFAULT setValue:paData[@"Mobile"] forKey:@"Mobile"];
        [USER_DEFAULT setValue:@"1" forKey:@"willBind"];
        if (self.fromJobApply) {
            [USER_DEFAULT setValue:@"1" forKey:@"willApplyJob"];
        }
        [CommonToos saveData:APP_STATUS value:@"0"];
        [self.view.window makeToast:@"登录成功"];
        UIViewController *prevCtrl = [self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count - 2];
        if ([prevCtrl isKindOfClass:[RegisterViewController class]]) {
            [self.navigationController popToRootViewControllerAnimated:true];
        }
        else {
            [self.navigationController popToRootViewControllerAnimated:true];
//            [self.navigationController popToViewController:prevCtrl animated:true];
        }
    }
    else if (request.tag == 4) {
        NSArray *arrContact = [CommonFunc getArrayFromXml:requestData tableName:@"Table"];
        if (arrContact.count == 0) {
            BindPaMainViewController *bindPaMainCtrl = [[BindPaMainViewController alloc] init];
            bindPaMainCtrl.openId = self.openId;
            bindPaMainCtrl.unionId = self.unionId;
            bindPaMainCtrl.contactType = [NSString stringWithFormat:@"%ld", (long)self.contactType];
            bindPaMainCtrl.fromJobApply = self.fromJobApply;
            [self.navigationController pushViewController:bindPaMainCtrl animated:YES];
        }
        else {
            self.paMainId = [[arrContact objectAtIndex:0] objectForKey:@"PaMainID"];
            [self genPaMainCode:[[arrContact objectAtIndex:0] objectForKey:@"PaAddDate"]];
            NSString *loginFrom = @"24";
            if (self.contactType == 1) {
                loginFrom = @"24";
            }
            else if (self.contactType == 4) {
                loginFrom = @"23";
            }
            self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"InsertPaLoginLogNew" params:[NSDictionary dictionaryWithObjectsAndKeys:self.paMainId, @"paMainID", @"", @"browser", [CommonFunc getCode], @"code", @"", @"ip", loginFrom, @"loginfrom", nil] tag:5];
            [self.runningRequest setDelegate:self];
            [self.runningRequest startAsynchronous];
        }
    }
    else if (request.tag == 5) {
        [self getPaMainInfo];
    }
}

- (void)genPaMainCode:(NSString *)result {
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
}

- (void)getPaMainInfo {
    //获取用户名
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetPaMainInfoByID" params:[NSDictionary dictionaryWithObjectsAndKeys:self.paMainId, @"paMainID", [USER_DEFAULT objectForKey:@"code"], @"code", nil] tag:3];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (IBAction)wechatClick:(id)sender {
    [self wechatLogin];
}

- (IBAction)qqClick:(id)sender {
    [ShareSDK getUserInfo:SSDKPlatformTypeQQ
           onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error)
     {
         if (state == SSDKResponseStateSuccess)
         {
             [self thirdLogin:user.uid unionId:@"" utype:1];
         }
         
         else
         {
             NSLog(@"授权失败!error code == %@", error);
         }
         
     }];
}

//- (IBAction)weiboClick:(id)sender {
//    [ShareSDK getUserInfoWithType:ShareTypeSinaWeibo authOptions:nil result:^(BOOL result, id<ISSPlatformUser> userInfo, id<ICMErrorInfo> error) {
//        if (result) {
//            [self thirdLogin:[userInfo uid] unionId:@"" utype:2];
//        }
//    }];
//}

- (IBAction)baiduClick:(id)sender {
    
}

- (void)thirdLogin:(NSString *)openId unionId:(NSString *)unionId utype:(NSInteger)utype {
    NSString *currentOpenId = @"";
    self.openId = openId;
    self.unionId = unionId;
    currentOpenId = openId;
    if (utype == 4) {
        currentOpenId = unionId;
    }
    self.contactType = utype;
    [self.loadingView startAnimating];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetpaLoginContactByOpenID" params:[NSDictionary dictionaryWithObjectsAndKeys:currentOpenId, @"UnionID", [NSString stringWithFormat:@"%ld", (long)utype], @"contactType", nil] tag:4];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (IBAction)wechatRegister:(id)sender {
    [self wechatLogin];
}

- (void)wechatLogin {
    [ShareSDK getUserInfo:SSDKPlatformSubTypeWechatSession
           onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error)
     {
         if (state == SSDKResponseStateSuccess)
         {
             [self thirdLogin:[user.rawData objectForKey:@"openid"] unionId:[user.rawData objectForKey:@"unionid"] utype:4];
         }
         else
         {
             NSLog(@"%@",error);
         }
         
     }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}
@end

//
//  CpLoginViewController.m
//  wutongguo
//
//  Created by Lucifer on 2019/2/25.
//  Copyright © 2019年 Lucifer. All rights reserved.
//  登录页面

#import "CpLoginViewController.h"
#import "NavViewController.h"
#import "ChoseSideViewController.h"
#import "CpRegisterViewController.h"
#import "NetWebServiceRequest.h"
#import "CpWebViewController.h"
#import "CommonMacro.h"
#import "CommonFunc.h"
#import "GDataXMLNode.h"
#import "LoginTextField.h"
#import "LoginTextField2.h"

@interface CpLoginViewController ()<UITextFieldDelegate,NetWebServiceRequestDelegate>
@property (nonatomic , strong) UIImageView *bgView;
@property (nonatomic , strong) LoginTextField *numTextField;
@property (nonatomic , strong) LoginTextField *userTextField;
@property (nonatomic , strong) LoginTextField2 *passwordTextField;
@property (nonatomic , strong) UIButton *loginBtn;
@property (nonatomic , strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;

@end

@implementation CpLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.navigationController setNavigationBarHidden:YES];
    self.title = @"登录";
    
    UIButton *returnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    returnBtn.frame = CGRectMake(10, STATUS_BAR_HEIGHT, 44, 44);
    [returnBtn setImage:[UIImage imageNamed:@"nav_return"] forState:UIControlStateNormal];
    [returnBtn addTarget:self action:@selector(returnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:returnBtn];
    
    UIButton *registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    registerBtn.frame = CGRectMake(SCREEN_WIDTH - 10 - 50, STATUS_BAR_HEIGHT, 50, 44);
    [registerBtn setTitle:@"注册" forState:UIControlStateNormal];
    [registerBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.bgView addSubview:registerBtn];
    [registerBtn addTarget:self action:@selector(registerClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.bgView];
    LoginTextField *numTextField = [[LoginTextField alloc]initWithFrame:CGRectMake(20, 200, SCREEN_WIDTH - 40, 40) title:@"企业编号" placeholder:@""];
    numTextField.delegate = self;
    [numTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    numTextField.text = [CommonToos getValue:@"CP_NUM"];
    numTextField.keyboardType = UIKeyboardTypeNumberPad;
    [self.bgView addSubview:numTextField];
    self.numTextField = numTextField;
    
    LoginTextField *userTextField = [[LoginTextField alloc]initWithFrame:CGRectMake(20, VIEW_BY(numTextField) + 20, SCREEN_WIDTH - 40, 40) title:@"用户名" placeholder:@""];
    [userTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    userTextField.text = [CommonToos getValue:@"CP_USERNAME"];
    [self.bgView addSubview:userTextField];
    userTextField.delegate = self;
    self.userTextField = userTextField;
    
    LoginTextField2 *passwordTextField = [[LoginTextField2 alloc]initWithFrame:CGRectMake(20, VIEW_BY(userTextField) + 20, SCREEN_WIDTH - 40, 40) title:@"密码" placeholder:@""];
    [passwordTextField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    passwordTextField.delegate = self;
    passwordTextField.text = [CommonToos getValue:@"CP_PASSWORD"];
    [self.bgView addSubview:passwordTextField];
    self.passwordTextField = passwordTextField;
    
    UIButton *loginBtn = [UIButton new];
    loginBtn.frame = CGRectMake(50, VIEW_BY(passwordTextField) + 100, SCREEN_WIDTH - 100, 40);
    loginBtn.layer.cornerRadius = 20;
    loginBtn.layer.masksToBounds = YES;
    [loginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [loginBtn setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithHex:0xDDDDDD] ] forState:UIControlStateDisabled];
    [loginBtn setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithHex:0x19BF62] ] forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(loginBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:loginBtn];
    loginBtn.enabled = self.numTextField.text.length && self.userTextField.text.length && self.passwordTextField.text.length;
    self.loginBtn = loginBtn;

    UILabel *tipLab = [UILabel new];
    tipLab.frame = CGRectMake(10, SCREEN_HEIGHT - 40 -10, SCREEN_WIDTH - 20, 40);
    tipLab.numberOfLines = 0;
    tipLab.textAlignment = NSTextAlignmentCenter;
    tipLab.text = @"客服电话：400-626-5151转1";
    tipLab.font = [UIFont systemFontOfSize:14];
    [self.bgView addSubview:tipLab];
    
    //等待动画
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.bgView addSubview:self.loadingView];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidChange:(LoginTextField *)textField{
    if (self.numTextField.text.length > 0 && self.userTextField.text.length > 0 && self.passwordTextField.text.length > 0) {
        self.loginBtn.enabled = YES;
    }else{
        self.loginBtn.enabled = NO;
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    if(textField ==self.userTextField&& self.numTextField.text.length >0){
        
        NSDictionary *paramDict = @{
                                    @"cpMainID":self.numTextField.text,
                                    };
        self.runningRequest = [NetWebServiceRequest cpServiceRequestUrl:@"CheckCpMainIDExists" params:paramDict tag:2];
        [self.runningRequest setDelegate:self];
        [self.runningRequest startAsynchronous];
        
        
    }else if(textField == self.passwordTextField && self.userTextField.text.length > 0){
        
        NSDictionary *paramDict = @{
                                    @"UserName":self.userTextField.text,
                                    };
        self.runningRequest = [NetWebServiceRequest cpServiceRequestUrl:@"CheckCpAccountUserNameExists" params:paramDict tag:3];
        [self.runningRequest setDelegate:self];
        [self.runningRequest startAsynchronous];
        
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (UIImageView *)bgView{
    if (!_bgView) {
        _bgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH , SCREEN_HEIGHT)];
        [_bgView setImage:[UIImage imageNamed:@"Companyloginbg"]];
        _bgView.userInteractionEnabled = YES;
    }
    return _bgView;
}

- (void)returnClick{
    
    if (_isRootView) {
        
        UIWindow * window = [[UIApplication sharedApplication] keyWindow];
        window.rootViewController = [[NavViewController alloc]initWithRootViewController:[ChoseSideViewController new]];
        
    }else{
      [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - 登录
- (void)loginBtnClick{
    [self.view endEditing:YES];
    [self.loadingView startAnimating];
    NSDictionary *paramDict = @{
                                @"CpMainID":self.numTextField.text,
                                @"Username":self.userTextField.text,
                                @"Password":self.passwordTextField.text,
                                @"LoginIP":[CommonToos getIPaddress],
                                @"LoginCookies":[CommonToos getCurrentTime],
                                @"Browser":@"ios15",
                                @"LoginFrom":@"101"
                                };
    self.runningRequest = [NetWebServiceRequest cpServiceRequestUrl:@"Login" params:paramDict tag:1];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1) {
        [self.loadingView stopAnimating];
        NSDictionary *resultDict = [CommonFunc dictionaryWithJsonString:result];
        if ([resultDict[@"result"] boolValue]) {
            [self.view.window makeToast:@"登录成功！"];
            [CommonToos saveData:APP_STATUS value:@"1"];
            [CommonToos saveData:CP_CODE_KEY value:resultDict[@"Token"]];
            [CommonToos saveData:CP_ACCOUNTID_KEY value:resultDict[@"cpAccountID"]];
            [CommonToos saveData:CP_MAINID_KEY value:resultDict[@"cpMainID"]];
            [CommonToos saveData:@"CP_NUM" value:self.numTextField.text];
            [CommonToos saveData:@"CP_USERNAME" value:self.userTextField.text];
            [CommonToos saveData:@"CP_PASSWORD" value:self.passwordTextField.text];

            // GCD延时执行
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                CpWebViewController *wvc = [CpWebViewController new];
                [self.navigationController pushViewController:wvc animated:YES];
            });
            
        }else{
            [self.view.window makeToast:@"企业编号、用户名、或密码错误"];
        }
    }else if (request.tag == 2){// 判断企业编号是否存在
        NSArray *resultArr = [CommonFunc getArrayFromXml:requestData tableName:@"Table"];
        if(resultArr != nil && resultArr.count > 0){
            NSDictionary *resultDDict = [resultArr firstObject];
            if ([resultDDict[@"id"] boolValue]) {
                NSLog(@"存在");
            }else{
                [self.view.window makeToast:@"企业编号不存在"];
            }
        }else{
            [self.view.window makeToast:@"企业编号不存在"];
        }
    }else if (request.tag == 3){// 判断用户名是否存在
        NSArray *resultArr = [CommonFunc getArrayFromXml:requestData tableName:@"Table"];
        if(resultArr != nil && resultArr.count > 0){
            NSDictionary *resultDDict = [resultArr firstObject];
            if ([resultDDict[@"id"] boolValue]) {
                NSLog(@"存在");
            }else{
                [self.view.window makeToast:@"用户名不存在"];
            }
        }else{
            [self.view.window makeToast:@"用户名不存在"];
        }
    }
}

#pragma mark - 注册
- (void)registerClick{
    CpRegisterViewController *rvc = [[CpRegisterViewController alloc]init];
    [self.navigationController pushViewController:rvc animated:YES];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}
@end

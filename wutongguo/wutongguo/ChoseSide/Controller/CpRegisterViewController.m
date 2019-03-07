//
//  RegisterViewController.m
//  wutongguo
//
//  Created by Lucifer on 2019/2/26.
//  Copyright © 2019年 Lucifer. All rights reserved.
//

#import "CpRegisterViewController.h"
#import "NetWebServiceRequest.h"
#import "CpWebViewController.h"
#import "CommonMacro.h"
#import "CommonFunc.h"
#import "GDataXMLNode.h"
#import "CpRegisterModel.h"
#import "TemporaryModel.h"
#import "CpRegisterCell.h"
#import "CommonMacro.h"
#import "WKPopView.h"
#import "ProtocolViewController.h"

@interface CpRegisterViewController ()<UITableViewDelegate,UITableViewDataSource,WKPopViewDelegate,NetWebServiceRequestDelegate>
@property (nonatomic , strong) UITableView *tableView;
@property (nonatomic , strong) NSArray *dataArr;
@property (nonatomic , strong) CpRegisterModel *model;
@property (nonatomic , strong) UIButton *registerBtn;
@property (nonatomic , strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;

@end

@implementation CpRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"注册";
    UILabel *tipLab = [UILabel new];
    tipLab.frame = CGRectMake(0, 0, SCREEN_WIDTH, 40);
    tipLab.text = @"   一键注册，开启校园招聘之旅";
    [self.view addSubview:tipLab];
    tipLab.font = [UIFont systemFontOfSize:14];
    tipLab.backgroundColor =  BGCOLOR;
    [self.view addSubview:self.tableView];
    
    //等待动画
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.view addSubview:self.loadingView];
}

- (CpRegisterModel *)model{
    if (!_model) {
        _model = [[CpRegisterModel alloc]init];
    }
    return _model;
}
- (NSArray *)dataArr{
    if (!_dataArr) {
        
        NSArray *titleArr = [NSArray arrayWithObjects:@"企业名称",@"所在城市",@"联系人",@"手机号",@"电子邮箱",@"用户名",@"密码",@"确认密码", nil];
        NSArray *placeholderArr = [NSArray arrayWithObjects:@"与营业执照名称一致",@"点击选择",@"点击输入",@"点击输入",@"点击输入",@"6-20位字符，字母/数字/横线/下划线/点",@"8-20位字符",@"点击输入", nil];
        NSArray *valuerArr = [NSArray arrayWithObjects:@"",@"",@"",@"",@"",@"",@"",@"", nil];
        NSMutableArray *tempArr = [NSMutableArray array];
        for (int i = 0; i < titleArr.count; i ++) {
            TemporaryModel *model = [[TemporaryModel alloc]init];
            model.title = titleArr[i];
            model.content = placeholderArr[i];
            model.value = valuerArr[i];
            [tempArr addObject:model];
        }
        _dataArr = [NSArray arrayWithArray:tempArr];
    }
    return _dataArr;
}
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 40, SCREEN_WIDTH, SCREEN_HEIGHT - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT - 40) style:UITableViewStylePlain];
        _tableView.backgroundColor = BGCOLOR;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [self tableviewFootView];
    }
    return  _tableView;
}

- (UIView *)tableviewFootView{
    
    UIView *footView = [UIView new];
    footView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 100);
    footView.backgroundColor = BGCOLOR;
    
    NSString *tipStr1 = @"注册梧桐果代表您已同意";
    NSString *tipStr2 = @"注册协议";
    CGFloat width1 = [CommonToos stringWidth:tipStr1 fontSize:DEFAULTFONTSIZE];
    CGFloat width2 = [CommonToos stringWidth:tipStr2 fontSize:DEFAULTFONTSIZE];
    UILabel *tipLab = [[UILabel alloc]init];
    tipLab.frame = CGRectMake((SCREEN_WIDTH - width2 - width1)/2, 30, width1, 20);
    tipLab.text = tipStr1;
    tipLab.textAlignment = NSTextAlignmentCenter;
    tipLab.textColor = TEXTGRAYCOLOR;
    [footView addSubview:tipLab];
    tipLab.font = DEFAULTFONT;
    UIButton *protocolBtn = [UIButton new];
    protocolBtn.frame = CGRectMake(VIEW_BX(tipLab), VIEW_Y(tipLab), width2, VIEW_H(tipLab));
    protocolBtn.titleLabel.font = DEFAULTFONT;
    [protocolBtn setTitleColor:NAVBARCOLOR forState:UIControlStateNormal];
    [protocolBtn setTitle:@"注册协议" forState:UIControlStateNormal];
    [footView addSubview:protocolBtn];
    [protocolBtn addTarget:self action:@selector(protocolBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *registerBtn = [UIButton new];
    registerBtn.frame = CGRectMake(60, VIEW_BY(tipLab) + 10, SCREEN_WIDTH - 120, 40);
    registerBtn.layer.cornerRadius = 5;
    registerBtn.layer.masksToBounds = YES;
    [registerBtn setTitle:@"注册" forState:UIControlStateNormal];
    [registerBtn setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithHex:0xDDDDDD] ] forState:UIControlStateDisabled];
    [registerBtn setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithHex:0x19BF62] ] forState:UIControlStateNormal];
    [registerBtn addTarget:self action:@selector(registerBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [footView addSubview:registerBtn];
    registerBtn.enabled = NO;
    self.registerBtn = registerBtn;
    return footView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    TemporaryModel *titleModel = [self.dataArr objectAtIndex:indexPath.row];
    CpRegisterCell *cell = [[CpRegisterCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.model = self.model;
    cell.dataModel = titleModel;
    __weak typeof(self)weakself = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textFieldChangeBlock = ^(NSString *value, NSString *title) {
        
        [weakself infoIsFull];
    };
    cell.textFieldBeginEditing = ^(NSString *value, NSString *title) {
        [weakself infoIsFull];
        [weakself ajaxCheckCpExist:title];
    };
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 1) {
        [self selectRegion];
    }
}

#pragma mark - 选择城市
- (void)selectRegion{
    WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeRegionL2 value:@""];
    [popView setTag:1];
    [popView setDelegate:self];
    [popView showPopView:self];
}

#pragma mark - WKPopViewDelegate
- (void)WKPickerViewConfirm:(WKPopView *)popView arraySelect:(NSArray *)arraySelect {
    NSDictionary *dataSelect = [arraySelect lastObject];
    self.model.dcRegionID = dataSelect[@"id"];
    [self setDataValue:dataSelect[@"value"] title:@"所在城市"];
    [self.tableView reloadData];
    [self infoIsFull];
}

#pragma mark - 数据源赋值
- (void)setDataValue:(NSString *)value title:(NSString *)title{
    for (TemporaryModel *model in self.dataArr) {
        if ([title isEqualToString:model.title]) {
            model.value = value;
            break;
        }
    }
}

#pragma mark - 数据源取值
- (NSString *)getDataWithTitle:(NSString *)title{
    for (TemporaryModel *model in self.dataArr) {
        if ([title isEqualToString:model.title]) {
            return model.value;
        }
    }
    return @"";
}
        
#pragma mark - 检测是否有空信息

/**
 是否有空信息

 @return yes:有空信息 no无空信息
 */
- (BOOL)infoIsFull{
    for (TemporaryModel *model in self.dataArr) {
        if (model.value.length == 0 || model.value == nil) {
            self.registerBtn.enabled = NO;
            return YES;
        }
    }
    self.registerBtn.enabled = YES;
    return NO;
}
#pragma mark - 注册
- (void)registerBtnClick{
    [self.view endEditing:YES];
    // 检测输入信息位数
    // 联系人
    NSString *value1 = [self getDataWithTitle:@"联系人"];
    if (value1.length<2) {
        [self.view.window makeToast:@"联系人为2-20个字符"];
        return;
    }
    
    NSString *value2 = [self getDataWithTitle:@"用户名"];
    if (value2.length<6) {
        [self.view.window makeToast:@"用户名6-20个字符"];
        return;
    }
    
    NSString *value3 = [self getDataWithTitle:@"密码"];
    if (value3.length<8) {
        [self.view.window makeToast:@"密码8-20个字符"];
        return;
    }
    
    NSString *password1 = [self getDataWithTitle:@"密码"];
    NSString *password2 = [self getDataWithTitle:@"确认密码"];
    if(![password1 isEqualToString:password2]){
        [self.view.window makeToast:@"密码不一致"];
        return;
    }
    
    [self.loadingView startAnimating];
    [self Register];

}

#pragma mark - 注册接口
- (void)Register{
    //CheckCpAccountUserNameExists
    NSDictionary *paramDict = @{
                                @"cpName":[self getDataWithTitle:@"企业名称"],
                                @"dcRegionID":self.model.dcRegionID,
                                @"LinkMan":[self getDataWithTitle:@"联系人"],
                                @"Mobile":[self getDataWithTitle:@"手机号"],
                                @"Email":[self getDataWithTitle:@"电子邮箱"],
                                @"Username":[self getDataWithTitle:@"用户名"],
                                @"Password":[self getDataWithTitle:@"密码"],
                                @"RegisterIP":[CommonToos getIPaddress],
                                @"Browser":@"ios15",
                                @"Cookies":[CommonToos getCurrentTime],
                                @"RegisterMode":@"1",
                                @"RegisterFrom":@"101"
                                };
    self.runningRequest = [NetWebServiceRequest cpServiceRequestUrl:@"Register" params:paramDict tag:3];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

#pragma mark - 检测企业名称
- (void)ajaxCheckCpExist:(NSString *)title{
    if ([title containsString:@"联系人"]) {
        
        if ([CommonToos deptNumInputShouldNumber:[self getDataWithTitle:@"企业名称"]]) {
            [self.view.window makeToast:@"企业名称不能全为数字"];
            [self.view endEditing:YES];
            return;
        }
        
        NSDictionary *paramDict = @{
                                    @"cpName":[self getDataWithTitle:@"企业名称"]
                                    };
        self.runningRequest = [NetWebServiceRequest cpServiceRequestUrl:@"ajaxCheckCpExist" params:paramDict tag:1];
        [self.runningRequest setDelegate:self];
        [self.runningRequest startAsynchronous];
    
    }else if ([title containsString:@"手机号"]){
        NSString *value = [self getDataWithTitle:@"联系人"];

        if (value.length>=2 && value.length <= 20) {
            
        }else{
            [self.view endEditing:YES];
            [self.view.window makeToast:@"联系人为2-20个字符"];
        }
    }else if ([title isEqualToString:@"密码"]){
        //CheckCpAccountUserNameExists
        NSDictionary *paramDict = @{
                                    @"UserName":[self getDataWithTitle:@"用户名"]
                                    };
        self.runningRequest = [NetWebServiceRequest cpServiceRequestUrl:@"CheckCpAccountUserNameExists" params:paramDict tag:2];
        [self.runningRequest setDelegate:self];
        [self.runningRequest startAsynchronous];
    }
}

#pragma mark - NetWebServiceRequestDelegate
- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData{
    
    if(request.tag == 1){// 企业名是否存在
        if ([result isEqualToString:@"1"]) {
            [self.view.window makeToast:@"企业名称已经存在"];
        }
    }else if (request.tag == 2){// 用户名是否存在
        NSArray *dataArr = [CommonFunc getArrayFromXml:requestData tableName:@"Table"];
        if (dataArr.count >0) {
            [self.view endEditing:YES];
            [self.view.window makeToast:@"用户名已经存在"];
        }
    }else if (request.tag == 3){
        [self.loadingView stopAnimating];
        NSDictionary *resultDict = [CommonFunc dictionaryWithJsonString:result];
        NSString *result = [NSString stringWithFormat:@"%@",resultDict[@"result"]];
        if ([result isEqualToString:@"1"]) {
            [self.view.window makeToast:@"注册成功！"];
            [self loginWithToken:resultDict[@"Token"] cpAccountID:resultDict[@"cpAccountID"] cpMainID:resultDict[@"cpMainID"]];
        }else{
            NSString *error = [CommonToos registerResult:[resultDict[@"result"] integerValue]];
            [self.view.window makeToast:error];
        }
    }
}

#pragma mark - 注册成功后跳转登录页面
- (void)loginWithToken:(NSString *)token cpAccountID:(NSString *)cpAccountID cpMainID:(NSString *)cpMainID{
    
    [CommonToos saveData:APP_STATUS value:@"1"];
    [CommonToos saveData:CP_CODE_KEY value:token];
    [CommonToos saveData:CP_ACCOUNTID_KEY value:cpAccountID];
    [CommonToos saveData:CP_MAINID_KEY value:cpMainID];
    
    // GCD延时执行
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CpWebViewController *wvc = [CpWebViewController new];
        [self.navigationController pushViewController:wvc animated:YES];
    });
}

#pragma mark - 注册协议
- (void)protocolBtnClick{
    ProtocolViewController *pvc = [ProtocolViewController new];
    [self.navigationController pushViewController:pvc animated:YES];
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

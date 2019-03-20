//
//  ConfirmOrderController.m
//  wutongguo
//
//  Created by Lucifer on 2019/3/19.
//  Copyright © 2019年 Lucifer. All rights reserved.
//

#import "ConfirmOrderController.h"
#import "NetWebServiceRequest.h"
#import "PayWayCell.h"
#import "DiscountCell.h"
#import "PayWayModel.h"
#import "BottomPayView.h"
#import "WXApi.h"
#import "CommonFunc.h"
#import <AlipaySDK/AlipaySDK.h>



@interface ConfirmOrderController ()<UITableViewDelegate,UITableViewDataSource,NetWebServiceRequestDelegate>
{
    NSInteger payMethodID;// 支付方式1微信，2支付宝（默认）
    BOOL _useDiscount;// 是否使用鼓励金
}
@property (nonatomic , strong) UITableView *tableView;
@property (nonatomic , copy) NSString *validDiscount;// 可用的鼓励金额
@property (nonatomic , strong) BottomPayView *bottomPayView;//底部支付按钮
@property (nonatomic , strong) NSMutableArray *payWayArr;//支付方式数据源
@property (nonatomic , strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;

@end

@implementation ConfirmOrderController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"确认订单";
    payMethodID = 2;//
    [self createUI];
    [self createBottomView];
    self.view.backgroundColor = [UIColor colorWithHex:0xF2F3F3];
    [self.view addSubview:self.tableView];
    
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.view addSubview:self.loadingView];
}

- (NSString *)validDiscount{
    if (!_validDiscount) {
        CGFloat myDiscount = [self.myDiscount floatValue];
        CGFloat maxDiscont = [self.model.MaxDiscount floatValue];
        CGFloat validDiscount = 0;
        if(myDiscount > maxDiscont){
            validDiscount = maxDiscont;
        }else{
            validDiscount = myDiscount;
        }
        if (validDiscount>0) {
            _useDiscount = YES;
        }else{
            _useDiscount = NO;
        }
        _validDiscount = [NSString stringWithFormat:@"%f",validDiscount];
    }
    return _validDiscount;
}

- (void)createUI{
    
    UIView *bgView = [UIView new];
    [self.view addSubview:bgView];
    bgView.sd_layout
    .leftSpaceToView(self.view, 0)
    .topSpaceToView(self.view, 0)
    .rightSpaceToView(self.view, 0)
    .heightIs(44);
    bgView.backgroundColor =  [UIColor whiteColor];
    UILabel *titleLab = [UILabel new];
    [bgView addSubview:titleLab];
    titleLab.sd_layout
    .leftSpaceToView(bgView, 0)
    .topSpaceToView(bgView, 0)
    .widthRatioToView(bgView, 0.6)
    .heightRatioToView(bgView, 1);
    titleLab.font = [UIFont boldSystemFontOfSize:BIGGERFONTSIZE];
    titleLab.text = [NSString stringWithFormat:@"    %@天智能网申",self.model.Days];
//    titleLab.backgroundColor = [UIColor whiteColor];
    
    UILabel *priceLab = [UILabel new];
    [bgView addSubview:priceLab];
    priceLab.sd_layout
    .rightSpaceToView(bgView, 10)
    .topSpaceToView(bgView, 0)
    .bottomSpaceToView(bgView, 0)
    .leftSpaceToView(titleLab, 0);
    priceLab.textColor = [UIColor colorWithHex:0xFF8117];
    priceLab.textAlignment = NSTextAlignmentRight;
    priceLab.text = [NSString stringWithFormat:@"￥%@",self.model.Price];
    priceLab.font = DEFAULTFONT;
    priceLab.backgroundColor = [UIColor whiteColor];
}
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 44, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT - 44 - 45 - 10 - STATUS_BAR_HEIGHT) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor =[UIColor colorWithHex:0xF2F3F3];
        _tableView.tableFooterView = [UIView new];
        //        _tableView.scrollEnabled = NO;
    }
    return _tableView;
}

- (NSMutableArray *)payWayArr{
    if (!_payWayArr) {
        _payWayArr = [NSMutableArray array];
        NSMutableArray *payWayArr = [NSMutableArray arrayWithObjects:@"支付宝支付",@"微信支付",nil];
        NSMutableArray *logoNameArr = [NSMutableArray arrayWithObjects:@"icon_alipay",@"icon_wechat_pay",nil];
        
        for (int i = 0; i<payWayArr.count; i ++) {
            PayWayModel *model = [[PayWayModel alloc]init];
            model.payWay = payWayArr[i];
            model.logoName = logoNameArr[i];
            if (i == 0) {
                model.isSelected = YES;
            }else{
                model.isSelected = NO;
            }
            [_payWayArr addObject:model];
        }
    }
    return _payWayArr;
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alipayFailed) name:NOTIFICATION_ALIPAYFAILED object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(InquireWeiXinOrder:) name:NOTIFICATION_ALIPAYSUCCESS object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wxpayFailed) name:NOTIFICATION_WXPAYFAILED object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(InquireWeiXinOrder:) name:NOTIFICATION_WXPAYSUCCESS object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFICATION_ALIPAYFAILED object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFICATION_ALIPAYSUCCESS object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFICATION_WXPAYFAILED object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFICATION_WXPAYSUCCESS object:nil];
}
- (void)createBottomView{
    
    if (!_bottomPayView) {
        BottomPayView *bottomPayView = [BottomPayView new];
        [self.view addSubview:bottomPayView];
        bottomPayView.sd_layout
        .leftSpaceToView(self.view, 0)
        .rightSpaceToView(self.view, 0)
        .bottomSpaceToView(self.view, 0)
        .heightIs(45);
        self.bottomPayView = bottomPayView;
    }
    self.bottomPayView.money = [NSString stringWithFormat:@"%.2f",[self payTotalMoney]];
    __weak typeof(self)weakself = self;
    self.bottomPayView.payEvent = ^{
        // 检测时候否安装了微信客户端
        BOOL install = [WXApi isWXAppInstalled];
        
        if (!install && payMethodID == 1) {
            [RCToast showMessage:@"您未安装微信客户端"];
            return ;
        }
        [weakself getAppPayOrder];
    };
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    __weak typeof(self)weakself = self;
    if (indexPath.section == 0){
        PayWayCell *cell = [[PayWayCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil indexPath:indexPath];
        if (indexPath.row > 0) {
            cell.payModel = self.payWayArr[indexPath.row - 1];
        }
        cell.selectPayWay = ^(PayWayModel *payModel) {
            if([payModel.payWay containsString:@"微信"]){
                payMethodID = 1;
            }else if([payModel.payWay containsString:@"支付宝"]){
                payMethodID = 2;
            }
            
            for (PayWayModel *modle in self.payWayArr) {
                if ([modle.payWay isEqualToString:payModel.payWay]) {
                    modle.isSelected = YES;
                }else{
                    modle.isSelected = NO;
                }
            }
            [weakself.tableView reloadData];
        };
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }else if (indexPath.section == 1 ){
        DiscountCell *cell = [[DiscountCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil indexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.discount = self.validDiscount;
        cell.selectDiscountBlock = ^(BOOL useDiscount) {
            _useDiscount = useDiscount;
        };
        return cell;
        
    }
    return nil;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if ([self.validDiscount floatValue] >0) {
        return 2;
    }
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 0) {
        return 3;
    }else{
        return 1;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100)];
    headerView.backgroundColor = [UIColor colorWithHex:0xF2F3F3];
    return headerView;
}

#pragma mark - 支付金额
- (CGFloat)payTotalMoney{
    // 计算优惠的金额
    CGFloat price = [self.model.Price floatValue];
    CGFloat validPrcie = [self.validDiscount floatValue];
    // 计算应付的金额
    CGFloat totalMoney = price - validPrcie;
    return totalMoney;
}

#pragma mark - 统一下单接口
- (void)getAppPayOrder{
    [self.loadingView startAnimating];
    NSDictionary *paramDict = @{
                                @"paMainId":[CommonFunc getPaMainId],
                                @"code":[CommonFunc getCode],
                                @"orderid":@"0",
                                @"DcPaOrderPriceID":self.model.Id,
                                @"UseDiscount":_useDiscount?@"1":@"0",
                                @"payMethodID":[NSString stringWithFormat:@"%ld",(long)payMethodID],
                                @"mobileIP":[CommonToos getIPaddress],
                                @"payFrom":@"4"
                                };
    
    self.runningRequest = [NetWebServiceRequest cvServiceRequestUrl:@"GetAppPayOrder" params:paramDict tag: 1];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData{
    
    [self.loadingView stopAnimating];
    if(request.tag == 1){
        if(payMethodID == 2){// 支付宝
            [self alipayParamData:result];
        }else{
            [self wxpayParamData:result];
        }
    }else if (request.tag == 2){
        
        NSDictionary *dict = [CommonToos translateJsonStrToDictionary:result];
        if ([dict[@"orderStatus"] isEqualToString:@"1"]) {
            // 支付成功
            if (payMethodID == 2) {
                [self alipaySuccess:dict];
            }else if (payMethodID == 1){
                [self wxpaySuccess:dict];
            }
        }else{
            if (payMethodID == 2) {
                [self alipayFailed];
            }else if (payMethodID == 1){
                [self wxpayFailed];
            }
        }
    }
}

#pragma mark - 支付宝支付
- (void)alipayParamData:(NSString *)dataStr{
    // 获取appScheme
    NSDictionary *plistDic = [[NSBundle mainBundle] infoDictionary];
    NSArray * arr = plistDic[@"CFBundleURLTypes"];
    NSString * appScheme = [[[arr objectAtIndex:4] objectForKey:@"CFBundleURLSchemes"] firstObject];
    
    [[AlipaySDK defaultService]payOrder:dataStr fromScheme:appScheme callback:^(NSDictionary *resultDic) {
        
        if ([resultDic[@"resultStatus"] isEqualToString:@"9000"]){
            
            // 查询支付结果
            NSString *result = resultDic[@"result"];
            NSDictionary *resultDict = [CommonToos translateJsonStrToDictionary:result];
            NSString *out_trade_no = [resultDict[@"alipay_trade_app_pay_response"] objectForKey:@"out_trade_no"];
            [self InquireWeiXinOrder:out_trade_no];
            
        }else{
            [self alipayFailed];
        }
    }];
}

#pragma mark - 调起微信支付
- (void)wxpayParamData:(NSString *)dataStr{
    NSDictionary *dataDict = [CommonToos translateJsonStrToDictionary:dataStr];
    
    //需要创建这个支付对象
    PayReq *req   = [[PayReq alloc] init];
    //由用户微信号和AppID组成的唯一标识，用于校验微信用户
    req.openID = [dataDict objectForKey:@"appid"];
    
    // 商家id，在注册的时候给的
    req.partnerId =  [dataDict objectForKey:@"partnerid"];
    
    // 预支付订单这个是后台跟微信服务器交互后，微信服务器传给你们服务器的，你们服务器再传给你
    req.prepayId  =  [dataDict objectForKey:@"prepayid"];
    
    [[NSUserDefaults standardUserDefaults]setObject:dataDict[@"outTradeNo"] forKey:@"key_payOrdernum"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    // 根据财付通文档填写的数据和签名
    //这个比较特殊，是固定的，只能是即req.package = Sign=WXPay
    req.package   =  [dataDict objectForKey:@"package"];
    
    // 随机编码，为了防止重复的，在后台生成
    req.nonceStr  =  [dataDict objectForKey:@"noncestr"];
    
    // 这个是时间戳，也是在后台生成的，为了验证支付的
    NSString * stamp =  [dataDict objectForKey:@"timestamp"];
    req.timeStamp = stamp.intValue;
    
    // 这个签名也是后台做的
    req.sign =  [dataDict objectForKey:@"sign"];
    
    //发送请求到微信，等待微信返回onResp
    [WXApi sendReq:req];
}

#pragma mark - 微信支付通知

- (void)wxpayFailed{
    
    self.sendbackOrderName(NO, nil,nil);
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)wxpaySuccess:(NSDictionary *)dict{
    
    self.sendbackOrderName(YES,dict,self.model);
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - 支付宝支付通知

- (void)alipayFailed{
    
    self.sendbackOrderName(NO, nil,nil);
    [self.navigationController popViewControllerAnimated:NO];
}
- (void)alipaySuccess:(NSDictionary *)dict{
    
    self.sendbackOrderName(YES,dict,self.model);
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - 支付宝/微信查询支付结果
- (void)InquireWeiXinOrder:(NSString *)orderNum{
    if (![orderNum isKindOfClass:[NSString class]]) {
        orderNum = [[NSUserDefaults standardUserDefaults]objectForKey:KEY_PAYORDERNUM];
    }
    
    [self.loadingView startAnimating];
    // InquireWeiXinOrder
    NSDictionary *paramDict = @{
                                @"paMainId":[CommonFunc getPaMainId],
                                @"code":[CommonFunc getCode],
                                @"orderNum":orderNum
                                };
    
    self.runningRequest = [NetWebServiceRequest cvServiceRequestUrl:@"InquireWeiXinOrder" params:paramDict tag: 2];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

@end

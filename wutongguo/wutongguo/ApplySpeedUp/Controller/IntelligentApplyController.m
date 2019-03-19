//
//  IntelligentApplyController.m
//  wutongguo
//
//  Created by Lucifer on 2019/3/19.
//  Copyright © 2019年 Lucifer. All rights reserved.
//  智能网申

#import "IntelligentApplyController.h"
#import "NetWebServiceRequest.h"
#import "CommonMacro.h"
#import "CommonFunc.h"
#import "GDataXMLNode.h"
#import "PaOrderPriceModel.h"
#import "CVPackageView.h"
#import "CommonFunc.h"
#import "ConfirmOrderController.h"

@interface IntelligentApplyController ()<NetWebServiceRequestDelegate>
@property (nonatomic , strong) UIScrollView *scrollView;
@property (nonatomic , strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;
@property (nonatomic , strong) NSMutableArray *dataArr;
@property (nonatomic , strong) UILabel *myMoneyLab;// 我的求职鼓励金
@property (nonatomic , strong) NSString *myDiscount;// 我的抵扣金金额


@end

@implementation IntelligentApplyController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"智能网申";
    [self getPaOrderPrice];
    //等待动画
    self.view.backgroundColor = [UIColor whiteColor];
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.scrollView addSubview:self.loadingView];
}

- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

- (void)setupUI{
    self.scrollView = [UIScrollView new];
    [self.view addSubview:self.scrollView];
    self.scrollView.sd_layout
    .leftSpaceToView(self.view, 0)
    .topSpaceToView(self.view, 0)
    .rightSpaceToView(self.view, 0)
    .bottomSpaceToView(self.view, 0);
    self.scrollView.backgroundColor = [UIColor whiteColor];
    
    CGFloat Package_W = SCREEN_WIDTH/3;
    CVPackageView *tempPackageView = nil;
    for (int i = 0 ;i<self.dataArr.count;i ++) {
        PaOrderPriceModel *model = self.dataArr[i];
        CVPackageView *packageView = [CVPackageView new];
        [self.scrollView addSubview:packageView];
        packageView.sd_layout
        .leftSpaceToView(self.scrollView, Package_W *i)
        .topSpaceToView(self.scrollView, 20)
        .heightIs(120)
        .widthIs(Package_W);
        packageView.model = model;
        packageView.buyBtnClickBlock = ^(PaOrderPriceModel *model) {

            ConfirmOrderController *cvc = [ConfirmOrderController new];
            cvc.model = model;
            cvc.myDiscount = self.myDiscount;
            
            cvc.sendbackOrderName = ^(BOOL paySuccess, NSDictionary *resultDict) {
              
                if (paySuccess) {
                    [RCToast showMessage:@"支付成功"];
                }else{
                    [RCToast showMessage:@"支付未成功，请重新下单支付"];
                }
            };
    
            [self.navigationController pushViewController:cvc animated:YES];
        };
        if (i ==0) {
            tempPackageView = packageView;
        }
    }
    
    UILabel *titleLab = [UILabel new];
    [self.scrollView addSubview:titleLab];
    titleLab.sd_layout
    .leftSpaceToView(self.scrollView, 15)
    .topSpaceToView(tempPackageView, 20)
    .autoHeightRatio(0)
    .widthIs(150);
    titleLab.font = [UIFont boldSystemFontOfSize:BIGGERFONTSIZE];
    titleLab.text =@"获得求职鼓励金";
    // 我的求职鼓励金
    UILabel *myMoneyLab = [UILabel new];
    [self.scrollView addSubview:myMoneyLab];
    myMoneyLab.sd_layout
    .rightSpaceToView(self.scrollView, 15)
    .leftSpaceToView(titleLab, 0)
    .bottomEqualToView(titleLab)
    .heightRatioToView(titleLab, 1);
    myMoneyLab.font = DEFAULTFONT;
    myMoneyLab.textAlignment  = NSTextAlignmentRight;
    myMoneyLab.textColor = [UIColor colorWithHex:0xFF0015];
    self.myMoneyLab = myMoneyLab;
    
    // 说明
    UILabel *tipLab = [UILabel new];
    [self.scrollView addSubview:tipLab];
    tipLab.sd_layout
    .leftSpaceToView(self.scrollView, 15)
    .rightSpaceToView(self.scrollView, 15)
    .topSpaceToView(titleLab, 15)
    .autoHeightRatio(0);
    tipLab.font = DEFAULTFONT;
    tipLab.textColor = TEXTGRAYCOLOR;
    tipLab.text = @"每邀请一位身边的同学来注册，并填写一份简历，即可成功领取10元求职鼓励金。购买网站提供的求职增值服务时，可以用求职鼓励金抵扣现金。";
    
    UIButton *button  = [UIButton new];
    [self.scrollView addSubview:button];
    button.sd_layout
    .leftSpaceToView(self.scrollView, 40)
    .rightSpaceToView(self.scrollView, 40)
    .topSpaceToView(tipLab, 10)
    .heightIs(35);
    [button setTitle:@"分享给同学，领取求职鼓励金" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor colorWithHex:0xFF8117];
    button.sd_cornerRadius = @(5);
    [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    button.titleLabel.font = DEFAULTFONT;
    
    
    UIView *separateView = [UIView new];
    [self.scrollView addSubview:separateView];
    separateView.sd_layout
    .leftSpaceToView(self.scrollView, 0)
    .rightSpaceToView(self.scrollView, 0)
    .topSpaceToView(button, 20)
    .heightIs(10);
    separateView.backgroundColor = [UIColor colorWithHex:0xEFEFF5];
    
    // 特别说明
    UILabel *lable1 = [UILabel new];
    [self.scrollView addSubview:lable1];
    lable1.sd_layout
    .leftEqualToView(titleLab)
    .rightEqualToView(tipLab)
    .topSpaceToView(separateView, 20)
    .autoHeightRatio(0);
    lable1.font = [UIFont boldSystemFontOfSize:SMALLERFONTSIZE];
    lable1.text = @"特别说明：";
    
    // 说明
    UILabel *lable2 = [UILabel new];
    [self.scrollView addSubview:lable2];
    lable2.sd_layout
    .leftEqualToView(lable1)
    .rightEqualToView(lable1)
    .topSpaceToView(lable1, 5)
    .autoHeightRatio(0);
    lable2.font = DEFAULTFONT;
    lable2.textColor = TEXTGRAYCOLOR;
    lable2.text = @"1、购买前请认真阅读《用户协议》\n2、对服务有任何疑问或索要发票等事宜，请于每周一到周日8:30-17:30拨打客服热线400-626-5151转1";
    [self.scrollView setupAutoContentSizeWithBottomView:lable2 bottomMargin:20];
    
    UIView *bottomView = [UIView new];
    [self.scrollView addSubview:bottomView];
    bottomView.sd_layout
    .topSpaceToView(lable2, 20)
    .rightSpaceToView(self.scrollView, 0)
    .leftSpaceToView(self.scrollView, 0)
    .heightIs(500);
    bottomView.backgroundColor = [UIColor colorWithHex:0xEFEFF5];
}

- (void)getPaOrderPrice{
    [self.view endEditing:YES];
    [self.loadingView startAnimating];
    NSDictionary *paramDict = @{
                                @"OrderType":@"1"
                                };
    self.runningRequest = [NetWebServiceRequest cvServiceRequestUrl:@"GetPaOrderPrice" params:paramDict tag:1];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (void)getPaDiscount{
    NSDictionary *paramDict = @{
                                @"PaMainID":[CommonFunc getPaMainId],
                                @"code":[CommonFunc getCode]
                                };
    self.runningRequest = [NetWebServiceRequest cvServiceRequestUrl:@"GetPaDiscount" params:paramDict tag: 3];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}
#pragma mark - NetWebServiceRequestDelegate
- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData{
    [self.loadingView stopAnimating];
    if(request.tag == 1){
        [self.dataArr removeAllObjects];
        NSArray *dataArr = [CommonFunc getArrayFromXml:requestData tableName:@"Table"];
        for (NSDictionary *dict in dataArr) {
            PaOrderPriceModel *model = [PaOrderPriceModel buildModelWithDic:dict];
            [self.dataArr addObject:model];
        }
        [self setupUI];
        [self getPaDiscount];
    }else if (request.tag == 3){
        NSArray *dataArr = [CommonFunc getArrayFromXml:requestData tableName:@"Table"];
        
        NSString *myMoney = [NSString stringWithFormat:@"我的求职鼓励金:%@元",[[dataArr firstObject] objectForKey:@"Discount"]];
        self.myDiscount = [[dataArr firstObject] objectForKey:@"Discount"];
        NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:myMoney];
        NSRange range = [myMoney rangeOfString:@"我的求职鼓励金:"];
        [AttributedStr addAttribute:NSForegroundColorAttributeName value:TEXTGRAYCOLOR range:range];
        self.myMoneyLab.attributedText = AttributedStr;
    }
}

#pragma mark - 分享
- (void)buttonClick{
    
    [CommonFunc share:@"我即将找到工作，就差你的鼓励了！" content:@"我即将找到工作，就差你的鼓励了！" url:@"http://m.wutongguo.com/Personal/Account/IntelligenceApplication?SpreadPamainid=502124" view:self.view imageUrl:@"" content2:@"我即将找到工作，就差你的鼓励了"];
}
@end

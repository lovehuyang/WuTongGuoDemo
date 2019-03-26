//
//  ProtocolView.m
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/2.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "ProtocolView.h"
@interface ProtocolView()
@property (nonatomic , strong) UIView *bgView;
@property (nonatomic , strong) UIView *alertView;
@end

@implementation ProtocolView

- (instancetype)init{
    self = [super init];
    if (self) {
        
        self.bgView = [UIView new];
        [self addSubview:self.bgView];
        self.bgView.sd_layout
        .leftSpaceToView(self, 0)
        .topSpaceToView(self, 0)
        .rightSpaceToView(self, 0)
        .bottomSpaceToView(self, 0);
        self.bgView.backgroundColor = [UIColor blackColor];
        self.bgView.alpha = 0.5;
        self.bgView.userInteractionEnabled = YES;
        
        //创建alertView
        self.alertView = [[UIView alloc]init];
        self.alertView.center = CGPointMake(self.center.x, self.center.y);
        self.alertView.layer.masksToBounds = YES;
        self.alertView.layer.cornerRadius = 5;
        self.alertView.clipsToBounds = YES;
        self.alertView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.alertView];
        self.alertView.sd_layout
        .centerXEqualToView(self)
        .leftSpaceToView(self, 40)
        .rightSpaceToView(self, 40)
        .topSpaceToView(self, HEIGHT_STATUS_NAV + 35)
        .bottomSpaceToView(self, HEIGHT_STATUS_NAV + 35);
        self.alertView.backgroundColor = [UIColor whiteColor];
        self.alertView.sd_cornerRadius = @(5);
        
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews{
    
    UILabel *titleLab = [UILabel new];
    [self.alertView addSubview:titleLab];
    titleLab.text = @"用户协议";
    titleLab.font = [UIFont boldSystemFontOfSize:BIGGERFONTSIZE];
    titleLab.sd_layout
    .centerXEqualToView(self.alertView)
    .topSpaceToView(self.alertView, 10)
    .heightIs(30);
    titleLab.textColor = [UIColor blackColor];
    [titleLab setSingleLineAutoResizeWithMaxWidth:200];
    
    UIButton *closeBtn = [UIButton new];
    [self.alertView addSubview:closeBtn];
    closeBtn.sd_layout
    .rightSpaceToView(self.alertView, 15)
    .centerYEqualToView(titleLab)
    .heightIs(20)
    .widthEqualToHeight();
    [closeBtn setImage:[UIImage imageNamed:@"speedup_close"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(dissmiss) forControlEvents:UIControlEventTouchUpInside];
    
    UITextView *textView = [UITextView new];
    [self.alertView addSubview:textView];
    textView.sd_layout
    .topSpaceToView(titleLab, 0)
    .rightSpaceToView(self.alertView, 10)
    .leftSpaceToView(self.alertView, 10)
    .bottomSpaceToView(self.alertView, 15);
    textView.editable = NO;
    textView.text = @"1.服务将于在线支付成功后自动开通。一旦您完成支付，即视为您已认可本服务标明之价格及使用期间的约定，本协议即时生效。服务到期后，您的简历将自动恢复到服务购买前的状态。本网站不提供退费服务，敬请谅解。\n2.开通“智能网申”后，请务必确保在网站上创建一份简历，这样我们才能根据您的信息进行智能投递。若由于您没有及时创建简历，而影响了服务的效果，我们将不对因您的上述行为产生的结果承担任何责任。\n3.服务效果及求职结果将受到您简历的完整性、教育经历及企业的个性化需求等多重因素的影响，网站不对您购买本服务后的求职结果做任何保证和承诺。\n4. 免责条款\n4.1. 用户应对个人简历的真实性、完整性、有效性、合法性负责。\n4.2. 所有用户均应遵守与本网站之间的《用户协议》相关使用规则。若用户因违反上述约定或规则被暂停或终止使用账户，本服务将同时终止。用户应为自己的不当行为负责，本网站不对上述终止情形承担任何责任或退还任何已缴纳的费用。\n4.3. 因政府禁令、现行生效的适用法律或法规的变更、火灾、地震、动乱、战争、停电、通讯线路中断、黑客攻击、计算机病毒侵入或发作、电信部门技术调整、因政府管制而造成网站的暂时性关闭等任何影响网络正常运营的不可预见、不可避免、不可克服和不可控制的事件（“不可抗力事件”）导致本服务暂停，使用户遭受的一切损失，本网站均不承担任何责任或退还任何已缴纳的费用。\n5. 违约条款 若用户存在任何违反本协议中的内容或其他影响本网站商业信誉、商品声誉的不当行为，本网站均有权立即终止本服务，暂停或终止本网站账户和使用权限，且不承担任何责任或退还任何已缴纳的费用，并保留对因此给本网站造成的损失的追索权。";
}

- (void)show{
    
    UIView *view = [[UIApplication sharedApplication] keyWindow];
    [view addSubview:self];
    self.sd_layout
    .leftSpaceToView(view, 0)
    .rightSpaceToView(view, 0)
    .topSpaceToView(view, 0)
    .bottomSpaceToView(view, 0);
    
    self.alertView.transform = CGAffineTransformMakeScale(1.21f, 1.21f);
    
    [UIView animateWithDuration:.5f delay:0.f usingSpringWithDamping:.7f initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alertView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        
    } completion:nil];
}

- (void)dissmiss {
    
    [UIView animateWithDuration:.3 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        self.bgView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
@end

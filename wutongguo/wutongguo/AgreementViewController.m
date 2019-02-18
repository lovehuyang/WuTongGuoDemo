//
//  AgreementViewController.m
//  wutongguo
//
//  Created by Lucifer on 15/7/7.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "AgreementViewController.h"
#import "CommonMacro.h"
#import "CustomLabel.h"

@interface AgreementViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation AgreementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"用户注册协议";
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.view addSubview:self.scrollView];
    
    NSString *content = @"<p>本网站及与本网站链接的网站，仅提供求职、招聘及其它与此相关联之服务。求职者、招聘单位以及因其它任何目的进入本网站的访问者接受本协议书条款，注册成为梧桐果会员，并遵守本协议所述之条款使用本网站所提供之服务。如果您不接受本声明之条款，请勿使用本网站。接受本声明之条款，您将遵守本协议之规定。</p><font color=\"#07B670\">1.信息的发布</font><p>不得发布任何违反有关法律规定信息；</p><p>不得发布任何与本网站求职、招聘目的不适之信息；</p><p>不得发布任何不完整、虚假的信息；</p><p>用户对所发布的信息承担完全责任。</p><font color=\"#07B670\">2.信息的使用</font><p>招聘单位仅可就招聘目的使用求职者之简历信息；</p><p>求职者仅可因应聘某职位，使用招聘单位发布之招聘信息；</p><p>本网站提供的其它信息，仅与其相应内容有关的目的而被使用；</p><p>不得将任何本网站的信息用作任何商业目的。</p><font color=\"#07B670\">3.信息的公开</font><p>在本网站所登录的任何信息，均有可能被任何本网站的访问者浏览，也有可能被任何搜索引擎收录，也可能被错误使用。本网站对此将不予承担任何责任。 </p><font color=\"#07B670\">4.信息的准确性</font><p>任何在本网站发布的信息，均必须符合合法、准确、及时、完整的原则。但本网站将不能保证所有由第三方提供的信息，或本网站自行采集的信息完全准确。使用者了解，对这些信息的使用，需要经过进一步核实。本网站对访问者未经自行核实误用本网站信息造成的任何损失不予承担任何责任。 </p><font color=\"#07B670\">5.信息更改与删除</font><p>除了信息的发布者外，任何访问者不得更改或删除他人发布的任何信息。本网站有权根据其判断保留修改或删除任何不适信息之权利。 </p><font color=\"#07B670\">6.版权、商标权</font><p>本网站的图形、图像、文字及其程序等均属梧桐果之版权，受商标法及相关知识产权法律保护，未经梧桐果书面许可，任何人不得下载、复制、再使用。在本网发布信息之商标，归其相应的商标所有权人，受商标法保护。 </p><font color=\"#07B670\">7、注册信息使用</font><p>注册会员所提供的个人资料将会被梧桐果统计、汇总，在我们的严格管理下，为梧桐果的广告商及合作者提供依据。梧桐果会不定期地通过注册会员留下的电子邮箱同该会员保持联系。 </p><p>梧桐果承诺：在未经访问者授权同意的情况下，梧桐果不会将访问者的个人资料泄露给第三方。但以下情况除外。</p><p>- 根据执法单位之要求或为公共之目的向相关单位提供个人资料；</p><p>- 由于您将用户密码告知他人或与他人共享注册帐户，由此导致的任何个人资料泄露；</p><p>- 由于黑客攻击、计算机病毒侵入或发作、因政府管制而造成的暂时性关闭等影响网络正常经营之不可抗力而造成的个人资料泄露、丢失、被盗用或被窜改等；</p><p>- 由于与梧桐果链接的其它网站所造成之个人资料泄露及由此而导致的任何法律争议和后果；</p><p>- 为免除访问者在生命、身体或财产方面之急迫危险。</p><font color=\"#07B670\">8.自责</font><p>所有使用本网站的用户，对使用本网站信息和在本网站发布信息的被使用，承担完全责任。本网站对任何因使用本网站而产生的第三方之间的纠纷，不负任何责任。 </p><p>网站有权记录所有注册用户在本网站上的活动记录，在产生相关纠纷的时候，网站有提供相关历史记录的义务。</p><font color=\"#07B670\">9.服务终止</font><p>本网站有权在预先通知或不予通知的情况下终止任何免费服务。</p><font color=\"#07B670\">10.本网站因正常的系统维护、系统升级，或者因网络拥塞而导致网站不能访问，本网站不承担任何责任。</font><br /><br /><font color=\"#07B670\">11.本协议及因使用本网站而产生的与本网站之间纠纷，将依据中华人民共和国的有关法律解决。</font>";
    NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[content dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    CustomLabel *lbDescription = [[CustomLabel alloc] initWithFixedSpacing:CGRectMake(15, 20, SCREEN_WIDTH - 30, 5000) content:content size:16 color:nil];
    [lbDescription setAttributedText:attrStr];
    [lbDescription sizeToFit];
    [self.scrollView addSubview:lbDescription];
    [self.scrollView setContentSize:CGSizeMake(SCREEN_WIDTH, VIEW_BY(lbDescription) + 10)];
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

@end

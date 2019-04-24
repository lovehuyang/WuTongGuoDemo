//
//  CpRegisterCell.m
//  wutongguo
//
//  Created by Lucifer on 2019/2/26.
//  Copyright © 2019年 Lucifer. All rights reserved.
//

#import "CpRegisterCell.h"
#import "TemporaryModel.h"
#import "CpRegisterModel.h"
#import "NetWebServiceRequest.h"
#import "CommonFunc.h"
#import "Common.h"

#define ALPHANUM @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_."

@interface CpRegisterCell()<UITextFieldDelegate,NetWebServiceRequestDelegate>
@property (nonatomic ,strong)UILabel *titleLab;
@property (nonatomic ,strong)UITextField *textFideld;
@property (nonatomic ,strong)UIButton *rightBtn;
@property (nonatomic , strong) NetWebServiceRequest *runningRequest;

@end

@implementation CpRegisterCell

- (void)setupSubViewsWithTitle:(NSString *)title placeholder:(NSString *)placeholder value:(NSString *)value{
    UILabel *titleLab = [UILabel new];
    titleLab.frame = CGRectMake(10, 0, 75, self.frame.size.height);
    [self.contentView addSubview:titleLab];
    titleLab.font = DEFAULTFONT;
    titleLab.text = title;
    self.titleLab = titleLab;
    
    UIImageView *arrowImgView = nil;
    if ([titleLab.text isEqualToString:@"所在城市"]) {
        arrowImgView = [UIImageView new];
        arrowImgView.frame = CGRectMake(SCREEN_WIDTH - 10 - 15, 0, 15, VIEW_H(self));
        arrowImgView.image = [UIImage imageNamed:@"re_nextArrow"];
        arrowImgView.contentMode = UIViewContentModeScaleAspectFit;
        [self.contentView addSubview:arrowImgView];
    }
    
    UITextField *textFideld = [UITextField new];
    textFideld.frame = CGRectMake(VIEW_BX(titleLab), 0, SCREEN_WIDTH - VIEW_BX(titleLab) - 10 - (arrowImgView == nil ?0 : 15), VIEW_H(self));
    textFideld.placeholder = placeholder;
    textFideld.textAlignment = NSTextAlignmentRight;
    textFideld.font = DEFAULTFONT;
    textFideld.delegate = self;
    textFideld.text = value;
    self.textFideld = textFideld;
    [self.contentView addSubview:textFideld];
    [self.textFideld addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    if([title containsString:@"验证码"]){
        UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        rightBtn.frame = CGRectMake(0, 0, 95, 26);
        [rightBtn setTitle:@"获取短信验证码" forState:UIControlStateNormal];
        rightBtn.titleLabel.font = SMALLERFONT;
        rightBtn.backgroundColor = NAVBARCOLOR;
        rightBtn.layer.cornerRadius = 2;
        rightBtn.layer.masksToBounds = YES;
        textFideld.rightView = rightBtn;
        textFideld.rightViewMode = UITextFieldViewModeAlways;
        [rightBtn addTarget:self action:@selector(getCodeEvent) forControlEvents:UIControlEventTouchUpInside];
        self.rightBtn = rightBtn;
    }
    
    if ([title containsString:@"手机号"]) {
        self.textFideld.keyboardType = UIKeyboardTypeNumberPad;
    }else if ([title containsString:@"所在城市"]){
        self.textFideld.userInteractionEnabled = NO;
    }else if ([title containsString:@"密码"]){
        self.textFideld.secureTextEntry = YES;
        self.textFideld.keyboardType = UIKeyboardTypeASCIICapable;
    }else if ([title containsString:@"电子邮箱"]){
        self.textFideld.keyboardType = UIKeyboardTypeEmailAddress;
    }else if ([title containsString:@"用户名"]){
        self.textFideld.keyboardType = UIKeyboardTypeASCIICapable;
    }
}

- (void)setModel:(CpRegisterModel *)model{
    _model = model;
}
- (void)setDataModel:(TemporaryModel *)dataModel{
    _dataModel = dataModel;
    [self setupSubViewsWithTitle:_dataModel.title placeholder:_dataModel.content value:_dataModel.value];
    
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
   
    if ([self.dataModel.title containsString:@"用户名"]) {
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:ALPHANUM] invertedSet];
        NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        return [string isEqualToString:filtered];
    }
    return YES;
    
   
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.textFideld resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    self.textFieldBeginEditing(textField.text, self.titleLab.text);
    return YES;
}
- (void)textFieldDidChange:(UITextField *)textField{
    
    if([self.dataModel.title containsString:@"用户名"] || [self.dataModel.title containsString:@"联系人"] || [self.dataModel.title containsString:@"密码" ] ||[self.dataModel.title containsString:@"手机号"]){// 最多输入20字符
        
        CGFloat maxLength = [self.dataModel.title containsString:@"手机号"]?11:20 ;
        NSString *toBeString = textField.text;
        
        //获取高亮部分
        UITextRange *selectedRange = [textField markedTextRange];
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        if (!position || !selectedRange)
        {
            if (toBeString.length > maxLength)
            {
                NSRange rangeIndex = [toBeString rangeOfComposedCharacterSequenceAtIndex:maxLength];
                if (rangeIndex.length == 1)
                {
                    textField.text = [toBeString substringToIndex:maxLength];
                }
                else
                {
                    NSRange rangeRange = [toBeString rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, maxLength)];
                    textField.text = [toBeString substringWithRange:rangeRange];
                }
            }
        }
    }
    
    self.dataModel.value = textField.text;
    if ([self.dataModel.title containsString:@"手机号"]) {
        self.model.Mobile = self.dataModel.value;
    }
    self.textFieldChangeBlock(textField.text, self.titleLab.text);
}

#pragma mark - 获取验证码
- (void)getCodeEvent{
    if (self.model.Mobile.length ==0) {
        [RCToast showMessage:@"请先输入手机号"];
        return;
    }
    
    self.getCodeBlock(1);
//    [self openCountdown:300];
    [self getCode];
}

#pragma mark - 到计时
- (void)openCountdown:(NSInteger)seconds{
    
    __block NSInteger time = seconds; //倒计时时间
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    
    dispatch_source_set_event_handler(_timer, ^{
        
        if(time <= 0){ //倒计时结束，关闭
            
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //设置按钮的样式
                [self.rightBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
                self.rightBtn.backgroundColor = NAVBARCOLOR;
                self.rightBtn.enabled = YES;
            });
            
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //设置按钮显示读秒效果
                [self.rightBtn setTitle:[NSString stringWithFormat:@"%lds", (long)time] forState:UIControlStateNormal];
                self.rightBtn.backgroundColor = [UIColor lightGrayColor];

                self.rightBtn.enabled = NO;
            });
            time--;
        }
    });
    dispatch_resume(_timer);
}
#pragma mark - 获取验证码

- (void)getCode{
    NSDictionary *param = @{
                            @"strMobile":self.model.Mobile,
                            @"ip":@""
                            };
    self.runningRequest = [NetWebServiceRequest cpMobileServiceRequestUrl:@"GetMobileCheckCodeByUpdateCpInfo" params:param tag:4];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

#pragma mark - NetWebServiceRequestDelegate
- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData{
    self.getCodeBlock(0);
    if (request.tag == 4){// 获取验证码
        
        if ([result containsString:@"s"]) {
            [RCToast showMessage:[NSString stringWithFormat:@"剩余发送间隔%@",result]];
        }else if (result != nil) {
            if ([result isEqualToString:@"1"]) {
                // 开始倒计时
                [self openCountdown:180];
            }else{
                NSInteger errCode = [result integerValue];
                [RCToast showMessage:[Common getCpMobileVerifyCodeResult:errCode]];
            }
        }else{
            
        }
        NSLog(@"");
    }
}
@end

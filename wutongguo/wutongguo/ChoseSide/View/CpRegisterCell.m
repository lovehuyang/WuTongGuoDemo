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
#define ALPHANUM @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_."

@interface CpRegisterCell()<UITextFieldDelegate>
@property (nonatomic ,strong)UILabel *titleLab;
@property (nonatomic ,strong)UITextField *textFideld;
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
    self.textFieldChangeBlock(textField.text, self.titleLab.text);
    
}
@end

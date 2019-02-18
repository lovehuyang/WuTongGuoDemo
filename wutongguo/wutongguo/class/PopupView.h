//
//  PopupView.h
//  wutongguo
//
//  Created by Lucifer on 15-5-11.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum {
    popupTypeWithRegion,
    popupTypeWithMajor
} popupType;

@protocol PopupViewDelegate <NSObject>
@optional
- (void)itemDidSelected:(id)value;
- (void)closePopupWhenTapArrow;
- (void)popupAlerConfirm;
@end

@interface PopupView : UIView
@property (nonatomic, weak) id <PopupViewDelegate>delegate;
@property (nonatomic) BOOL noRequired;
- (id)initWithCity:(UIView *)targetView parentView:(UIView *)parentView required:(BOOL)required;
- (id)initWithArray:(UIView *)targetView parentView:(UIView *)parentView array:(NSArray *)array required:(BOOL)required;
- (id)initWithMajor:(UIView *)targetView parentView:(UIView *)parentView required:(BOOL)required;
- (id)initWithCombo:(UIView *)targetView parentView:(UIView *)parentView IsGov:(BOOL)IsGov;
- (void)setDefaultWithLv2:(NSString *)value type:(popupType)type;
- (void)setDefaultWithLv1:(NSString *)value;
- (void)setDefaultWithCombo:(NSArray *)value;
- (id)initWithWechatFocus:(UIView *)targetView;
- (id)initWithWarningAlert:(UIView *)targetView
                     title:(NSString *)title
                   content:(NSString *)content
                     okMsg:(NSString *)okMsg
                 cancelMsg:(NSString *)cancelMsg;
- (id)initWithNoListTips:(UIView *)targetView
                 tipsMsg:(NSString *)tipsMsg;
- (id)initWithOtherApplyAlert:(UIView *)targetView
                      content:(NSString *)content
                        okMsg:(NSString *)okMsg;
- (void)popupClose;
@end

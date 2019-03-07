//
//  WKPopView.h
//  iOS51rcProject
//
//  Created by Lucifer on 2017/6/20.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDatabase.h"
#import "WKLabel.h"

typedef enum {
    WKPickerTypeGender,
    WKPickerTypeBirth,
    WKPickerTypeRegionL3,
    WKPickerTypeRegionL2,
    WKPickerTypeProvince,
    WKPickerTypeJobType,
    WKPickerTypeIndustry,
    WKPickerTypeCompanySize,
    WKPickerTypeCompanyKind,
    WKPickerTypeLowerNumber,
    WKPickerTypeDegree,
    WKPickerTypeJobDegree,
    WKPickerTypeCareerStatus,
    WKPickerTypeRelationWorkYears,
    WKPickerTypeSalary,
    WKPickerTypeJobSalary,
    WKPickerTypeEmployType,
    WKPickerTypeGraduation,
    WKPickerTypeEduType,
    WKPickerTypeMajor,
    WKPickerTypeWorkBeginDate,
    WKPickerTypeWorkEndDate,
    WKPickerTypeLanguage,
    WKPickerTypeNeedNumber,
    WKPickerTypeNeedWorkYears,
    WKPickerTypeNegotiable,
    WKPickerTypeSearchGraducation,
    WKPickerTypeSearchAge,
    WKPickerTypeSearchHeight,
    WKPickerTypeSearchOnline,
    WKPickerTypeSearchSalary,
    WKPickerTypeSearchDegree,
    WKPickerTypeSearchNeedWorkYears,
    WKPickerTypeCustom
} WKPickerType;

@protocol WKPopViewDelegate;

@interface WKPopView : UIView<UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, assign) id<WKPopViewDelegate> delegate;
@property (nonatomic) WKPickerType pickerType;
@property (nonatomic, strong) FMDatabase *dataBase;
@property (strong, nonatomic) NSMutableArray *arrayData;
@property (strong, nonatomic) UIPickerView *pickerView;
@property (strong, nonatomic) WKLabel *lbTips;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) UIButton *btnCancel;
@property (nonatomic) Boolean cancelHidden;
@property (nonatomic) Boolean cancelClear;

- (id)initWithCustomView:(UIView *)customView;
- (id)initWithPickerType:(WKPickerType)pickerType value:(NSString *)value;
- (id)initWithArray:(NSArray *)array value:(NSString *)value;
- (id)initWithArray:(NSArray *)array value:(NSString *)value title:(NSString *)title tipsLable:(WKLabel *)tipsLable;
- (void)showPopView:(UIViewController *)viewController;
- (void)cancelClick;
@end

@protocol WKPopViewDelegate <NSObject>

@optional
- (void)WKPopViewConfirm:(WKPopView *)popView;
- (void)WKPickerViewConfirm:(WKPopView *)popView arraySelect:(NSArray *)arraySelect;
@end

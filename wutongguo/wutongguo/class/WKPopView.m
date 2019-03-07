//
//  WKPopView.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/6/20.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "WKPopView.h"
#import "CommonMacro.h"
#import "Common.h"

@interface WKPopView()
@property (nonatomic , strong)UIViewController *viewController;
@end

@implementation WKPopView

- (id)initWithCustomView:(UIView *)customView {
    self = [super initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    if (self) {
        
        // 键盘弹起
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillShowNotification object:nil];
        // 键盘收起
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];

        
        UIButton *btnBackground = [[UIButton alloc] initWithFrame:self.frame];
        [btnBackground setTag:POPBACKGROUNDVIEWTAG];
        [btnBackground addTarget:self action:@selector(cancelClick) forControlEvents:UIControlEventTouchUpInside];
        [btnBackground setBackgroundColor:[UIColor blackColor]];
        [btnBackground setAlpha:0];
        [self addSubview:btnBackground];
        
        UIView *viewContent = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, VIEW_H(customView) + 46)];
        [viewContent setBackgroundColor:[UIColor whiteColor]];
        [viewContent setTag:POPVIEWTAG];
        [self addSubview:viewContent];
        
        UIButton *btnOk = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 100, 0, 100, 46)];
        [btnOk setTitle:@"确定" forState:UIControlStateNormal];
        [btnOk setTitleColor:NAVBARCOLOR forState:UIControlStateNormal];
        [btnOk.titleLabel setFont:BIGGERFONT];
        [btnOk addTarget:self action:@selector(okClick) forControlEvents:UIControlEventTouchUpInside];
        [viewContent addSubview:btnOk];
        
        self.btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 46)];
        [self.btnCancel setTitle:@"取消" forState:UIControlStateNormal];
        [self.btnCancel setTitleColor:TEXTGRAYCOLOR forState:UIControlStateNormal];
        [self.btnCancel.titleLabel setFont:BIGGERFONT];
        [self.btnCancel addTarget:self action:@selector(cancelClick) forControlEvents:UIControlEventTouchUpInside];
        [viewContent addSubview:self.btnCancel];
        
        if (self.title != nil) {
            WKLabel *lbTitle = [[WKLabel alloc] initWithFrame:CGRectMake(VIEW_BX(btnOk), 0, VIEW_X(self.btnCancel) - VIEW_BX(btnOk), VIEW_H(btnOk)) content:self.title size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR];
            [lbTitle setTextAlignment:NSTextAlignmentCenter];
            [viewContent addSubview:lbTitle];
        }
        
        [customView setFrame:CGRectMake(VIEW_X(customView), VIEW_BY(btnOk), VIEW_W(customView), VIEW_H(customView))];
        if (customView.tag == 0) {
            [customView setTag:POPVIEWCONTENTTAG];
        }
        [viewContent addSubview:customView];
    }
    return self;
}

- (id)initWithPickerType:(WKPickerType)pickerType value:(NSString *)value {
    self.pickerType = pickerType;
    if (self.arrayData == nil) {
        self.arrayData = [NSMutableArray arrayWithCapacity:3];
    }
    [self setupPickerArray];
    UIView *viewContent = [[UIView alloc] init];
    float y = 0;
    if (self.lbTips != nil) {
        [viewContent addSubview:self.lbTips];
        y = VIEW_BY(self.lbTips) + 10;
    }
    self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, y, SCREEN_WIDTH, 180)];
    [self.pickerView setDataSource:self];
    [self.pickerView setDelegate:self];
    [viewContent addSubview:self.pickerView];
    [viewContent setFrame:CGRectMake(0, 0, SCREEN_WIDTH, VIEW_BY(self.pickerView))];
    return [self initWithCustomView:viewContent];
}

- (id)initWithArray:(NSArray *)array value:(NSString *)value {
    self.arrayData = [NSMutableArray arrayWithCapacity:3];
    [self.arrayData setObject:array atIndexedSubscript:0];
    return [self initWithPickerType:WKPickerTypeCustom value:value];
}

- (id)initWithArray:(NSArray *)array value:(NSString *)value title:(NSString *)title tipsLable:(WKLabel *)tipsLable {
    self.title = title;
    self.lbTips = tipsLable;
    self.arrayData = [NSMutableArray arrayWithCapacity:3];
    [self.arrayData setObject:array atIndexedSubscript:0];
    return [self initWithPickerType:WKPickerTypeCustom value:value];
}

- (void)setCancelHidden:(Boolean)cancelHidden {
    if (cancelHidden) {
        [self.btnCancel setHidden:YES];
    }
}

- (void)setCancelClear:(Boolean)cancelClear {
    if (cancelClear) {
        [self.btnCancel setTitle:@"清空" forState:UIControlStateNormal];
        [self.btnCancel addTarget:self action:@selector(clearClick) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)okClick {
    if (self.pickerView != nil) {
        NSMutableArray *arraySelect = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < self.arrayData.count; i++) {
            NSArray *arrayLv = [self.arrayData objectAtIndex:i];
            if (arrayLv.count == 0) {
                if (self.pickerType == WKPickerTypeJobSalary) {
                    [arraySelect addObject:[[NSDictionary alloc] init]];
                }
                else {
                    break;
                }
            }
            else {
                [arraySelect addObject:[arrayLv objectAtIndex:[self.pickerView selectedRowInComponent:i]]];
            }
        }
        [self.delegate WKPickerViewConfirm:self arraySelect:arraySelect];
        [self cancelClick];
    }
    else {
        [self.delegate WKPopViewConfirm:self];
    }
}

- (void)clearClick {
    [self.delegate WKPickerViewConfirm:self arraySelect:[[NSArray alloc] initWithObjects:[[NSDictionary alloc] initWithObjectsAndKeys:@"", @"id", @"", @"value", nil], nil]];
    [self cancelClick];
}

- (void)cancelClick {
    UIView *viewContent = [self viewWithTag:POPVIEWTAG];
    UIButton *btnBackground = [self viewWithTag:POPBACKGROUNDVIEWTAG];
    [UIView animateWithDuration:0.5 animations:^{
        [viewContent setFrame:CGRectMake(VIEW_X(viewContent), SCREEN_HEIGHT, VIEW_W(viewContent), VIEW_H(viewContent))];
        [btnBackground setAlpha:0];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self.dataBase close];
    }];
}

- (void)showPopView:(UIViewController *)viewController {
    self.viewController = viewController;
    [viewController.view endEditing:YES];
    if (self.pickerType == WKPickerTypeBirth) {
        [self.pickerView selectRow:5 inComponent:0 animated:YES];
    }
    else if (self.pickerType == WKPickerTypeGraduation) {
        [self.pickerView selectRow:2 inComponent:0 animated:YES];
        [self.pickerView selectRow:6 inComponent:1 animated:YES];
    }
    [viewController.view.window addSubview:self];
//    if (viewController.view.tag == 1) {
//        [viewController.view.window addSubview:self];
//    }
//    else {
//        [viewController.view addSubview:self];
//    }
    UIView *viewContent = [self viewWithTag:POPVIEWTAG];
    UIButton *btnBackground = [self viewWithTag:POPBACKGROUNDVIEWTAG];
    [UIView animateWithDuration:0.5 animations:^{
        [viewContent setFrame:CGRectMake(VIEW_X(viewContent), SCREEN_HEIGHT - VIEW_H(viewContent), VIEW_W(viewContent), VIEW_H(viewContent))];
        [btnBackground setAlpha:0.5];
    }];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return self.arrayData.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [[self.arrayData objectAtIndex:component] count];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view {
    NSArray *array = [self.arrayData objectAtIndex:component];
    WKLabel *lbTitle = [[WKLabel alloc] initWithFixedHeight:CGRectMake(0, 0, SCREEN_WIDTH, 20) content:[[array objectAtIndex:row] objectForKey:@"value"] size:BIGGERFONTSIZE color:nil];
    return lbTitle;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    @try {
        if (component == pickerView.numberOfComponents - 1) {
            return;
        }
        NSString *selId = [[[self.arrayData objectAtIndex:component] objectAtIndex:row] objectForKey:@"id"];
        [self updatePickerArray:selId inComponent:component];
        for (NSInteger i = (component + 1); i < pickerView.numberOfComponents; i++) {
            if (self.pickerType == WKPickerTypeJobSalary && i == 3) {
                continue;
            }
            [pickerView reloadComponent:i];
            [pickerView selectRow:0 inComponent:i animated:YES];
        }
        if (self.pickerType == WKPickerTypeJobSalary) {
            if (component == 0 && [selId isEqualToString:@"17"]) {
                [pickerView selectRow:14 inComponent:2 animated:YES];
            }
            else if (component == 2 && [selId isEqualToString:@"17"]) {
                [pickerView selectRow:14 inComponent:0 animated:YES];
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

- (void)setupPickerArray {
    NSString *sqlString;
    if (self.pickerType == WKPickerTypeGender) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"0", @"id", @"男", @"value", nil]];
        [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"1", @"id", @"女", @"value", nil]];
        [self.arrayData setObject:array atIndexedSubscript:0];
    }
    else if (self.pickerType == WKPickerTypeBirth) {
        [self.arrayData setObject:[self setArrayYear:-16 range:60] atIndexedSubscript:0];
        [self.arrayData setObject:[self setArrayMonth] atIndexedSubscript:1];
    }
    else if (self.pickerType == WKPickerTypeGraduation) {
        [self.arrayData setObject:[self setArrayYear:2 range:60] atIndexedSubscript:0];
        [self.arrayData setObject:[self setArrayMonth] atIndexedSubscript:1];
    }
    else if (self.pickerType == WKPickerTypeGraduation) {
        [self.arrayData setObject:[self setArrayYear:2 range:60] atIndexedSubscript:0];
        [self.arrayData setObject:[self setArrayMonth] atIndexedSubscript:1];
    }
    else if (self.pickerType == WKPickerTypeWorkBeginDate) {
        [self.arrayData setObject:[self setArrayYear:0 range:60] atIndexedSubscript:0];
        [self.arrayData setObject:[self setArrayMonth] atIndexedSubscript:1];
    }
    else if (self.pickerType == WKPickerTypeWorkEndDate) {
        NSMutableArray *arrayYear = [[self setArrayYear:0 range:60] mutableCopy];
        [arrayYear insertObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"999999", @"id", @"至今", @"value", nil] atIndex:0];
        [self.arrayData setObject:arrayYear atIndexedSubscript:0];
        [self.arrayData setObject:[[NSMutableArray alloc] init] atIndexedSubscript:1];
    }
    else if (self.pickerType == WKPickerTypeSalary) {
        sqlString = @"SELECT * FROM dcSalary WHERE _id < 15";
        [self querySql:sqlString index:0];
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"1", @"id", @"可面议", @"value", nil]];
        [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"0", @"id", @"不可面议", @"value", nil]];
        [self.arrayData setObject:array atIndexedSubscript:1];
    }
    else if (self.pickerType == WKPickerTypeSearchSalary) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"1", @"id", @"1K~2K", @"value", nil]];
        [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"2", @"id", @"2K~3K", @"value", nil]];
        [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"3", @"id", @"3K~5K", @"value", nil]];
        [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"4", @"id", @"5K~8K", @"value", nil]];
        [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"5", @"id", @"8K~15K", @"value", nil]];
        [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"6", @"id", @"15K~30K", @"value", nil]];
        [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"7", @"id", @"30K以上", @"value", nil]];
        [self.arrayData setObject:array atIndexedSubscript:0];
    }
    else if (self.pickerType == WKPickerTypeJobSalary) {
        sqlString = @"SELECT * FROM dcSalaryCp";
        [self querySql:sqlString index:0];
        NSMutableArray *arraySalaryMin = [[self.arrayData objectAtIndex:0] mutableCopy];
        [arraySalaryMin setObject:[NSDictionary dictionaryWithObjectsAndKeys:@"16", @"id", @"50K以上", @"value", nil] atIndexedSubscript:arraySalaryMin.count - 1];
        [self.arrayData setObject:arraySalaryMin atIndexedSubscript:0];
        
        [self.arrayData setObject:[[NSMutableArray alloc] initWithObjects:[[NSDictionary alloc] initWithObjectsAndKeys:@"", @"id", @"至", @"value", nil], nil] atIndexedSubscript:1];
        
        sqlString = @"SELECT * FROM dcSalaryCp WHERE _id > 2";
        [self querySql:sqlString index:2];
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"1", @"id", @"可面议", @"value", nil]];
        [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"0", @"id", @"不可面议", @"value", nil]];
        [self.arrayData setObject:array atIndexedSubscript:3];
    }
    else if (self.pickerType == WKPickerTypeDegree) {
        sqlString = @"SELECT * FROM dcEducation";
        [self querySql:sqlString index:0];
    }
    else if (self.pickerType == WKPickerTypeJobDegree) {
        sqlString = @"SELECT * FROM dcEducation";
        [self querySql:sqlString index:0];
        
        NSMutableArray *array = [[self.arrayData objectAtIndex:0] mutableCopy];
        [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"100", @"id", @"不限", @"value", nil]];
        [self.arrayData setObject:array atIndexedSubscript:0];
    }
    else if (self.pickerType == WKPickerTypeCompanySize) {
        sqlString = @"SELECT * FROM dcCompanySize";
        [self querySql:sqlString index:0];
    }
    else if (self.pickerType == WKPickerTypeCompanyKind) {
        sqlString = @"SELECT * FROM dcCompanyKind";
        [self querySql:sqlString index:0];
    }
    else if (self.pickerType == WKPickerTypeLowerNumber) {
        sqlString = @"SELECT * FROM dcLowerNumber";
        [self querySql:sqlString index:0];
    }
    else if (self.pickerType == WKPickerTypeEduType) {
        sqlString = @"SELECT * FROM dcEduType";
        [self querySql:sqlString index:0];
    }
    else if (self.pickerType == WKPickerTypeRelationWorkYears) {
        sqlString = @"SELECT * FROM dcRelationWorkYears";
        [self querySql:sqlString index:0];
    }
    else if (self.pickerType == WKPickerTypeCareerStatus) {
        sqlString = @"SELECT * FROM dcCareerStatus";
        [self querySql:sqlString index:0];
    }
    else if (self.pickerType == WKPickerTypeEmployType) {
        sqlString = @"SELECT * FROM dcEmployType";
        [self querySql:sqlString index:0];
    }
    else if (self.pickerType == WKPickerTypeLanguage) {
        sqlString = @"SELECT * FROM dcLanguage";
        [self querySql:sqlString index:0];
    }
    else if (self.pickerType == WKPickerTypeNeedNumber) {
        sqlString = @"SELECT * FROM dcNeedNumber";
        [self querySql:sqlString index:0];
    }
    else if (self.pickerType == WKPickerTypeSearchNeedWorkYears) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"0", @"id", @"无工作经验", @"value", nil]];
        [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"1", @"id", @"1~2年", @"value", nil]];
        [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"5", @"id", @"2~3年", @"value", nil]];
        [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"2", @"id", @"3~5年", @"value", nil]];
        [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"3", @"id", @"6~10年", @"value", nil]];
        [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"4", @"id", @"10年以上", @"value", nil]];
        [self.arrayData setObject:array atIndexedSubscript:0];
    }
    else if (self.pickerType == WKPickerTypeNeedWorkYears) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"0", @"id", @"不限", @"value", nil]];
        [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"1", @"id", @"1~2年", @"value", nil]];
        [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"2", @"id", @"3~5年", @"value", nil]];
        [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"3", @"id", @"6~10年", @"value", nil]];
        [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"4", @"id", @"10年以上", @"value", nil]];
        [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"5", @"id", @"应届毕业生", @"value", nil]];
        [self.arrayData setObject:array atIndexedSubscript:0];
    }
    else if (self.pickerType == WKPickerTypeProvince) {
        sqlString = @"SELECT * FROM dcRegion WHERE ParentId = 0 AND _id < 90";
        [self querySql:sqlString index:0];
    }
    else if (self.pickerType == WKPickerTypeMajor) {
        for (NSInteger i = 0; i < 2; i++) {
            NSString *parentId = @"0";
            if (i > 0) {
                parentId = [[[self.arrayData objectAtIndex:(i - 1)] objectAtIndex:0] objectForKey:@"id"];
            }
            sqlString = [NSString stringWithFormat:@"SELECT * FROM dcMajor WHERE ParentId = %@ ORDER BY CASE _id WHEN 1106 THEN 1 WHEN 1000 THEN 2 ELSE 0 END, _id", parentId];
            [self querySql:sqlString index:i];
        }
    }
    else if (self.pickerType == WKPickerTypeIndustry) {
        for (NSInteger i = 0; i < 2; i++) {
            NSString *parentId = @"0";
            if (i > 0) {
                parentId = [[[self.arrayData objectAtIndex:(i - 1)] objectAtIndex:0] objectForKey:@"id"];
            }
            sqlString = [NSString stringWithFormat:@"SELECT * FROM dcIndustry WHERE ParentId = %@ ORDER BY OrderNo", parentId];
            [self querySql:sqlString index:i];
        }
    }
    else if (self.pickerType == WKPickerTypeJobType) {
        for (NSInteger i = 0; i < 2; i++) {
            NSString *parentId = @"0";
            if (i > 0) {
                parentId = [[[self.arrayData objectAtIndex:(i - 1)] objectAtIndex:0] objectForKey:@"id"];
            }
            sqlString = [NSString stringWithFormat:@"SELECT * FROM dcJobType WHERE ParentId = %@ ORDER BY _id", parentId];
            [self querySql:sqlString index:i];
        }
    }
    else if (self.pickerType == WKPickerTypeRegionL2 || self.pickerType == WKPickerTypeRegionL3) {
        for (NSInteger i = 0; i < (self.pickerType == WKPickerTypeRegionL2 ? 2 : 3); i++) {
            NSString *parentId = @"0";
            if (i > 0) {
                parentId = [[[self.arrayData objectAtIndex:(i - 1)] objectAtIndex:0] objectForKey:@"id"];
            }
            if (i == 1 && self.pickerType == WKPickerTypeRegionL2 && ([parentId isEqualToString:@"10"] || [parentId isEqualToString:@"11"] || [parentId isEqualToString:@"30"] || [parentId isEqualToString:@"60"])) {
                
                sqlString = @"SELECT * FROM dcRegion WHERE 1 = 2";
            }
            else {
                sqlString = [NSString stringWithFormat:@"SELECT * FROM dcRegion_copy1 WHERE ParentId = '%@' ORDER BY CASE _id WHEN %@ THEN 0 ELSE _id END", parentId, [USER_DEFAULT stringForKey:@"provinceId"]];
            }
            [self querySql:sqlString index:i];
        }
    }
    else if (self.pickerType == WKPickerTypeNegotiable) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"0", @"id", @"不可面议", @"value", nil]];
        [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"1", @"id", @"可面议", @"value", nil]];
        [self.arrayData setObject:array atIndexedSubscript:0];
    }
    else if (self.pickerType == WKPickerTypeSearchDegree) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"1", @"id", @"初中、高中、中技、中专", @"value", nil]];
        [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"2", @"id", @"大专及以下", @"value", nil]];
        [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"3", @"id", @"大专", @"value", nil]];
        [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"4", @"id", @"大专及本科", @"value", nil]];
        [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"9", @"id", @"大专及以上", @"value", nil]];
        [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"5", @"id", @"本科", @"value", nil]];
        [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"6", @"id", @"本科及以上", @"value", nil]];
        [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"7", @"id", @"硕士", @"value", nil]];
        [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"8", @"id", @"博士", @"value", nil]];
        [self.arrayData setObject:array atIndexedSubscript:0];
    }
    else if (self.pickerType == WKPickerTypeSearchOnline) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"", @"id", @"不限", @"value", nil]];
        [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"1", @"id", @"在线", @"value", nil]];
        [self.arrayData setObject:array atIndexedSubscript:0];
    }
    else if (self.pickerType == WKPickerTypeSearchGraducation) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        NSDate *date = [NSDate date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:NSCalendarUnitYear fromDate:date];
        NSInteger year = [components year];
        [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%ld", (year + 1)], @"id", [NSString stringWithFormat:@"%ld年及以后", (year + 1)], @"value", nil]];
        for (NSInteger i = year; i > year - 10; i--) {
            [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%ld", i], @"id", [NSString stringWithFormat:@"%ld年", i], @"value", nil]];
        }
        [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%ld", (year - 10)], @"id", [NSString stringWithFormat:@"%ld年及之前", (year - 10)], @"value", nil]];
        [self.arrayData setObject:array atIndexedSubscript:0];
    }
    else if (self.pickerType == WKPickerTypeSearchAge) {
        NSMutableArray *arrayMin = [[NSMutableArray alloc] init];
        NSMutableArray *arrayMax = [[NSMutableArray alloc] init];
        [arrayMin addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"99", @"id", @"不限", @"value", nil]];
        [arrayMax addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"99", @"id", @"不限", @"value", nil]];
        for (NSInteger i = 16; i < 61; i++) {
            [arrayMin addObject:[[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%ld", i], @"id", [NSString stringWithFormat:@"%ld岁", i], @"value", nil]];
            [arrayMax addObject:[[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%ld", i], @"id", [NSString stringWithFormat:@"%ld岁", i], @"value", nil]];
        }
        NSMutableArray *arrayTo = [[NSMutableArray alloc] initWithObjects:[[NSDictionary alloc] initWithObjectsAndKeys:@"", @"id", @"至", @"value", nil], nil];
        [self.arrayData setObject:arrayMin atIndexedSubscript:0];
        [self.arrayData setObject:arrayTo atIndexedSubscript:1];
        [self.arrayData setObject:arrayMax atIndexedSubscript:2];
    }
    else if (self.pickerType == WKPickerTypeSearchHeight) {
        NSMutableArray *arrayMin = [[NSMutableArray alloc] init];
        NSMutableArray *arrayMax = [[NSMutableArray alloc] init];
        [arrayMin addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"", @"id", @"不限", @"value", nil]];
        [arrayMax addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"", @"id", @"不限", @"value", nil]];
        for (NSInteger i = 140; i < 231; i++) {
            [arrayMin addObject:[[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%ld", i], @"id", [NSString stringWithFormat:@"%ldcm", i], @"value", nil]];
            [arrayMax addObject:[[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%ld", i], @"id", [NSString stringWithFormat:@"%ldcm", i], @"value", nil]];
        }
        NSMutableArray *arrayTo = [[NSMutableArray alloc] initWithObjects:[[NSDictionary alloc] initWithObjectsAndKeys:@"", @"id", @"至", @"value", nil], nil];
        [self.arrayData setObject:arrayMin atIndexedSubscript:0];
        [self.arrayData setObject:arrayTo atIndexedSubscript:1];
        [self.arrayData setObject:arrayMax atIndexedSubscript:2];
    }
}

- (NSArray *)setArrayYear:(NSInteger)diff range:(NSInteger)range {
    NSDate *dateNow = [[NSDate alloc] init];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:NSCalendarUnitYear fromDate:dateNow];
    
    NSMutableArray *arrayYear = [[NSMutableArray alloc] init];
    for (NSInteger i = ([comps year] + diff); i > ([comps year] - range); i--) {
        NSString *year = [NSString stringWithFormat:@"%ld", i];
        [arrayYear addObject:[[NSDictionary alloc] initWithObjectsAndKeys:year, @"id", [NSString stringWithFormat:@"%@年", year], @"value", nil]];
    }
    return arrayYear;
}

- (NSArray *)setArrayMonth {
    NSMutableArray *arrayMonth = [[NSMutableArray alloc] init];
    for (NSInteger i = 1; i < 13; i++) {
        NSString *month = [NSString stringWithFormat:@"%ld", i];
        [arrayMonth addObject:[[NSDictionary alloc] initWithObjectsAndKeys:month, @"id", [NSString stringWithFormat:@"%@月", month], @"value", nil]];
    }
    return arrayMonth;
}

- (void)updatePickerArray:(NSString *)parentId inComponent:(NSInteger)component {
    NSString *sqlString;
    if (self.pickerType == WKPickerTypeMajor) {
        sqlString = [NSString stringWithFormat:@"SELECT * FROM dcMajor WHERE ParentId = %@ ORDER BY CASE _id WHEN 1106 THEN 1 WHEN 1000 THEN 2 ELSE 0 END, _id", parentId];
        [self querySql:sqlString index:1];
    }
    else if (self.pickerType == WKPickerTypeIndustry) {
        sqlString = [NSString stringWithFormat:@"SELECT * FROM dcIndustry WHERE ParentId = %@ ORDER BY OrderNo", parentId];
        [self querySql:sqlString index:1];
    }
    else if (self.pickerType == WKPickerTypeJobType) {
        sqlString = [NSString stringWithFormat:@"SELECT * FROM dcJobType WHERE ParentId = %@ ORDER BY _id", parentId];
        [self querySql:sqlString index:1];
    }
    else if (self.pickerType == WKPickerTypeWorkEndDate) {
        if ([parentId isEqualToString:@"999999"]) {
            [self.arrayData setObject:[[NSMutableArray alloc] init] atIndexedSubscript:1];
        }
        else {
            [self.arrayData setObject:[self setArrayMonth] atIndexedSubscript:1];
        }
    }
    else if (self.pickerType == WKPickerTypeRegionL2 || self.pickerType == WKPickerTypeRegionL3) {
        NSInteger fromIndex = (parentId.length == 2 ? 1 : 2);
        for (NSInteger i = fromIndex; i < (self.pickerType == WKPickerTypeRegionL2 ? 2 : 3); i++) {
            if (i > fromIndex) {
                parentId = [[[self.arrayData objectAtIndex:(i - 1)] objectAtIndex:0] objectForKey:@"id"];
            }
            if (i == 1 && self.pickerType == WKPickerTypeRegionL2 && ([parentId isEqualToString:@"10"] || [parentId isEqualToString:@"11"] || [parentId isEqualToString:@"30"] || [parentId isEqualToString:@"60"])) {
                
                sqlString = @"SELECT * FROM dcRegion WHERE 1 = 2";
            }
            else {
                sqlString = [NSString stringWithFormat:@"SELECT * FROM dcRegion WHERE ParentId = '%@' ORDER BY CASE _id WHEN %@ THEN 0 ELSE _id END", parentId, [USER_DEFAULT stringForKey:@"provinceId"]];
            }
            [self querySql:sqlString index:i];
        }
    }
    else if (self.pickerType == WKPickerTypeJobSalary) {
        if (component == 0) {
            sqlString = [NSString stringWithFormat:@"SELECT * FROM dcSalaryCp WHERE _id > %@", parentId];
            [self querySql:sqlString index:2];
            
            if ([parentId isEqualToString:@"16"]) {
                [self.arrayData setObject:[[NSMutableArray alloc] init] atIndexedSubscript:1];
            }
            else {
                [self.arrayData setObject:[[NSMutableArray alloc] initWithObjects:[[NSDictionary alloc] initWithObjectsAndKeys:@"", @"id", @"至", @"value", nil], nil] atIndexedSubscript:1];
            }
        }
    }
    else if (self.pickerType == WKPickerTypeSearchAge) {
        if (component == 0) {
            NSMutableArray *arrayMax = [[NSMutableArray alloc] init];
            [arrayMax addObject:[[NSDictionary alloc] initWithObjectsAndKeys:@"99", @"id", @"不限", @"value", nil]];
            for (NSInteger i = [parentId integerValue]; i < 61; i++) {
                [arrayMax addObject:[[NSDictionary alloc] initWithObjectsAndKeys:[NSString stringWithFormat:@"%ld", i], @"id", [NSString stringWithFormat:@"%ld岁", i], @"value", nil]];
            }
            [self.arrayData setObject:arrayMax atIndexedSubscript:2];
        }
    }
}

- (void)querySql:(NSString *)sql index:(NSInteger)index {
    NSArray *array = [Common querySql:sql dataBase:self.dataBase];
    [self.arrayData setObject:array atIndexedSubscript:index];
}


#pragma mark --键盘弹出
- (void)keyboardWillChangeFrame:(NSNotification *)notification{
    
    if (![self.viewController isKindOfClass:[[self viewControllerFromStr:@"InterviewViewController"] class]]) {
        return;
    }
    UIView *viewContent = [self viewWithTag:POPVIEWTAG];
    //取出键盘动画的时间
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    //取得键盘最后的frame
    CGRect keyboardFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    //计算控制器的view需要平移的距离
    CGFloat transformY = keyboardFrame.origin.y - VIEW_H(viewContent);
    
    //执行动画
    [UIView animateWithDuration:duration animations:^{
        viewContent.frame = CGRectMake(0, transformY, VIEW_W(viewContent),VIEW_H(viewContent));
    }];
}
#pragma mark --键盘收回
- (void)keyboardDidHide:(NSNotification *)notification{
    
    if (![self.viewController isKindOfClass:[[self viewControllerFromStr:@"InterviewViewController"] class]]) {
        return;
    }
    UIView *viewContent = [self viewWithTag:POPVIEWTAG];
    CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:duration animations:^{
        //执行动画
        [UIView animateWithDuration:duration animations:^{
            [viewContent setFrame:CGRectMake(VIEW_X(viewContent), SCREEN_HEIGHT - VIEW_H(viewContent), VIEW_W(viewContent), VIEW_H(viewContent))];
        }];
    }];
}

- (UIViewController *)viewControllerFromStr:(NSString *)viewcontrollerName{
    ;
    Class aVCClass = NSClassFromString(viewcontrollerName);
    //创建vc对象
    UIViewController * vc = [[aVCClass alloc] init];
    return vc;
}
@end

//
//  PopupView.m
//  wutongguo
//
//  Created by Lucifer on 15-5-11.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "PopupView.h"
#import "CommonFunc.h"
#import "CommonMacro.h"
#import "CustomLabel.h"

@interface PopupView() <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UITableView *Lv1TableView;
@property (nonatomic, strong) UITableView *Lv2TableView;
@property (nonatomic, strong) NSMutableArray *arrLv1Data;
@property (nonatomic, strong) NSMutableArray *arrLv2Data;
@property (nonatomic) float widthForLv1;
@property (nonatomic) NSInteger rowForLv1;
@property (nonatomic, strong) NSArray *arrNoLv2;
@property (nonatomic) BOOL IsGovment;
@property (nonatomic, strong) NSArray *arrSort;
@property (nonatomic, strong) NSArray *arrEducation;
@property (nonatomic, strong) NSArray *arrCompanyKind;
@property (nonatomic, strong) NSArray *arrPushlish;
@property (nonatomic, strong) NSArray *arrTop500;
@property (nonatomic, strong) NSMutableArray *arrComboSelect;

@end

@implementation PopupView

- (id)initWithCity:(UIView *)targetView parentView:(UIView *)parentView required:(BOOL)required {
    CGRect framePopup;
    CGRect frameTarget = [targetView convertRect:targetView.bounds toView:parentView];
    float marginLeft = 0;
    self.rowForLv1 = -1;
    self.arrNoLv2 = @[@"0", @"10", @"11", @"30", @"60", @"90", @"91", @"92", @"93"];
    framePopup.origin.x = marginLeft;
    framePopup.origin.y = frameTarget.origin.y + frameTarget.size.height;
    framePopup.size.width = SCREEN_WIDTH - (framePopup.origin.x * 2);
    framePopup.size.height = SCREEN_HEIGHT - framePopup.origin.y;
    self = [super initWithFrame:framePopup];

    //添加底层关闭
    UIButton *viewClose = [[UIButton alloc] initWithFrame:CGRectMake(0 - marginLeft, VIEW_H(self) - TAB_TAB_HEIGHT, VIEW_W(self) + (marginLeft * 2), TAB_TAB_HEIGHT)];
    [viewClose setBackgroundColor:UIColorWithRGBA(0, 0, 0, 0.6)];
    [viewClose addTarget:self action:@selector(arrowTap) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *imgClose = [[UIImageView alloc] initWithFrame:CGRectMake((VIEW_W(viewClose) - 36) / 2, 9, 36, 30)];
    [imgClose setImage:[UIImage imageNamed:@"coArrowClose.png"]];
    [viewClose addSubview:imgClose];
    [self addSubview:viewClose];
    //添加省份tableView
    self.Lv1TableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, VIEW_W(self), VIEW_H(self) - TAB_TAB_HEIGHT)];
    
    self.widthForLv1 = self.Lv1TableView.frame.size.width;
    self.Lv1TableView.delegate = self;
    self.Lv1TableView.dataSource = self;
    self.Lv1TableView.tag = 0;
    [self.Lv1TableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.Lv1TableView setBackgroundColor:UIColorWithRGBA(232, 240, 240, 1)];
    [self addSubview:self.Lv1TableView];
    self.arrLv1Data = (NSMutableArray *)[CommonFunc getDataFromDB:[NSString stringWithFormat:@"select * from dcRegion where parentid = '' order by case _id when %@ then 0 else orderno end", [[USER_DEFAULT objectForKey:@"regionId"] substringToIndex:2]]];
    if (!required) {
        [self.arrLv1Data insertObject:[NSDictionary dictionaryWithObjectsAndKeys:@"0", @"id", @"不限", @"name", nil] atIndex:0];
    }
    //添加城市tableView
    self.Lv2TableView = [[UITableView alloc] initWithFrame:CGRectMake(VIEW_BX(self.Lv1TableView), VIEW_Y(self.Lv1TableView), VIEW_W(self) / 1.8, VIEW_H(self) - TAB_TAB_HEIGHT)];
    self.Lv2TableView.delegate = self;
    self.Lv2TableView.dataSource = self;
    self.Lv2TableView.tag = 1;
    [self.Lv2TableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.Lv2TableView setBackgroundColor:UIColorWithRGBA(250, 251, 251, 1)];
    [self addSubview:self.Lv2TableView];
    //添加上边框
    UIView *separateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, VIEW_W(self), 1)];
    [separateView setBackgroundColor:NAVBARCOLOR];
    [self addSubview:separateView];
    UIImageView *arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_X(targetView) + (VIEW_W(targetView) / 2) - 11, -11, 22, 12)];
    [arrowView setImage:[UIImage imageNamed:@"applyUpArrow.png"]];
    [self addSubview:arrowView];
    [self PopupAnimate];
    return self;
}

- (id)initWithArray:(UIView *)targetView parentView:(UIView *)parentView array:(NSArray *)array required:(BOOL)required {
    CGRect framePopup;
    CGRect frameTarget = [targetView convertRect:targetView.bounds toView:parentView];
    float marginLeft = 0;
    self.rowForLv1 = -1;
    framePopup.origin.x = marginLeft;
    framePopup.origin.y = frameTarget.origin.y + frameTarget.size.height;
    framePopup.size.width = SCREEN_WIDTH - (framePopup.origin.x * 2);
    framePopup.size.height = SCREEN_HEIGHT - framePopup.origin.y;
    self = [super initWithFrame:framePopup];
    
    //添加底层关闭
    UIButton *viewClose = [[UIButton alloc] initWithFrame:CGRectMake(0 - marginLeft, VIEW_H(self) - TAB_TAB_HEIGHT, VIEW_W(self) + (marginLeft * 2), TAB_TAB_HEIGHT)];
    [viewClose setBackgroundColor:UIColorWithRGBA(0, 0, 0, 0.6)];
    [viewClose addTarget:self action:@selector(arrowTap) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *imgClose = [[UIImageView alloc] initWithFrame:CGRectMake((VIEW_W(viewClose) - 36) / 2, 9, 36, 30)];
    [imgClose setImage:[UIImage imageNamed:@"coArrowClose.png"]];
    [viewClose addSubview:imgClose];
    [self addSubview:viewClose];
    //添加行业tableView
    self.Lv1TableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, VIEW_W(self), VIEW_H(self) - TAB_TAB_HEIGHT)];
    self.widthForLv1 = self.Lv1TableView.frame.size.width;
    self.Lv1TableView.delegate = self;
    self.Lv1TableView.dataSource = self;
    self.Lv1TableView.tag = 2;
    [self.Lv1TableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.Lv1TableView setBackgroundColor:UIColorWithRGBA(232, 240, 240, 1)];
    [self addSubview:self.Lv1TableView];
    self.arrLv1Data = [array mutableCopy];
    if (!required) {
        [self.arrLv1Data insertObject:[NSDictionary dictionaryWithObjectsAndKeys:@"0", @"id", @"不限", @"name", nil] atIndex:0];
    }
    //添加上边框
    UIView *separateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, VIEW_W(self), 1)];
    [separateView setBackgroundColor:NAVBARCOLOR];
    [self addSubview:separateView];
    UIImageView *arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_X(targetView) + (VIEW_W(targetView) / 2) - 11, -11, 22, 12)];
    [arrowView setImage:[UIImage imageNamed:@"applyUpArrow.png"]];
    [self addSubview:arrowView];
    [self PopupAnimate];
    return self;
}

- (id)initWithMajor:(UIView *)targetView parentView:(UIView *)parentView required:(BOOL)required {
    CGRect framePopup;
    CGRect frameTarget = [targetView convertRect:targetView.bounds toView:parentView];
    float marginLeft = 0;
    self.rowForLv1 = -1;
    self.arrNoLv2 = @[@"0"];
    framePopup.origin.x = marginLeft;
    framePopup.origin.y = frameTarget.origin.y + frameTarget.size.height;
    framePopup.size.width = SCREEN_WIDTH - (framePopup.origin.x * 2);
    framePopup.size.height = SCREEN_HEIGHT - framePopup.origin.y;
    self = [super initWithFrame:framePopup];
    
    //添加底层关闭
    UIButton *viewClose = [[UIButton alloc] initWithFrame:CGRectMake(0 - marginLeft, VIEW_H(self) - TAB_TAB_HEIGHT, VIEW_W(self) + (marginLeft * 2), TAB_TAB_HEIGHT)];
    [viewClose setBackgroundColor:UIColorWithRGBA(0, 0, 0, 0.6)];
    [viewClose addTarget:self action:@selector(arrowTap) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *imgClose = [[UIImageView alloc] initWithFrame:CGRectMake((VIEW_W(viewClose) - 36) / 2, 9, 36, 30)];
    [imgClose setImage:[UIImage imageNamed:@"coArrowClose.png"]];
    [viewClose addSubview:imgClose];
    [self addSubview:viewClose];
    //添加专业一级tableView
    self.Lv1TableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, VIEW_W(self), VIEW_H(self) - TAB_TAB_HEIGHT)];
    self.widthForLv1 = self.Lv1TableView.frame.size.width;
    self.Lv1TableView.delegate = self;
    self.Lv1TableView.dataSource = self;
    self.Lv1TableView.tag = 4;
    [self.Lv1TableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.Lv1TableView setBackgroundColor:UIColorWithRGBA(232, 240, 240, 1)];
    [self addSubview:self.Lv1TableView];
    self.arrLv1Data = (NSMutableArray *)[CommonFunc getDataFromDB:@"select * from dcMajor where parentid is null ORDER BY CategoryOrderNo"];
    if (!required) {
        [self.arrLv1Data insertObject:[NSDictionary dictionaryWithObjectsAndKeys:@"0", @"id", @"不限", @"name", nil] atIndex:0];
    }
    //添加专业二级tableView
    self.Lv2TableView = [[UITableView alloc] initWithFrame:CGRectMake(VIEW_BX(self.Lv1TableView), VIEW_Y(self.Lv1TableView), VIEW_W(self) / 1.8, VIEW_H(self) - TAB_TAB_HEIGHT)];
    self.Lv2TableView.delegate = self;
    self.Lv2TableView.dataSource = self;
    self.Lv2TableView.tag = 5;
    [self.Lv2TableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.Lv2TableView setBackgroundColor:UIColorWithRGBA(250, 251, 251, 1)];
    [self addSubview:self.Lv2TableView];
    //添加上边框
    UIView *separateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, VIEW_W(self), 1)];
    [separateView setBackgroundColor:NAVBARCOLOR];
    [self addSubview:separateView];
    UIImageView *arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_X(targetView) + (VIEW_W(targetView) / 2) - 11, -11, 22, 12)];
    [arrowView setImage:[UIImage imageNamed:@"applyUpArrow.png"]];
    [self addSubview:arrowView];
    [self PopupAnimate];
    return self;
}

- (id)initWithCombo:(UIView *)targetView parentView:(UIView *)parentView IsGov:(BOOL)IsGov {
    self.IsGovment = IsGov;
    CGRect framePopup;
    CGRect frameTarget = [targetView convertRect:targetView.bounds toView:parentView];
    float marginLeft = 0;
    self.rowForLv1 = -1;
    framePopup.origin.x = marginLeft;
    framePopup.origin.y = frameTarget.origin.y + frameTarget.size.height;
    framePopup.size.width = SCREEN_WIDTH - (framePopup.origin.x * 2);
    framePopup.size.height = SCREEN_HEIGHT - framePopup.origin.y;
    self = [super initWithFrame:framePopup];
    
    //添加底层关闭
    UIButton *viewClose = [[UIButton alloc] initWithFrame:CGRectMake(0 - marginLeft, VIEW_H(self) - TAB_TAB_HEIGHT, VIEW_W(self) + (marginLeft * 2), TAB_TAB_HEIGHT)];
    [viewClose setBackgroundColor:UIColorWithRGBA(0, 0, 0, 0.6)];
    [viewClose addTarget:self action:@selector(arrowTap) forControlEvents:UIControlEventTouchUpInside];
    UIImageView *imgClose = [[UIImageView alloc] initWithFrame:CGRectMake((VIEW_W(viewClose) - 36) / 2, 9, 36, 30)];
    [imgClose setImage:[UIImage imageNamed:@"coArrowClose.png"]];
    [viewClose addSubview:imgClose];
    [self addSubview:viewClose];
    //添加组合搜索tableView
    self.Lv1TableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, VIEW_W(self), VIEW_H(self) - TAB_TAB_HEIGHT * 2)];
    self.widthForLv1 = self.Lv1TableView.frame.size.width;
    self.Lv1TableView.delegate = self;
    self.Lv1TableView.dataSource = self;
    self.Lv1TableView.tag = 3;
    [self.Lv1TableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.Lv1TableView setBackgroundColor:UIColorWithRGBA(232, 240, 240, 1)];
    [self addSubview:self.Lv1TableView];
    self.arrLv1Data = [[NSMutableArray alloc] init];
    [self.arrLv1Data addObject:@"0显示顺序"];
    [self.arrLv1Data addObject:@"1企业性质"];
    [self.arrLv1Data addObject:@"2学历要求"];
    [self.arrLv1Data addObject:@"3截止时间"];
    [self.arrLv1Data addObject:@"4500强"];
    self.arrSort = [NSArray arrayWithObjects:@"5最新发布时间排序", @"5网申截止时间排序", nil];
    if (IsGov) { //政府招考
        self.arrCompanyKind = [NSArray arrayWithObjects:@"6不限", @"6行政机关", @"6事业单位", @"6非盈利机构", @"6社会团体", nil];
    }
    else {
        self.arrCompanyKind = [NSArray arrayWithObjects:@"6不限", @"6中央省属国有企业", @"6地方国有企业", @"6外资企业", @"6中外合资企业", @"6行政机关", @"6事业单位", @"6民营企业", @"6股份制企业" , @"6非盈利机构", @"6社会团体", @"6其他", nil];
    }
    self.arrEducation = [NSArray arrayWithObjects:@"7不限", @"7大专", @"7本科", @"7双学士", @"7硕士研究生", @"7博士研究生", @"7MBA", nil];
    self.arrPushlish = [NSArray arrayWithObjects:@"8不限", @"8今天", @"8明天", @"8后天", @"8本周", @"8下周", @"8本月", @"8下个月", nil];
    self.arrTop500 = [NSArray arrayWithObjects:@"9不限", @"9财富世界500强", @"9财富中国500强", @"9中国企业500强", @"9中国民营企业500强", nil];
    self.arrComboSelect = [NSMutableArray arrayWithObjects:@"50", @"60", @"70", @"80", @"90", nil];
    //添加确认按钮
    UIView *viewConfirm = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_BY(self.Lv1TableView), VIEW_W(self), TAB_TAB_HEIGHT)];
    [viewConfirm setBackgroundColor:UIColorWithRGBA(232, 240, 240, 1)];
    UIButton *btnConfirm = [[UIButton alloc] initWithFrame:CGRectMake(10, 5, VIEW_W(viewConfirm) - 20, VIEW_H(viewConfirm) - 10)];
    [btnConfirm setBackgroundColor:NAVBARCOLOR];
    [btnConfirm setTitle:@"确认" forState:UIControlStateNormal];
    [btnConfirm setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnConfirm.layer setMasksToBounds:YES];
    [btnConfirm.layer setCornerRadius:2];
    [btnConfirm addTarget:self action:@selector(comboValueSave) forControlEvents:UIControlEventTouchUpInside];
    [viewConfirm addSubview:btnConfirm];
    [self addSubview:viewConfirm];
    //添加上边框
    UIView *separateView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, VIEW_W(self), 1)];
    [separateView setBackgroundColor:NAVBARCOLOR];
    [self addSubview:separateView];
    UIImageView *arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_X(targetView) + (VIEW_W(targetView) / 2) - 11, -11, 22, 12)];
    [arrowView setImage:[UIImage imageNamed:@"applyUpArrow.png"]];
    [self addSubview:arrowView];
    [self PopupAnimate];
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)popupClose {
    [self removeFromSuperview];
}

- (void)arrowTap {
    [self.delegate closePopupWhenTapArrow];
    [self popupClose];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == 0 || tableView.tag == 2 || tableView.tag == 3 || tableView.tag == 4) {
        return self.arrLv1Data.count;
    }
    else {
        return self.arrLv2Data.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellView"];
    for(UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellView"];
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (tableView.tag == 0 || tableView.tag == 4) {
        [cell setTag:[self.arrLv1Data[indexPath.row][@"id"] intValue]];
        //文字
        CustomLabel *lbTitle = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(10, 13, 200, 20) content:self.arrLv1Data[indexPath.row][@"name"] size:14 color:nil];
        [cell.contentView addSubview:lbTitle];
        //箭头
        if ([self.arrNoLv2 indexOfObject:[NSString stringWithFormat:@"%ld", (long)cell.tag]] == NSNotFound) {
            UIImageView *imgArrow = [[UIImageView alloc] initWithFrame:CGRectMake(self.widthForLv1 - 20, 15, 8, 15)];
            [imgArrow setImage:[UIImage imageNamed:@"coLeftArrow.png"]];
            [cell.contentView addSubview:imgArrow];
        }
        //选中样式
        if (self.rowForLv1 == indexPath.row) {
            [self highLightCell:cell];
        }
    }
    else if (tableView.tag == 1 || tableView.tag == 5) {
        CustomLabel *lbTitle = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(10, 13, 200, 20) content:self.arrLv2Data[indexPath.row][@"name"] size:14 color:nil];
        [cell.contentView addSubview:lbTitle];
        [cell setTag:[self.arrLv2Data[indexPath.row][@"id"] intValue]];
    }
    else if (tableView.tag == 2) {
        CustomLabel *lbTitle = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(10, 13, SCREEN_WIDTH - 20, 20) content:self.arrLv1Data[indexPath.row][@"name"] size:14 color:nil];
        [cell.contentView addSubview:lbTitle];
        [cell setTag:[self.arrLv1Data[indexPath.row][@"id"] intValue]];
        if (self.rowForLv1 == indexPath.row) {
            [lbTitle setTextColor:NAVBARCOLOR];
        }
    }
    else if (tableView.tag == 3) {
        NSString *cellType = [self.arrLv1Data[indexPath.row] substringToIndex:1];
        [cell setTag:[cellType intValue]];
        NSArray *arrCurrent = [self getCurrentArr:cell.tag];
        if (cell.tag > 4) { //筛选分类
            //分类名称
            [cell setTag:[[NSString stringWithFormat:@"%@%lu", cellType, (unsigned long)[arrCurrent indexOfObject:self.arrLv1Data[indexPath.row]]] intValue]];
            CustomLabel *lbTitle = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(35, 13, 300, 20) content:[self.arrLv1Data[indexPath.row] substringFromIndex:1] size:14 color:([self.arrComboSelect indexOfObject:[NSString stringWithFormat:@"%ld", (long)cell.tag]] == NSNotFound ? nil : NAVBARCOLOR)];
            [cell.contentView addSubview:lbTitle];
            [cell setBackgroundColor:UIColorWithRGBA(241, 246, 246, 1)];
        }
        else { //筛选标题
            //箭头
            UIImageView *imgArrow = [[UIImageView alloc] initWithFrame:CGRectMake(10, 13, 20, 20)];
            [imgArrow setImage:[UIImage imageNamed:([self.arrLv1Data indexOfObject:arrCurrent[0]] == NSNotFound ? @"coDownArrowCircle.png" : @"coUpArrowCircle.png")]];
            [cell.contentView addSubview:imgArrow];
            //标题名称
            CustomLabel *lbTitle = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgArrow) + 5, 13, 100, 20) content:[self.arrLv1Data[indexPath.row] substringFromIndex:1] size:14 color:nil];
            [cell.contentView addSubview:lbTitle];
            //选中值
            CustomLabel *lbValue = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(self.widthForLv1, 13, 200, 20) content:[arrCurrent[[[self.arrComboSelect[cell.tag] substringFromIndex:1] intValue]] substringFromIndex:1] size:14 color:TEXTGRAYCOLOR];
            CGRect frameValue = lbValue.frame;
            frameValue.origin.x = frameValue.origin.x - frameValue.size.width - 10;
            [lbValue setFrame:frameValue];
            [lbValue setTextAlignment:NSTextAlignmentRight];
            [cell.contentView addSubview:lbValue];
        }
        [cell.contentView addSubview:[[CustomLabel alloc] initSeparate:cell.contentView]];
        if (self.IsGovment && cell.tag == 4) {
            [cell setHidden:YES];
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 46;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.rowForLv1 = indexPath.row;
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (tableView.tag == 0 || tableView.tag == 4) {
        //显示二级
        if ([self.arrNoLv2 indexOfObject:[NSString stringWithFormat:@"%ld", (long)cell.tag]] == NSNotFound) {
            [tableView beginUpdates];
            [self highLightCell:cell];
            [tableView endUpdates];
            [self popupLv2Table:tableView dictionaryId:cell.tag];
        }
        else {
            [self valueSave:self.arrLv1Data[indexPath.row]];
        }
    }
    else if (tableView.tag == 1 || tableView.tag == 5) {
        [self valueSave:self.arrLv2Data[indexPath.row]];
    }
    else if (tableView.tag == 2) {
        [self valueSave:self.arrLv1Data[indexPath.row]];
    }
    else if (tableView.tag == 3) {
        NSInteger posForArr = 0;
        if (cell.tag > 4) {
            posForArr = [[[NSString stringWithFormat:@"%ld", (long)cell.tag] substringToIndex:1] intValue] - 5;
            self.arrComboSelect[posForArr] = [NSString stringWithFormat:@"%ld", (long)cell.tag];
        }
        else {
            posForArr = cell.tag;
        }
        NSArray *arrCurrent = [self getCurrentArr:posForArr];
        if ([self.arrLv1Data indexOfObject:arrCurrent[0]] == NSNotFound) {
            [self.arrLv1Data removeAllObjects];
            [self.arrLv1Data addObject:@"0显示顺序"];
            [self.arrLv1Data addObject:@"1企业性质"];
            [self.arrLv1Data addObject:@"2学历要求"];
            [self.arrLv1Data addObject:@"3截止时间"];
            [self.arrLv1Data addObject:@"4500强"];
            [self.arrLv1Data insertObjects:arrCurrent atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(posForArr + 1, arrCurrent.count)]];
        }
        else {
            [self.arrLv1Data removeObjectsInArray:arrCurrent];
        }
        [self.Lv1TableView reloadData];
    }
}

- (void)highLightCell:(UITableViewCell *)cell {
    UIView *selectView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, VIEW_H(cell))];
    [selectView setBackgroundColor:NAVBARCOLOR];
    [cell.contentView addSubview:selectView];
    [cell setBackgroundColor:UIColorWithRGBA(250, 251, 251, 1)];
}

- (void)popupLv2Table:(UITableView *)tableView dictionaryId:(NSInteger)dictionaryId {
    NSString *sql = @"";
    if (tableView.tag == 0) {
        sql = [NSString stringWithFormat:@"select * from dcRegion where parentid = %ld or _id = %ld order by _id", (long)dictionaryId, (long)dictionaryId];
    }
    else {
        sql = [NSString stringWithFormat:@"select * from dcMajor where parentid = %ld or _id = %ld order by CategoryOrderNo", (long)dictionaryId, (long)dictionaryId];
    }
    self.arrLv2Data = (NSMutableArray *)[CommonFunc getDataFromDB:sql];
    NSMutableDictionary *parentItem = [[self.arrLv2Data objectAtIndex:0] mutableCopy];
    [parentItem setValue:[NSString stringWithFormat:@"%@全部", [parentItem objectForKey:@"name"]] forKey:@"name"];
    [self.arrLv2Data replaceObjectAtIndex:0 withObject:parentItem];
    [self.Lv2TableView reloadData];
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frameLv1 = self.Lv1TableView.frame;
        frameLv1.size.width = VIEW_W(self) - VIEW_W(self.Lv2TableView);
        [self.Lv1TableView setFrame:frameLv1];
        self.widthForLv1 = self.Lv1TableView.frame.size.width;
        CGRect frameCity = self.Lv2TableView.frame;
        frameCity.origin.x = VIEW_BX(self.Lv1TableView);
        [self.Lv2TableView setFrame:frameCity];
    } completion:^(BOOL finished) {
        [self.Lv1TableView reloadData];
    }];
}

- (void)valueSave:(NSDictionary *)value {
    [self.delegate itemDidSelected:value];
    [self popupClose];
}

- (void)comboValueSave {
    [self.delegate itemDidSelected:self.arrComboSelect];
    [self popupClose];
}

- (NSArray *)getCurrentArr:(NSInteger)cellType {
    if (cellType > 4) {
        cellType = cellType - 5;
    }
    if (cellType == 0) {
        return self.arrSort;
    }
    else if (cellType == 1) {
        return self.arrCompanyKind;
    }
    else if (cellType == 2) {
        return self.arrEducation;
    }
    else if (cellType == 3) {
        return self.arrPushlish;
    }
    else if (cellType == 4) {
        return self.arrTop500;
    }
    return nil;
}

- (void)PopupAnimate {
    self.alpha = 0;
    CGRect frameView = self.frame;
    float yView = frameView.origin.y;
    frameView.origin.y = SCREEN_HEIGHT;
    [self setFrame:frameView];
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 100;
        CGRect frameViewNew = self.frame;
        frameViewNew.origin.y = yView;
        [self setFrame:frameViewNew];
    }];
}

- (void)setDefaultWithLv2:(NSString *)value type:(popupType)type {
    if (value.length == 0 || [value isEqualToString:@"0"]) {
        return;
    }
    NSString *parentValue = @"";
    NSInteger rowForCell;
    if (type == popupTypeWithRegion) {
        parentValue = [value substringToIndex:2];
    }
    else if (type == popupTypeWithMajor) {
        NSArray *arrMajor = [CommonFunc getDataFromDB:[NSString stringWithFormat:@"select * from dcMajor where _id in(select parentid from dcMajor where _id = %@) ORDER BY CategoryOrderNo", value]];
        parentValue = arrMajor.count == 0 ? value : [[arrMajor objectAtIndex:0] objectForKey:@"id"];
    }
    rowForCell = [self getRowForCell:parentValue];
    if (rowForCell > -1) {
        self.rowForLv1 = rowForCell;
        [self.Lv1TableView reloadData];
        [self.Lv1TableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rowForCell inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        if (type == popupTypeWithRegion && [self.arrNoLv2 indexOfObject:parentValue] != NSNotFound) {
            
        }
        else {
            [self popupLv2Table:self.Lv1TableView dictionaryId:[parentValue intValue]];
            UITableViewCell *cell = [self.Lv2TableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self getRowForCellLv2:value] inSection:0]];
            if (cell == nil) {
                return;
            }
            for (UIView *view in cell.contentView.subviews) {
                if ([view isKindOfClass:[CustomLabel class]]) {
                    CustomLabel *lbTitle = (CustomLabel *)view;
                    [lbTitle setTextColor:NAVBARCOLOR];
                    break;
                }
            }
        }
    }
}

- (void)setDefaultWithLv1:(NSString *)value {
    NSInteger rowForCell = [self getRowForCell:value];
    if (rowForCell > -1) {
        self.rowForLv1 = rowForCell;
        [self.Lv1TableView reloadData];
        [self.Lv1TableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:rowForCell inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
    }
}

- (void)setDefaultWithCombo:(NSArray *)value {
    self.arrComboSelect = [NSMutableArray arrayWithObjects:
                           [NSString stringWithFormat:@"5%@", [value objectAtIndex:0]],
                           [NSString stringWithFormat:@"6%@", [value objectAtIndex:1]],
                           [NSString stringWithFormat:@"7%@", [value objectAtIndex:2]],
                           [NSString stringWithFormat:@"8%@", [value objectAtIndex:3]],
                           [NSString stringWithFormat:@"9%@", [value objectAtIndex:4]], nil];
    [self.Lv1TableView reloadData];
}

- (NSInteger)getRowForCell:(NSString *)value {
    NSInteger rowForCell = -1;
    for (NSInteger index = 0; index < self.arrLv1Data.count; index++) {
        NSDictionary *oneValue = [self.arrLv1Data objectAtIndex:index];
        if ([[oneValue objectForKey:@"id"] isEqualToString:value]) {
            rowForCell = index;
            break;
        }
    }
    return rowForCell;
}

- (NSInteger)getRowForCellLv2:(NSString *)value {
    NSInteger rowForCell = -1;
    for (NSInteger index = 0; index < self.arrLv2Data.count; index++) {
        NSDictionary *oneValue = [self.arrLv2Data objectAtIndex:index];
        if ([[oneValue objectForKey:@"id"] isEqualToString:value]) {
            rowForCell = index;
            break;
        }
    }
    return rowForCell;
}

- (id)initWithWechatFocus:(UIView *)targetView {
    self = [super initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    if (self) {
        [self setAlpha:0];
        [self setBackgroundColor:UIColorWithRGBA(0, 0, 0, 0.6)];
        UIImageView *viewRegSuccess = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, (SCREEN_WIDTH) * 0.736)];
        [viewRegSuccess setCenter:targetView.center];
        [viewRegSuccess setImage:[UIImage imageNamed:@"ucRegSuccess.png"]];
        [viewRegSuccess setUserInteractionEnabled:YES];
        [self addSubview:viewRegSuccess];
        //绑定按钮
        UIButton *btnFocus = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_W(viewRegSuccess) * 0.25, VIEW_H(viewRegSuccess) * 0.65, VIEW_W(viewRegSuccess) / 2, VIEW_H(viewRegSuccess) / 5.5)];
        [btnFocus addTarget:self action:@selector(closeWechat) forControlEvents:UIControlEventTouchUpInside];
        [viewRegSuccess addSubview:btnFocus];
        [UIView animateWithDuration:0.5 animations:^{
            [self setAlpha:1];
        }];
    }
    return self;
}

- (void)closeWechat {
    [self popupClose];
}

- (id)initWithWarningAlert:(UIView *)targetView
                     title:(NSString *)title
                   content:(NSString *)content
                     okMsg:(NSString *)okMsg
                 cancelMsg:(NSString *)cancelMsg {
    self = [super initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    if (self) {
        [self setAlpha:0];
        [self setBackgroundColor:UIColorWithRGBA(0, 0, 0, 0.6)];
        CGRect frameContent = CGRectMake(0, 0, SCREEN_WIDTH - 40, 300);
        UIView *viewContent = [[UIView alloc] initWithFrame:frameContent];
        [viewContent setBackgroundColor:[UIColor whiteColor]];
        [viewContent.layer setCornerRadius:5];
        [self addSubview:viewContent];
        CustomLabel *lbTitle = [[CustomLabel alloc] initWithFrame:CGRectMake(15, 20, VIEW_W(viewContent) - 20, 20) content:title size:16 color:NAVBARCOLOR];
        [lbTitle setTextAlignment:NSTextAlignmentCenter];
        [viewContent addSubview:lbTitle];
        UIImageView *imgTips = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_W(viewContent) - 80, VIEW_Y(lbTitle) - 10, 65, 40)];
        [imgTips setImage:[UIImage imageNamed:@"coTipsTitle.png"]];
        [viewContent addSubview:imgTips];
        UILabel *lbSeparate = [[UILabel alloc] initWithFrame:CGRectMake(VIEW_X(lbTitle), VIEW_BY(imgTips), VIEW_W(lbTitle), 0.5)];
        [lbSeparate setBackgroundColor:SEPARATECOLOR];
        [viewContent addSubview:lbSeparate];
        CustomLabel *lbContent = [[CustomLabel alloc] initWithFixed:CGRectMake(VIEW_X(lbTitle), VIEW_BY(lbSeparate) + 15, VIEW_W(lbTitle), 500) content:content size:15 color:nil];
        [viewContent addSubview:lbContent];
        UIButton *btnOk = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_X(lbTitle), VIEW_BY(lbContent) + 25, (VIEW_W(viewContent) - 40) / 2, 40)];
        [btnOk addTarget:self action:@selector(alertConfrim) forControlEvents:UIControlEventTouchUpInside];
        [btnOk setTitle:okMsg forState:UIControlStateNormal];
        [btnOk.titleLabel setFont:FONT(14)];
        [btnOk setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnOk.layer setBorderColor:[SEPARATECOLOR CGColor]];
        [btnOk.layer setBorderWidth:0.5];
        [btnOk.layer setCornerRadius:5];
        [viewContent addSubview:btnOk];
        UIButton *btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_BX(btnOk) + 10, VIEW_Y(btnOk), VIEW_W(btnOk), VIEW_H(btnOk))];
        [btnCancel addTarget:self action:@selector(popupClose) forControlEvents:UIControlEventTouchUpInside];
        [btnCancel setTitle:cancelMsg forState:UIControlStateNormal];
        [btnCancel.titleLabel setFont:FONT(14)];
        [btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnCancel setBackgroundColor:NAVBARCOLOR];
        [btnCancel.layer setCornerRadius:5];
        [viewContent addSubview:btnCancel];
        //设置高度
        frameContent.size.height = VIEW_BY(btnOk) + 12;
        [viewContent setFrame:frameContent];
        [viewContent setCenter:self.center];
        //动画
        [UIView animateWithDuration:0.5 animations:^{
            [self setAlpha:1];
        }];
    }
    return self;
}

- (id)initWithOtherApplyAlert:(UIView *)targetView
                      content:(NSString *)content
                        okMsg:(NSString *)okMsg {
    self = [super initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    if (self) {
        [self setAlpha:0];
        [self setBackgroundColor:UIColorWithRGBA(0, 0, 0, 0.6)];
        CGRect frameContent = CGRectMake(0, 0, SCREEN_WIDTH - 40, 300);
        UIView *viewContent = [[UIView alloc] initWithFrame:frameContent];
        [viewContent setBackgroundColor:[UIColor whiteColor]];
        [viewContent.layer setCornerRadius:5];
        [self addSubview:viewContent];
        UIImageView *imgTips = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 42, 40)];
        [imgTips setImage:[UIImage imageNamed:@"coTipsTitleApply.png"]];
        [viewContent addSubview:imgTips];
        CustomLabel *lbHello = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgTips) + 3, 25, 300, 20) content:@"Hi~同学" size:16 color:NAVBARCOLOR];
        [viewContent addSubview:lbHello];
        CustomLabel *lbTitle = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(lbHello) + 3, VIEW_Y(lbHello), 300, 20) content:@"请按照以下方式进行网申哦~" size:12 color:nil];
        [lbTitle setTextAlignment:NSTextAlignmentLeft];
        [viewContent addSubview:lbTitle];
        
        UIScrollView *scrollContent = [[UIScrollView alloc] initWithFrame:CGRectMake(10, VIEW_BY(imgTips), VIEW_W(viewContent) - 20, SCREEN_HEIGHT * 0.7)];
        [scrollContent setBackgroundColor:UIColorWithRGBA(231, 254, 255, 1.0f)];
        CustomLabel *lbContent = [[CustomLabel alloc] initWithFixed:CGRectMake(10, 15, VIEW_W(scrollContent) - 20, 5000) content:content size:12 color:nil];
        [scrollContent addSubview:lbContent];
        [scrollContent setContentSize:CGSizeMake(VIEW_W(scrollContent), VIEW_BY(lbContent) + 15)];
        if (scrollContent.contentSize.height < scrollContent.frame.size.height) {
            CGRect frameScroll = scrollContent.frame;
            frameScroll.size.height = scrollContent.contentSize.height;
            [scrollContent setFrame:frameScroll];
        }
        [viewContent addSubview:scrollContent];
        CustomLabel *lbTips = [[CustomLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_X(scrollContent), VIEW_BY(scrollContent) + 10, VIEW_W(scrollContent), 50) content:@"已经将该职位放到您“关注的职位”中，需要您在电脑端登录梧桐果完成网申！" size:12 color:[UIColor redColor]];
        [lbTips setTextAlignment:NSTextAlignmentLeft];
        [viewContent addSubview:lbTips];
        UIButton *btnOk = [[UIButton alloc] initWithFrame:CGRectMake((VIEW_W(viewContent) - (VIEW_W(viewContent) - 40) / 2) / 2, VIEW_BY(lbTips) + 10, (VIEW_W(viewContent) - 40) / 2, 35)];
        [btnOk addTarget:self action:@selector(popupClose) forControlEvents:UIControlEventTouchUpInside];
        [btnOk setTitle:okMsg forState:UIControlStateNormal];
        [btnOk.titleLabel setFont:FONT(12)];
        [btnOk setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnOk setBackgroundColor:NAVBARCOLOR];
        [btnOk.layer setCornerRadius:5];
        [viewContent addSubview:btnOk];
        //设置高度
        frameContent.size.height = VIEW_BY(btnOk) + 12;
        [viewContent setFrame:frameContent];
        [viewContent setCenter:self.center];
        //动画
        [UIView animateWithDuration:0.5 animations:^{
            [self setAlpha:1];
        }];
    }
    return self;
}

- (void)alertConfrim {
    [self.delegate popupAlerConfirm];
    [self popupClose];
}

- (id)initWithNoListTips:(UIView *)targetView tipsMsg:(NSString *)tipsMsg {
    if (tipsMsg.length == 0) {
        self = [super initWithFrame:CGRectMake(0, 30, SCREEN_WIDTH - 100, (SCREEN_WIDTH - 100) * 0.517)];
        if (self) {
            UIImageView *imgNoList = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            [imgNoList setImage:[UIImage imageNamed:@"coNoList.png"]];
            [self addSubview:imgNoList];
            [self setCenter:CGPointMake(targetView.center.x, self.center.y)];
        }
    }
    else {
        self = [super initWithFrame:CGRectMake(0, 30, SCREEN_WIDTH, SCREEN_WIDTH)];
        if (self) {
            UIImageView *imgNoList = [[UIImageView alloc] initWithFrame:CGRectMake(50, 0, self.frame.size.width - 100, (self.frame.size.height - 100) * 0.437)];
            [imgNoList setImage:[UIImage imageNamed:@"coNoMsgTips.png"]];
            [self addSubview:imgNoList];
            [self setCenter:CGPointMake(targetView.center.x, self.center.y)];
            CustomLabel *lbTips = [[CustomLabel alloc] initWithFixed:CGRectMake(10, VIEW_BY(imgNoList) + 20, VIEW_W(self) - 20, 200) content:tipsMsg size:14 color:nil];
            NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithData:[tipsMsg dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            [lbTips setAttributedText:attrString];
            [lbTips sizeToFit];
            [lbTips setCenter:CGPointMake(self.center.x, lbTips.center.y)];
            [self addSubview:lbTips];
        }
    }
    return self;
}

@end

//
//  MajorPickerViewController.m
//  wutongguo
//
//  Created by Lucifer on 16/1/14.
//  Copyright © 2016年 Lucifer. All rights reserved.
//

#import "MajorPickerViewController.h"
#import "CommonFunc.h"
#import "CommonMacro.h"
#import "CustomLabel.h"

@interface MajorPickerViewController ()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *Lv1TableView;
@property (nonatomic, strong) UITableView *Lv2TableView;
@property (nonatomic, strong) NSArray *arrLv1Data;
@property (nonatomic, strong) NSArray *arrLv2Data;
@property NSInteger selectRowIndex;
@end

@implementation MajorPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    // Do any additional setup after loading the view.
    UIBarButtonItem *btnCancel = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelPickerView)];
    [btnCancel setTintColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = btnCancel;
    //添加专业一级tableView
    self.Lv1TableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT)];
    self.Lv1TableView.delegate = self;
    self.Lv1TableView.dataSource = self;
    self.Lv1TableView.tag = 0;
    [self.Lv1TableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.Lv1TableView setBackgroundColor:UIColorWithRGBA(232, 240, 240, 1)];
    [self.view addSubview:self.Lv1TableView];
    self.arrLv1Data = [CommonFunc getDataFromDB:@"select * from dcMajor where parentid is null ORDER BY CategoryOrderNo"];
    //添加专业二级tableView
    self.Lv2TableView = [[UITableView alloc] initWithFrame:CGRectMake(VIEW_BX(self.Lv1TableView), VIEW_Y(self.Lv1TableView), VIEW_W(self.Lv1TableView), VIEW_H(self.Lv1TableView))];
    self.Lv2TableView.delegate = self;
    self.Lv2TableView.dataSource = self;
    self.Lv2TableView.tag = 1;
    [self.Lv2TableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.Lv2TableView setBackgroundColor:UIColorWithRGBA(250, 251, 251, 1)];
    [self.view addSubview:self.Lv2TableView];
    self.selectRowIndex = -1;
    [self.Lv1TableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cancelPickerView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == 0) {
        return self.arrLv1Data.count;
    }
    else {
        return self.arrLv2Data.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellView"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellView"];
    }
    for(UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    [cell setBackgroundColor:[UIColor clearColor]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (tableView.tag == 0) {
        [cell setTag:[self.arrLv1Data[indexPath.row][@"id"] intValue]];
        //文字
        CustomLabel *lbTitle = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(10, 13, 200, 20) content:self.arrLv1Data[indexPath.row][@"name"] size:14 color:nil];
        [cell.contentView addSubview:lbTitle];
        //选中样式
        if (self.selectRowIndex == indexPath.row) {
            [self highLightCell:cell];
        }
    }
    else if (tableView.tag == 1) {
        CustomLabel *lbTitle = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(10, 13, 200, 20) content:self.arrLv2Data[indexPath.row][@"name"] size:14 color:nil];
        [cell.contentView addSubview:lbTitle];
        [cell setTag:[self.arrLv2Data[indexPath.row][@"id"] intValue]];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 46;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (tableView.tag == 0) {
        //显示二级
        self.selectRowIndex = indexPath.row;
        [self popupLv2Table:tableView dictionaryId:cell.tag];
    }
    else if (tableView.tag == 1) {
        NSDictionary *rowData = self.arrLv2Data[indexPath.row];
        [self.btnMajor setTitle:[rowData objectForKey:@"name"] forState:UIControlStateNormal];
        [self.btnMajor setTag:[[rowData objectForKey:@"id"] integerValue]];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)highLightCell:(UITableViewCell *)cell {
    UIView *selectView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, VIEW_H(cell))];
    [selectView setBackgroundColor:NAVBARCOLOR];
    [cell.contentView addSubview:selectView];
    [cell setBackgroundColor:UIColorWithRGBA(250, 251, 251, 1)];
}

- (void)popupLv2Table:(UITableView *)tableView dictionaryId:(NSInteger)dictionaryId {
    self.arrLv2Data = (NSMutableArray *)[CommonFunc getDataFromDB:[NSString stringWithFormat:@"select * from dcMajor where parentid = %ld ORDER BY CategoryOrderNo", (long)dictionaryId]];
    [self.Lv2TableView reloadData];
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frameLv2Table = self.Lv2TableView.frame;
        frameLv2Table.origin.x = SCREEN_WIDTH / 2;
        [self.Lv2TableView setFrame:frameLv2Table];
    } completion:^(BOOL finished) {
        [self.Lv1TableView reloadData];
    }];
}

@end

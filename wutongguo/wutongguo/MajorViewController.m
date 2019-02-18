//
//  MajorViewController.m
//  wutongguo
//
//  Created by Lucifer on 15-5-14.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "MajorViewController.h"
#import "CustomLabel.h"
#import "CommonMacro.h"
#import "CommonFunc.h"
#import "JobListViewController.h"

@interface MajorViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *arrMajorLv1;
@property (nonatomic, strong) NSArray *arrMajorLv1Id;
@property (nonatomic) NSInteger selectedSection;
@property (nonatomic, strong) NSArray *arrBgColor;
@end

@implementation MajorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"按专业找工作";
    self.selectedSection = -1;
    self.arrMajorLv1 = @[@"理学", @"工学", @"管理学/经济学", @"文学/艺术学", @"医学/农学", @"哲学/法学/教育"];
    self.arrMajorLv1Id = @[@"6", @"7", @"1,8", @"5,9", @"10,11", @"2,3,4"];
    self.arrBgColor = @[UIColorWithRGBA(123, 186, 249, 1), UIColorWithRGBA(142, 160, 203, 1), UIColorWithRGBA(1, 186, 170, 1), UIColorWithRGBA(255, 114, 119, 1), UIColorWithRGBA(0, 183, 194, 1), UIColorWithRGBA(95, 216, 106, 1)];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.arrMajorLv1.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 11;
    }
    else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellView"];
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    UIView *viewTitle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 46)];
    [viewTitle setBackgroundColor:self.arrBgColor[indexPath.section]];
    UIImageView *imgTitle = [[UIImageView alloc] initWithFrame:CGRectMake(30, 6, 56, 36)];
    [imgTitle setImage:[UIImage imageNamed:[NSString stringWithFormat:@"major%ld.png", indexPath.section + 1]]];
    [viewTitle addSubview:imgTitle];
    CustomLabel *lbTitle = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgTitle) + 5, 13, SCREEN_WIDTH - VIEW_BX(imgTitle) - 50, 20) content:self.arrMajorLv1[indexPath.section] size:15 color:[UIColor whiteColor]];
    [viewTitle addSubview:lbTitle];
    UIImageView *imgArrow = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 40, 17, 20, 12)];
    [imgArrow setImage:[UIImage imageNamed:(self.selectedSection == indexPath.section ? @"majorUpArrow.png" : @"majorDownArrow.png")]];
    [viewTitle addSubview:imgArrow];
    [cell setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 46)];
    if (self.selectedSection == indexPath.section) {
        [cell setFrame:CGRectMake(0, 0, SCREEN_WIDTH, [self fillMajor:indexPath.section titleView:viewTitle cell:cell])];
    }
    [cell.contentView addSubview:viewTitle];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectedSection == indexPath.section) {
        self.selectedSection = -1;
    }
    else {
        NSInteger prevSection = self.selectedSection;
        self.selectedSection = indexPath.section;
        if (prevSection > -1) {
            [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:0 inSection:prevSection],nil] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
//    [tableView reloadData];
    [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (float)fillMajor:(NSInteger)rowIndex titleView:(UIView *)titleView cell:(UITableViewCell *)cell {
    NSArray *arrMajorLv2 = [CommonFunc getDataFromDB:[NSString stringWithFormat:@"SELECT * FROM dcMajor WHERE CategoryID IN (%@) AND ParentID IS NULL ORDER BY CategoryOrderNo", self.arrMajorLv1Id[rowIndex]]];
    float fltY = VIEW_BY(titleView) + 10;
    float fltX = VIEW_X(titleView) + 10;
    float fltMargin = 7;
    float fltWidth = (SCREEN_WIDTH - (VIEW_X(titleView) + 10) * 2 - fltMargin * 2) / 2;
    float fltHeight = 30;
    for (int i = 0; i < arrMajorLv2.count; i++) {
        if (i % 2 == 0) {
            if (i > 0) {
                fltX = VIEW_X(titleView) + 10;
                fltY = fltY + fltHeight + fltMargin;
            }
        }
        else {
            fltX = fltX + fltWidth + fltMargin;
        }
        UIButton *btnMajor = [[UIButton alloc] initWithFrame:CGRectMake(fltX, fltY, fltWidth, fltHeight)];
        [btnMajor setTitle:arrMajorLv2[i][@"name"] forState:UIControlStateNormal];
        [btnMajor setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnMajor setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [btnMajor setContentEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
        [btnMajor.titleLabel setFont:FONT(14)];
        [btnMajor addTarget:self action:@selector(majorClick:) forControlEvents:UIControlEventTouchUpInside];
        [btnMajor setTag:[arrMajorLv2[i][@"id"] intValue]];
        [cell.contentView addSubview:btnMajor];
    }
    fltY = fltY + fltHeight + fltMargin;
    return fltY;
}

- (void)majorClick:(UIButton *)sender {
    NSArray *arrMajor = [CommonFunc getDataFromDB:[NSString stringWithFormat:@"SELECT * FROM dcMajor WHERE _ID = %ld ORDER BY CategoryOrderNo", (long)sender.tag]];
    JobListViewController *jobListCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"jobListView"];
    jobListCtrl.majorId = [[arrMajor objectAtIndex:0] objectForKey:@"id"];
    jobListCtrl.majorName = [[arrMajor objectAtIndex:0] objectForKey:@"name"];
    [self.navigationController pushViewController:jobListCtrl animated:YES];
}

@end

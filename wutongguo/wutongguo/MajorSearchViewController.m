//
//  MajorSearchViewController.m
//  wutongguo
//
//  Created by Lucifer on 2017/3/16.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "MajorSearchViewController.h"
#import "CommonMacro.h"
#import "CommonFunc.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"

@interface MajorSearchViewController ()<UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, NetWebServiceRequestDelegate>

@property (nonatomic, strong) UITextField *txtSearch;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *viewHot;
@property (nonatomic, strong) NSArray *arrMajorData;
@property (nonatomic, strong) NSArray *arrHotData;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;
@end

@implementation MajorSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    self.txtSearch = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 110, 30)];
    [self.txtSearch setDelegate:self];
    [self.txtSearch setFont:[UIFont systemFontOfSize:14]];
    [self.txtSearch setClearButtonMode:UITextFieldViewModeAlways];
    [self.txtSearch setBorderStyle:UITextBorderStyleRoundedRect];
    [self.txtSearch setBackgroundColor:UIColorWithRGBA(1, 219, 168, 1)];
    [self.txtSearch setReturnKeyType:UIReturnKeyDone];
    [self.txtSearch setPlaceholder:@"请输入专业名称"];
    [self.txtSearch setText:self.jobListCtrl.majorName];
    [self.txtSearch setTextColor:[UIColor whiteColor]];
    [self.txtSearch setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    [self.txtSearch addTarget:self action:@selector(seachMajor:) forControlEvents:UIControlEventEditingChanged];
    self.navigationItem.titleView = self.txtSearch;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setHidden:YES];
    [self.view addSubview:self.tableView];
    //[USER_DEFAULT removeObjectForKey:@"MajorHistory"];
    [self getHotData];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrMajorData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellView"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellView"];
    }
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    NSDictionary *dicMajor = [self.arrMajorData objectAtIndex:indexPath.row];
    [cell.textLabel setText:[dicMajor objectForKey:@"Name"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *dicMajor = [self.arrMajorData objectAtIndex:indexPath.row];
    [self searchMajor:[dicMajor objectForKey:@"ID"] majorName:[dicMajor objectForKey:@"Name"]];
}

- (void)seachMajor:(UITextField *)sender {
    if (sender.text.length == 0) {
        [self.viewHot setHidden:NO];
        [self.tableView setHidden:YES];
        return;
    }
    [self.loadingView startAnimating];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"AjaxGetMajor" params:[NSDictionary dictionaryWithObjectsAndKeys:sender.text, @"searchText", @"0", @"language", nil] tag:1];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (void)getHotData {
    if (![CommonFunc checkLogin]) {
        [self fillHot];
        return;
    }
    [self.loadingView startAnimating];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetPaMajor" params:[NSDictionary dictionaryWithObjectsAndKeys:[CommonFunc getPaMainId], @"paMainID", [CommonFunc getCode], @"code", nil] tag:0];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 0) {
        self.arrHotData = [CommonFunc getArrayFromXml:requestData tableName:@"Table"];
        [self fillHot];
    }
    else if (request.tag == 1) {
        [self.viewHot setHidden:YES];
        [self.tableView setHidden:NO];
        [self.loadingView stopAnimating];
        self.arrMajorData = [CommonFunc getArrayFromXml:requestData tableName:@"Table"];
        [self.tableView reloadData];
    }
}

- (void)fillHot {
    self.viewHot = [[UIView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT)];
    [self.view addSubview:self.viewHot];
    float fltY = 15;
    NSArray *arrMajorHistory = [USER_DEFAULT objectForKey:@"MajorHistory"];
    if (arrMajorHistory.count > 0) {
        UILabel *lbHistory = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, SCREEN_WIDTH - 30, 20)];
        [lbHistory setText:@"最近搜索"];
        [lbHistory setFont:FONT(14)];
        [lbHistory setTextColor:TEXTGRAYCOLOR];
        [self.viewHot addSubview:lbHistory];
        fltY = VIEW_BY(lbHistory) + 10;
        float fltX = VIEW_X(lbHistory);
        float fltMargin = 7;
        float fltWidth = (SCREEN_WIDTH - VIEW_X(lbHistory) * 2 - fltMargin * 2) / 3;
        float fltHeight = 30;
        arrMajorHistory = [[arrMajorHistory reverseObjectEnumerator] allObjects];
        for (int i = 0; i < arrMajorHistory.count; i++) {
            NSDictionary *majorData = [arrMajorHistory objectAtIndex:i];
            if (i % 3 == 0) {
                if (i > 0) {
                    fltX = VIEW_X(lbHistory);
                    fltY = fltY + fltHeight + fltMargin;
                }
            }
            else {
                fltX = fltX + fltWidth + fltMargin;
            }
            UIButton *btnHistory = [[UIButton alloc] initWithFrame:CGRectMake(fltX, fltY, fltWidth, fltHeight)];
            [btnHistory setTitle:[majorData objectForKey:@"Name"] forState:UIControlStateNormal];
            [btnHistory setTag:i];
            [btnHistory setBackgroundColor:UIColorWithRGBA(184, 237, 219, 1)];
            [btnHistory setTitleColor:UIColorWithRGBA(84, 84, 84, 1) forState:UIControlStateNormal];
            [btnHistory.titleLabel setFont:FONT(14)];
            [btnHistory.layer setMasksToBounds:YES];
            [btnHistory.layer setCornerRadius:fltWidth/7];
            [btnHistory addTarget:self action:@selector(historyClick:) forControlEvents:UIControlEventTouchUpInside];
            btnHistory.titleLabel.lineBreakMode =  NSLineBreakByTruncatingTail;
            [self.viewHot addSubview:btnHistory];
        }
        fltY = fltY + 45;
    }
    if (self.arrHotData.count > 0) {
        UILabel *lbHot = [[UILabel alloc] initWithFrame:CGRectMake(15, fltY, SCREEN_WIDTH - 30, 20)];
        [lbHot setText:@"猜你想找"];
        [lbHot setFont:FONT(14)];
        [lbHot setTextColor:TEXTGRAYCOLOR];
        [self.viewHot addSubview:lbHot];
        
        fltY = VIEW_BY(lbHot) + 10;
        float fltX = VIEW_X(lbHot);
        float fltMargin = 7;
        float fltWidth = (SCREEN_WIDTH - VIEW_X(lbHot) * 2 - fltMargin * 2) / 3;
        float fltHeight = 30;
        for (int i = 0; i < self.arrHotData.count; i++) {
            NSDictionary *hotData = [self.arrHotData objectAtIndex:i];
            if (i % 3 == 0) {
                if (i > 0) {
                    fltX = VIEW_X(lbHot);
                    fltY = fltY + fltHeight + fltMargin;
                }
            }
            else {
                fltX = fltX + fltWidth + fltMargin;
            }
            UIButton *btnHot = [[UIButton alloc] initWithFrame:CGRectMake(fltX, fltY, fltWidth, fltHeight)];
            [btnHot setTitle:[hotData objectForKey:@"name"] forState:UIControlStateNormal];
            [btnHot setTag:i];
            [btnHot setBackgroundColor:UIColorWithRGBA(184, 237, 219, 1)];
            [btnHot setTitleColor:UIColorWithRGBA(84, 84, 84, 1) forState:UIControlStateNormal];
            [btnHot.titleLabel setFont:FONT(14)];
            [btnHot.layer setMasksToBounds:YES];
            [btnHot.layer setCornerRadius:fltWidth/7];
            [btnHot addTarget:self action:@selector(hotClick:) forControlEvents:UIControlEventTouchUpInside];
            btnHot.titleLabel.lineBreakMode =  NSLineBreakByTruncatingTail;
            [self.viewHot addSubview:btnHot];
        }
        fltY = fltY + 45;
    }
    UIButton *btnClear = [[UIButton alloc] initWithFrame:CGRectMake(15, fltY, SCREEN_WIDTH - 30, 30)];
    [btnClear setTitle:@"清空所选专业" forState:UIControlStateNormal];
    [btnClear setBackgroundColor:NAVBARCOLOR];
    if ([self.jobListCtrl.majorId isEqualToString:@"0"]) {
        [btnClear setHidden:YES];
    }
    [btnClear.titleLabel setFont:FONT(14)];
    [btnClear addTarget:self action:@selector(clearMajor) forControlEvents:UIControlEventTouchUpInside];
    [btnClear.layer setCornerRadius:5];
    [self.viewHot addSubview:btnClear];
    
    CGRect frameHotView = self.viewHot.frame;
    frameHotView.size.height = fltY + 45;
    [self.viewHot setFrame:frameHotView];
}

- (void)hotClick:(UIView *)sender {
    NSDictionary *hodData = [self.arrHotData objectAtIndex:sender.tag];
    [self searchMajor:[hodData objectForKey:@"id"] majorName:[hodData objectForKey:@"name"]];
}

- (void)historyClick:(UIView *)sender {
    NSArray *arrMajorData = [USER_DEFAULT objectForKey:@"MajorHistory"];
    NSDictionary *majorData = [arrMajorData objectAtIndex:sender.tag];
    [self searchMajor:[majorData objectForKey:@"ID"] majorName:[majorData objectForKey:@"Name"]];
}

- (void)clearMajor {
    [self searchMajor:@"0" majorName:@"专业要求"];
}

- (void)searchMajor:(NSString *)majorId majorName:(NSString *)majorName {
    if (![majorId isEqualToString:@"0"]) {
        NSMutableArray *arrMajorHistory = [[USER_DEFAULT objectForKey:@"MajorHistory"] mutableCopy];
        NSDictionary *majorData = [[NSDictionary alloc] initWithObjectsAndKeys:majorId, @"ID", majorName, @"Name", nil];
        if (arrMajorHistory == nil) {
            arrMajorHistory = [[NSMutableArray alloc] init];
        }
        for (NSDictionary *data in arrMajorHistory) {
            if ([[data objectForKey:@"ID"] isEqualToString:majorId]) {
                [arrMajorHistory removeObject:data];
                break;
            }
        }
        [arrMajorHistory addObject:majorData];
        if (arrMajorHistory.count == 7) {
            [arrMajorHistory removeObjectAtIndex:0];
        }
        [USER_DEFAULT setObject:arrMajorHistory forKey:@"MajorHistory"];
    }
    self.jobListCtrl.majorId = majorId;
    self.jobListCtrl.majorName = majorName;
    self.jobListCtrl.lbMajor.text = majorName;
    [self.jobListCtrl getData];
    [self.navigationController popViewControllerAnimated:YES];
}

@end

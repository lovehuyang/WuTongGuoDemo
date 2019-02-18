//
//  CollegeSelectViewController.m
//  wutongguo
//
//  Created by Lucifer on 16/1/18.
//  Copyright © 2016年 Lucifer. All rights reserved.
//

#import "CollegePickerViewController.h"
#import "CommonMacro.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "CommonFunc.h"

@interface CollegePickerViewController ()<UITableViewDataSource, UITableViewDelegate, NetWebServiceRequestDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;
@property (nonatomic, strong) UITextField *txtSearch;
@property (nonatomic, strong) NSArray *keyWordListData;
@end

@implementation CollegePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.navigationController.navigationBar setBarTintColor:NAVBARCOLOR];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-back.png"] style:UIBarButtonItemStyleDone target:self action:@selector(viewClose)];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    self.txtSearch = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 110, 30)];
    [self.txtSearch setDelegate:self];
    [self.txtSearch setFont:[UIFont systemFontOfSize:14]];
    [self.txtSearch setClearButtonMode:UITextFieldViewModeAlways];
    [self.txtSearch setBorderStyle:UITextBorderStyleRoundedRect];
    [self.txtSearch setBackgroundColor:UIColorWithRGBA(1, 219, 168, 1)];
    [self.txtSearch addTarget:self action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self.txtSearch setReturnKeyType:UIReturnKeySearch];
    [self.txtSearch setPlaceholder:@"请输入学校名称"];
    [self.txtSearch setTextColor:[UIColor whiteColor]];
    [self.txtSearch setValue:[UIColor whiteColor] forKeyPath:@"_placeholderLabel.textColor"];
    self.navigationItem.titleView = self.txtSearch;
    //等待动画
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.view addSubview:self.loadingView];
}

- (void)viewClose {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
    return self.keyWordListData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"cellView"];
    NSDictionary *rowData = [self.keyWordListData objectAtIndex:indexPath.row];
    [cell.textLabel setText:[rowData objectForKey:@"Name"]];
    [cell.textLabel setFont:FONT(14)];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.txtSearch resignFirstResponder];
    NSDictionary *rowData = [self.keyWordListData objectAtIndex:indexPath.row];
    [self.btnCollege setTitle:[rowData objectForKey:@"Name"] forState:UIControlStateNormal];
    [self.btnCollege setTag:[[rowData objectForKey:@"ID"] integerValue]];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    self.keyWordListData = [CommonFunc getArrayFromXml:requestData tableName:@"Table"];
    [self.tableView reloadData];
}

- (void)textFieldTextDidChange:(UITextField *)textfield {
    UITextRange *selectedRange = [textfield markedTextRange];
    NSString *newText = [textfield textInRange:selectedRange];
    //获取高亮部分
    if (newText.length>0) {
        return;
    }
    if (textfield.text.length == 0) {
        self.keyWordListData = nil;
        [self.tableView reloadData];
    }
    else {
        NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
        [dicParam setObject:textfield.text forKey:@"KeyWord"];
        [dicParam setObject:@"0" forKey:@"SearchType"];
        self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetCollegeByKeyword" params:dicParam tag:1];
        [self.runningRequest setDelegate:self];
        [self.runningRequest startAsynchronous];
    }
}

@end

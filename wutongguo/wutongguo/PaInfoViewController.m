//
//  PaInfoViewController.m
//  wutongguo
//
//  Created by Lucifer on 16/1/13.
//  Copyright © 2016年 Lucifer. All rights reserved.
//

#import "PaInfoViewController.h"
#import "CommonMacro.h"
#import "CommonFunc.h"
#import "CustomLabel.h"
#import "MajorPickerViewController.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "GDataXMLNode.h"
#import "CollegePickerViewController.h"
#import "Toast+UIView.h"

@interface PaInfoViewController ()<UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, NetWebServiceRequestDelegate>

@property (nonatomic, strong) UITextField *targetText;
@property (nonatomic, strong) UIPickerView *degreePickView;
@property (nonatomic, strong) UIDatePicker *birthPickView;
@property (nonatomic, strong) UIDatePicker *graduationPickView;
@property (nonatomic, strong) UIPickerView *accountPlacePickView;
@property (nonatomic, strong) UIView *viewBirth;
@property (nonatomic, strong) UIView *viewDegree;
@property (nonatomic, strong) UIView *viewAccountPlace;
@property (nonatomic, strong) UIView *viewGraduation;
@property (nonatomic, strong) NSArray *arrEducation;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;
@property (nonatomic, strong) NSArray *arrRegionL1;
@property (nonatomic, strong) NSArray *arrRegionL2;
@property (nonatomic, strong) NSArray *arrRegionL3;
@end

@implementation PaInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"填写基本信息";
    [self.navigationController.navigationBar setBarTintColor:NAVBARCOLOR];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName]];
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-back.png"] style:UIBarButtonItemStyleDone target:self action:@selector(viewClose)];
    self.navigationItem.leftBarButtonItem = leftBarItem;
    //等待动画
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.view addSubview:self.loadingView];
    
    [self.txtName.layer setCornerRadius:5];
    [self.txtMobile.layer setCornerRadius:5];
    [self.btnBirth.layer setCornerRadius:5];
    [self.btnCollege.layer setCornerRadius:5];
    [self.btnDegree.layer setCornerRadius:5];
    [self.btnMajor.layer setCornerRadius:5];
    [self.btnSave.layer setCornerRadius:5];
    UIView *paddingViewName = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.txtName.leftView = paddingViewName;
    self.txtName.leftViewMode = UITextFieldViewModeAlways;
    UIView *paddingViewMobile = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.txtMobile.leftView = paddingViewMobile;
    self.txtMobile.leftViewMode = UITextFieldViewModeAlways;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardWillHideNotification object:nil];
    self.arrEducation = [NSArray arrayWithObjects:@"大专", @"本科", @"双学士", @"硕士研究生", @"博士研究生", nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewClose {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)birthClick:(id)sender {
    [self resignAllText];
    if (self.viewBirth == nil) {
        self.viewBirth = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 230)];
        [self.viewBirth setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:self.viewBirth];
        
        UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeSystem];
        [btnCancel setFrame:CGRectMake(10, 10, 50, 20)];
        [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
        [btnCancel setTag:1];
        [btnCancel addTarget:self action:@selector(cancelPick:) forControlEvents:UIControlEventTouchUpInside];
        [self.viewBirth addSubview:btnCancel];
        
        UIButton *btnOk = [UIButton buttonWithType:UIButtonTypeSystem];
        [btnOk setFrame:CGRectMake(SCREEN_WIDTH - VIEW_W(btnCancel) - 10, VIEW_Y(btnCancel), VIEW_W(btnCancel), VIEW_H(btnCancel))];
        [btnOk setTitle:@"确定" forState:UIControlStateNormal];
        [btnOk setTag:1];
        [btnOk addTarget:self action:@selector(savePicker:) forControlEvents:UIControlEventTouchUpInside];
        [self.viewBirth addSubview:btnOk];
        
        self.birthPickView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 30, SCREEN_WIDTH, 200)];
        [self.birthPickView setDatePickerMode:UIDatePickerModeDate];
        [self.viewBirth addSubview:self.birthPickView];
    }
    CGRect frameViewBirth = self.viewBirth.frame;
    frameViewBirth.origin.y = SCREEN_HEIGHT - 200;
    [UIView animateWithDuration:0.5 animations:^{
        [self.viewBirth setFrame:frameViewBirth];
    }];
}

- (IBAction)accountPlaceClick:(id)sender {
    [self resignAllText];
    if (self.viewAccountPlace == nil) {
        self.viewAccountPlace = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 230)];
        [self.viewAccountPlace setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:self.viewAccountPlace];
        
        UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeSystem];
        [btnCancel setFrame:CGRectMake(10, 10, 50, 20)];
        [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
        [btnCancel setTag:3];
        [btnCancel addTarget:self action:@selector(cancelPick:) forControlEvents:UIControlEventTouchUpInside];
        [self.viewAccountPlace addSubview:btnCancel];
        
        UIButton *btnOk = [UIButton buttonWithType:UIButtonTypeSystem];
        [btnOk setFrame:CGRectMake(SCREEN_WIDTH - VIEW_W(btnCancel) - 10, VIEW_Y(btnCancel), VIEW_W(btnCancel), VIEW_H(btnCancel))];
        [btnOk setTitle:@"确定" forState:UIControlStateNormal];
        [btnOk setTag:3];
        [btnOk addTarget:self action:@selector(savePicker:) forControlEvents:UIControlEventTouchUpInside];
        [self.viewAccountPlace addSubview:btnOk];
        
        self.accountPlacePickView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 30, SCREEN_WIDTH, 200)];
        [self.accountPlacePickView setTag:2];
        [self.accountPlacePickView setDelegate:self];
        [self.accountPlacePickView setDataSource:self];
        [self.viewAccountPlace addSubview:self.accountPlacePickView];
        self.arrRegionL1 = [self getRegionArray:@""];
        [self.accountPlacePickView reloadAllComponents];
        [self pickerView:self.accountPlacePickView didSelectRow:0 inComponent:0];
    }
    CGRect frameViewAccountPlace = self.viewAccountPlace.frame;
    frameViewAccountPlace.origin.y = SCREEN_HEIGHT - 200;
    [UIView animateWithDuration:0.5 animations:^{
        [self.viewAccountPlace setFrame:frameViewAccountPlace];
    }];
}

- (IBAction)collegeClick:(id)sender {
    CollegePickerViewController *collegePickerCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"collegePickerView"];
    collegePickerCtrl.btnCollege = self.btnCollege;
    UINavigationController *navCollegeSelect = [[UINavigationController alloc] initWithRootViewController:collegePickerCtrl];
    [self.navigationController presentViewController:navCollegeSelect animated:YES completion:nil];
}

- (IBAction)graduationClick:(id)sender {
    [self resignAllText];
    if (self.viewGraduation == nil) {
        self.viewGraduation = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 230)];
        [self.viewGraduation setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:self.viewGraduation];
        
        UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeSystem];
        [btnCancel setFrame:CGRectMake(10, 10, 50, 20)];
        [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
        [btnCancel setTag:4];
        [btnCancel addTarget:self action:@selector(cancelPick:) forControlEvents:UIControlEventTouchUpInside];
        [self.viewGraduation addSubview:btnCancel];
        
        UIButton *btnOk = [UIButton buttonWithType:UIButtonTypeSystem];
        [btnOk setFrame:CGRectMake(SCREEN_WIDTH - VIEW_W(btnCancel) - 10, VIEW_Y(btnCancel), VIEW_W(btnCancel), VIEW_H(btnCancel))];
        [btnOk setTitle:@"确定" forState:UIControlStateNormal];
        [btnOk setTag:4];
        [btnOk addTarget:self action:@selector(savePicker:) forControlEvents:UIControlEventTouchUpInside];
        [self.viewGraduation addSubview:btnOk];
        
        self.graduationPickView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 30, SCREEN_WIDTH, 200)];
        [self.graduationPickView setDatePickerMode:UIDatePickerModeDate];
        [self.viewGraduation addSubview:self.graduationPickView];
    }
    CGRect frameViewGraduation = self.viewGraduation.frame;
    frameViewGraduation.origin.y = SCREEN_HEIGHT - 200;
    [UIView animateWithDuration:0.5 animations:^{
        [self.viewGraduation setFrame:frameViewGraduation];
    }];
}

- (void)savePicker:(UIButton *)sender {
    [self cancelPick:sender];
    if (sender.tag == 1) {
        [self.btnBirth setTitle:[CommonFunc stringFromDate:self.birthPickView.date formatType:@"yyyy-MM-dd"] forState:UIControlStateNormal];
        [self.btnBirth setTag:[[CommonFunc stringFromDate:self.birthPickView.date formatType:@"yyyyMMdd"] integerValue]];
    }
    else if (sender.tag == 2) {
        NSInteger selectRow = [self.degreePickView selectedRowInComponent:0];
        [self.btnDegree setTitle:[self.arrEducation objectAtIndex:selectRow] forState:UIControlStateNormal];
        [self.btnDegree setTag:selectRow + 1];
    }
    else if (sender.tag == 3) {
        NSDictionary *regionDataLv1 = [self.arrRegionL1 objectAtIndex:[self.accountPlacePickView selectedRowInComponent:0]];
        NSMutableString *regionString = [[NSMutableString alloc] init];
        [regionString appendString:[regionDataLv1 objectForKey:@"name"]];
        if (self.arrRegionL2.count > 0) {
            NSDictionary *regionDataLv2 = [self.arrRegionL2 objectAtIndex:[self.accountPlacePickView selectedRowInComponent:1]];
            [regionString appendString:[regionDataLv2 objectForKey:@"name"]];
            if (self.arrRegionL3.count > 0) {
                NSDictionary *regionDataLv3 = [self.arrRegionL3 objectAtIndex:[self.accountPlacePickView selectedRowInComponent:2]];
                [regionString appendString:[regionDataLv3 objectForKey:@"name"]];
                [self.btnAccountPlace setTag:[[regionDataLv3 objectForKey:@"id"] integerValue]];
            }
            else {
                [self.btnAccountPlace setTag:[[regionDataLv2 objectForKey:@"id"] integerValue]];
            }
        }
        else {
            [self.btnAccountPlace setTag:[[regionDataLv1 objectForKey:@"id"] integerValue]];
        }
        [self.btnAccountPlace setTitle:regionString forState:UIControlStateNormal];
    }
    else if (sender.tag == 4) {
        [self.btnGraduation setTitle:[CommonFunc stringFromDate:self.graduationPickView.date formatType:@"yyyy-MM-dd"] forState:UIControlStateNormal];
        [self.btnGraduation setTag:[[CommonFunc stringFromDate:self.graduationPickView.date formatType:@"yyyyMMdd"] integerValue]];
    }
}

- (void)cancelPick:(UIButton *)sender {
    UIView *targetView;
    if (sender.tag == 1) {
        targetView = self.viewBirth;
    }
    else if (sender.tag == 2) {
        targetView = self.viewDegree;
    }
    else if (sender.tag == 3) {
        targetView = self.viewAccountPlace;
    }
    else if (sender.tag == 4) {
        targetView = self.viewGraduation;
    }
    CGRect frameView = targetView.frame;
    frameView.origin.y = SCREEN_HEIGHT;
    [UIView animateWithDuration:0.5 animations:^{
        [targetView setFrame:frameView];
    }];
}

- (IBAction)degreeClick:(id)sender {
    [self resignAllText];
    if (self.viewDegree == nil) {
        self.viewDegree = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 230)];
        [self.viewDegree setBackgroundColor:[UIColor whiteColor]];
        [self.view addSubview:self.viewDegree];
        
        UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeSystem];
        [btnCancel setFrame:CGRectMake(10, 10, 50, 20)];
        [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
        [btnCancel setTag:2];
        [btnCancel addTarget:self action:@selector(cancelPick:) forControlEvents:UIControlEventTouchUpInside];
        [self.viewDegree addSubview:btnCancel];
        
        UIButton *btnOk = [UIButton buttonWithType:UIButtonTypeSystem];
        [btnOk setFrame:CGRectMake(SCREEN_WIDTH - VIEW_W(btnCancel) - 10, VIEW_Y(btnCancel), VIEW_W(btnCancel), VIEW_H(btnCancel))];
        [btnOk setTitle:@"确定" forState:UIControlStateNormal];
        [btnOk setTag:2];
        [btnOk addTarget:self action:@selector(savePicker:) forControlEvents:UIControlEventTouchUpInside];
        [self.viewDegree addSubview:btnOk];
        
        self.degreePickView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 30, SCREEN_WIDTH, 200)];
        [self.degreePickView setTag:1];
        [self.degreePickView setDelegate:self];
        [self.degreePickView setDataSource:self];
        [self.viewDegree addSubview:self.degreePickView];
        [self.degreePickView reloadAllComponents];
    }
    CGRect frameViewDegree = self.viewDegree.frame;
    frameViewDegree.origin.y = SCREEN_HEIGHT - 200;
    [UIView animateWithDuration:0.5 animations:^{
        [self.viewDegree setFrame:frameViewDegree];
    }];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (pickerView.tag == 1) {
        return 1;
    }
    else if (pickerView.tag == 2) {
        return 3;
    }
    return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView.tag == 1) {
        return self.arrEducation.count;
    }
    else if (pickerView.tag == 2) {
        if (component == 0) {
            return self.arrRegionL1.count;
        }
        else if (component == 1) {
            return self.arrRegionL2.count;
        }
        else if (component == 2) {
            return self.arrRegionL3.count;
        }
    }
    return 0;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view {
    NSString *content = @"";
    if (pickerView.tag == 1) {
        content = [self.arrEducation objectAtIndex:row];
    }
    else if (pickerView.tag == 2) {
        if (component == 0) {
            content = [[self.arrRegionL1 objectAtIndex:row] objectForKey:@"name"];
        }
        else if (component == 1) {
            content = [[self.arrRegionL2 objectAtIndex:row] objectForKey:@"name"];
        }
        else if (component == 2) {
            content = [[self.arrRegionL3 objectAtIndex:row] objectForKey:@"name"];
        }
    }
    CustomLabel *lbTitle = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(0, 0, SCREEN_WIDTH, 20) content:content size:16 color:nil];
    return lbTitle;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView.tag == 2) {
        if (component == 0) {
            NSDictionary *regionData = [self.arrRegionL1 objectAtIndex:row];
            self.arrRegionL2 = [self getRegionArray:[regionData objectForKey:@"id"]];
            if (self.arrRegionL2.count > 0) {
                self.arrRegionL3 = [self getRegionArray:[[self.arrRegionL2 objectAtIndex:0] objectForKey:@"id"]];
            }
            else {
                self.arrRegionL3 = nil;
            }
        }
        else if (component == 1) {
            NSDictionary *regionData = [self.arrRegionL2 objectAtIndex:row];
            self.arrRegionL3 = [self getRegionArray:[regionData objectForKey:@"id"]];
        }
        [pickerView reloadAllComponents];
        if (component == 0) {
            [pickerView selectRow:0 inComponent:1 animated:YES];
            [pickerView selectRow:0 inComponent:2 animated:YES];
        }
        else if (component == 1) {
            [pickerView selectRow:0 inComponent:2 animated:YES];
        }
    }
}

- (NSArray *)getRegionArray:(NSString *)parentId {
    return [CommonFunc getDataFromDB:[NSString stringWithFormat:@"SELECT * FROM dcRegion WHERE ParentID = '%@' ORDER BY _id", parentId]];
}

- (IBAction)majorClick:(id)sender {
    MajorPickerViewController *majorPickerView = [[MajorPickerViewController alloc] init];
    majorPickerView.btnMajor = self.btnMajor;
    UINavigationController *majorPickerCtrl = [[UINavigationController alloc] initWithRootViewController:majorPickerView];
    [majorPickerCtrl.navigationBar setBarTintColor:NAVBARCOLOR];
    [self.navigationController presentViewController:majorPickerCtrl animated:YES completion:^{
        
    }];
}

- (IBAction)saveClick:(id)sender {
    NSString *name = self.txtName.text;
    NSString *gender = [NSString stringWithFormat:@"%ld", (long)self.segGender.selectedSegmentIndex];
    NSString *birth = [NSString stringWithFormat:@"%ld", (long)self.btnBirth.tag];
    NSString *accountPlace = [NSString stringWithFormat:@"%ld", (long)self.btnAccountPlace.tag];
    NSString *mobile = self.txtMobile.text;
    NSString *college = [NSString stringWithFormat:@"%ld", (long)self.btnCollege.tag];
    NSString *graduation = [NSString stringWithFormat:@"%ld", (long)self.btnGraduation.tag];
    NSString *major = [NSString stringWithFormat:@"%ld", (long)self.btnMajor.tag];
    NSString *degree = [NSString stringWithFormat:@"%ld", (long)self.btnDegree.tag];
    if (name.length == 0) {
        [self.view makeToast:@"请输入姓名"];
        return;
    }
    if ([gender isEqualToString:@"-1"]) {
        [self.view makeToast:@"请选择性别"];
        return;
    }
    if ([birth isEqualToString:@"0"]) {
        [self.view makeToast:@"请选择出生日期"];
        return;
    }
    if ([accountPlace isEqualToString:@"0"]) {
        [self.view makeToast:@"请选择户口所在地"];
        return;
    }
    if ([college isEqualToString:@"0"]) {
        [self.view makeToast:@"请选择毕业院校"];
        return;
    }
    if ([graduation isEqualToString:@"0"]) {
        [self.view makeToast:@"请选择毕业时间"];
        return;
    }
    if ([degree isEqualToString:@"0"]) {
        [self.view makeToast:@"请选择学历"];
        return;
    }
    if ([major isEqualToString:@"0"]) {
        [self.view makeToast:@"请选择专业"];
        return;
    }
    if (mobile.length == 0) {
        [self.view makeToast:@"请输入手机号码"];
        return;
    }
    if (![CommonFunc checkMobileValid:mobile]) {
        [self.view makeToast:@"请输入有效的手机号"];
        return;
    }
    [self.loadingView startAnimating];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"SavePaMainBaseNew" params:[NSDictionary dictionaryWithObjectsAndKeys:
                                    name,    @"Name",
                                    gender,  @"Gender",
                                    birth,   @"BirthDay",
                                    mobile,  @"Mobile",
                                    college, @"SchoolID",
                                    major,   @"dcMajorID",
                                    degree,  @"Degree",
                              accountPlace,  @"AccountPlace",
        self.btnGraduation.titleLabel.text,  @"EndDate",
                  [CommonFunc getPaMainId],  @"paMainID",
                      [CommonFunc getCode],  @"code", nil] tag:1];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1) {
        [USER_DEFAULT setValue:@"1" forKey:@"willApplyJob"];
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.targetText = textField;
    return YES;
}

- (CGFloat)keyboardEndingFrameHeight:(NSDictionary *)userInfo//计算键盘的高度
{
    CGRect keyboardEndingUncorrectedFrame = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect keyboardEndingFrame = [self.view convertRect:keyboardEndingUncorrectedFrame fromView:nil];
    return keyboardEndingFrame.size.height;
}

- (void)keyboardWillAppear:(NSNotification *)notification
{
    CGRect currentFrame = self.view.frame;
    CGFloat change = [self keyboardEndingFrameHeight:[notification userInfo]];
    CGRect frameText = [self.scrollView convertRect:self.targetText.frame toView:self.view];
    if (frameText.origin.y + frameText.size.height + change > SCREEN_HEIGHT) {
        currentFrame.origin.y = 0 - ((frameText.origin.y + frameText.size.height + change) - SCREEN_HEIGHT) - 10;
    }
    self.view.frame = currentFrame;
}

- (void)keyboardWillDisappear:(NSNotification *)notification
{
    CGRect currentFrame = self.view.frame;
    currentFrame.origin.y = 0;
    self.view.frame = currentFrame;
}

- (void)resignAllText {
    [self.txtMobile resignFirstResponder];
    [self.txtName resignFirstResponder];
}
@end

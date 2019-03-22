//
//  UserCenterViewController.m
//  wutongguo
//
//  Created by Lucifer on 15-5-8.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "UserCenterViewController.h"
#import "ApplyLogViewController.h"
#import "ExchangeRoleViewController.h"
#import "AccountManagerViewController.h"
#import "FocusViewController.h"
#import "InformViewController.h"
#import "CompanyNoticeViewController.h"
#import "CommonMacro.h"
#import "CustomLabel.h"
#import "PopupView.h"
#import "NetWebServiceRequest.h"
#import "LoadingAnimationView.h"
#import "CommonFunc.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "MLImageCrop.h"
#import "Toast+UIView.h"
#import "MobileCerViewController.h"
#import "UIImageView+WebCache.h"
#import "CvModifyViewController.h"
#import "MyTalentsTestController.h"
#import "MyOrderListController.h"

@interface UserCenterViewController () <UITableViewDelegate, UITableViewDataSource, NetWebServiceRequestDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MLImageCropDelegate>
{
    BOOL OrderType1;// 1 已开通智能网申
    BOOL OrderType2;// 1 已开通应聘优先
}
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) LoadingAnimationView *loadingView;
@property (nonatomic, strong) NSArray *arrTitle;
@property (nonatomic, strong) NSArray *titleImgArr;
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UIButton *btnPhoto;
@end

@implementation UserCenterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    OrderType1 = NO;
    OrderType2 = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.loadingView = [[LoadingAnimationView alloc] initLoading];
    [self.view addSubview:self.loadingView];

    self.arrTitle = @[@[ @"我的申请表", @"网申记录", @"企业通知", @"我的关注"], @[@"我的订单",@"网站消息", @"账户管理", @"我的测评",@"我要反馈", @"应用分享",@"切换身份"]];
    self.titleImgArr = @[@[ @"ucButton1", @"ucButton2", @"ucButton3", @"ucButton4"], @[@"ucButton11",@"ucButton5", @"ucButton6", @"ucButton9" ,@"ucButton7", @"ucButton8",@"ucButton10"]];
    //头部的视图
    self.titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100)];
    [self.titleView setBackgroundColor:[UIColor colorWithPatternImage: [UIImage imageNamed:@"ucIndexBg.png"]]];
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 80, SCREEN_WIDTH, 20)];
    [bgView setBackgroundColor:UIColorWithRGBA(247, 250, 250, 1)];
    [self.titleView addSubview:bgView];
    //头像，可点击上传头像
    self.btnPhoto = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 45, 20, 90, 90)];
    [self.btnPhoto setImage:[UIImage imageNamed:@"loginTitle.png"] forState:UIControlStateNormal];
    [self.btnPhoto addTarget:self action:@selector(photoClick:) forControlEvents:UIControlEventTouchUpInside];
    self.btnPhoto.layer.masksToBounds = YES;
    self.btnPhoto.layer.cornerRadius = 45;
    self.btnPhoto.layer.borderColor = [UIColorWithRGBA(122.0f, 122.0f, 122.0f, 0.3f) CGColor];
    self.btnPhoto.layer.borderWidth = 5.0f;
    [self.titleView addSubview:self.btnPhoto];
    //照相机图标
    self.imgCamera = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_BX(self.btnPhoto) - 30, VIEW_BY(self.btnPhoto) - 30, 25, 25)];
    [self.imgCamera setImage:[UIImage imageNamed:@"ucCamera.png"]];
    [self.titleView addSubview:self.imgCamera];
    //设置按钮
    UIButton *btnSetting = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 40, 35, 25, 25)];
    [btnSetting setImage:[UIImage imageNamed:@"ucOption.png"] forState:UIControlStateNormal];
    [btnSetting addTarget:self action:@selector(settingClick) forControlEvents:UIControlEventTouchUpInside];
    [self.titleView addSubview:btnSetting];
    UIView *viewPhotoSelect = [self.viewPhoto.subviews objectAtIndex:0];
    [viewPhotoSelect.layer setMasksToBounds:YES];
    [viewPhotoSelect.layer setCornerRadius:5];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self.viewUser setHidden:YES];
    [self.btnLogin setHidden:NO];
    if ([CommonFunc checkLogin]) {
        [self.imgCamera setHidden:NO];
        //[self.loadingView startAnimating];
        self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetPaMainInfoByID" params:[NSDictionary dictionaryWithObjectsAndKeys:[USER_DEFAULT objectForKey:@"paMainId"], @"paMainID", [USER_DEFAULT objectForKey:@"code"], @"code", nil] tag:1];
        [self.runningRequest setDelegate:self];
        [self.runningRequest startAsynchronous];
    }
    else {
        [self.navigationController.view addSubview:self.titleView];
        [self.imgCamera setHidden:YES];
        [self.btnPhoto setImage:[UIImage imageNamed:@"loginTitle.png"] forState:UIControlStateNormal];
        [self.lbMobileCer setText:@"手机未认证"];
        [self.lbMobileCer setTextColor:NAVBARCOLOR];
        [self.imgMobileCer setImage:[UIImage imageNamed:@"ucMobile.png"]];
        [self.btnMobileCer setTag:0];
        
        OrderType1 = NO;
        OrderType2 = NO;
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([[USER_DEFAULT objectForKey:@"registerSuccess"] isEqualToString:@"1"]) {
        [USER_DEFAULT removeObjectForKey:@"registerSuccess"];
        PopupView *viewPopup = [[PopupView alloc] initWithWechatFocus:self.view];
        [self.view.window addSubview:viewPopup];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.titleView removeFromSuperview];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    [self.loadingView stopAnimating];
    if (request.tag == 1) {
        [self.navigationController.view addSubview:self.titleView];
        [self.viewUser setHidden:NO];
        [self.btnLogin setHidden:YES];
        NSDictionary *paData = [[CommonFunc getArrayFromXml:requestData tableName:@"Table"] objectAtIndex:0];
        self.lbName.text = paData[@"Name"];
        self.lbMobile.text = paData[@"Mobile"];
        self.lbEmail.text = paData[@"Email"];
        OrderType1 = [paData[@"OrderType1"] boolValue];
        OrderType2 = [paData[@"OrderType2"] boolValue];
        
        [USER_DEFAULT setValue:paData[@"Name"] forKey:@"Name"];
        [USER_DEFAULT setValue:paData[@"Mobile"] forKey:@"Mobile"];
        [USER_DEFAULT setValue:paData[@"Email"] forKey:@"Email"];
        self.constraintEmailCenterY.constant = 10;
        if (self.lbName.text.length == 0) {
            [self.lbName setHidden:YES];
            [self.lbUserSeparate setHidden:YES];
            self.constraintEmail.constant = 0;
            self.constraintMobile.constant = 43;
            self.lbEmail.textAlignment = NSTextAlignmentCenter;
            self.lbMobile.textAlignment = NSTextAlignmentCenter;
        }
        else {
            [self.lbName setHidden:NO];
            [self.lbUserSeparate setHidden:NO];
            self.constraintEmail.constant = -56;
            self.constraintMobile.constant = -8;
            self.lbEmail.textAlignment = NSTextAlignmentLeft;
            self.lbMobile.textAlignment = NSTextAlignmentLeft;
            if (self.lbMobile.text.length == 0) {
                self.constraintEmailCenterY.constant = 0;
            }
        }
        [self.btnPhoto setImage:[UIImage imageNamed:@"ucNoPhoto.png"] forState:UIControlStateNormal];
        if (paData[@"PhotoProcess"] != nil) {
            NSString *path = [NSString stringWithFormat:@"%d",([[USER_DEFAULT objectForKey:@"paMainId"] intValue] / 100000 + 1) * 100000];
            NSInteger lastLength = 9 - path.length;
            for (int i = 0; i < lastLength; i++) {
                path = [NSString stringWithFormat:@"0%@",path];
            }
            path = [NSString stringWithFormat:@"L%@",path];
            path = [NSString stringWithFormat:@"http://down.51rc.com/imagefolder/wutongguo/Photo/%@/Processed/%@",path,paData[@"PhotoProcess"]];
            [self.btnPhoto setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:path]]] forState:UIControlStateNormal];
        }
        if (self.lbMobile.text.length == 0) {
            [self.lbMobileCer setHidden:YES];
            [self.imgMobileCer setHidden:YES];
            [self.btnMobileCer setHidden:YES];
        }
        else {
            [self.lbMobileCer setHidden:NO];
            [self.imgMobileCer setHidden:NO];
            [self.btnMobileCer setHidden:NO];
        }
        if (paData[@"MobileVerifyDate"] != nil) {
            [self.lbMobileCer setText:@"手机已认证"];
            [self.lbMobileCer setTextColor:TEXTGRAYCOLOR];
            [self.imgMobileCer setImage:[UIImage imageNamed:@"ucMobileCer.png"]];
            [self.btnMobileCer setTag:1];
        }
        else {
            [self.lbMobileCer setText:@"手机未认证"];
            [self.lbMobileCer setTextColor:NAVBARCOLOR];
            [self.imgMobileCer setImage:[UIImage imageNamed:@"ucMobile.png"]];
            [self.btnMobileCer setTag:0];
        }
        [self.tableView reloadData];
    }
    else if (request.tag == 2) {
        [self.view.window makeToast:@"头像上传成功"];
    }
    else if (request.tag == 3) {
        NSArray *arrContent = [CommonFunc getArrayFromXml:requestData tableName:@"Table"];
        NSString *shareContent = [[arrContent objectAtIndex:0] objectForKey:@"ContentText"];
        NSString *shareContent2 = [[arrContent objectAtIndex:0] objectForKey:@"ContentText2"];
        NSString *shareTitle = [[arrContent objectAtIndex:0] objectForKey:@"Title"];
        [CommonFunc share:shareTitle content:shareContent url:@"http://m.wutongguo.com/Home/App" view:self.view imageUrl:@"" content2:shareContent2];
    }
}

- (void)photoClick:(UIButton *)button {
    if (![self isLogin]) {
        return;
    }
    [self.viewPhoto setFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.view.window addSubview:self.viewPhoto];
    self.viewPhoto.alpha = 0;
    [self.viewPhoto setHidden:NO];
    [UIView animateWithDuration:0.5 animations:^{
        self.viewPhoto.alpha = 1;
    }];
}

- (IBAction)photoFromCamera:(UIButton *)sender {
    [self getMediaFromSource:UIImagePickerControllerSourceTypeCamera];
}

- (IBAction)photoFromAlbum:(UIButton *)sender {
    [self getMediaFromSource:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (IBAction)cancelPhoto:(UIButton *)sender {
    [self.viewPhoto setHidden:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if([[info objectForKey:UIImagePickerControllerMediaType] isEqual:(NSString *) kUTTypeImage])
    {
        UIImage *chosenImage = [info objectForKey:UIImagePickerControllerOriginalImage];
        MLImageCrop *imgCrop = [[MLImageCrop alloc] init];
        imgCrop.delegate = self;
        imgCrop.image = chosenImage;
        imgCrop.ratioOfWidthAndHeight = 3.0f/4.0f;
        [imgCrop showWithAnimation:true];
    }
    if([[info objectForKey:UIImagePickerControllerMediaType] isEqual:(NSString *) kUTTypeMovie])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示信息!" message:@"系统只支持图片格式" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles: nil];
        [alert show];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)getMediaFromSource:(UIImagePickerControllerSourceType)sourceType {
    [self cancelPhoto:nil];
    NSArray *mediatypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    if([UIImagePickerController isSourceTypeAvailable:sourceType] &&[mediatypes count]>0){
        NSArray *mediatypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.mediaTypes = mediatypes;
        picker.delegate = self;
        picker.sourceType = sourceType;
        NSString *requiredmediatype = (NSString *)kUTTypeImage;
        NSArray *arrmediatypes = [NSArray arrayWithObject:requiredmediatype];
        [picker setMediaTypes:arrmediatypes];
        [self presentViewController:picker animated:YES completion:nil];
    }
    else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误信息!" message:@"当前设备不支持拍摄功能" delegate:nil cancelButtonTitle:@"确认" otherButtonTitles: nil];
        [alert show];
    }
}

- (void)cropImage:(UIImage*)cropImage forOriginalImage:(UIImage*)originalImage
{
    [self cancelPhoto:nil];
    [self.btnPhoto setImage:cropImage forState:UIControlStateNormal];
    NSData *dataPhoto = UIImageJPEGRepresentation(cropImage, 0);
    [self uploadPhoto:[dataPhoto base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]];
}

- (void)uploadPhoto:(NSString *)dataPhoto
{
    [self.loadingView startAnimating];
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"UploadPhoto" params:[NSDictionary dictionaryWithObjectsAndKeys:dataPhoto, @"stream", [USER_DEFAULT objectForKey:@"paMainId"], @"paMainID", [USER_DEFAULT objectForKey:@"code"], @"code", nil] tag:2];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

- (void)settingClick {
    UIViewController *settingView = [self.storyboard instantiateViewControllerWithIdentifier:@"settingView"];
    [self.navigationController pushViewController:settingView animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *sectionArr = self.arrTitle[section];
    return sectionArr.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.arrTitle.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    
    UIImageView *imgButton = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 25, 25)];
    [imgButton setImage:[UIImage imageNamed:self.titleImgArr[indexPath.section][indexPath.row]]];
    [cell.contentView addSubview:imgButton];
    
    NSString *title = self.arrTitle[indexPath.section][indexPath.row];
    CustomLabel *lbTitle = [[CustomLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgButton) + 10, VIEW_Y(imgButton) + 3, 100, 20) content:title size:14 color:nil];
    [cell.contentView addSubview:lbTitle];
    
    UIImageView *imgArrow = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 30, 15, 8, 15)];
    [imgArrow setImage:[UIImage imageNamed:@"coLeftArrow.png"]];
    [cell.contentView addSubview:imgArrow];
    //if (indexPath.row != 3 && indexPath.row != 7) {
        [cell.contentView addSubview:[[CustomLabel alloc] initSeparate:cell.contentView]];
    //}
//    self.iIndex = self.iIndex + 1;
    
    if(indexPath.section == 0 && indexPath.row == 0){
        UILabel *OrderType1Lab = [UILabel new];
        [cell.contentView addSubview:OrderType1Lab];
        OrderType1Lab.sd_layout
        .rightSpaceToView(imgArrow, 10)
        .heightIs(22)
        .widthIs(72)
        .centerYEqualToView(imgArrow);
        OrderType1Lab.layer.borderColor = NAVBARCOLOR.CGColor;
        OrderType1Lab.layer.borderWidth = 0.8;
        OrderType1Lab.sd_cornerRadius = @(11);
        OrderType1Lab.text = @"智能网申";
        OrderType1Lab.font = SMALLERFONT;
        OrderType1Lab.textAlignment = NSTextAlignmentCenter;
        OrderType1Lab.textColor = TEXTGRAYCOLOR;
        
        UILabel *OrderType2Lab = [UILabel new];
        [cell.contentView addSubview:OrderType2Lab];
        OrderType2Lab.sd_layout
        .rightSpaceToView(OrderType1Lab, 5)
        .heightRatioToView(OrderType1Lab, 1)
        .widthRatioToView(OrderType1Lab, 1)
        .centerYEqualToView(imgArrow);
        OrderType2Lab.layer.borderColor = NAVBARCOLOR.CGColor;
        OrderType2Lab.layer.borderWidth = 0.8;
        OrderType2Lab.sd_cornerRadius = @(11);
        OrderType2Lab.text = @"应聘优先";
        OrderType2Lab.font = OrderType1Lab.font;
        OrderType2Lab.textAlignment = NSTextAlignmentCenter;
        OrderType2Lab.textColor = OrderType1Lab.textColor;
        OrderType1Lab.hidden = !OrderType1;
        OrderType2Lab.hidden = !OrderType2;
        
        if(OrderType1 == NO){
            OrderType1Lab.hidden = YES;
            OrderType2Lab.sd_layout
            .rightSpaceToView(imgArrow, 10);
            [OrderType2Lab updateLayout];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section == 1){
        
        if (indexPath.row == 4) {// 我要反馈
            UIViewController *feedbackCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"feedbackView"];
            [self.navigationController pushViewController:feedbackCtrl animated:YES];
            return;
        }
        if (indexPath.row == 5) {// 应用分享
            self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"GetShareTitle" params:[NSDictionary dictionaryWithObjectsAndKeys:@"212", @"pageID", @"", @"id", nil] tag:3];
            [self.runningRequest setDelegate:self];
            [self.runningRequest startAsynchronous];
            return;
        }
    }
    
    if(indexPath.section == 1 && indexPath.row == 6){// 切换身份
        ExchangeRoleViewController *evc = [ExchangeRoleViewController new];
        evc.status = @"学生";
        [self.navigationController pushViewController:evc animated:YES];
        return;
    }
    
    if (![self isLogin]) {
        return;
    }
    
    if(indexPath.section == 0){
        if (indexPath.row == 0) {// 简历管理
            CvModifyViewController *cvModifyCtrl = [[CvModifyViewController alloc] init];
            [self.navigationController pushViewController:cvModifyCtrl animated:YES];
        }
        else if ( indexPath.row == 1) {// 网申记录
            ApplyLogViewController *applyLogCtrl = [[ApplyLogViewController alloc] init];
            [self.navigationController pushViewController:applyLogCtrl animated:YES];
        }
        else if (indexPath.row == 2) {// 企业通知
            CompanyNoticeViewController *companyNoticeCtrl = [[CompanyNoticeViewController alloc] init];
            [self.navigationController pushViewController:companyNoticeCtrl animated:YES];
        }
        else if (indexPath.row == 3) {// 我的关注
            FocusViewController *focusCtrl = [[FocusViewController alloc] init];
            [self.navigationController pushViewController:focusCtrl animated:YES];
        }
    }else if (indexPath.section == 1){
     
        if (indexPath.row == 0) {
            // 我的订单
            MyOrderListController *mvc = [MyOrderListController new];
            mvc.view.backgroundColor = [UIColor whiteColor];
            [self.navigationController pushViewController:mvc animated:YES];
        }
        else if (indexPath.row == 1) {// 网站消息
            InformViewController *informCtrl = [[InformViewController alloc] init];
            [self.navigationController pushViewController:informCtrl animated:YES];
        }
        else if (indexPath.row == 2) {// 账户管理
            AccountManagerViewController *accountManagerCtrl = [[AccountManagerViewController alloc] init];
            [self.navigationController pushViewController:accountManagerCtrl animated:YES];
        }else if(indexPath.row == 3){// 我的测评
            MyTalentsTestController *mvc = [[MyTalentsTestController alloc]init];
            [self.navigationController pushViewController:mvc animated:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 42;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 8;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (IBAction)loginClick:(UIButton *)sender {
    if (![self isLogin]) {
        return;
    }
}

- (IBAction)mobileCerClick:(UIButton *)sender {
    if (![self isLogin]) {
        return;
    }
    if (sender.tag == 1) {
        return;
    }
    MobileCerViewController *mobileCerCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"mobileCerView"];
    mobileCerCtrl.mobile = self.lbMobile.text;
    [self.navigationController pushViewController:mobileCerCtrl animated:YES];
}

- (BOOL)isLogin {
    if (![CommonFunc checkLogin]) {
        
        UIViewController *loginCtrl = [self.storyboard instantiateViewControllerWithIdentifier:@"loginView"];
        [self.navigationController pushViewController:loginCtrl animated:YES];
        return NO;
    }
    return YES;
}

@end

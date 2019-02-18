//
//  MapViewController.m
//  wutongguo
//
//  Created by Lucifer on 15/6/5.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "MapViewController.h"
#import "CommonMacro.h"
#import "CustomLabel.h"
#import "Toast+UIView.h"

@interface MapViewController ()<BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate, BMKRouteSearchDelegate, UITextFieldDelegate>

@property (nonatomic, strong) BMKMapView *mapView;
@property (nonatomic, strong) BMKLocationService *locService;
@property (nonatomic, strong) BMKGeoCodeSearch *geoCodeSearch;
@property (nonatomic, strong) BMKRouteSearch *routesearch;
@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (IS_IPHONE_4) {
        [self.viewLine setHidden:YES];
        [self.constraintMapViewHeight setConstant:SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT];
    }
    self.title = self.mapTitle;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.viewOutMap.layer setBorderColor:[SEPARATECOLOR CGColor]];
    [self.viewOutMap.layer setBorderWidth:0.5];
    [self.viewLine.layer setBorderColor:[SEPARATECOLOR CGColor]];
    [self.viewLine.layer setBorderWidth:0.5];
    [self.viewEnd.layer setBorderColor:[SEPARATECOLOR CGColor]];
    [self.viewEnd.layer setBorderWidth:0.5];
    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_BY(self.lbTitle) + 10, SCREEN_WIDTH, 0.5)];
    [viewSeparate setBackgroundColor:SEPARATECOLOR];
    [self.viewLine addSubview:viewSeparate];
    [self.lbEnd setText:self.mapAddress];
    _mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 10, self.constraintMapViewHeight.constant - 10)];
    [_mapView setCenterCoordinate:CLLocationCoordinate2DMake(self.lat, self.lng)];
    [_mapView setZoomLevel:16];
    [self.viewMap addSubview:_mapView];
    _locService = [[BMKLocationService alloc] init];
    [_locService setDelegate:self];
    [_locService startUserLocationService];
    _geoCodeSearch = [[BMKGeoCodeSearch alloc] init];
    [_geoCodeSearch setDelegate:self];
    _routesearch = [[BMKRouteSearch alloc] init];
    [_routesearch setDelegate:self];
}

- (void)viewDidAppear:(BOOL)animated {
    BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc] init];
    annotation.coordinate = CLLocationCoordinate2DMake(self.lat, self.lng);
    annotation.title = self.mapAddress;
    [_mapView addAnnotation:annotation];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(VIEW_X(self.viewLine), VIEW_Y(self.viewLine), VIEW_W(self.viewLine), SCREEN_HEIGHT - VIEW_Y(self.viewLine))];
    [self.scrollView setBackgroundColor:[UIColor whiteColor]];
    [self.scrollView setHidden:YES];
    [self.view addSubview:self.scrollView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    [_locService stopUserLocationService];
    [_mapView updateLocationData:userLocation];
    [self getAddress:userLocation.location.coordinate];
}

- (void)getAddress:(CLLocationCoordinate2D) pt
{
    [self.txtBegin setText:@"正在定位..."];
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc] init];
    reverseGeocodeSearchOption.reverseGeoPoint = pt;
    BOOL flag = [_geoCodeSearch reverseGeoCode:reverseGeocodeSearchOption];
    if(!flag)
    {
        [self.txtBegin setText:@""];
    }
}

//根据坐标获取地理位置成功执行此方法
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    if (error == BMK_SEARCH_NO_ERROR) {
        [self.txtBegin setText:result.address];
    }
    else {
        [self.txtBegin setText:@""];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frameBtnBusLine = [self.btnBusLine convertRect:self.btnBusLine.frame fromView:self.view];
        CGRect frameView = self.view.frame;
        frameView.origin.y = MIN(SCREEN_HEIGHT + frameBtnBusLine.origin.y - 100 - KEYBOARD_HEIGHT, 0);
        [self.view setFrame:frameView];
    }];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frameView = self.view.frame;
        frameView.origin.y = 0;
        [self.view setFrame:frameView];
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)lineClick:(UIButton *)sender {
    BMKPlanNode* start = [[BMKPlanNode alloc] init];
    start.name = self.txtBegin.text;
    BMKPlanNode* end = [[BMKPlanNode alloc] init];
    end.name = self.lbEnd.text;
    end.pt = CLLocationCoordinate2DMake(self.lat, self.lng);
    BOOL flag;
    if (sender.tag == 0) {
        BMKTransitRoutePlanOption *transitRouteSearchOption = [[BMKTransitRoutePlanOption alloc] init];
        transitRouteSearchOption.from = start;
        transitRouteSearchOption.to = end;
        transitRouteSearchOption.city = self.mapAddress;
        flag = [_routesearch transitSearch:transitRouteSearchOption];
    }
    else {
        BMKDrivingRoutePlanOption *drivingRouteSearchOption = [[BMKDrivingRoutePlanOption alloc] init];
        drivingRouteSearchOption.from = start;
        drivingRouteSearchOption.to = end;
        flag = [_routesearch drivingSearch:drivingRouteSearchOption];
    }
    if(flag)
    {
        NSLog(@"检索发送成功");
    }
    else
    {
        NSLog(@"检索发送失败");
    }
}

- (void)onGetTransitRouteResult:(BMKRouteSearch*)searcher result:(BMKTransitRouteResult*)result errorCode:(BMKSearchErrorCode)error {
    if (error == BMK_SEARCH_NO_ERROR) {
        BMKTransitRouteLine* plan = (BMKTransitRouteLine*)[result.routes objectAtIndex:0];
        NSMutableString *routeString = [[NSMutableString alloc] init];
        for (int i = 0; i < plan.steps.count; i++) {
            BMKDrivingStep *transitStep = [plan.steps objectAtIndex:i];
            if (i == 0) {
                [routeString appendString:@"起点"];
            }
            [routeString appendFormat:@"\n%d、%@", i + 1, transitStep.instruction];
            if (i == plan.steps.count - 1) {
                [routeString appendString:@"\n终点"];
            }
        }
        CustomLabel *lbRoute = [[CustomLabel alloc] initWithFixedSpacing:CGRectMake(10, 10, SCREEN_WIDTH - 20, 5000) content:routeString size:12 color:nil];
        [self.scrollView addSubview:lbRoute];
        [self.scrollView setContentSize:CGSizeMake(VIEW_W(self.scrollView), VIEW_BY(lbRoute) + 10)];
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        [self.scrollView setHidden:NO];
        UIButton *btnClose = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 30, VIEW_Y(self.viewLine) + 10, 20, 20)];
        [btnClose setImage:[UIImage imageNamed:@"coMapClose.png"] forState:UIControlStateNormal];
        [btnClose addTarget:self action:@selector(routeClose:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btnClose];
    }
    else {
        [self errorToast:error];
    }
}

- (void)onGetDrivingRouteResult:(BMKRouteSearch*)searcher result:(BMKDrivingRouteResult*)result errorCode:(BMKSearchErrorCode)error {
    if (error == BMK_SEARCH_NO_ERROR) {
        BMKDrivingRouteLine* plan = (BMKDrivingRouteLine*)[result.routes objectAtIndex:0];
        NSMutableString *routeString = [[NSMutableString alloc] init];
        for (int i = 0; i < plan.steps.count; i++) {
            BMKDrivingStep *transitStep = [plan.steps objectAtIndex:i];
            if (i == 0) {
                [routeString appendString:@"起点"];
            }
            [routeString appendFormat:@"\n%d、%@", i + 1, transitStep.entraceInstruction];
            if (i == plan.steps.count - 1) {
                [routeString appendString:@"\n终点"];
            }
        }
        CustomLabel *lbRoute = [[CustomLabel alloc] initWithFixedSpacing:CGRectMake(10, 10, SCREEN_WIDTH - 20, 5000) content:routeString size:12 color:nil];
        [self.scrollView addSubview:lbRoute];
        [self.scrollView setContentSize:CGSizeMake(VIEW_W(self.scrollView), VIEW_BY(lbRoute) + 10)];
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
        [self.scrollView setHidden:NO];
        UIButton *btnClose = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 30, VIEW_Y(self.viewLine) + 10, 20, 20)];
        [btnClose setImage:[UIImage imageNamed:@"coMapClose.png"] forState:UIControlStateNormal];
        [btnClose addTarget:self action:@selector(routeClose:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btnClose];
    }
    else {
        [self errorToast:error];
    }
}

- (void)errorToast:(BMKSearchErrorCode)error {
    if (error == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR) {
        [self.view.window makeToast:@"起点有歧义，请精确起点地址"];
    }
    else if (error == BMK_SEARCH_NOT_SUPPORT_BUS) {
        [self.view.window makeToast:@"该城市不支持公交搜索"];
    }
    else if (error == BMK_SEARCH_NOT_SUPPORT_BUS_2CITY) {
        [self.view.window makeToast:@"不支持跨城市公交"];
    }
    else if (error == BMK_SEARCH_RESULT_NOT_FOUND) {
        [self.view.window makeToast:@"没有找到检索结果"];
    }
    else if (error == BMK_SEARCH_ST_EN_TOO_NEAR) {
        [self.view.window makeToast:@"起终点太近"];
    }
}

- (void)routeClose:(UIButton *)sender {
    if (self.scrollView.subviews.count > 0) {
        [[self.scrollView.subviews objectAtIndex:0] removeFromSuperview];
    }
    [self.scrollView setHidden:YES];
    [sender removeFromSuperview];
}

@end

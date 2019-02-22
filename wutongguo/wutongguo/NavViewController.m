//
//  NavViewController.m
//  wutongguo
//
//  Created by Lucifer on 15-5-4.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "NavViewController.h"
#import "CommonMacro.h"
#import "CommonFunc.h"
#import "Toast+UIView.h"
#import "NetWebServiceRequest.h"
#import "JPUSHService.h"
#import "MyTalentsTestController.h"

@interface NavViewController ()<NetWebServiceRequestDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@end

@implementation NavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.delegate = self;
    self.tabBarItem.selectedImage = [[UIImage imageNamed:[NSString stringWithFormat:@"bottom%ld_highlight.png", (long)self.tabItem.tag]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [self.tabBarController.tabBar setTintColor:NAVBARCOLOR];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.tabItem.tag == 2) {
        [self clickLog:@"17"];
    }
    else if (self.tabItem.tag == 3) {
        [self clickLog:@"18"];
    }
    else if (self.tabItem.tag == 4) {
        [self clickLog:@"19"];
    }
    else if (self.tabItem.tag == 5) {
        [self clickLog:@"16"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    viewController.view.backgroundColor = BGCOLOR;
    if ([[USER_DEFAULT objectForKey:@"willBind"] isEqualToString:@"1"]) {
        [USER_DEFAULT removeObjectForKey:@"willBind"];
        [self bindPush];
    }
    
    if ([viewController isKindOfClass:[MyTalentsTestController class]]) {
        return;
    }
    
    if(navigationController.viewControllers.count > 1) {
        UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-back.png"] style:UIBarButtonItemStyleDone target:self action:@selector(popViewControllerAnimated:)];
        viewController.navigationItem.leftBarButtonItem = leftBarItem;
    }
}

- (void)bindPush {
    if ([[JPUSHService registrationID] length] > 0) {
        self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"InsertpaIOSBind" params:[NSDictionary dictionaryWithObjectsAndKeys:[CommonFunc getPaMainId], @"paMainID", [JPUSHService registrationID], @"uniqueID", [CommonFunc getCode], @"code", nil] tag:1];
        [self.runningRequest setDelegate:self];
        [self.runningRequest startAsynchronous];
    }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [viewController setHidesBottomBarWhenPushed:true];
    [super pushViewController:viewController animated:animated];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    
}

- (void)clickLog:(NSString *)buttonType {
    self.runningRequest = [NetWebServiceRequest serviceRequestUrl:@"InsertAppBtnClickLog" params:[NSDictionary dictionaryWithObjectsAndKeys:@"2", @"SysType", [CommonFunc getDeviceID], @"DeviceID", [CommonFunc getPaMainId], @"pamainID", buttonType, @"dcAppBtnID", nil] tag:2];
    [self.runningRequest setDelegate:self];
    [self.runningRequest startAsynchronous];
}

@end

//
//  AppDelegate.m
//  wutongguo
//
//  Created by Lucifer on 15-5-4.
//  Copyright (c) 2015年 Lucifer. All rights reserved.
//

#import "AppDelegate.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/QQApiInterface.h>
#import "WXApi.h"
#import "WeiboSDK.h"
//新浪微博SDK需要在项目Build Settings中的Other Linker Flags添加"-ObjC"
#import "JPUSHService.h"
#import "UIImageView+WebCache.h"
#import "CommonMacro.h"
#import "ChoseSideViewController.h"
#import "NavViewController.h"
#import "CpLoginViewController.h"
#import "WXApiManager.h"
#import "WXApi.h"
#import <AlipaySDK/AlipaySDK.h>
#import "WTGTabbarController.h"
#import "CompanyViewController.h"
#import "ApplyLogViewController.h"
#import "CpJobDetailViewController.h"
#import "FocusViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // 向微信注册,发起支付必须注册
    [WXApi registerApp:@"wxbbde9453b1aa1c18"];
    
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    //将字典存入到document内
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
    NSLog(@"%@",paths);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:@"dictionary.db"];
    NSFileManager *file = [NSFileManager defaultManager];
    if ([file fileExistsAtPath:dbPath]) {
        
    }
    else {
        NSString *originDbPath = [[NSBundle mainBundle] pathForResource:@"dictionary.db" ofType:nil];
        NSData *mainBundleFile = [NSData dataWithContentsOfFile:originDbPath];
        [file createFileAtPath:dbPath contents:mainBundleFile attributes:nil];
    }
    /**
     *  设置ShareSDK的appKey，如果尚未在ShareSDK官网注册过App，请移步到http://mob.com/login 登录后台进行应用注册，
     *  在将生成的AppKey传入到此方法中。
     *  方法中的第二个第三个参数为需要连接社交平台SDK时触发，
     *  在此事件中写入连接代码。第四个参数则为配置本地社交平台时触发，根据返回的平台类型来配置平台信息。
     *  如果您使用的时服务端托管平台信息时，第二、四项参数可以传入nil，第三项参数则根据服务端托管平台来决定要连接的社交SDK。
     */
    [ShareSDK registerApp:@"75491323f292"
     
          activePlatforms:@[
                            @(SSDKPlatformTypeSinaWeibo),
                            @(SSDKPlatformTypeMail),
                            @(SSDKPlatformTypeSMS),
                            @(SSDKPlatformTypeWechat),
                            @(SSDKPlatformTypeQQ)]
                 onImport:^(SSDKPlatformType platformType)
     {
         switch (platformType)
         {
             case SSDKPlatformTypeWechat:
                 [ShareSDKConnector connectWeChat:[WXApi class]];
                 break;
             case SSDKPlatformTypeQQ:
                 [ShareSDKConnector connectQQ:[QQApiInterface class] tencentOAuthClass:[TencentOAuth class]];
                 break;
             case SSDKPlatformTypeSinaWeibo:
                 [ShareSDKConnector connectWeibo:[WeiboSDK class]];
                 break;
             default:
                 break;
         }
     }
          onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo)
     {
         
         switch (platformType)
         {
             case SSDKPlatformTypeSinaWeibo:
                 //设置新浪微博应用信息,其中authType设置为使用SSO＋Web形式授权
                 [appInfo SSDKSetupSinaWeiboByAppKey:@"1548077241"
                                           appSecret:@"35b89ade5a834ae0df4dbddefd8c98a5"
                                         redirectUri:@"http://m.wutongguo.com"
                                            authType:SSDKAuthTypeBoth];
                 break;
             case SSDKPlatformTypeWechat:
                 [appInfo SSDKSetupWeChatByAppId:@"wxbbde9453b1aa1c18"
                                       appSecret:@"fbec1762caec172c2e9250394ef3a5ad"];
                 break;
             case SSDKPlatformTypeQQ:
                 [appInfo SSDKSetupQQByAppId:@"1104616129"
                                      appKey:@"5EhkIfew5cPsgBFk"
                                    authType:SSDKAuthTypeBoth];
                 break;
             default:
                 break;
         }
     }];
    
    //添加腾讯微博应用 注册网址 http://dev.t.qq.com
//    [ShareSDK connectTencentWeiboWithAppKey:@"801307650"
//                                  appSecret:@"ae36f4ee3946e1cbb98d6965b0b2ff5c"
//                                redirectUri:@"http://m.wutongguo.com"
//                                   wbApiCls:[WeiboApi class]];
    
    
    _mapManager = [[BMKMapManager alloc] init];
    // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
    BOOL ret = [_mapManager start:@"9tspmhRxa4wLG4DQ4BEWSxDf"  generalDelegate:nil];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    //JPush推送
    // Required
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                       UIUserNotificationTypeSound |
                                                       UIUserNotificationTypeAlert)
                                           categories:nil];
    } else {
        //categories 必须为nil
        [JPUSHService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                       UIRemoteNotificationTypeSound |
                                                       UIRemoteNotificationTypeAlert)
                                           categories:nil];
    }
    
    // Required
    [JPUSHService setupWithOption:launchOptions];
    if ([USER_DEFAULT objectForKey:@"attentionType"] == nil) {
        [USER_DEFAULT setValue:@"0" forKey:@"attentionType"];
    }
    // clearBadgeNumber
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    // 设置跟控制器
    [self setupRootViewController];
    
    return YES;
    
}

#pragma mark - 设置跟控制器
- (void)setupRootViewController{
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    NSString *app_Status = [CommonToos getValue:APP_STATUS];
    if (app_Status == nil) {
        self.window.rootViewController = [[NavViewController alloc]initWithRootViewController:[ChoseSideViewController new]];
        
    }else if([app_Status isEqualToString:@"0"]){
        UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
        self.window.rootViewController = [storyBoard instantiateViewControllerWithIdentifier:@"person"];
    }else if ([app_Status isEqualToString:@"1"]){
        CpLoginViewController *cvc  = [CpLoginViewController new];
        cvc.isRootView = YES;
        self.window.rootViewController = [[NavViewController alloc]initWithRootViewController:cvc];
    }
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken");
    // Required
    [JPUSHService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"1111111112");
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    // Required
    [JPUSHService handleRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    NSLog(@"this is iOS7 Remote Notification");
    // 取得 APNs 标准信息内容
    NSDictionary *aps = [userInfo valueForKey:@"aps"];
    NSString *content = [aps valueForKey:@"alert"]; //推送显示的内容
    NSInteger badge = [[aps valueForKey:@"badge"] integerValue]; //badge数量
    NSString *sound = [aps valueForKey:@"sound"]; //播放的声音
    [self presentController:userInfo];
    
    // IOS 7 Support Required
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
    //[USER_DEFAULT setObject:userInfo forKey:@"pushUserInfo"];
}

/*
 1,3,4,20,23 招聘简章页面 招聘简章id
 2 企业宣讲会列表页面  企业id
 5,6 我的关注职位页面
 7 高校页面招聘会列表 高校id
 8,21 高校页面宣讲会列表 高校id
 9,10 我的关注宣讲会页面
 11,12 我的关注招聘会页面
 22 宣讲会查询列表 地区id
 51 网申记录页面
 52 职位详情页面 职位id
 */
- (void)presentController:(NSDictionary *)extrasDict{
    
    NSString *DetailID = [extrasDict objectForKey:@"DetailID"];
    NSString *PushType = [extrasDict objectForKey:@"PushType"];
    
    if([self.window.rootViewController isKindOfClass:[WTGTabbarController class]]){
        
        NSUserDefaults*pushJudge = [NSUserDefaults standardUserDefaults];
        [pushJudge setObject:@"push"forKey:@"push"];
        [pushJudge synchronize];
        
        if ([PushType isEqualToString:@"52"]) {// 职位详情
            //589B76B751
            CpJobDetailViewController *targetVc = [CpJobDetailViewController new];
            targetVc.secondId = DetailID;
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:targetVc];
            [self.window.rootViewController presentViewController:nav animated:YES completion:nil];
        }else if ([PushType isEqualToString:@"51"]){// 网申记录页面
            ApplyLogViewController *targetVc = [ApplyLogViewController new];
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:targetVc];
            [self.window.rootViewController presentViewController:nav animated:YES completion:nil];
        }else if ([PushType isEqualToString:@"22"]){// 宣讲会列表
            
            UIViewController *targetVc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"campusListView"];
             [self.window.rootViewController presentViewController:targetVc animated:YES completion:nil];
            
        }else if([PushType isEqualToString:@"11"] || [PushType isEqualToString:@"12"]){// 11,12 我的关注招聘会页面
            FocusViewController *focusCtrl = [[FocusViewController alloc] init];
            focusCtrl.navTabBarIndex = 4;
            [self.window.rootViewController presentViewController:focusCtrl animated:YES completion:nil];
            
        }else if([PushType isEqualToString:@"11"] || [PushType isEqualToString:@"12"]){// 9,10 我的关注宣讲会页面
            FocusViewController *focusCtrl = [[FocusViewController alloc] init];
            focusCtrl.navTabBarIndex = 3;
            [self.window.rootViewController presentViewController:focusCtrl animated:YES completion:nil];
            
        }else if([PushType isEqualToString:@"5"] || [PushType isEqualToString:@"6"]){// 5,6 我的关注职位页面
            FocusViewController *focusCtrl = [[FocusViewController alloc] init];
            focusCtrl.navTabBarIndex = 1;
            [self.window.rootViewController presentViewController:focusCtrl animated:YES completion:nil];
            
        }
    }
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.51rc.wutongguo" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"wutongguo" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"wutongguo.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

// NOTE: 9.0以后使用新API接口
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString*, id> *)options
{
    if ([url.host isEqualToString:@"safepay"]) {
        // 支付跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
            if ([[resultDic objectForKey:@"resultStatus"] isEqualToString:@"9000"]) {

                // 查询支付结果
                NSString *result = resultDic[@"result"];
                NSDictionary *resultDict = [CommonToos translateJsonStrToDictionary:result];
                NSString *out_trade_no = [resultDict[@"alipay_trade_app_pay_response"] objectForKey:@"out_trade_no"];
                [[NSUserDefaults standardUserDefaults] setObject:out_trade_no forKey:KEY_PAYORDERNUM];
                [[NSUserDefaults standardUserDefaults]synchronize];

                // 支付成功
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ALIPAYSUCCESS object:nil];
            }else{
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ALIPAYFAILED object:nil];
            }
        }];

        // 授权跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
            // 解析 auth code
            NSString *result = resultDic[@"result"];
            NSString *authCode = nil;
            if (result.length>0) {
                NSArray *resultArr = [result componentsSeparatedByString:@"&"];
                for (NSString *subResult in resultArr) {
                    if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
                        authCode = [subResult substringFromIndex:10];
                        break;
                    }
                }
            }
            NSLog(@"授权结果 authCode = %@", authCode?:@"");
        }];

    }else {
        // 微信支付
        return  [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([url.host isEqualToString:@"safepay"]) {
        // 支付跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
        }];

        // 授权跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processAuth_V2Result:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"result = %@",resultDic);
            // 解析 auth code
            NSString *result = resultDic[@"result"];
            NSString *authCode = nil;
            if (result.length>0) {
                NSArray *resultArr = [result componentsSeparatedByString:@"&"];
                for (NSString *subResult in resultArr) {
                    if (subResult.length > 10 && [subResult hasPrefix:@"auth_code="]) {
                        authCode = [subResult substringFromIndex:10];
                        break;
                    }
                }
            }
            NSLog(@"授权结果 authCode = %@", authCode?:@"");
        }];
        
    }else if ([sourceApplication isEqualToString:@"com.tencent.xin"]) {
        //微信支付回调
        return [WXApi handleOpenURL:url delegate:[WXApiManager sharedManager]];
    }
    return YES;
}


- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings{
    [application registerForRemoteNotifications];
}
@end

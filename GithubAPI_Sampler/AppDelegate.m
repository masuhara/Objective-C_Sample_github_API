//
//  AppDelegate.m
//  GithubAPI_Sampler
//
//  Created by Master on 2014/11/21.
//  Copyright (c) 2014年 net.masuhara. All rights reserved.
//

#import "AppDelegate.h"
#import "GADBannerView.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
{
    GADBannerView *_gadBannerView;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    
    [self getTabBarWithAdMob];
    return YES;
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
}

- (void)getTabBarWithAdMob
{
    // *UITabBarControllerを取得する
    UITabBarController *tabBarController = (UITabBarController*)self.window.rootViewController;
    
    _gadBannerView = [[GADBannerView alloc]
                      initWithFrame:CGRectMake(0.0,
                                               tabBarController.view.frame.size.height -
                                               GAD_SIZE_320x50.height - 49,
                                               GAD_SIZE_320x50.width,
                                               GAD_SIZE_320x50.height)];
    
    _gadBannerView.adUnitID = @"ca-app-pub-6363351251362748/2672447116";
    _gadBannerView.rootViewController = tabBarController;
    [tabBarController.view addSubview:_gadBannerView];
    
    [_gadBannerView loadRequest:[GADRequest request]];
    
    
    // 開発段階では必ずテスト モードを使用
    // ---- AdMob test --->
    GADRequest *request = [GADRequest request];
    
    request.testDevices = [NSArray arrayWithObjects:
                           // シミュレータ
                           GAD_SIMULATOR_ID,
                           // iOS 端末をテスト: TEST_DEVICE_ID
                           @"c??????????????????????????????6",
                           nil];
}

@end

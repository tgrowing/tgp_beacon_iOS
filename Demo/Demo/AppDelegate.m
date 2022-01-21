//
//  AppDelegate.m
//  DEMO
//
//  Created by yiqiwang on 2021/3/8.
//  Copyright © 2021 yiqiwang. All rights reserved.
//

#import "AppDelegate.h"
#import <BeaconAPI_Base/BeaconReport.h>

@interface AppDelegate ()

@property (nonatomic, copy) NSString *appKey;
@property (nonatomic, copy) NSString *uploadURL;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
     
    [self startBeacon];
    
    return YES;
}

- (void)startBeacon {
    self.appKey = [[NSUserDefaults standardUserDefaults] objectForKey:@"appkey"];
    self.uploadURL = [[NSUserDefaults standardUserDefaults] objectForKey:@"uploadurl"];

    if (!self.appKey || self.appKey.length == 0) {
        return;
    }
    
    BeaconReportConfig *reportConfig = [BeaconReportConfig new];
    if (self.uploadURL && self.uploadURL.length > 0) {
        reportConfig.uploadURL = self.uploadURL;    // 设置上报域名
    }

    BeaconReport.sharedInstance.channelId = @"channelId";
    BeaconReport.sharedInstance.logLevel = 5;  // 设置本地调试时控制台输出的日志级别
    BeaconReport.sharedInstance.strictMode = YES; // 开发调试阶段，打开严苛模式，可以发现一些致命的基础问题，上线时必须关闭
    [BeaconReport.sharedInstance.getCommonParams setAppVersion:@"123"]; //设置appVersion
    [BeaconReport.sharedInstance setAdditionalParams:@{@"addKey1" : @"addValue1" , @"app_pos" : @(0)} forAppKey:self.appKey];
    [BeaconReport.sharedInstance initOstar];    // startWithAppkey 之前必须调用
    [BeaconReport.sharedInstance startWithAppkey:self.appKey config:reportConfig];
    [BeaconReport.sharedInstance setSocketOnOff:NO];
}

@end

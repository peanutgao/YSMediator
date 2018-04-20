//
//  YSAppDelegate.m
//  YSMediator
//
//  Created by peanutgao on 04/10/2018.
//  Copyright (c) 2018 peanutgao. All rights reserved.
//

#import "YSAppDelegate.h"
#import "YSMediator.h"

@implementation YSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 可以在启动时注册映射
    // 也可以在类文件中 + load 方法中注册
    [YSMediator mapName:@"mainVC" toClassName:@"MainViewController" withParams:nil];
    [YSMediator mapBaseWebViewWithName:@"webView" toClassName:@"BaseWebViewController" paramsMapDict:nil];

    // [YSMediator registerScheme:@"com.ysmediator.demo" andHost:nil];
    [YSMediator registerUrlInfos:@{
                                   @"com.ysmediator.demo": @"host",
                                   @"com.ysmediator.demo1": [NSNull null],
                                   @"com.ysmediator.demo2": @[@"host0", @"host1", @"host2"],
                                   }];
    return YES;
}

@end

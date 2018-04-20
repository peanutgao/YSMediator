//
//  YSMediator+Router.h
//  Mediator
//
//  Created by Joseph Gao on 2017/4/11.
//  Copyright © 2017年 Joseph. All rights reserved.
//

#import "YSMediator.h"


@interface YSMediator (Router)

/**
 映射跳转的baseWebView, 如果有web页面必须得注册
 
 @param nameString 映射字段, 非空
 @param toClassName baseWebViewController 类名名称字符, 非空
 @param paramsMapDict 映射参数字典. key为当前类的要映射的属性字段, value为url中要映射的参数key; 如果参数一致, 可以不写
 */
+ (BOOL)mapBaseWebViewWithName:(NSString *_Nonnull)nameString
                   toClassName:(NSString *_Nonnull)toClassName
                 paramsMapDict:(NSDictionary *_Nullable)paramsMapDict;

/**
 注册Router跳转的URL Scheme 和 Host, 用该方式限制唯一的scheme和host

 @param scheme 跳转的URL Scheme,不能为空
 @param host 跳转的URL Host
 */
+ (void)registerScheme:(NSString *_Nonnull)scheme andHost:(NSString *_Nullable)host;

/**
 注册Router跳转的URL信息
 key: url的scheme字符串.
 value: 对应Scheme的host. 如果是单个可以用NSString类型; 如果是多个可以用NSArray<NSString *>类型; 如果是不限制scheme的host的话值设置成 [NSNull null]
 @code
 [self registerUrlInfos:@{
                         @"com.ysmediator.demo1": @"host", // 只能跳转到 com.ysmediator.demo1://host下的页面
                         @"com.ysmediator.demo2": @[@"host1", @"host2", @"host3"], // 只能跳转到 com.ysmediator.demo2://host1 host2 和 host3下的页面
                         @"com.ysmediator.demo3": [NSNull null] //可以跳转到 com.ysmediator.demo3://任意host下的页面
                        }];
 @endcode
 @param UrlInfos 所有url的Scheme和host信息,
 */
+ (void)registerUrlInfos:(NSDictionary *_Nonnull)UrlInfos;

/**
 打开跳转链接,如果是http或者https,会直接打开注册的baseWebView,
 如果urlStr是注册的scheme,会尝试打开原生注册的页面
 */
+ (void)openURL:(NSString *_Nonnull)urlStr;

/**
 打开跳转链接,如果是http或者https,会直接打开注册的baseWebView,
 如果urlStr是注册的scheme,会尝试打开原生注册的页面

 @param urlStr 映射的url字段
 @param filter 限制跳转的规则,params是解析出来的参数字典,可根据字段检查是否允许打开页面
 */
+ (void)openURL:(NSString *_Nonnull)urlStr withFilter:(BOOL(^)(NSDictionary *params))filter;


/**
 通过映射字符串跳转页面

 @param path 映射的路径的字符串, 不能为空
 @param params 映射参数字典. key为当前类的要映射的属性字段, value为url中要映射的参数key; 如果参数一致, 可以不写
 */
+ (void)openPath:(NSString *_Nonnull)path withParams:(NSDictionary *_Nullable)params;

@end

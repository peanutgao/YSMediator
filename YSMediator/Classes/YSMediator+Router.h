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
 @param paramsMapDict 映射参数字典, key为url参数, value为类的对应的参数, 如果参数一致, 可以不写
 */
+ (BOOL)mapBaseWebViewWithName:(NSString *)nameString
                   toClassName:(NSString *)toClassName
                 paramsMapDict:(NSDictionary *)paramsMapDict;

/**
 注册Router跳转的URL Scheme 和 Host

 @param scheme 跳转的URL Scheme, 不能为空
 @param host 跳转的URL Host, 不能为空
 */
+ (void)registerScheme:(NSString *)scheme andHost:(NSString *)host;

/**
 打开跳转链接,如果是http或者https,会直接打开注册的baseWebView,
 如果urlStr是注册的scheme,会尝试打开原生注册的页面
 */
+ (void)openURL:(NSString *)urlStr;

/**
 打开跳转链接,如果是http或者https,会直接打开注册的baseWebView,
 如果urlStr是注册的scheme,会尝试打开原生注册的页面

 @param urlStr 映射的url字段
 @param filter 限制跳转的规则,params是解析出来的参数字典,可根据字段检查是否允许打开页面
 */
+ (void)openURL:(NSString *)urlStr withFilter:(BOOL(^)(NSDictionary *params))filter;


/**
 通过映射字符串跳转页面

 @param path 映射的路径的字符串, 不能为空
 @param params 映射的参数字典, @{映射的字段: 当前参数}
 */
+ (void)openPath:(NSString *)path withParams:(NSDictionary *)params;

@end

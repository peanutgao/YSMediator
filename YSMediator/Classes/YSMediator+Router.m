//
//  YSMediator+Router.m
//  Mediator
//
//  Created by Joseph Gao on 2017/4/11.
//  Copyright © 2017年 Joseph. All rights reserved.
//

#import "YSMediator+Router.h"
#import "YSMediator+Transition.h"
#import "YSMediator+Tools.h"
#import <objc/runtime.h>
#import "YSMapModel.h"

static const char *kWebViewURLPropertyKey = "urlString";
static const void *ys_registerInfosKey = "ys_registerInfosKey";

@interface YSMediator ()

@property (nonatomic, strong) NSDictionary *registerInfos;

@end


@implementation YSMediator (Router)

- (void)setRegisterInfos:(NSDictionary *)registerInfos {
    objc_setAssociatedObject(self, &ys_registerInfosKey, registerInfos, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDictionary *)registerInfos {
    return objc_getAssociatedObject(self, &ys_registerInfosKey);
}


#pragma mark - Open

+ (void)registerScheme:(NSString *)scheme andHost:(NSString *)host {
    if (scheme == nil || ![scheme isKindOfClass:[NSString class]]) {
        YSMediatorAssert(@"注册信息错误"); return;
    }
    
    YSMediator *instance = [YSMediator shareMediator];
    instance.registerInfos = @{scheme : host ?: [NSNull null]};
}

+ (void)registerUrlInfos:(NSDictionary <NSString *, NSArray *> *_Nonnull)UrlInfos {
    if (UrlInfos == nil) {
        YSMediatorAssert(@"注册信息不能为空"); return;
    }
    
    YSMediator *instance = [YSMediator shareMediator];
    instance.registerInfos = UrlInfos;
}

+ (BOOL)mapBaseWebViewWithName:(NSString *_Nonnull)nameString
                   toClassName:(NSString *_Nonnull)toClassName
                 paramsMapDict:(NSDictionary *_Nullable)paramsMapDict {
    BOOL result = [self mapName:nameString toClassName:toClassName withParams:paramsMapDict];
    if (result) {
        [YSMediator shareMediator].baseWebClassName = toClassName;
    }
    return result;
}

+ (void)openPath:(NSString *)path withParams:(NSDictionary *)params {
    if (isEmptyString(path)) {
        YSMediatorAssert(@"path不能为空!!!"); return;
    }
    [self searchPathInfo:path successHandler:^(YSMapModel *obj) {
        [YSMediator pushToViewController:obj.mapClassName
                              withParams:obj.paramsMapDict
                                animated:YES callBack:NULL];
        
    } failureHandler:^(NSError *error){
        YSMediatorAssert(error.localizedDescription);
    }];
}

+ (void)openURL:(NSString *)urlStr {
    [self openURL:urlStr withFilter:[YSMediator shareMediator].filter ?: NULL];
}

+ (void)openURL:(NSString *)urlStr withFilter:(BOOL(^)(NSDictionary *params))filter {
    if (isEmptyString(urlStr)) {
        YSMediatorAssert(@"urlStr为空!!!"); return;
    }
    
    NSURL *url = [NSURL URLWithString:urlStr];
    if (![self isLegalUrl:url]) {
        NSLog(@"\n");
        NSLog(@"=====================================");
        NSLog(@"=============> Warning <=============");
        NSLog(@"    非法URL: 当前注册信息中未包含该URL:");
        NSLog(@"%@", url);
        NSLog(@"=====================================\n");
        NSLog(@"\n");
        return;
    }
    
    BOOL b = [self tryToOpenInWebView:urlStr withFilter:filter];
    if (b) return;
    
    [self searchPathInfo:url.path successHandler:^(YSMapModel *obj) {
        [self openInNativePageOfURL:url withMapObj:obj andFilter:filter];
        
    } failureHandler:^(NSError *error){
        YSMediatorAssert(error.localizedDescription);
    }];
}

+ (BOOL)isHttpUrl:(NSURL *)url {
    return ([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"]);
}

+ (BOOL)isLegalUrl:(NSURL *)url {
    YSMediator *mediator = [YSMediator shareMediator];
    NSArray *schemes = mediator.registerInfos.allKeys;
    
    if (url.scheme.length == 0) return NO;
    if ([self isHttpUrl:url] || !mediator.registerInfos) return YES;
    if (![schemes containsObject:url.scheme]) return NO;
    
    id hosts = [mediator.registerInfos objectForKey:url.scheme];
    if ([hosts isEqual:[NSNull null]]) {
        return YES;
    }
    else if ([hosts isKindOfClass:[NSString class]]) {
        return [hosts isEqualToString:url.host];
    }
    else if ([hosts isKindOfClass:[NSArray class]]) {
        return [hosts containsObject:url.host];
    }
    
    YSMediatorAssert(@"格式错误: 注册的hosts是 NSString 或者 NSArray 类型");
    return NO;
}


#pragma mark - Other

+ (BOOL)tryToOpenInWebView:(NSString *)urlStr withFilter:(BOOL(^)(NSDictionary *params))filter {
    NSURL *url = [NSURL URLWithString:urlStr];
    if ([self isHttpUrl:url]) {
        if ([YSMediator shareMediator].baseWebClassName.length == 0) {
            YSMediatorAssert(@"没有注册一个baseWeb控制器"); return NO;
        }
        
        Class clazz = NSClassFromString([YSMediator shareMediator].baseWebClassName);
        objc_property_t property = class_getProperty(clazz, kWebViewURLPropertyKey);
        if (!property) {
            // @property (nonatomic, copy) NSString *urlString;
            YSMediatorAssert(@"注册的web控制器需要添加接受 url 的字符串属性 urlString "); return NO;
        }
        NSString *attributesName = [NSString stringWithUTF8String:property_getAttributes(property)];
        if (![attributesName containsString:@"T@\"NSString\""]) {
            YSMediatorAssert(@"注册的web控制器需要添加接受 url 的字符串属性 urlString "); return NO;
        }
        
        NSDictionary *params = @{[NSString stringWithUTF8String:kWebViewURLPropertyKey]: urlStr};
        if (filter) {
            BOOL b = filter(params);
            if (!b) return NO;
        }

        UIViewController *vc = [[clazz alloc] init];
        [vc setValue:urlStr forKey:[NSString stringWithUTF8String:kWebViewURLPropertyKey]];
        [YSMediator pushViewController:vc
                              withParams:params
                                animated:YES
                                callBack:NULL];
        
        
        return YES;
    }
    
    return NO;
}

+ (void)openInNativePageOfURL:(NSURL *)url withMapObj:(YSMapModel *)obj andFilter:(BOOL(^)(NSDictionary *params))filter {
    NSDictionary *params = [self paramsDictWithURL:url];
    if (filter) {
        BOOL b = filter(params);
        if (!b) return;
    }
    
    Class Clazz = NSClassFromString(obj.mapClassName);
    if ([Clazz isSubclassOfClass:[UIViewController class]]) {
        [YSMediator pushToViewController:obj.mapClassName
                              withParams:params
                                animated:YES
                                callBack:NULL];
    }
    else if ([Clazz isKindOfClass:[NSObject class]]) {
        NSDictionary *mapParams = [self fixParams:params withMapDict:obj.paramsMapDict];
        id obj = [[Clazz alloc] init];
        [self setPropretyOfTarget:obj withParams:mapParams handle:NULL];
    }
    
}

+ (void)searchPathInfo:(NSString *)path
        successHandler:(void(^)(YSMapModel *obj))successHandler
        failureHandler:(void(^)(NSError *error))failureHandler {

    YSMapModel *map = [[YSMediator shareMediator].mapInfoDict objectForKey:path];
    if (!map
        || map.mapClassName == nil
        || NSClassFromString(map.mapClassName) == nil) {
        
        NSString *errorStr = @"没有找到当前类型的控制器类, 请检查是否有添加映射";
        NSError *error = [NSError errorWithDomain:YS_MEDIATOR_ERROR_DOMAIN
                                             code:YS_MEDIATOR_MAP_ERROR_CODE
                                         userInfo:@{NSLocalizedDescriptionKey: errorStr}];
        
        if (failureHandler) {
            failureHandler(error);
        }
        return;
    }
    
    if (successHandler) {
        successHandler(map);
    }
}

+ (NSDictionary *)paramsDictWithURL:(NSURL *)url {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    NSString *query = url.query;
    if (!query) return nil;
    
    NSArray *componets = [query componentsSeparatedByString:@"&"];
    for (NSString *str in componets) {
        NSArray *pairComponents = [str componentsSeparatedByString:@"="];
        NSString *key = [[pairComponents firstObject] stringByRemovingPercentEncoding];
        NSString *value = [[pairComponents lastObject] stringByRemovingPercentEncoding];
        
        [params setObject:value forKey:key];
    }
    
    return params;
}

@end

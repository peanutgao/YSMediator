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
static const void *ys_urlSchemeKey = "ys_urlSchemeKey";
static const void *ys_urlHostKey = "ys_urlHostKey";
static const void *ys_sort_block = "ys_sort_block";

@interface YSMediator ()

@property (nonatomic, copy) NSString *urlScheme;
@property (nonatomic, copy) NSString *urlHost;

@end


@implementation YSMediator (Router)


- (void)setUrlScheme:(NSString *)urlScheme {
    objc_setAssociatedObject(self, &ys_urlSchemeKey, urlScheme, OBJC_ASSOCIATION_COPY);
}

- (NSString *)urlScheme {
    return objc_getAssociatedObject(self, &ys_urlSchemeKey);
}

- (void)setUrlHost:(NSString *)urlHost {
    objc_setAssociatedObject(self, &ys_urlHostKey, urlHost, OBJC_ASSOCIATION_COPY);
}

- (NSString *)urlHost {
    return objc_getAssociatedObject(self, &ys_urlHostKey);
}

-(void)setSorted:(BOOL (^)(NSDictionary *))sorted {
    objc_setAssociatedObject(self, &ys_sort_block, sorted, OBJC_ASSOCIATION_COPY);
}

- (BOOL (^)(NSDictionary *))sorted {
    return objc_getAssociatedObject(self, &ys_sort_block);
}


#pragma mark - Open

+ (void)registerScheme:(NSString *)scheme andHost:(NSString *)host {
    if (scheme == nil) {
        YSMediatorAssert(@"注册信息不能为空"); return;
    }
    
    YSMediator *instance = [YSMediator shareMediator];
    instance.urlScheme = scheme;
    instance.urlHost = host;
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
    
    [self searchPathInfo:path successHandle:^(YSMapModel *obj) {
        [YSMediator pushToViewController:obj.mapClassName
                              withParams:obj.paramsMapDict
                                animated:YES callBack:NULL];
        
    } failureHandle:^{
        
    }];
}

+ (void)openURL:(NSString *)urlStr {
    [self openURL:urlStr withSorted:[YSMediator shareMediator].sorted ?:NULL];
}

+ (void)openURL:(NSString *)urlStr withSorted:(BOOL(^)(NSDictionary *params))sorted {
    if (isEmptyString(urlStr)) {
        YSMediatorAssert(@"urlStr为空!!!"); return;
    }
    
    NSURL *url = [NSURL URLWithString:urlStr];
    BOOL b = [self tryToOpenInWebView:urlStr withSorted:sorted];
    if (b) return;
    
    void(^failureHandler)() = ^{
        NSLog(@"无法打开URL:\n<当前Scheme: %@, 注册的Scheme: %@>\n<当前Host: %@, 注册的Host: %@>",\
              url.scheme,\
              [YSMediator shareMediator].urlScheme,\
              url.host,\
              [YSMediator shareMediator].urlHost);
    };
    
    [self searchPathInfo:url.path successHandle:^(YSMapModel *obj) {
        NSString *urlHost = [YSMediator shareMediator].urlHost;
        if ((urlHost && ![url.host isEqualToString:urlHost]) || (![url.scheme isEqualToString:[YSMediator shareMediator].urlScheme])) {
            failureHandler();
        }
        
        [self openInNativePageOfURL:url withMapObj:obj andSorted:sorted];
        
    } failureHandle:^{
        BOOL b = [self tryToOpenInWebView:urlStr withSorted:sorted];
        if (b) return;
        
        failureHandler();
    }];
}


#pragma mark - Other

+ (BOOL)tryToOpenInWebView:(NSString *)urlStr withSorted:(BOOL(^)(NSDictionary *params))sorted {
    NSURL *url = [NSURL URLWithString:urlStr];
    if ([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"]) {
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
        if (sorted) {
            BOOL b = sorted(params);
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

+ (void)openInNativePageOfURL:(NSURL *)url withMapObj:(YSMapModel *)obj andSorted:(BOOL(^)(NSDictionary *params))sorted {
    NSDictionary *params = [self paramsDictWithURL:url];
    if (sorted) {
        BOOL b = sorted(params);
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
        return;
    }
    
}

+ (void)searchPathInfo:(NSString *)path
        successHandle:(void(^)(YSMapModel *obj))successHandler
           failureHandle:(void(^)())failureHandler {

    YSMapModel *map = [[YSMediator shareMediator].mapInfoDict objectForKey:path];
    if (!map
        || map.mapClassName == nil
        || NSClassFromString(map.mapClassName) == nil) {
        NSLog(@"========>  没有找到映射跳转的路径!!!, 请检查是否有添加映射  <========");
        
        if (failureHandler) {
            failureHandler();
        }
        return;
    }
    
    if (successHandler) {
        successHandler(map);
    }
    
/*
    不再支持openURL的方式通过传入map字段来跳转页面
 */
//    [self searchMapModelWithURLPath:path result:^(YSMapModel *map) {
//        if (!map) {
//            NSLog(@"========>  没有找到映射跳转的路径!!!, 请检查是否有添加映射  <========");
//            if (failureHandler) {
//                failureHandler();
//            }
//            return;
//        }
//
//        NSString *clazzName = map.mapClassName;
//        if (clazzName == nil || NSClassFromString(clazzName) == nil) {
//            NSLog(@"========>  没有找到映射的控制器!!!, 请检查是否有添加映射  <========");
//            if (failureHandler) {
//                failureHandler();
//            }
//            return;
//        }
//
//        if (successHandler) {
//            successHandler(clazzName, map);
//        }
//    }];
}

//+ (void)searchMapModelWithURLPath:(NSString *)path result:(void(^)(YSMapModel *map))result {
//    __block YSMapModel *map = [[YSMediator shareMediator].mapDataCache objectForKey:path];
//
//    // 检查是否是映射字符
//    // 检查是否是类名字符
//    if (!map) map = [[YSMediator shareMediator].mapDataCache objectForKey:[NSString stringWithFormat:@"/%@", path]];
//    if (map) {}
//    else if (NSClassFromString(path)) {
//        [[YSMediator shareMediator].mapDataCache enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, YSMapModel * _Nonnull obj, BOOL * _Nonnull stop) {
//            @autoreleasepool {
//                if ([obj.mapClassName isEqualToString:path]) {
//                    map = obj;
//                    *stop = YES;
//                }
//            }
//        }];
//    }
//
//    if (result) {
//        result(map);
//    }
//}


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

//
//  YSMediator+Transition.m
//  HCDoctor
//
//  Created by Joseph Gao on 2017/5/31.
//  Copyright © 2017年 WondersGroup.com. All rights reserved.
//

#import "YSMediator+Transition.h"
#import "YSMediator+Tools.h"
#import "YSMapModel.h"

typedef NS_ENUM(NSInteger, YSMediatorShowType) {
    YSMediatorShowTypePush, 
    YSMediatorShowTypePresent
};


@implementation YSMediator (Transition)


#pragma mark - Push

+ (void)pushToViewController:(NSString *)vcString
                  withParams:(NSDictionary *)params
                    animated:(BOOL)flag
                    callBack:(void(^)(void))callBack {
    if (vcString == nil) {
        YSMediatorAssert(@"跳转的控制器名不能为空"); return;
    }
    [self jumpToTargetWithVCString:vcString
                            params:params
                          animated:flag
                          showType:YSMediatorShowTypePush
                          callBack:callBack];
}

+ (void)pushViewController:(__kindof UIViewController *)vc
                withParams:(NSDictionary *)params
                  animated:(BOOL)flag
                  callBack:(void(^)(void))callBack {
    [self jumpToTargetVC:vc
              withParams:params
                animated:flag
                showType:YSMediatorShowTypePush
                callBack:callBack];
}


#pragma mark - Present

+ (void)presentToViewController:(NSString *)vcString
                     withParams:(NSDictionary *)params
                       animated:(BOOL)flag
                       callBack:(void(^)(void))callBack {
    if (vcString == nil) {
        YSMediatorAssert(@"跳转的控制器名不能为空"); return;
    }

    [self jumpToTargetWithVCString:vcString
                             params:params
                           animated:flag
                           showType:YSMediatorShowTypePresent
                           callBack:callBack];
}

+ (void)presentViewController:(__kindof UIViewController *)vc
                   withParams:(NSDictionary *)params
                     animated:(BOOL)flag
                     callBack:(void (^)(void))callBack {
    [self jumpToTargetVC:vc
               withParams:params
                 animated:flag
                 showType:YSMediatorShowTypePresent
                 callBack:callBack];
}

+ (void)jumpToTargetWithVCString:(NSString *)vcString
                           params:(NSDictionary *)params
                         animated:(BOOL)flag
                         showType:(YSMediatorShowType)showType
                         callBack:(void(^)(void))callBack {
    [self searchMapInfoWithName:vcString params:params result:^(NSString *vcClass, NSDictionary *fixedParams, NSError *error) {
        if (error) return;
        
        UIViewController *targetVC = [[NSClassFromString(vcClass) alloc] init];
        [self jumpToTargetVC:targetVC
                  withParams:fixedParams
                    animated:flag
                    showType:showType
                    callBack:callBack];
    }];
}
     
+ (void)jumpToTargetVC:(__kindof UIViewController *)targetVC
            withParams:(NSDictionary *)params
                animated:(BOOL)flag
              showType:(YSMediatorShowType)showType
                    callBack:(void(^)(void))callBack {
    [self setPropretyOfTarget:targetVC withParams:params handle:^(UIViewController *targetVC) {
        UIViewController *from = [self topViewController];
        
        switch (showType) {
            case YSMediatorShowTypePush: {
                UINavigationController *nav = from.navigationController;
                if (!nav) {
                    NSString *str = [NSString stringWithFormat:@"控制器:%@ 没有导航控制器", from];
                    YSMediatorAssert(str);
                    return;
                }
                
                targetVC.hidesBottomBarWhenPushed = YES;
                [nav pushViewController:targetVC animated:YES];
                if (callBack) {
                    callBack();
                }
                break;
            }
            case YSMediatorShowTypePresent: {
                if (from.presentedViewController) {
                    [from dismissViewControllerAnimated:NO completion:^{
                        [from presentViewController:targetVC animated:YES completion:callBack];
                    }];
                }
                else {
                    [from presentViewController:targetVC animated:YES completion:callBack];
                }
            }
                
            default:
                break;
        }
    }];
}

+ (UIViewController *)topViewController {
    return [self topViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

+ (UIViewController *)topViewController:(UIViewController *)rootViewController {
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController;
        return [self topViewController:[navigationController.viewControllers lastObject]];
    }
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)rootViewController;
        return [self topViewController:tabBarController.selectedViewController];
    }
    if (rootViewController.presentedViewController) {
        return [self topViewController:rootViewController.presentedViewController];
    }
    return rootViewController;
}


#pragma mark - Pop

+ (void)popToViewControllerName:(NSString *)vcName animated:(BOOL)flag {
    if (vcName ==  nil) {
        YSMediatorAssert(@"返回的控制器名不能为空!!!"); return;
    }
    
    Class clazz = NSClassFromString(vcName);
    if (clazz) {
        [self popToViewControllerByVCClass:clazz animated:flag];
        return;
    }
    else {
        clazz = [self mapClassByName:vcName];
        if (clazz) {
            [self popToViewControllerByVCClass:clazz animated:flag];
            return;
        }
        else {
            NSArray *arr = [vcName componentsSeparatedByString:@"../"];
            if (arr.count == 0) return;
            
            UIViewController *from = [self topViewController];
            UINavigationController *nav = from.navigationController;
            UIViewController *to = nil;
            
            if (arr.count >= nav.childViewControllers.count) {
                [nav popToRootViewControllerAnimated:flag];
            }
            else {
                to = nav.childViewControllers[nav.childViewControllers.count - arr.count];
                [nav popToViewController:to animated:flag];
            }
            
            return;
        }
    }

    // 到此标明遍历结束, 在堆栈中没有找到要pop的控制器
    YSMediatorAssert(@"当前NavController堆栈中没有当前类型的控制器对象");
}

+ (void)popToViewControllerByVCClass:(Class)clazz animated:(BOOL)flag {
    UIViewController *from = [self topViewController];
    UINavigationController *nav = from.navigationController;
    UIViewController *to = nil;
    
    for (NSInteger i = 0; i < nav.viewControllers.count; i++) {
        @autoreleasepool {
            to = [nav.viewControllers objectAtIndex:i];
            if ([to isMemberOfClass:clazz]) {
                [nav popToViewController:to animated:flag];
                return;
            }
        }
    }
    
//    for(NSInteger i = nav.viewControllers.count - 1; i >= 0; i--) {
//        @autoreleasepool {
//            to = [nav.viewControllers objectAtIndex:i];
//            if ([to isMemberOfClass:clazz]) {
//                [nav popToViewController:to animated:flag];
//                return;
//            }
//        }
//    }
    
    NSLog(@"\n");
    NSLog(@"=====================================");
    NSLog(@"============> Warning <============");
    NSLog(@"    堆栈中没有找到要返回的控制器!!!");
    NSLog(@"=====================================\n");
    NSLog(@"\n");
}

+ (Class)mapClassByName:(NSString *)name {
    YSMapModel *map = [[YSMediator shareMediator].mapInfoDict objectForKey:[NSString stringWithFormat:@"/%@", name]];
    if (map) return NSClassFromString(map.mapClassName);
    
    return nil;
}


#pragma mark - Dismiss

+ (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^ __nullable)(void))completion {
    UIViewController *from = [self topViewController];
    [from.navigationController dismissViewControllerAnimated:flag completion:completion];
}


#pragma mark - Other

+ (void)searchMapInfoWithName:(NSString *)name
                       params:(NSDictionary *)params
                       result:(void(^)(NSString *vcClass, NSDictionary *fixedParams, NSError *error))result {
    YSMapModel *map = [self mapModelWithName:name];
    NSDictionary *fixedParams = params;
    NSString *vcName = name;
    if (map) {
        vcName = map.mapClassName;
        if (map.paramsMapDict) {
            fixedParams = [self fixParams:params withMapDict:map.paramsMapDict];
        }
    }

    if ([self checkIsViewController:vcName]) {
        if (result) {
            result(vcName, fixedParams, nil);
        }
        return;
    }
    
    NSString *errorStr = @"没有找到当前类型的控制器类, 请检查是否有添加映射";
    YSMediatorAssert(errorStr);
        
    if (result) {
        NSError *error = [NSError errorWithDomain:YS_MEDIATOR_ERROR_DOMAIN
                                             code:YS_MEDIATOR_MAP_ERROR_CODE
                                         userInfo:@{NSLocalizedDescriptionKey: errorStr}];
        result(vcName, fixedParams, error);
    }
}

+ (BOOL)checkIsViewController:(NSString *)name {
    Class Clazz = NSClassFromString(name);
    return !(Clazz == nil || ![Clazz isSubclassOfClass:[UIViewController class]]);
}

+ (YSMapModel *)mapModelWithName:(NSString *)name {
    __block YSMapModel *result = [self searchMapInfoDictWithPath:[NSString stringWithFormat:@"/%@", name]];
    
    if (result) return result;
    if (NSClassFromString(name)) {
        [[YSMediator shareMediator].mapInfoDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, YSMapModel * _Nonnull obj, BOOL * _Nonnull stop) {
            @autoreleasepool {
                if ([obj.mapClassName isEqualToString:name]) {
                    result = obj;
                    *stop = YES;
                }
            }
        }];
    }
    
    return result;
}

+ (YSMapModel *)searchMapInfoDictWithPath:(NSString *)path {
    return [[YSMediator shareMediator].mapInfoDict objectForKey:path];
}

@end

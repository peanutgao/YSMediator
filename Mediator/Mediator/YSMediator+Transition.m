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
    
    [self searchMapInfoWithName:vcString params:params result:^(NSString *vcClass, NSDictionary *fixedParams) {
        [self jumpToTargetWithClassName:vcClass
                                 params:fixedParams
                               animated:flag
                               showType:YSMediatorShowTypePush
                  transitioningDelegate:nil
                               callBack:callBack];
    }];
}

+ (void)pushViewController:(__kindof UIViewController *)vc
                withParams:(NSDictionary *)params
                  animated:(BOOL)flag
                  callBack:(void(^)(void))callBack {
    [self jumpToTargetVC:vc
              withParams:params
                animated:flag
                showType:YSMediatorShowTypePush
   transitioningDelegate:nil
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
    
    [self searchMapInfoWithName:vcString params:params result:^(NSString *vcClass, NSDictionary *fixedParams) {
        [self jumpToTargetWithClassName:vcClass
                                 params:fixedParams
                               animated:flag
                               showType:YSMediatorShowTypePresent
                  transitioningDelegate:nil
                               callBack:callBack];
    }];
}

+ (void)presentViewController:(__kindof UIViewController *)vc
                   withParams:(NSDictionary *)params
                     animated:(BOOL)flag
                     callBack:(void (^)(void))callBack {
    [self jumpToTargetVC:vc
               withParams:params
                 animated:flag
                 showType:YSMediatorShowTypePresent
    transitioningDelegate:nil
                 callBack:callBack];
}


+ (void)jumpToTargetWithClassName:(NSString *)tCName
                           params:(NSDictionary *)params
                         animated:(BOOL)flag
                         showType:(YSMediatorShowType)showType
            transitioningDelegate:(id<UIViewControllerTransitioningDelegate>)delegate
                         callBack:(void(^)(void))callBack {
    if (tCName == nil) {
        YSMediatorAssert(@"跳转的控制器名不能为空"); return;
    }
    
    Class Clazz = NSClassFromString(tCName);
    if (Clazz == nil || ![Clazz isSubclassOfClass:[UIViewController class]]) {
        NSLog(@"========>  没有找到当前类型的控制器类!!!, 请检查是否有添加映射  <========");
        return;
    }
    
    UIViewController *targetVC = [[Clazz alloc] init];
    [self jumpToTargetVC:targetVC
              withParams:params
                animated:flag
                showType:showType
   transitioningDelegate:delegate
                callBack:callBack];
}

+ (void)jumpToTargetVC:(__kindof UIViewController *)targetVC
            withParams:(NSDictionary *)params
                animated:(BOOL)flag
              showType:(YSMediatorShowType)showType
transitioningDelegate:(id<UIViewControllerTransitioningDelegate>)delegate
                    callBack:(void(^)(void))callBack {
    
    // 属性赋值
    [self setPropretyOfTarget:targetVC withParams:params handle:^(UIViewController *targetVC) {
        UIViewController *from = [self topViewController];
        UINavigationController *nav = from.navigationController;
        
        // 跳转
        switch (showType) {
            case YSMediatorShowTypePush: {
                targetVC.hidesBottomBarWhenPushed = YES;
                [nav pushViewController:targetVC animated:YES];
                if (callBack) {
                    callBack();
                }
                break;
            }
            case YSMediatorShowTypePresent: {
                if (delegate) {
                    if ([delegate conformsToProtocol:@protocol(UIViewControllerTransitioningDelegate)]) {
                        targetVC.transitioningDelegate = delegate;
                        targetVC.modalPresentationStyle = UIModalPresentationCustom;
                    }
                    else {
                        YSMediatorAssert(@"自定义转场动画代理需要遵守UIViewControllerTransitioningDelegate协议");
                    }
                }
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
    return [self topViewControllerOfRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

+ (UIViewController *)topViewControllerOfRootViewController:(UIViewController *)rootViewController {
    UIViewController *topVC = rootViewController;
    
    if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UIViewController *lastViewController = [[(UINavigationController *)rootViewController viewControllers] lastObject];
        topVC = [self topViewControllerOfRootViewController:lastViewController];
    }
    
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UIViewController *selectedVC = [(UITabBarController *)rootViewController selectedViewController];
        topVC = [self topViewControllerOfRootViewController:selectedVC];
    }
    
    return topVC;
}


#pragma mark - Pop

+ (void)popToViewControllerName:(NSString *)vcName animated:(BOOL)flag {
    if (vcName ==  nil) {
        YSMediatorAssert(@"返回的控制器名不能为空"); return;
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
    
    for(NSInteger i = nav.viewControllers.count - 1; i >= 0; i--) {
        @autoreleasepool {
            to = [nav.viewControllers objectAtIndex:i];
            if ([to isMemberOfClass:clazz]) {
                [nav popToViewController:to animated:flag];
                return;
            }
        }
    }
    
    NSLog(@"=========> 堆栈中没有找到要返回的控制器!!! <==========");
}

+ (Class)mapClassByName:(NSString *)name {
    YSMapModel *map = [[YSMediator shareMediator].mapInfoDict objectForKey:[NSString stringWithFormat:@"/%@", name]];
    if (map) return NSClassFromString(map.mapClassName);
    
    return nil;
}


#pragma mark - Other

+ (void)searchMapInfoWithName:(NSString *)name
                      params:(NSDictionary *)params
                       result:(void(^)(NSString *vcClass, NSDictionary *fixedParams))result {
    YSMapModel *map = [self mapModelWithName:name];
    NSDictionary *fixedParams = params;
    NSString *vcName = name;
    if (map) {
        vcName = map.mapClassName;
        fixedParams = map.paramsMapDict;
        if (fixedParams) {
            fixedParams = [self fixParams:params withMapDict:fixedParams];
        }
    }
    
    if (result) {
        result(vcName, fixedParams);
    }
}

+ (YSMapModel *)mapModelWithName:(NSString *)name {
    __block YSMapModel *result = nil;

    result = [[YSMediator shareMediator].mapInfoDict objectForKey:[NSString stringWithFormat:@"/%@", name]];
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


@end

//
//  YSMediator+Transition.h
//  HCDoctor
//
//  Created by Joseph Gao on 2017/5/31.
//  Copyright © 2017年 WondersGroup.com. All rights reserved.
//

#import "YSMediator.h"

@interface YSMediator (Transition)

/**
 push方式展现控制器

 @param vcString 跳转的目标控制器, 可以是字符串也可以是映射的字段
 @param params 传递的参数字典, 可以是映射的字段, 也可以key要和push到的控制器接口的参数名一致
 @param flag push时是否显示动画
 @param callBack push完成后回调
 */
+ (void)pushToViewController:(NSString *)vcString
                withParams:(NSDictionary *)params
                  animated:(BOOL)flag
                  callBack:(void(^)(void))callBack;

/**
 push方式展现控制器

 @param vc push到的控制器
 @param params 传递的参数字典, 注意: key要和push到的控制器接口的参数名一致
 @param flag push时是否显示动画
 @param callBack push完成后回调
 */
+ (void)pushViewController:(__kindof UIViewController *)vc
                withParams:(NSDictionary *)params
                  animated:(BOOL)flag
                  callBack:(void(^)(void))callBack;


/**
 present方式展现控制器
 
 @param vcString 跳转的目标控制器, 可以是字符串也可以是映射的字段
 @param params 传递的参数字典, 可以是映射的字段, 也可以key要和push到的控制器接口的参数名一致
 @param flag push时是否显示动画
 @param callBack push完成后回调
 */
+ (void)presentToViewController:(NSString *)vcString
                     withParams:(NSDictionary *)params
                       animated:(BOOL)flag
                       callBack:(void(^)(void))callBack;

/**
 present方式展现控制器

 @param vc present到的控制器
 @param params 传递的参数字典, 注意: key要和push到的控制器接口的参数名一致
 @param flag present时是否显示动画
 @param callBack present完成后回调
 */
+ (void)presentViewController:(__kindof UIViewController *)vc
                   withParams:(NSDictionary *)params
                     animated:(BOOL)flag
                     callBack:(void(^)(void))callBack;


/**
 定义返回对应控制器, 支持ViewController类字符串 映射字符串 以及 ../../方式

 @param vcName 支持ViewController类字符串 映射字符串 以及 ../../方式
 @param flag 是否需要动画
 */
+ (void)popToViewControllerName:(NSString *)vcName animated:(BOOL)flag;

+ (UIViewController *)topViewController;

@end

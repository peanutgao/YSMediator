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
 
 @remark 例:
 AViewController映射的字段为 aview, push时需要给属性 mid传值, 则:
 @code
 [YSMediator pushToViewController:@"aview"
              withParams:@{@"mid": @"abcdefg"}
                         animated:YES
                         callBack:^{
                             NSLog(@"Push finish");
                         }];
 @endcode

 @param vcString 跳转的目标控制器名字, 可以是字符串也可以是映射的字段
 @param params 传递的参数字典, key可以是映射的字段, 也可以要目标控制器属性名一致
 @param flag push时是否显示动画
 @param callBack push完成后回调
 */
+ (void)pushToViewController:(NSString *_Nonnull)vcString
                withParams:(NSDictionary *_Nullable)params
                  animated:(BOOL)flag
                  callBack:(void(^)(void))callBack;

/**
 push方式展现控制器

 @param vc push的目标控制器
 @param params 传递的参数字典, 注意: key要和push到的控制器接口的参数名一致
 @param flag push时是否显示动画
 @param callBack push完成后回调
 */
+ (void)pushViewController:(__kindof UIViewController *_Nonnull)vc
                withParams:(NSDictionary *_Nullable)params
                  animated:(BOOL)flag
                  callBack:(void(^)(void))callBack;


/**
 @brief present方式展现控制器
 
 @remark 例:
 AViewController映射的字段为 aview, present时需要给属性 mid传值, 则:
 @code
 [YSMediator presentToViewController:@"aview"
                          withParams:@{@"mid": @"abcdefg"}
                            animated:YES
                            callBack:^{
                                NSLog(@"Push finish");
                            }];
 @endcode
 
 @param vcString 跳转的目标控制器, 可以是字符串也可以是映射的字段
 @param params 传递的参数字典, key可以是映射的字段, 也可以要目标控制器属性名一致
 @param flag push时是否显示动画
 @param callBack push完成后回调
 */
+ (void)presentToViewController:(NSString *_Nonnull)vcString
                     withParams:(NSDictionary *_Nullable)params
                       animated:(BOOL)flag
                       callBack:(void(^)(void))callBack;

/**
 present方式展现控制器

 @param vc present到的控制器
 @param params 传递的参数字典, 注意: key要和push到的控制器接口的参数名一致
 @param flag present时是否显示动画
 @param callBack present完成后回调
 */
+ (void)presentViewController:(__kindof UIViewController *_Nonnull)vc
                   withParams:(NSDictionary *_Nullable)params
                     animated:(BOOL)flag
                     callBack:(void(^)(void))callBack;


/*!
 定义返回对应控制器,支持:
 * 控制器类型的字符串
 * 控制器映射的字符串
 * 以及 ../../ 相对路径的方式

 @param vcName 支持ViewController类字符串 映射字符串 以及 ../../ 相对路径的方式
 @param flag 是否需要动画
 */
+ (void)popToViewControllerName:(NSString *_Nonnull)vcName animated:(BOOL)flag;

/**
 dismiss控制器

 @param flag 是否显示动画
 @param completion 完成后回调
 */
+ (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^ __nullable)(void))completion;

/// 当前页面最顶端的控制器
+ (UIViewController *)topViewController;

@end

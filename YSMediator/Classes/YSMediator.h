//
//  YSMediator.h
//  Mediator
//
//  Created by Joseph Gao on 2017/4/6.
//  Copyright © 2017年 Joseph. All rights reserved.
//

#import <UIKit/UIKit.h>

#define YSMediatorAssert(desc) {\
            NSLog(@"\n\n\
                    ============================\n\
           !!!!!! %@ !!!!!!\n\
                    ============================\n\
                    ", desc);\
            NSAssert(NO, desc);\
        }

#define YS_MEDIATOR_ERROR_DOMAIN @"com.ysmediator.error"
#define YS_MEDIATOR_MAP_ERROR_CODE 1900

NS_ASSUME_NONNULL_BEGIN

@interface YSMediator : NSObject


/**
 映射跳转页面控制器, 可以在appDelegate中集中写所有的映射

 @param name url映射的字符, 非空
 @param toClassName 对应的类名名称字符, 非空; 如果传入的是控制器类名,则跳转控制器, 如果传入的是NSObject对象, 则是实例化一个NSObject对象
 @param paramsMapDict 映射参数字典. key为当前类的要映射的属性字段, value为url中要映射的参数key; 如果参数一致, 可以不写
 */

+ (BOOL)mapName:(NSString *_Nonnull)name
    toClassName:(NSString *_Nonnull)toClassName
    withParams:(NSDictionary *_Nullable)paramsMapDict;



/// YSMediator 单例
+ (instancetype)shareMediator;

/// 映射表
@property (nonatomic, strong, readonly) NSDictionary *mapInfoDict;
/// 用于跳转web页面的baseViewController
@property (nonatomic, copy) NSString *baseWebClassName;
/// 限制跳转的规则
@property (nonatomic, copy) BOOL(^filter)(NSDictionary *params);

@end


@interface NSObject (YSMediator)

/**
 注册页面映射, 需要写在要映射的类的 + load 方法中
 
 @param name 映射的字符串
 @param paramsMapDict 映射参数字典. key为当前类的要映射的属性字段, value为url中要映射的参数key; 如果参数一致, 可以不写
 */
+ (void)mapName:(NSString *_Nonnull)name withParams:(NSDictionary *_Nullable)paramsMapDict;

/**
 注册baseWebView页面映射, 需要写在要映射的类的 + load 方法中
 
 @param name 映射的字符串
 @param paramsMapDict 映射参数字典. key为当前类的要映射的属性字段, value为url中要映射的参数key; 如果参数一致, 可以不写
 */
+ (void)mapAsBaseWebViewWithName:(NSString *_Nonnull)name andParams:(NSDictionary *_Nullable)paramsMapDict;

@end

NS_ASSUME_NONNULL_END

#import "YSMediator+Transition.h"
#import "YSMediator+Router.h"
#import "YSMediator+TargetAction.h"

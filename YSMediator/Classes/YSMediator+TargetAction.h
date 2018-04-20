//
//  YSMediator+TargetAction.h
//  Mediator
//
//  Created by Joseph Gao on 2017/4/11.
//  Copyright © 2017年 Joseph. All rights reserved.
//

#import "YSMediator.h"

@interface YSMediator (TargetAction)


/**
 调用`实例`方法:
 @remark列:
 @code
 NSString *name = @"Hello World";
 id result = [YSMediator performTarget:@"WDTestViewController" doInstanceAction:@"printInfoWithAge:andName:" withObjects:[NSNull null], name, nil];
 @endcode
 
 @warning注意:
 1. 不支持C基本类型;
 2. 可变参数结尾一定要有nil;
 3. 如果传递的参数中有nil时, 参数用 [NSNull null]

 @param targetClass 调用方法的目标控制器
 @param aSelector 方法字符串
 @param obj1 可变参数,注意: 1. 不支持C基本类型, 2. 可变参数结尾一定要有nil; 3. 如果传递的参数中有nil时, 参数用 [NSNull null]
 @return 返回值
 */
+ (id)performTarget:(NSString *_Nonnull)targetClass doInstanceAction:(NSString *_Nonnull)aSelector withObjects:(id)obj1,...;

/**
 调用`类`方法:
 
 @remark列:
 @code
 NSString *name = @"Hello World";
 id result = [YSMediator performTarget:@"WDTestViewController" doInstanceAction:@"printInfoWithAge:andName:" withObjects:[NSNull null], name, nil];
 @endcode
 
 @warning 注意:
 1. 不支持C基本类型;
 2. 可变参数结尾一定要有nil;
 3. 如果传递的参数中有nil时, 参数用 [NSNull null]
 
 @param targetClass 调用方法的目标控制器
 @param aSelector 方法字符串
 @param obj1 可变参数,注意: 1. 不支持C基本类型, 2. 可变参数结尾一定要有nil; 3. 如果传递的参数中有nil时, 参数用 [NSNull null]
 @return 返回值
 */
+ (id)performTarget:(NSString *_Nonnull)targetClass doClassAction:(NSString *_Nonnull)aSelector withObjects:(id)obj1,...;

@end

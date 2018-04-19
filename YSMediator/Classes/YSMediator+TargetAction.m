//
//  YSMediator+TargetAction.m
//  Mediator
//
//  Created by Joseph Gao on 2017/4/11.
//  Copyright © 2017年 Joseph. All rights reserved.
//

#import <objc/runtime.h>
#import "YSMediator+TargetAction.h"
#import "YSMediator+Tools.h"

typedef NS_ENUM(NSInteger, MediatorMethodType) {
    MediatorMethodTypeInstance,
    MediatorMethodTypeClass,
};

@implementation YSMediator (TargetAction)

+ (id)performTarget:(NSString *)targetClass doInstanceAction:(NSString *)aSelector withObjects:(id)obj1,... {
    NSMutableArray *objs = [NSMutableArray array];
    if (obj1) {
        va_list arg_list;
        id arg;
        va_start(arg_list, obj1);
        while ((arg = va_arg(arg_list, id))) {
            [objs addObject:arg];
        }
        va_end(arg_list);
    }

    return [self performTarget:targetClass
                      doAction:aSelector
                    methodType:MediatorMethodTypeInstance
                   withObjects:objs];
}

+ (id)performTarget:(NSString *)targetClass doClassAction:(NSString *)aSelector withObjects:(id)obj1,... {
    NSMutableArray *objs = [NSMutableArray array];
    if (obj1) {
        va_list arg_list;
        id arg;
        va_start(arg_list, obj1);
        while ((arg = va_arg(arg_list, id))) {
            [objs addObject:arg];
        }
        va_end(arg_list);
    }
    
    return [self performTarget:targetClass
                      doAction:aSelector
                    methodType:MediatorMethodTypeClass
                   withObjects:objs];
}


+ (id)performTarget:(NSString *)targetClass
             doAction:(NSString *)aSelector
           methodType:(MediatorMethodType)methodType
        withObjects:(NSArray *)arguments {
    
    if (isEmptyString(targetClass) || isEmptyString(aSelector)) {
        YSMediatorAssert(@"====> !!! Error: targetClass or aSelector is Empty !!!"); return nil;
    }
    
    Class clazz = NSClassFromString(targetClass);
    if (clazz == nil) {
        YSMediatorAssert(@"====> !!! Error: targetClass is nil"); return nil;
    }
    
    
    SEL action = NSSelectorFromString(aSelector);
    id obj = nil;
    NSMethodSignature *signature = nil;

    switch (methodType) {
        case MediatorMethodTypeInstance: {
            signature = [clazz instanceMethodSignatureForSelector:action];
            obj = [[clazz alloc] init];
            break;
        }
        case MediatorMethodTypeClass: {
            signature = [clazz methodSignatureForSelector:action];
            obj = clazz;
            break;
        }
        default:
            break;
    }

    if (signature == nil) {
        YSMediatorAssert(@"Cannot find the method invocation!!!"); return nil;
    }
    
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = obj;
    invocation.selector = action;
    
    // 设置参数
    NSUInteger argsCount = signature.numberOfArguments - 2;  // 参数个数去除_cmd 和 self
    for (int i = 0; i < MIN(arguments.count, argsCount); i++) {
        id obj = arguments[i];
        
        if ([obj isEqual:[NSNull null]]) continue;
        
        [invocation setArgument:&obj atIndex:i+2];  // 前2个参数是 _cmd 和 self
    }
    
    [invocation retainArguments];
    
    // 调用
    [invocation invoke];
    
    // 返回值
    id returnObj = nil;
    if (signature.methodReturnLength) {
        [invocation setReturnValue:&returnObj];
    }
    
    return returnObj;
}

@end

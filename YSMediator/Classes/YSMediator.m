//
//  YSMediator.m
//  Mediator
//
//  Created by Joseph Gao on 2017/4/6.
//  Copyright © 2017年 Joseph. All rights reserved.
//

#import <objc/runtime.h>
#import "YSMediator.h"
#import "YSMediator+Tools.h"
#import "YSMapModel.h"

@interface YSMediator ()

@property (nonatomic, strong) NSMutableDictionary *mapInfoDictM;

@end


@implementation YSMediator


#pragma mark - Singleton

static YSMediator *_instance;

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [super allocWithZone:zone];
    });
    return _instance;
}


- (id)copyWithZone:(NSZone *)zone {
    return _instance;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    return _instance;
}

+ (instancetype)shareMediator {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[YSMediator alloc] init];
        _instance->_mapInfoDict = [NSDictionary dictionary];
    });
    return _instance;
}


#pragma mark - Public Method

+ (BOOL)mapName:(NSString *_Nonnull)name
    toClassName:(NSString *_Nonnull)toClassName
     withParams:(NSDictionary *_Nullable)paramsMapDict {
    return [self mapName:name
             toClassName:toClassName
         isAsBaseWebView:NO
              withParams:paramsMapDict];
}

+ (BOOL)mapName:(NSString *_Nonnull)name
    toClassName:(NSString *_Nonnull)toClassName
isAsBaseWebView:(BOOL)isBaseWebView
     withParams:(NSDictionary *_Nullable)paramsMapDict {
    if (isEmptyString(name) || isEmptyString(toClassName)) {
        YSMediatorAssert(@"映射信息不能为空!!!") return NO;
    }
    if (NSClassFromString(toClassName) == nil) {
        YSMediatorAssert(@"映射的类名错误!!!") return NO;
    }
    
    YSMapModel *mapData = [YSMapModel modelWithMapName:name
                                           mapClassName:toClassName
                                          paramsMapDict: paramsMapDict];
    [[YSMediator shareMediator].mapInfoDictM setObject:mapData forKey:mapData.pathName];
    [YSMediator shareMediator]->_mapInfoDict = [YSMediator shareMediator].mapInfoDictM.copy;
    if (isBaseWebView) [YSMediator shareMediator]->_baseWebClassName = mapData.mapClassName;
    
    return YES;
}


#pragma mark - Lazy Loading

- (NSMutableDictionary *)mapInfoDictM {
    if (!_mapInfoDictM) {
        _mapInfoDictM = [NSMutableDictionary dictionary];
    }
    return _mapInfoDictM;
}

@end


@implementation NSObject (YSMediator)

+ (void)mapName:(NSString *_Nonnull)name withParams:(NSDictionary *_Nullable)paramsMapDict {
    [YSMediator mapName:name toClassName:NSStringFromClass(self.class) isAsBaseWebView:NO withParams:paramsMapDict];
}

+ (void)mapAsBaseWebViewWithName:(NSString *_Nonnull)name andParams:(NSDictionary *_Nullable)paramsMapDict {
    [YSMediator mapName:name toClassName:NSStringFromClass(self.class) isAsBaseWebView:YES withParams:paramsMapDict];
}

@end


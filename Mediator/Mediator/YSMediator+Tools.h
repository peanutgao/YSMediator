//
//  YSMediator+Tools.h
//  CPPatient
//
//  Created by Joseph Koh on 2017/10/13.
//  Copyright © 2017年 WondersGroup.com. All rights reserved.
//

#import <objc/runtime.h>
#import "YSMediator.h"

@interface YSMediator (Tools)

+ (void)setPropretyOfTarget:(id)target
                 withParams:(NSDictionary *)params
                     handle:(void(^)(id target))handler;

+ (NSDictionary *)fixParams:(NSDictionary *)params withMapDict:(NSDictionary *)mapDict;

@end


static inline BOOL isEmptyString(NSString *str) {
    if (str == nil
        || (NSNull *)str == [NSNull null]
        || [[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        return YES;
    }
    return NO;
}

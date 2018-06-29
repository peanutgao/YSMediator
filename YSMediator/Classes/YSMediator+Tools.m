//
//  YSMediator+Tools.m
//  CPPatient
//
//  Created by Joseph Koh on 2017/10/13.
//  Copyright © 2017年 WondersGroup.com. All rights reserved.
//

#import "YSMediator+Tools.h"

@implementation YSMediator (Tools)

typedef void(^YSMediatorEnumeration)(Class cls, BOOL *stop);

+ (void)setPropretyOfTarget:(id)target
                 withParams:(NSDictionary *)params
                     handle:(void(^)(id target))handler {
    if ([params isKindOfClass:[NSDictionary class]]
        && params
        && params != (id)kCFNull) {
        
        [self enumerateTargetClass:[target class] enumeration:^(__unsafe_unretained Class cls, BOOL *stop) {
            NSMutableArray *propertiesArray = [NSMutableArray array];
            NSMutableArray *attributesArray = [NSMutableArray array];
            unsigned int outCount = 0;
            
            objc_property_t *properties = class_copyPropertyList(cls, &outCount);
            
            for (unsigned int i = 0; i < outCount; i++) {
                objc_property_t property = properties[i];
                NSString *propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
                [propertiesArray addObject:propertyName];
                
                NSString *attributeName = [NSString stringWithUTF8String:getPropertyType(property)];
                [attributesArray addObject:attributeName];
            }
            
            for (int i = 0; i < propertiesArray.count; i++) {
                NSString *property = propertiesArray[i];
                NSString *attribute = attributesArray[i];
                id value = [params objectForKey:property];
                
                if (value == nil) continue;
                if ([value isKindOfClass:NSClassFromString(attribute)] ||
                    [self isKindOfBlockClass:value]) {
                    [target setValue:value forKey:property];
                }
                
                // 数字类型赋值
                // https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html
                if ([[attribute uppercaseString] isEqualToString:@"Q"] ||       // NSInterger
                    [[attribute uppercaseString] isEqualToString:@"I"]) {       // Int
                    NSNumber *r = [NSNumber numberWithInteger:[value integerValue]];
                    if (r) [target setValue:r forKey:property];
                }
                else if ([[attribute uppercaseString] isEqualToString:@"D"] ||  // Double
                         [[attribute uppercaseString] isEqualToString:@"L"]) {  // Long
                    NSNumber *r = [NSNumber numberWithInteger:[value doubleValue]];
                    if (r) [target setValue:r forKey:property];
                }
                else if ([[attribute uppercaseString] isEqualToString:@"F"]) {  // Float
                    NSNumber *r = [NSNumber numberWithInteger:[value floatValue]];
                    if (r) [target setValue:r forKey:property];
                }
            }
            
            free(properties);
        }];
    }
    
    if (handler) {
        handler(target);
    }
}


+ (BOOL)isKindOfBlockClass:(id)item {
    id block = ^{};
    Class clz = [block class];
    while ([clz superclass] != [NSObject class]) {
        clz = [clz superclass];
    }
    return [item isKindOfClass:clz];
}

+ (void)enumerateTargetClass:(Class)targetClass enumeration:(YSMediatorEnumeration)enumeration {
    if (enumeration == nil) return;
    
    BOOL stop = NO;
    Class c = targetClass;
    while (c && !stop) {
        enumeration(c, &stop);
        c = class_getSuperclass(c);
        
        if (c == [NSObject class]) {
            stop = YES;
        } else {
            stop = NO;
        }
    }
    
}

static const char *getPropertyType(objc_property_t property) {
    const char *attributes = property_getAttributes(property);
    //printf("attributes=%s\n", attributes);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T' && attribute[1] != '@') {
            // it's a C primitive type:
            
            // if you want a list of what will be returned for these primitives, search online for
            // "objective-c" "Property Attribute Description Examples"
            // apple docs list plenty of examples of what you get for int "i", long "l", unsigned "I", struct, etc.
            
            NSString *name = [[NSString alloc] initWithBytes:attribute + 1 length:strlen(attribute) - 1 encoding:NSASCIIStringEncoding];
            return (const char *)[name cStringUsingEncoding:NSASCIIStringEncoding];
        }
        else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
            // it's an ObjC id type:
            return "id";
        }
        else if (attribute[0] == 'T' && attribute[1] == '@') {
            // it's another ObjC object type:
            NSString *name = [[NSString alloc] initWithBytes:attribute + 3 length:strlen(attribute) - 4 encoding:NSASCIIStringEncoding];
            if (name) {
                return (const char *)[name cStringUsingEncoding:NSASCIIStringEncoding];
            }
            else {
                // TODO: block判断 待优化
                return "Block";
            }
            
        }
    }
    return "";
}


+ (NSDictionary *)fixParams:(NSDictionary *)params withMapDict:(NSDictionary *)mapDict {
    if (!params || [params isEqual:[NSNull null]] || ![params isKindOfClass:[NSDictionary class]]) return nil;
    if (!mapDict || [mapDict isEqual:[NSNull null]] || ![mapDict isKindOfClass:[NSDictionary class]]) return params;
    
    
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:params.count];
    //NSLog(@"\n%@", params);
    [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        @autoreleasepool {
            NSString *k = key;
            NSString *mapKey = [mapDict valueForKey:key];
            if (mapKey) k = mapKey;
            [result setObject:obj forKey:k];
        }
    }];
    
    return result;
}


@end

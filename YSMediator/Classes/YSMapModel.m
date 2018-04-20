//
//  YSMapModel.m
//  Mediator
//
//  Created by Joseph Koh on 08/12/2017.
//  Copyright © 2017 Joseph. All rights reserved.
//

#import "YSMapModel.h"

@implementation YSMapModel

+ (instancetype)modelWithMapName:(NSString *)mapName
                     mapClassName:(NSString *)mapClassName
                    paramsMapDict:(NSDictionary *)paramsMapDict {
    YSMapModel *model = [[self alloc] init];
   
    model.mapName = mapName;
    model.pathName = [NSString stringWithFormat:@"/%@", mapName];
    model.mapClassName = mapClassName;
    model.paramsMapDict = [self swapDictionary:paramsMapDict];
    
    return model;
}

+ (NSDictionary *)swapDictionary:(NSDictionary *)dict {
    NSArray *keys = dict.allKeys;
    NSArray *values = [dict objectsForKeys:keys notFoundMarker:[NSNull null]];
    return [NSDictionary dictionaryWithObjects:keys forKeys:values];
}

@end

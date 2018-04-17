//
//  YSMapModel.m
//  Mediator
//
//  Created by Joseph Koh on 08/12/2017.
//  Copyright © 2017 Joseph. All rights reserved.
//

#import "YSMapModel.h"

@implementation YSMapModel

+ (instancetype)modelWithPathName:(NSString *)pathName
                     mapClassName:(NSString *)mapClassName
                    paramsMapDict:(NSDictionary *)paramsMapDict {
    YSMapModel *model = [[self alloc] init];
   
    model.pathName = pathName;
    model.mapClassName = mapClassName;
    model.paramsMapDict = paramsMapDict;
    
    return model;
}

@end

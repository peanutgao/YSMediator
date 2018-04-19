//
//  YSMapModel.h
//  Mediator
//
//  Created by Joseph Koh on 08/12/2017.
//  Copyright © 2017 Joseph. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YSMapModel : NSObject

@property (nonatomic, copy) NSString *mapName;
@property (nonatomic, copy) NSString *pathName;
@property (nonatomic, copy) NSString *mapClassName;
@property (nonatomic, strong) NSDictionary *paramsMapDict;

+ (instancetype)modelWithMapName:(NSString *)mapName
                     mapClassName:(NSString *)mapClassName
                    paramsMapDict:(NSDictionary *)paramsMapDict;

@end

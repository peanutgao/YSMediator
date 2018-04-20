//
//  LocalViewController.h
//  YSMediator_Example
//
//  Created by Joseph Koh on 2018/4/20.
//  Copyright © 2018年 peanutgao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocalViewController : UIViewController

@property (nonatomic, assign) NSInteger idx;
@property (nonatomic, copy) void(^actionHandler)(NSInteger idx);

@end

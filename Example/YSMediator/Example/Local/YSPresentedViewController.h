//
//  YSPresentedViewController.h
//  YSMediator_Example
//
//  Created by Joseph Koh on 2018/4/20.
//  Copyright © 2018年 peanutgao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YSPresentedViewController : UIViewController

@property (nonatomic, copy) void(^myCallBack)(NSString *value);

@end

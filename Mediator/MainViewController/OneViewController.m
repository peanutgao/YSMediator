//
//  OneViewController.m
//  Mediator
//
//  Created by Joseph Koh on 11/12/2017.
//  Copyright © 2017 Joseph. All rights reserved.
//

#import "OneViewController.h"
#import "YSMediator.h"

@interface OneViewController ()

@end

@implementation OneViewController

// 在 + load函数中注册当前控制器
+ (void)load {
    [self mapName:@"oneVC" withParams:@{@"name": @"title"}];
}


// 用控制器类名字符来跳转
- (IBAction)pushWithVCClassName:(id)sender {
    [YSMediator pushToViewController:@"TwoViewController"
                          withParams:@{
                                       @"name": [NSString stringWithFormat:@"第%zd个页面", self.idx + 1],
                                       @"idx": @(self.idx + 1),
                                       }
                            animated:YES
                            callBack:NULL];
}

// 用控制器映射字符来跳转
- (IBAction)pushByVCMapName:(id)sender {
    [YSMediator pushToViewController:@"twoVC"
                          withParams:@{
                                       @"name": [NSString stringWithFormat:@"第%zd个页面", self.idx + 1],
                                       @"idx": @(self.idx + 1)
                                       }
                            animated:YES
                            callBack:NULL];
}


// 根据控制器类名字符来pop
- (IBAction)popByVCClassName:(id)sender {
    [YSMediator popToViewControllerName:@"TwoViewController" animated:YES];
}

// 根据控制器映射字符来pop
- (IBAction)popByVCMapName:(id)sender {
    [YSMediator popToViewControllerName:@"twoVC" animated:YES];
}

// 根据File path格式字符pop
- (IBAction)popByFilePath:(id)sender {
    [YSMediator popToViewControllerName:@"../../" animated:YES];
}

@end

//
//  LocalViewController.m
//  YSMediator_Example
//
//  Created by Joseph Koh on 2018/4/20.
//  Copyright © 2018年 peanutgao. All rights reserved.
//

#import "LocalViewController.h"

@interface LocalViewController ()

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation LocalViewController

// 在 + load函数中注册当前控制器
+ (void)load {
    [self mapName:@"localVC" withParams:@{@"title": @"name"}];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.infoLabel.text = self.title;
    
    self.dataArray = @[@[@"映射字段方式Push",
                         @"类名字符方式Push"],
                       @[@"映射字段方式Present",
                         @"类名字符方式Present"],
                       @[@"映射字段方式Pop",
                         @"类名字符方式Pop",
                         @"相对路径../../方式Pop"]
                       ];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *params = nil;
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {   // 映射字段方式Push
            params = @{
                       @"name": [NSString stringWithFormat:@"第%zd个页面", self.idx + 1],
                       @"idx": @(self.idx + 1)
                       };
            [YSMediator pushToViewController:@"localVC"
                                  withParams:params
                                    animated:YES
                                    callBack:NULL];
        }
        else if (indexPath.row == 1) {  // 类名字符方式Push
            params = @{
                       @"name": [NSString stringWithFormat:@"第%zd个页面", self.idx + 1],
                       @"idx": @(self.idx + 1)
                       };
            [YSMediator pushToViewController:@"LocalViewController"
                                  withParams:params
                                    animated:YES
                                    callBack:NULL];
        }
    }
    else if (indexPath.section == 1) {
        // 回调暂时只支持block的方式
        id block = ^(NSString *value){
            NSLog(@"回调数据为: %@", value);
            self.infoLabel.text = value;
        };
        if (indexPath.row == 0) {   // 映射字段方式Present
            [YSMediator presentToViewController:@"presentedVC"
                                     withParams:@{@"myCallBack": block}
                                       animated:YES
                                       callBack:NULL];
        }
        else if (indexPath.row == 1) {  // 类名字符方式Present
            [YSMediator presentToViewController:@"presentedVC"
                                     withParams:@{@"myCallBack": block}
                                       animated:YES
                                       callBack:NULL];
        }
    }
    else {
        if (indexPath.row == 0) {   // 映射字段方式Pop
            [YSMediator popToViewControllerName:@"mainVC" animated:YES];
        }
        else if (indexPath.row == 1) {  // 类名字符方式Pop
            [YSMediator popToViewControllerName:@"LocalViewController" animated:YES];
        }
        else if (indexPath.row == 2) {  // 相对路径../../方式Pop
            [YSMediator popToViewControllerName:@"../../" animated:YES];
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseID"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseID"];
    }
    cell.textLabel.text = self.dataArray[indexPath.section][indexPath.row];
    return cell;
}


@end

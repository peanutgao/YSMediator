//
//  SchemeViewController.m
//  Mediator
//
//  Created by Joseph Koh on 12/12/2017.
//  Copyright © 2017 Joseph. All rights reserved.
//

#import "SchemeViewController.h"

@interface SchemeViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (nonatomic, strong) NSArray *dataArray;

@end

@implementation SchemeViewController

+ (void)load {
    [self mapName:@"schemeDemoPage" withParams:@{
                                                 @"mid": @"id",
                                                 @"title": @"name"
                                                 }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.infoLabel.text = [NSString stringWithFormat:@"mid: %@", self.mid];
    
    self.dataArray = @[@[@"映射字段",
                         @"打开web链接",],
                       @[@"url和注册的scheme、host同时匹配",
                         @"url和注册的scheme匹配，注册的host为nil",
                         @"url和注册的scheme不匹配",
                         @"url和注册的scheme匹配，但host不匹配"]
                       ];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *urlStr = nil;
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {   // 映射字段
            urlStr = [NSString stringWithFormat:@"com.ysmediator.demo://host/schemeDemoPage?id=%d&name=MapTest", arc4random_uniform(100)];
            [YSMediator openURL:urlStr withFilter:^BOOL(NSDictionary *params) {
                NSInteger mid = [params[@"id"] intValue];
                if (mid < 50) {
                    NSLog(@"mid: %zd, 不满足条件,不允许跳转", mid);
                    return NO;
                }
                return YES;
            }];
        }
        else if (indexPath.row == 1) {  // 打开web链接
            urlStr = @"https://www.baidu.com";
            [YSMediator openURL:urlStr];
        }
    }
    else {
        if (indexPath.row == 0) {   // url和注册的scheme、host同时匹配
            urlStr = @"com.ysmediator.demo://host/schemeDemoPage?id=888&name=MapTest";
        }
        else if (indexPath.row == 1) {  // url和注册的scheme匹配，注册的host为nil
            urlStr = @"com.ysmediator.demo1://host/schemeDemoPage?id=888&name=MapTest";
        }
        else if (indexPath.row == 2) {  // url和注册的scheme不匹配
            urlStr = @"com.ysmediator.errorScheme://host/schemeDemoPage?id=888&name=MapTest";
        }
        else if (indexPath.row == 3) {  // url和注册的scheme匹配，但host不匹配
            urlStr = @"com.ysmediator.demo2://errorHost/schemeDemoPage?id=888&name=MapTest";
        }
        [YSMediator openURL:urlStr];
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

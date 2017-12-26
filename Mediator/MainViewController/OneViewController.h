//
//  OneViewController.h
//  Mediator
//
//  Created by Joseph Koh on 11/12/2017.
//  Copyright © 2017 Joseph. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OneViewController : UIViewController

@property (nonatomic, assign) NSInteger idx;
@property (nonatomic, copy) void(^actionHandler)(NSInteger idx);

@end

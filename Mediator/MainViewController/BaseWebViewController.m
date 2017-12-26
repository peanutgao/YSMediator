//
//  BaseWebViewController.m
//  Mediator
//
//  Created by Joseph Koh on 12/12/2017.
//  Copyright © 2017 Joseph. All rights reserved.
//

#import "BaseWebViewController.h"

@interface BaseWebViewController ()

@property (nonatomic, strong) UIWebView *webView;

@end

@implementation BaseWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.webView];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.urlString]];
    [self.webView loadRequest:request];
}

@end

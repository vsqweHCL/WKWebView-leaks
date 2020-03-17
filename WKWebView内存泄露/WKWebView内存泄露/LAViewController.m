//
//  LAViewController.m
//  WKWebView内存泄露
//
//  Created by xuzhiyong on 2020/3/17.
//  Copyright © 2020 xxx. All rights reserved.
//

#import "LAViewController.h"
#import "LAWKDelegateController.h"
#import <WebKit/WebKit.h>

@interface LAViewController ()
<
WKDelegate
//WKScriptMessageHandler
>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) WKUserContentController *userContentController;

@end

NSString *MethodName = @"MethodName";

@implementation LAViewController

- (void)dealloc{
    //这里需要注意，前面增加过的方法一定要remove掉。
//    [self.webView.configuration.userContentController removeAllUserScripts];
    [self.webView.configuration.userContentController removeScriptMessageHandlerForName:MethodName];
    
    /**
     通过self注册方法，当退出该控制器的时候，不会走dealloc
     通过中间变量注册方法，当退出该控制器的时候，dealloc正常调用
     */
    NSLog(@"----dealloc----");
    
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    self.webView.frame = self.view.bounds;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    //配置环境
    WKWebViewConfiguration * configuration = [[WKWebViewConfiguration alloc]init];
    self.userContentController = [[WKUserContentController alloc]init];
    configuration.userContentController = self.userContentController;
    
    self.webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, 100, 100) configuration:configuration];
//    self.webView.UIDelegate = self;
//    self.webView.navigationDelegate = self;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"https://www.baidu.com"]]];
    [self.view addSubview:self.webView];
    /**
     注册方法
     addScriptMessageHandler:self
     当我们通过self注册方法的时候，发现dealloc不会调用，内存得不到释放
     解决方法：
     通过中间变量解决内存释放问题：LAWKDelegateController
     */
//    [self.userContentController addScriptMessageHandler:self name:MethodName];
    LAWKDelegateController *delegateController = [[LAWKDelegateController alloc]init];
    delegateController.delegate = self;
    [self.userContentController addScriptMessageHandler:delegateController  name:MethodName];
}


#pragma mark - WKScriptMessageHandler || WKDelegate
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"message.name = %@",message.name);
}

@end

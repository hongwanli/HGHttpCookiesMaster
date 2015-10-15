//
//  HGCookiesWebVC.m
//  HGHttpCookiesMaster
//
//  Created by XiaoDou on 15/8/24.
//  Copyright (c) 2015年 北京嗨购电子商务有限公司. All rights reserved.
//

#import "HGCookiesWebVC.h"
#import <JavaScriptCore/JavaScriptCore.h>

#define kSystemCookies              @"kSystemCookies"

@interface HGCookiesWebVC () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (nonatomic, strong) JSContext *context;
@end

@implementation HGCookiesWebVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Cookies测试页";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleHttpCookiesDidChanged:) name:NSHTTPCookieManagerCookiesChangedNotification object:nil];
//    [self outPutAllCookies];
    NSURL *URL = [NSURL URLWithString:@"http://www.weibo.com"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
//    [self loadHttpRequestCookiesIfNeeded];
    [_webView loadRequest:request];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_webView stopLoading];
    _webView.delegate = nil;
//    [self deleteAllCookies];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {

}

#pragma mark -UIWebViewDelegate

- (void)webViewDidStartLoad:(UIWebView *)webView {

}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self saveHttpRequestCookies];
    
    self.context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    self.context[@"TXBB_IOS_SDK"] = self;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
}

#pragma mark - Notification

- (void)handleHttpCookiesDidChanged:(NSNotification *)notification {
    NSLog(@"handleHttpCookiesDidChanged");
    [self outPutAllCookies];
}

#pragma mark - About Cookie

- (void)outPutAllCookies {
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    NSHTTPCookie *cookie = nil;
    for (id cObj in cookies) {
        if ([cObj isKindOfClass:[NSHTTPCookie class]]){
            cookie = (NSHTTPCookie *)cObj;
            NSLog(@"cookie properties: %@", cookie.properties);
        }
    }
}

- (void)saveHttpRequestCookies {
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    NSString *filePath = [self getCookiesFilePath];
    [NSKeyedArchiver archiveRootObject:cookies toFile:filePath];
}

- (void)loadHttpRequestCookiesIfNeeded {
    NSString *filePath = [self getCookiesFilePath];
    NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    NSHTTPCookie *cookie = nil;
    for (cookie in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    }
}

- (void)deleteAllCookies {
    NSString *filePath = [self getCookiesFilePath];
    NSArray *cookies = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    NSHTTPCookie *cookie = nil;
    for (cookie in cookies) {
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] deleteCookie:cookie];
    }
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSError *error = nil;
    [fileManager removeItemAtPath:filePath error:&error];
}

- (NSString *)getCookiesFilePath {
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [documentPath stringByAppendingPathComponent:kSystemCookies];
    return filePath;
}

@end

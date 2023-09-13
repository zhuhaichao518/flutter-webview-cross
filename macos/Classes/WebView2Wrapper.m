#import "WebView2Wrapper.h"
#include <Foundation/Foundation.h>

#import <MSWebView2Experimental/MSWebView2Experimental.h>

@interface WebView2Wrapper () <MSWebView2NavigationDelegate>

@property(nonatomic, strong) MSWebView2Environment* environment;
@property(nonatomic, strong) MSWebView2Controller* controller;
@property(nonatomic, strong) MSWebView2WebView* webview;

@end

@implementation WebView2Wrapper

- (void)printHello {
    NSLog(@"Hello, World!");
}

- (void)initWebView {
    NSString* librariesPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/Libraries"];
    NSString* browserApplicationPath = [[NSString stringWithFormat:@"%@/%@", librariesPath, @"Microsoft Edge WebView2.app"]
        stringByStandardizingPath];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *sourcePath = @"/Users/lichenliu/Documents/github_repo/flutter-webview-cross/macos/Microsoft Edge WebView2.app";
    NSString *destinationPath = librariesPath;
    NSError *error;
    if ([fileManager createDirectoryAtPath:destinationPath withIntermediateDirectories:YES attributes:nil error:&error]) {
        NSLog(@"Create folder successfully");
    } else {
        NSLog(@"Create folder failed: %@", [error localizedDescription]);
    }
    if ([fileManager copyItemAtPath:sourcePath toPath:[destinationPath stringByAppendingPathComponent:[sourcePath lastPathComponent]] error:&error]) {
        NSLog(@"Copy successfully");
    } else {
        NSLog(@"Copy failed, %@", [error localizedDescription]);
    }

    CreateMSWebView2Environment(browserApplicationPath, nil, nil,
        ^(MSWebView2Environment* environment, NSError* error) {
            if (error) {
              NSLog(@"Create webview environment failed with error: %@", error);
            } else {
              NSLog(@"Create webview environment successfully");
              self.environment = environment;
              NSArray<NSWindow*>* windows = [NSApp windows];
              NSView* view = [windows[0] contentView];
              [environment createWebViewController:view
                                          options:nil
                                completionHandler:^(MSWebView2Controller* controller, NSError* error) {
                                      if (error) {
                                        NSLog(@"Create webview controller failed with error: %@", error);
                                      } else {
                                        NSLog(@"Create webview controller successfully");
                                        self.controller = controller;
                                        self.webview = controller.webview;
                                        [self.webview navigate:@"https://www.bing.com"];
                                      }
                                }];
            }
        });

}

- (void)navigate {
  if (self.webview) {
    NSLog(@"start navigate");
    [self.webview navigate:@"https://www.bing.com"];
  } else {
    NSLog(@"self.webview is not initialized");
  }
}

// 实现name属性的setter和getter方法
@synthesize name = _name;

// 初始化方法
- (instancetype)init {
    self = [super init];
    if (self) {
        _name = @"John Doe";
    }
    return self;
}

#pragma mark - MSWebView2NavigationDelegate
- (MSWebView2NavigationStartingDecision*)webView:(MSWebView2WebView*)webView
                              navigationStarting:(MSWebView2NavigationStartingInfo*)info {
  NSLog(@"NavigationStarting callback triggered with id %llu", info.navigationID);

  MSWebView2NavigationStartingDecision* decision =
      [[MSWebView2NavigationStartingDecision alloc] init];
  decision.shouldCancel = NO;
  return decision;
}

@end

//
//  WebView2Wrapper.h
//  Pods
//

#ifndef WebView2Wrapper_h
#define WebView2Wrapper_h

#import <Foundation/Foundation.h>

@interface WebView2Wrapper : NSObject

- (void)printHello;
- (void)initWebView;
- (void)navigate;

@property (nonatomic, strong) NSString *name;

@end

#endif /* WebView2Wrapper_h */

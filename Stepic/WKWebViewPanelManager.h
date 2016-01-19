//
//  WKWebViewPanelManager.h
//
//  A few helpers to easily show WKWebView alerts, confirms, and prompts.
//
//  Created by Joshua Wright<@bendytree> on 11/4/15.
//
//  License: MIT
//
//  Inspired by: https://github.com/ShingoFukuyama/WKWebViewTips
//
//  Usage:
/*
 ...
 
 - (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
 [WKWebViewPanelManager presentAlertOnController:self title:@"Alert" message:message handler:completionHandler];
 }
 - (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
 [WKWebViewPanelManager presentConfirmOnController:self title:@"Confirm" message:message handler:completionHandler];
 }
 - (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler {
 [WKWebViewPanelManager presentPromptOnController:self title:@"Prompt" message:prompt defaultText:defaultText handler:completionHandler];
 }
 
 ...
 */


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WKWebViewPanelManager : NSObject

+ (void) presentAlertOnController:(nonnull UIViewController*)parentController title:(nullable NSString*)title message:(nullable NSString *)message handler:(nonnull void (^)())completionHandler;
+ (void) presentConfirmOnController:(nonnull UIViewController*)parentController title:(nullable NSString*)title message:(nullable NSString *)message handler:(nonnull void (^)(BOOL result))completionHandler;
+ (void) presentPromptOnController:(nonnull UIViewController*)parentController title:(nullable NSString*)title message:(nullable NSString *)message defaultText:(nullable NSString*)defaultText handler:(nonnull void (^)(NSString * __nullable result))completionHandler;

@end
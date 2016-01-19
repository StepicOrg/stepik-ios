//
//  WKWebViewPanelManager.m
//
//  Created by Joshua Wright<@bendytree> on 11/4/15. MIT License.
//

#import "WKWebViewPanelManager.h"

@implementation WKWebViewPanelManager

+ (void) presentAlertOnController:(nonnull UIViewController*)parentController title:(nullable NSString*)title message:(nullable NSString *)message handler:(nonnull void (^)())completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler();
    }]];
    [parentController presentViewController:alertController animated:YES completion:^{}];
}

+ (void) presentConfirmOnController:(nonnull UIViewController*)parentController title:(nullable NSString*)title message:(nullable NSString *)message handler:(nonnull void (^)(BOOL result))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        completionHandler(YES);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle: NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(NO);
    }]];
    [parentController presentViewController:alertController animated:YES completion:^{}];
}


+ (void) presentPromptOnController:(nonnull UIViewController*)parentController title:(nullable NSString*)title message:(nullable NSString *)message defaultText:(nullable NSString*)defaultText handler:(nonnull void (^)(NSString * __nullable result))completionHandler
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.text = defaultText;
    }];
    [alertController addAction:[UIAlertAction actionWithTitle: @"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *input = ((UITextField *)alertController.textFields.firstObject).text;
        completionHandler(input);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle: NSLocalizedString(@"Cancel", @"") style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        completionHandler(nil);
    }]];
    [parentController presentViewController:alertController animated:YES completion:^{}];
}

@end
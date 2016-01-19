//
//  WebControllerManager.swift
//  Stepic
//
//  Created by Alexander Karpov on 22.12.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import SafariServices
//import JSQWebViewController
//import DZNWebViewController
import WebKit

class WebControllerManager: NSObject {
    private override init() { super.init() }
    static var sharedManager = WebControllerManager()
    
    var currentWebController : UIViewController? {
        willSet(newValue) {
            if let c = currentWebController {
                c.dismissViewControllerAnimated(false, completion: nil)
                print("Web controllers conflict! Dismissed the underlying one.")
            }
        }
    }
    var currentWebControllerKey: String?
    
    func dismissWebControllerWithKey(key: String, animated: Bool, completion: (()->Void)?, error: (String->Void)?) {
        if let c = currentWebController, 
            let k = currentWebControllerKey {
                if k == key {
                    c.dismissViewControllerAnimated(animated, completion: completion)
                    currentWebController = nil
                    currentWebControllerKey = nil
                    return
                } 
        }
        print(currentWebController)
        error?("Could not dismiss web controller with key \(key)")
    }
    
    private func presentJSQWebController(url: NSURL, inController c: UIViewController, allowsSafari: Bool = true, backButtonStyle: BackButtonStyle) {
        let controller = WebViewController(url: url)
        controller.allowsToOpenInSafari = allowsSafari
        controller.backButtonStyle = backButtonStyle
        let nav = UINavigationController(rootViewController: controller)
        self.currentWebController = nav
//        nav.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "webControllerDonePressed")
        c.presentViewController(nav, animated: true, completion: nil)
        controller.webView.navigationDelegate = self
        controller.webView.UIDelegate = self
    }
    
    func webControllerDonePressed() {
        currentWebController?.dismissViewControllerAnimated(true, completion: nil)
        currentWebController = nil
        currentWebControllerKey = nil
    }
    
    func presentWebControllerWithURL(url: NSURL, inController c: UIViewController, withKey key: String, allowsSafari: Bool, backButtonStyle: BackButtonStyle) {
        self.currentWebControllerKey = key
//        if #available(iOS 9.0, *) {
//            let svc = SFSafariViewController(URL: url)
//            self.currentWebController = svc
//            c.presentViewController(svc, animated: true, completion: nil)
//        } else {
            presentJSQWebController(url, inController: c, allowsSafari: allowsSafari, backButtonStyle: backButtonStyle)
//        }
    }
    
    func presentWebControllerWithURLString(urlString: String, inController c: UIViewController, withKey key: String, allowsSafari: Bool, backButtonStyle: BackButtonStyle) {
        if let url = NSURL(string: urlString) {
            presentWebControllerWithURL(url, 
                inController: c, 
                withKey: key, 
                allowsSafari: allowsSafari, 
                backButtonStyle: backButtonStyle)
            
        } else {
            print("Invalid url")
        }
    }
}

enum BackButtonStyle {
    case Close, Back, Done
    
    //Do NOT forget to reset target and selector!!!
    var barButtonItem : UIBarButtonItem {
        switch self {
        case .Close:
            let item = UIBarButtonItem(image: Images.crossBarButtonItemImage, style: .Plain, target: nil, action: "")
            item.tintColor = UIColor.stepicGreenColor()
            return item
        case .Back:
            let item = UIBarButtonItem(image: Images.backBarButtonItemImage, style: .Plain, target: nil, action: "")
            item.tintColor = UIColor.stepicGreenColor()
            return item
        case .Done:
            let item = UIBarButtonItem(barButtonSystemItem: .Done, target: nil, action: "")
            item.tintColor = UIColor.stepicGreenColor()
            return item
        }
    }
}

extension WebControllerManager : WKNavigationDelegate {    
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        if (navigationAction.targetFrame != nil) {
            let rurl = navigationAction.request.URL
//            print(rurl)
            if let url = rurl {
                if url.scheme == "stepic" {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
        }
        decisionHandler(WKNavigationActionPolicy.Allow)
    }
}

extension WebControllerManager : WKUIDelegate {
    
    func webView(webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: () -> Void) {
        if let currentVC = currentWebController {
            WKWebViewPanelManager.presentAlertOnController(currentVC, title: NSLocalizedString("Alert", comment: ""), message: message, handler: completionHandler)
        }
    }
    
    func webView(webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: (Bool) -> Void) {
        if let currentVC = currentWebController {
            WKWebViewPanelManager.presentConfirmOnController(currentVC, title: NSLocalizedString("Confirm", comment: ""), message: message, handler: completionHandler)
        }
    }
    
    func webView(webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: (String?) -> Void) {
        if let currentVC = currentWebController {
            WKWebViewPanelManager.presentPromptOnController(currentVC, title: NSLocalizedString("Prompt", comment: ""), message: prompt, defaultText: defaultText, handler: completionHandler)
        }
    }
}

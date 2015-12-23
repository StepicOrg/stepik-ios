//
//  WebControllerManager.swift
//  Stepic
//
//  Created by Alexander Karpov on 22.12.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import SafariServices
import JSQWebViewController
import DZNWebViewController

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
    
    private func presentJSQWebController(url: NSURL, inController c: UIViewController) {
        let controller = WebViewController(url: url)
        let nav = UINavigationController(rootViewController: controller)
        self.currentWebController = nav
//        nav.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: "webControllerDonePressed")
        c.presentViewController(nav, animated: true, completion: nil)
        controller.webView.navigationDelegate = self

    }
    
    func webControllerDonePressed() {
        currentWebController?.dismissViewControllerAnimated(true, completion: nil)
        currentWebController = nil
        currentWebControllerKey = nil
    }
    
//    private func presentDZNWebController(url: NSURL, inController c: UIViewController) {
//        let controller = DZNWebViewController(URL: url)
//        let nav = UINavigationController(rootViewController: controller)
//        controller.supportedWebNavigationTools = .StopReload
//        controller.supportedWebActions = .DZNWebActionNone
//        controller.allowHistory = false
//        controller.showLoadingProgress = true
//        controller.hideBarsWithGestures = false
//        
//        self.currentWebController = nav
//        c.presentViewController(nav, animated: true, completion: nil)
//    }
    
    func presentWebControllerWithURL(url: NSURL, inController c: UIViewController, withKey key: String) {
        self.currentWebControllerKey = key
        if #available(iOS 9.0, *) {
            let svc = SFSafariViewController(URL: url)
            self.currentWebController = svc
            c.presentViewController(svc, animated: true, completion: nil)
        } else {
            presentJSQWebController(url, inController: c)
//            UIApplication.sharedApplication().openURL(NSURL(string: "https://stepic.org/accounts/password/reset/")!)
            // Fallback on earlier versions
        }
    }
    
    func presentWebControllerWithURLString(urlString: String, inController c: UIViewController, withKey key: String) {
        if let url = NSURL(string: urlString) {
            presentWebControllerWithURL(url, inController: c, withKey: key)
        } else {
            print("Invalid url")
        }
    }
}

extension WebControllerManager : WKNavigationDelegate {    
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        if (navigationAction.targetFrame != nil) {
            let rurl = navigationAction.request.URL
            print(rurl)
            if let url = rurl {
                if url.scheme == "stepic" {
                    UIApplication.sharedApplication().openURL(url)
                }
            }
        }
        decisionHandler(WKNavigationActionPolicy.Allow)
    }
}

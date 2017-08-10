//
//  WebControllerManager.swift
//  Stepic
//
//  Created by Alexander Karpov on 22.12.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import SafariServices
import WebKit

class WebControllerManager: NSObject {
    fileprivate override init() { super.init() }
    static var sharedManager = WebControllerManager()
    
    var currentWebController : UIViewController? {
        willSet(newValue) {
            guard newValue != nil else {
                return
            }
            if let c = currentWebController {
                c.dismiss(animated: false, completion: nil)
                print("Web controllers conflict! Dismissed the underlying one.")
            }
        }
    }
    var currentWebControllerKey: String?
    
    func dismissWebControllerWithKey(_ key: String, animated: Bool, completion: (()->Void)?, error: ((String)->Void)?) {
        if let c = currentWebController, 
            let k = currentWebControllerKey {
            if k == key {
                c.dismiss(animated: animated, completion: completion)
                currentWebController = nil
                currentWebControllerKey = nil
                return
            } 
        }
        print(currentWebController ?? "")
        error?("Could not dismiss web controller with key \(key)")
    }
    
    fileprivate func presentCustomWebController(_ url: URL, inController c: UIViewController, allowsSafari: Bool = true, backButtonStyle: BackButtonStyle, animated: Bool = true) {
        let controller = WebViewController(url: url)
        controller.allowsToOpenInSafari = allowsSafari
        controller.backButtonStyle = backButtonStyle
        controller.webView.navigationDelegate = self
        controller.webView.uiDelegate = self
        controller.onDismiss = { [weak self] in
            self?.currentWebController?.dismiss(animated: true, completion: nil)
            self?.currentWebController = nil
            self?.currentWebControllerKey = nil
        }
        
        let nav = UINavigationController(rootViewController: controller)
        self.currentWebController = nav
        c.present(nav, animated: animated, completion: nil)
    }
    
    func presentWebControllerWithURL(_ url: URL, inController c: UIViewController, withKey key: String, allowsSafari: Bool, backButtonStyle: BackButtonStyle, animated: Bool = true, forceCustom: Bool = false) {
        
        if #available(iOS 9.0, *), !forceCustom {
            let svc = SFSafariViewController(url: url)
            c.present(svc, animated: true, completion: nil)
            self.currentWebControllerKey = key
            self.currentWebController = svc
        } else {
            self.currentWebControllerKey = key
            presentCustomWebController(url, inController: c, allowsSafari: allowsSafari, backButtonStyle: backButtonStyle, animated: animated)
        }
    }
    
    func presentWebControllerWithURLString(_ urlString: String, inController c: UIViewController, withKey key: String, allowsSafari: Bool, backButtonStyle: BackButtonStyle) {
        print(urlString.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed) ?? "")
        if let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters:NSCharacterSet.urlQueryAllowed)!) {
            presentWebControllerWithURL(url, 
                                        inController: c, 
                                        withKey: key, 
                                        allowsSafari: allowsSafari, 
                                        backButtonStyle: backButtonStyle)
            
        } else {
            print("Invalid url")
        }
    }
    
    func defaultSelector() {}
}

enum BackButtonStyle {
    case close, back, done
    
    //Do NOT forget to reset target and selector!!!
    var barButtonItem : UIBarButtonItem {
        switch self {
        case .close:
            let item = UIBarButtonItem(image: Images.crossBarButtonItemImage, style: .plain, target: nil, action: #selector(WebControllerManager.defaultSelector))
            item.tintColor = UIColor.stepicGreenColor()
            return item
        case .back:
            let item = UIBarButtonItem(image: Images.backBarButtonItemImage, style: .plain, target: nil, action: #selector(WebControllerManager.defaultSelector))
            item.tintColor = UIColor.stepicGreenColor()
            return item
        case .done:
            let item = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(WebControllerManager.defaultSelector))
            item.tintColor = UIColor.stepicGreenColor()
            return item
        }
    }
}

extension WebControllerManager : WKNavigationDelegate {    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.targetFrame != nil {
            let rurl = navigationAction.request.url
            
            if let url = rurl {
                if url.scheme == StepicApplicationsInfo.urlScheme {
                    UIApplication.shared.openURL(url)
                } else if url.absoluteString.contains("social_signup_with_existing_email") {
                    if let url = URL(string: "\(StepicApplicationsInfo.social?.redirectUri ?? "")?\(url.query ?? "")") {
                        self.dismissWebControllerWithKey("social auth", animated: false, completion: {
                            UIApplication.shared.openURL(url)
                        }, error: nil)
                    }
                }
            }
        }
        decisionHandler(WKNavigationActionPolicy.allow)
    }
}

extension WebControllerManager : WKUIDelegate {
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        if let currentVC = currentWebController {
            WKWebViewPanelManager.presentAlert(on: currentVC, title: NSLocalizedString("Alert", comment: ""), message: message, handler: completionHandler)
        }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        if let currentVC = currentWebController {
            WKWebViewPanelManager.presentConfirm(on: currentVC, title: NSLocalizedString("Confirm", comment: ""), message: message, handler: completionHandler)
        }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        if let currentVC = currentWebController {
            WKWebViewPanelManager.presentPrompt(on: currentVC, title: NSLocalizedString("Prompt", comment: ""), message: prompt, defaultText: defaultText, handler: completionHandler)
        }
    }
}

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

final class WebControllerManager: NSObject {
    static var sharedManager = WebControllerManager()

    var currentWebControllerKey: String?
    var currentWebController: UIViewController? {
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

    private override init() {
        super.init()
    }

    func dismissWebControllerWithKey(_ key: String, animated: Bool, completion: (() -> Void)?, error: ((String) -> Void)?) {
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

    func presentWebControllerWithURL(
        _ url: URL,
        inController controller: UIViewController,
        withKey key: String,
        allowsSafari: Bool,
        backButtonStyle: BackButtonStyle,
        animated: Bool = true,
        forceCustom: Bool = false
    ) {
        guard ["http", "https"].contains(url.scheme?.lowercased() ?? "") else {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
            return
        }

        var url = url
        url.appendFromMobileQueryParameter()

        if forceCustom {
            self.currentWebControllerKey = key
            self.presentCustomWebController(
                url,
                inController: controller,
                allowsSafari: allowsSafari,
                backButtonStyle: backButtonStyle,
                animated: animated
            )
        } else {
            let safariViewController = SFSafariViewController(url: url)
            controller.present(safariViewController, animated: true)
            self.currentWebControllerKey = key
            self.currentWebController = safariViewController
        }
    }

    func presentWebControllerWithURLString(
        _ urlString: String,
        inController controller: UIViewController,
        withKey key: String,
        allowsSafari: Bool,
        backButtonStyle: BackButtonStyle
    ) {
        print(urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) ?? "")
        if let url = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!) {
            self.presentWebControllerWithURL(
                url,
                inController: controller,
                withKey: key,
                allowsSafari: allowsSafari,
                backButtonStyle: backButtonStyle
            )
        } else {
            print("Invalid url")
        }
    }

    @objc
    func defaultSelector() {
    }
}

enum BackButtonStyle {
    case close, back, done

    //Do NOT forget to reset target and selector!!!
    var barButtonItem: UIBarButtonItem {
        switch self {
        case .close:
            let item = UIBarButtonItem(image: Images.crossBarButtonItemImage, style: .plain, target: nil, action: #selector(WebControllerManager.defaultSelector))
            item.tintColor = UIColor.mainDark
            return item
        case .back:
            let item = UIBarButtonItem(image: Images.backBarButtonItemImage, style: .plain, target: nil, action: #selector(WebControllerManager.defaultSelector))
            item.tintColor = UIColor.mainDark
            return item
        case .done:
            let item = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(WebControllerManager.defaultSelector))
            item.tintColor = UIColor.mainDark
            return item
        }
    }
}

extension WebControllerManager: WKNavigationDelegate {
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

extension WebControllerManager: WKUIDelegate {
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

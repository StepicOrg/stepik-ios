//
//  WebControllerManager.swift
//  Stepic
//
//  Created by Alexander Karpov on 22.12.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import SafariServices
import SVProgressHUD
import UIKit
import WebKit

final class WebControllerManager: NSObject {
    static let shared = WebControllerManager()

    private var currentWebControllerKey: WebControllerKey?
    private var currentWebController: UIViewController? {
        willSet {
            guard newValue != nil else {
                return
            }

            if let currentWebController = self.currentWebController {
                currentWebController.dismiss(animated: false, completion: nil)
                print("Web controllers conflict! Dismissed the underlying one.")
            }
        }
    }

    private let magicLinksNetworkService: MagicLinksNetworkServiceProtocol

    override private init() {
        self.magicLinksNetworkService = MagicLinksNetworkService(
            magicLinksAPI: MagicLinksAPI(),
            userAccountService: UserAccountService()
        )
        super.init()
    }

    // MARK: Public API

    func dismissWebControllerWithKey(
        _ key: WebControllerKey,
        animated: Bool = true,
        completion: (() -> Void)? = nil,
        error: ((String) -> Void)? = nil
    ) {
        if let currentWebController = self.currentWebController,
           let currentWebControllerKey = self.currentWebControllerKey {
            if currentWebControllerKey == key {
                currentWebController.dismiss(animated: animated, completion: completion)
                self.currentWebController = nil
                self.currentWebControllerKey = nil
                return
            }
        }

        print(self.currentWebController ?? "")
        error?("Could not dismiss web controller with key \(key)")
    }

    func presentWebControllerWithURL(
        _ url: URL,
        inController controller: UIViewController,
        withKey key: WebControllerKey,
        allowsSafari: Bool,
        backButtonStyle: BackButtonStyle,
        animated: Bool = true,
        forceCustom: Bool = false
    ) {
        func present(url: URL) {
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
                safariViewController.modalPresentationStyle = .fullScreen

                self.currentWebControllerKey = key
                self.currentWebController = safariViewController

                controller.present(safariViewController, animated: true)
            }
        }

        guard ["http", "https"].contains(url.scheme?.lowercased() ?? "") else {
            UIApplication.shared.open(
                url,
                options: [:],
                completionHandler: nil
            )
            return
        }

        if key == .socialAuth {
            return present(url: url)
        }

        var queryParameters = ["from_mobile_app": "true"]
        if key == .externalLink {
            queryParameters["mobile_internal_deeplink"] = "true"
        }
        if key.isRequiresEmbeddedModeToOpenURL {
            queryParameters["embedded"] = "true"
        }

        guard let url = url.appendingQueryParameters(queryParameters) else {
            return
        }

        // Creates an URL with authorization token if needed.
        if self.shouldCreateMagicLinkForTargetURL(url, webControllerKey: key) {
            SVProgressHUD.show()

            let nextURLPath = url
                .absoluteString
                .replacingOccurrences(of: "\(url.scheme ?? "")://\(url.host ?? "")", with: "")

            self.magicLinksNetworkService.create(nextURLPath: nextURLPath).done { magicLink in
                if let magicLinkURL = URL(string: magicLink.url) {
                    present(url: magicLinkURL)
                } else {
                    present(url: url)
                }
            }.ensure {
                SVProgressHUD.dismiss()
            }.catch { error in
                print("WebControllerManager failed create magic link with error: \(error)")
                present(url: url)
            }
        } else {
            present(url: url)
        }
    }

    func presentWebControllerWithURLString(
        _ urlString: String,
        inController controller: UIViewController,
        withKey key: WebControllerKey,
        allowsSafari: Bool,
        backButtonStyle: BackButtonStyle
    ) {
        guard let urlEncodedString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: urlEncodedString) else {
            return print("Invalid url = \(urlString)")
        }

        self.presentWebControllerWithURL(
            url,
            inController: controller,
            withKey: key,
            allowsSafari: allowsSafari,
            backButtonStyle: backButtonStyle
        )
    }

    // MARK: Private API

    private func shouldCreateMagicLinkForTargetURL(_ url: URL, webControllerKey: WebControllerKey) -> Bool {
        let isPathComponentsValid = url.pathComponents.count > 1
        let isStepikExternalLink = webControllerKey == .externalLink
            && url.absoluteString.starts(with: StepikApplicationsInfo.stepikURL)
        return webControllerKey.isRequiresAuthorizationToOpenURL
            || (isStepikExternalLink && isPathComponentsValid)
    }

    private func presentCustomWebController(
        _ url: URL,
        inController presentingViewController: UIViewController,
        allowsSafari: Bool = true,
        backButtonStyle: BackButtonStyle,
        animated: Bool = true
    ) {
        if self.currentWebControllerKey == .socialAuth {
            WebCacheCleaner.clean()
        }

        let urlRequest = URLRequest(
            url: url,
            cachePolicy: self.currentWebControllerKey == .socialAuth ? .reloadIgnoringLocalCacheData : .useProtocolCachePolicy
        )

        let controller = WebViewController(urlRequest: urlRequest)
        controller.allowsToOpenInSafari = allowsSafari
        controller.backButtonStyle = backButtonStyle
        controller.webView.navigationDelegate = self
        controller.webView.uiDelegate = self
        controller.onDismiss = { [weak self] in
            self?.currentWebController?.dismiss(animated: true, completion: nil)
            self?.currentWebController = nil
            self?.currentWebControllerKey = nil
        }

        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.modalPresentationStyle = .fullScreen

        self.currentWebController = navigationController

        presentingViewController.present(navigationController, animated: animated, completion: nil)
    }

    enum WebControllerKey {
        case exam
        case solution
        case socialAuth
        case peerReview
        case paidCourse
        case certificate
        case externalLink
        case resetPassword
        case deleteUserAccount
        case openQuizInWeb

        fileprivate var isRequiresAuthorizationToOpenURL: Bool {
            self.withAuthorizationKeys.contains(self)
        }

        fileprivate var isRequiresEmbeddedModeToOpenURL: Bool {
            self.withEmbeddedModeKeys.contains(self)
        }

        private var withAuthorizationKeys: [WebControllerKey] {
            [.exam, .solution, .peerReview, .paidCourse, .openQuizInWeb, .deleteUserAccount]
        }

        private var withEmbeddedModeKeys: [WebControllerKey] {
            [.exam, .solution, .peerReview, .paidCourse, .openQuizInWeb]
        }
    }
}

enum BackButtonStyle {
    case close
    case back
    case done

    // Do NOT forget to reset target and selector!!!
    var barButtonItem: UIBarButtonItem {
        switch self {
        case .close:
            let item = UIBarButtonItem(
                image: Images.crossBarButtonItemImage,
                style: .plain,
                target: nil,
                action: nil
            )
            item.tintColor = UIColor.stepikAccent
            return item
        case .back:
            let item = UIBarButtonItem(
                image: Images.backBarButtonItemImage,
                style: .plain,
                target: nil,
                action: nil
            )
            item.tintColor = UIColor.stepikAccent
            return item
        case .done:
            let item = UIBarButtonItem(
                barButtonSystemItem: .done,
                target: nil,
                action: nil
            )
            item.tintColor = UIColor.stepikAccent
            return item
        }
    }
}

// MARK: - WebControllerManager: WKNavigationDelegate -

extension WebControllerManager: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if navigationAction.targetFrame != nil {
            if let requestURL = navigationAction.request.url {
                if requestURL.scheme == StepikApplicationsInfo.urlScheme {
                    UIApplication.shared.openURL(requestURL)
                } else if requestURL.absoluteString.contains("social_signup_with_existing_email") {
                    let socialURL = URL(
                        string: "\(StepikApplicationsInfo.social?.redirectUri ?? "")?\(requestURL.query ?? "")"
                    )
                    if let socialURL = socialURL {
                        self.dismissWebControllerWithKey(
                            .socialAuth,
                            animated: false,
                            completion: {
                                UIApplication.shared.openURL(socialURL)
                            },
                            error: nil
                        )
                    }
                }
            }
        }
        decisionHandler(.allow)
    }
}

// MARK: - WebControllerManager: WKUIDelegate -

extension WebControllerManager: WKUIDelegate {
    func webView(
        _ webView: WKWebView,
        runJavaScriptAlertPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping () -> Void
    ) {
        if let currentWebController = self.currentWebController {
            WKWebViewPanelManager.presentAlert(
                on: currentWebController,
                title: NSLocalizedString("Alert", comment: ""),
                message: message,
                handler: completionHandler
            )
        }
    }

    func webView(
        _ webView: WKWebView,
        runJavaScriptConfirmPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping (Bool) -> Void
    ) {
        if let currentWebController = self.currentWebController {
            WKWebViewPanelManager.presentConfirm(
                on: currentWebController,
                title: NSLocalizedString("Confirm", comment: ""),
                message: message,
                handler: completionHandler
            )
        }
    }

    func webView(
        _ webView: WKWebView,
        runJavaScriptTextInputPanelWithPrompt prompt: String,
        defaultText: String?,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping (String?) -> Void
    ) {
        if let currentWebController = self.currentWebController {
            WKWebViewPanelManager.presentPrompt(
                on: currentWebController,
                title: NSLocalizedString("Prompt", comment: ""),
                message: prompt,
                defaultText: defaultText,
                handler: completionHandler
            )
        }
    }
}

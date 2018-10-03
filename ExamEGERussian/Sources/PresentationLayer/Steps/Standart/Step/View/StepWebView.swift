//
// Created by Ivan Magda on 01/08/2018.
// Copyright (c) 2018 Alex Karpov. All rights reserved.
//

import Foundation
import WebKit
import PromiseKit

final class StepWebView: WKWebView {
    private static var configuration: WKWebViewConfiguration = {
        let script = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
        let userScript = WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let controller = WKUserContentController()
        controller.addUserScript(userScript)
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = controller

        return configuration
    }()

    var didFinishLoad: (() -> Void)?
    var onOpenImage: ((_ imageURL: URL) -> Void)?

    // MARK: - Init

    override init(frame: CGRect = .zero, configuration: WKWebViewConfiguration = StepWebView.configuration) {
        super.init(frame: frame, configuration: configuration)
        navigationDelegate = self
        scrollView.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public API

    func reloadContent() -> Promise<Void> {
        return Promise { seal in
            evaluateJavaScript("location.reload();", completionHandler: { _, error in
                if let error = error {
                    return seal.reject(error)
                }

                seal.fulfill(())
            })
        }
    }

    func getContentHeight() -> Promise<Int> {
        return Promise { seal in
            evaluateJavaScript("document.body.scrollHeight;") { res, error in
                if let error = error {
                    return seal.reject(error)
                }

                if let height = res as? Int {
                    seal.fulfill(height)
                } else {
                    seal.fulfill(0)
                }
            }
        }
    }

    func alignImages() -> Promise<Void> {
        // Disable WebKit callout on long press
        var jsCode = "document.documentElement.style.webkitTouchCallout='none';"
        // Change color for audio control
        jsCode += "document.body.style.setProperty('--actionColor', '#\(UIColor.stepicGreen.hexString)');"
        // Center images
        jsCode += "var imgs = document.getElementsByTagName('img');"
        jsCode += "for (var i = 0; i < imgs.length; i++){ imgs[i].style.marginLeft = (document.body.clientWidth / 2) - (imgs[i].clientWidth / 2) - 8 }"

        return Promise { seal in
            evaluateJavaScript(jsCode, completionHandler: { _, error in
                if let error = error {
                    return seal.reject(error)
                }

                seal.fulfill(())
            })
        }
    }
}

// MARK: - StepWebView: WKNavigationDelegate -

extension StepWebView: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        didFinishLoad?()
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            return decisionHandler(.cancel)
        }

        if url.scheme == "openimg" {
            var urlString = url.absoluteString
            urlString.removeSubrange(urlString.startIndex..<urlString.index(urlString.startIndex, offsetBy: 10))
            if let offset = urlString.indexOf("//") {
                urlString.insert(":", at: urlString.index(urlString.startIndex, offsetBy: offset))
                if let imageURL = URL(string: urlString) {
                    onOpenImage?(imageURL)
                }
            }

            return decisionHandler(.cancel)
        }

        return decisionHandler(.allow)
    }
}

// MARK: - StepWebView: UIScrollViewDelegate -

extension StepWebView: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
}

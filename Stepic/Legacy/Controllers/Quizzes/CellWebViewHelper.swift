//
//  CellWebViewHelper.swift
//  Stepic
//
//  Created by Alexander Karpov on 29.05.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import WebKit

final class CellWebViewHelper: NSObject {
    private weak var webView: WKWebView?
    private let fontSize: StepFontSize

    var mathJaxFinishedBlock: (() -> Void)?

    init(webView: WKWebView, fontSize: StepFontSize) {
        self.webView = webView
        self.fontSize = fontSize

        self.webView?.isOpaque = false
        self.webView?.backgroundColor = .clear
        self.webView?.isUserInteractionEnabled = false
        self.webView?.scrollView.backgroundColor = .clear
        self.webView?.scrollView.showsVerticalScrollIndicator = false
        self.webView?.scrollView.canCancelContentTouches = false
    }

    //Method sets text and returns the method which returns current cell height according to the webview content height
    func setTextWithTeX(_ text: String, color: UIColor = UIColor.stepikPrimaryText) {
        let processor = HTMLProcessor(html: text)
        let html = processor
            .injectDefault()
            .inject(script: .mathJaxCompletion)
            .inject(script: .textColor(color: color))
            .inject(script: .fontSize(fontSize: self.fontSize))
            .html

        webView?.navigationDelegate = self
        webView?.loadHTMLString(html, baseURL: URL(fileURLWithPath: Bundle.main.bundlePath))
    }
}

extension CellWebViewHelper: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if navigationAction.request.url?.scheme == "mathjaxfinish" {
            self.mathJaxFinishedBlock?()
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
}

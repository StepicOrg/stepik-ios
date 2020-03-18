//
//  CellWebViewHelper.swift
//  Stepic
//
//  Created by Alexander Karpov on 29.05.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

final class CellWebViewHelper: NSObject {
    private weak var webView: UIWebView?
    private let fontSize: StepFontSize

    var mathJaxFinishedBlock: (() -> Void)?

    init(webView: UIWebView, fontSize: StepFontSize) {
        self.webView = webView
        self.fontSize = fontSize

        self.webView?.isOpaque = false
        self.webView?.backgroundColor = UIColor.clear
        self.webView?.isUserInteractionEnabled = false
        self.webView?.scrollView.backgroundColor = UIColor.clear
        self.webView?.scrollView.showsVerticalScrollIndicator = false
        self.webView?.scrollView.canCancelContentTouches = false
    }

    private func getContentHeight(_ webView: UIWebView) -> Int {
        Int(webView.stringByEvaluatingJavaScript(from: "document.body.scrollHeight;") ?? "0") ?? 0
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

        webView?.delegate = self
        webView?.loadHTMLString(html, baseURL: URL(fileURLWithPath: Bundle.main.bundlePath))
    }

    private func finishedMathJax() {
        mathJaxFinishedBlock?()
    }
}

extension CellWebViewHelper: UIWebViewDelegate {
    func webView(
        _ webView: UIWebView,
        shouldStartLoadWith request: URLRequest,
        navigationType: UIWebView.NavigationType
    ) -> Bool {
        if request.url?.scheme == "mathjaxfinish" {
            finishedMathJax()
            return false
        }
        return true
    }
}

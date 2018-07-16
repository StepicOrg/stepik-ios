//
//  CardStepViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 22.12.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import Agrume
import WebKit
import PromiseKit
import SnapKit

class CardStepViewController: UIViewController, CardStepView {
    weak var presenter: CardStepPresenter?

    var problemText: String?
    weak var quizView: UIView?

    @IBOutlet weak var scrollView: UIScrollView!
    var stepWebView: WKWebView!
    @IBOutlet weak var quizPlaceholderView: UIView!
    var stepWebViewHeight: Constraint!

    // For updates after rotation only when controller not presented
    var shouldRefreshOnAppear: Bool = false

    var baseScrollView: UIScrollView {
        get {
            return scrollView
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupWebView()
        presenter?.refreshStep()
        NotificationCenter.default.addObserver(self, selector: #selector(self.didScreenRotate), name: .UIDeviceOrientationDidChange, object: nil)

        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
    }

    @objc func didScreenRotate() {
        refreshWebView()
        shouldRefreshOnAppear = !shouldRefreshOnAppear
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        view.setNeedsLayout()
        view.layoutIfNeeded()

        if shouldRefreshOnAppear {
            refreshWebView()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        shouldRefreshOnAppear = false
    }

    deinit {
        NotificationCenter.default.removeObserver(self)

        if stepWebView != nil {
            // If WKWebView is not deallocated, we should reset its delegate (iOS 9 crash)
            stepWebView.navigationDelegate = nil
            stepWebView.scrollView.delegate = nil
        }
        print("card step: deinit vc")
    }

    func setupWebView() {
        let jscript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
        let userScript = WKUserScript(source: jscript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let wkUController = WKUserContentController()
        wkUController.addUserScript(userScript)
        let wkWebConfig = WKWebViewConfiguration()
        wkWebConfig.userContentController = wkUController

        stepWebView = WKWebView(frame: .zero, configuration: wkWebConfig)
        stepWebView.navigationDelegate = self
        stepWebView.scrollView.isScrollEnabled = false
        stepWebView.scrollView.delegate = self
        scrollView.insertSubview(stepWebView, at: 0)

        stepWebView.translatesAutoresizingMaskIntoConstraints = false
        stepWebView.snp.makeConstraints { make -> Void in
            stepWebViewHeight = make.height.equalTo(5).constraint
            make.bottom.equalTo(quizPlaceholderView.snp.top)
            make.leading.equalTo(scrollView).offset(2)
            make.trailing.equalTo(scrollView).offset(-2)
            make.top.equalTo(scrollView).offset(5)
        }
    }

    func updateProblem(with htmlText: String) {

        let processor = HTMLProcessor(html: htmlText)
        let html = processor
            .injectDefault()
            .html
        stepWebView.loadHTMLString(html, baseURL: URL(fileURLWithPath: Bundle.main.bundlePath))
    }

    func updateQuiz(with controller: UIViewController) {
        quizView = controller.view

        self.addChildViewController(controller)
        quizPlaceholderView.addSubview(quizView!)
        quizView!.snp.makeConstraints { $0.edges.equalTo(quizPlaceholderView) }

        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }

    func scrollToQuizBottom() {
        DispatchQueue.main.async {
            // FIXME: move logic from presenter
            guard let quizHint = self.presenter?.calculateQuizHintSize() else {
                return
            }
            self.scrollView.layoutIfNeeded()

            if quizHint.height > self.view.frame.height {
                self.scrollView.scrollRectToVisible(CGRect(x: 0, y: quizHint.top.y, width: 1, height: self.scrollView.frame.height), animated: true)
            } else {
                let bottomOffset = CGPoint(x: 0, y: self.scrollView.contentSize.height - self.scrollView.bounds.height + self.scrollView.contentInset.bottom)
                if bottomOffset.y > 0 {
                    self.scrollView.setContentOffset(bottomOffset, animated: true)
                }
            }
        }
    }

    func refreshWebView() {
        resetWebViewHeight(5.0)

        func reloadContent() -> Promise<Void> {
            return Promise { seal in
                self.stepWebView.evaluateJavaScript("location.reload();", completionHandler: { _, error in
                    if let error = error {
                        return seal.reject(error)
                    }

                    seal.fulfill(())
                })
            }
        }

        reloadContent().then {
            self.alignImages(in: self.stepWebView)
        }.then {
            self.getContentHeight(self.stepWebView)
        }.done { height in
            self.resetWebViewHeight(Float(height))
            self.scrollView.layoutIfNeeded()
        }.catch { _ in
            print("card step: error while refreshing")
        }

    }
}

extension CardStepViewController: WKNavigationDelegate {
    func resetWebViewHeight(_ height: Float) {
        stepWebViewHeight.update(offset: height)
    }

    func getContentHeight(_ webView: WKWebView) -> Promise<Int> {
        return Promise { seal in
            webView.evaluateJavaScript("document.body.scrollHeight;", completionHandler: { res, error in
                if let error = error {
                    return seal.reject(error)
                }

                if let height = res as? Int {
                    seal.fulfill(height)
                } else {
                    seal.fulfill(0)
                }
            })
        }
    }

    func alignImages(in webView: WKWebView) -> Promise<Void> {
        // Disable WebKit callout on long press
        var jsCode = "document.documentElement.style.webkitTouchCallout='none';"
        // Change color for audio control
        jsCode += "document.body.style.setProperty('--actionColor', '#\(UIColor.stepicGreen.hexString)');"
        // Center images
        jsCode += "var imgs = document.getElementsByTagName('img');"
        jsCode += "for (var i = 0; i < imgs.length; i++){ imgs[i].style.marginLeft = (document.body.clientWidth / 2) - (imgs[i].clientWidth / 2) - 8 }"

        return Promise { seal in
            webView.evaluateJavaScript(jsCode, completionHandler: { _, error in
                if let error = error {
                    return seal.reject(error)
                }

                seal.fulfill(())
            })
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            return decisionHandler(.cancel)
        }

        // Check if the request is an iFrame
        if let text = problemText {
            if HTMLParsingUtil.getAlliFrameLinks(text).index(of: url.absoluteString) != nil {
                return decisionHandler(.allow)
            }
        }

        if url.scheme == "openimg" {
            var urlString = url.absoluteString
            urlString.removeSubrange(urlString.startIndex..<urlString.index(urlString.startIndex, offsetBy: 10))
            if let offset = urlString.indexOf("//") {
                urlString.insert(":", at: urlString.index(urlString.startIndex, offsetBy: offset))
                if let newUrl = URL(string: urlString) {
                    let agrume = Agrume(imageUrl: newUrl)
                    agrume.showFrom(self)
                }
            }
            return decisionHandler(.cancel)
        }
        return decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        alignImages(in: webView).then {
            self.getContentHeight(webView)
        }.done { height in
            self.resetWebViewHeight(Float(height))
            self.scrollView.layoutIfNeeded()

            self.presenter?.problemDidLoad()
        }.catch { _ in
            print("card step: error after webview loading did finish")
        }
    }
}

extension CardStepViewController: UIScrollViewDelegate {
    func viewForZooming(in: UIScrollView) -> UIView? {
        // Disable zooming
        return nil
    }
}

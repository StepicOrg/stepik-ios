//
//  CardStepViewController.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 31/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import Agrume
import WebKit
import PromiseKit
import SnapKit

class CardStepViewController: UIViewController, CardStepView {
    var presenter: CardStepPresenter?

    var stepWebView: WKWebView!
    var stepWebViewHeight: Constraint!

    @IBOutlet var scrollView: UIScrollView!

    // For updates after rotation only when controller not presented
    var shouldRefreshOnAppear: Bool = false

    // MARK: - UIViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupWebView()
        presenter?.refreshStep()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didScreenRotate),
            name: .UIDeviceOrientationDidChange,
            object: nil
        )

        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }

        scrollView.alwaysBounceVertical = true
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
    }

    // MARK: - Public API

    @objc func didScreenRotate() {
        refreshWebView()
        shouldRefreshOnAppear = !shouldRefreshOnAppear
    }

    func setupWebView() {
        let script = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
        let userScript = WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let controller = WKUserContentController()
        controller.addUserScript(userScript)
        let сonfiguration = WKWebViewConfiguration()
        сonfiguration.userContentController = controller

        stepWebView = WKWebView(frame: .zero, configuration: сonfiguration)
        stepWebView.navigationDelegate = self
        stepWebView.scrollView.isScrollEnabled = false
        stepWebView.scrollView.delegate = self
        scrollView.insertSubview(stepWebView, at: 0)

        stepWebView.translatesAutoresizingMaskIntoConstraints = false
        stepWebView.snp.makeConstraints { make in
            stepWebViewHeight = make.height.equalTo(5).constraint
            make.top.equalToSuperview().offset(5)
            make.bottom.equalToSuperview().offset(-5)
            make.leading.equalToSuperview().offset(2)
            make.trailing.equalToSuperview().offset(-2)
            make.centerX.equalToSuperview()
        }
    }

    func updateProblem(with htmlText: String) {
        let processor = HTMLProcessor(html: htmlText)
        let html = processor
            .injectDefault()
            .html
        stepWebView.loadHTMLString(html, baseURL: URL(fileURLWithPath: Bundle.main.bundlePath))
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

// MARK: - CardStepViewController: WKNavigationDelegate -

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
        }.catch { _ in
            print("card step: error after webview loading did finish")
        }
    }
}

// MARK: - CardStepViewController: UIScrollViewDelegate -

extension CardStepViewController: UIScrollViewDelegate {
    func viewForZooming(in: UIScrollView) -> UIView? {
        return nil
    }
}

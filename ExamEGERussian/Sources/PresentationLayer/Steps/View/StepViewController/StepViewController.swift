//
//  StepViewController.swift
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

class StepViewController: UIViewController, StepView {

    // MARK: IBOutlets

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var placeholderView: UIView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    private var stepWebViewHeight: Constraint!

    // MARK: Instance Properties

    var presenter: StepPresenter?

    private lazy var stepWebView: WKWebView = {
        let stepWebView = WKWebView(frame: .zero, configuration: self.webViewConfiguration)
        stepWebView.navigationDelegate = self
        stepWebView.scrollView.delegate = self
        stepWebView.translatesAutoresizingMaskIntoConstraints = false

        return stepWebView
    }()

    private lazy var webViewConfiguration: WKWebViewConfiguration = {
        let script = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
        let userScript = WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let controller = WKUserContentController()
        controller.addUserScript(userScript)
        let сonfiguration = WKWebViewConfiguration()
        сonfiguration.userContentController = controller

        return сonfiguration
    }()

    // For updates after rotation only when controller not presented
    var shouldRefreshOnAppear: Bool = false

    // MARK: - UIViewController Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didScreenRotate),
            name: .UIDeviceOrientationDidChange,
            object: nil
        )

        setupWebView()

        activityIndicator.startAnimating()
        presenter?.refreshStep()
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

        stepWebView.navigationDelegate = nil
        stepWebView.scrollView.delegate = nil
    }

    // MARK: - StepView

    func update(with htmlText: String) {
        let processor = HTMLProcessor(html: htmlText)
        let html = processor.injectDefault().html
        stepWebView.loadHTMLString(html, baseURL: URL(fileURLWithPath: Bundle.main.bundlePath))
    }

    // MARK: - Private API

    @objc func didScreenRotate() {
        refreshWebView()
        shouldRefreshOnAppear = !shouldRefreshOnAppear
    }

    private func setupWebView() {
        scrollView.insertSubview(stepWebView, at: 0)
        stepWebView.snp.makeConstraints { make in
            stepWebViewHeight = make.height.equalTo(5).constraint
            make.bottom.equalTo(placeholderView.snp.top)
            make.leading.equalTo(scrollView).offset(2)
            make.trailing.equalTo(scrollView).offset(-2)
            make.top.equalTo(scrollView).offset(5)
        }
    }

    private func refreshWebView() {
        activityIndicator.startAnimating()
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
            self.animate()
        }.catch { _ in
            print("card step: error while refreshing")
        }
    }
}

// MARK: - StepViewController: WKNavigationDelegate -

extension StepViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        alignImages(in: webView).then {
            self.getContentHeight(webView)
        }.done { height in
            self.resetWebViewHeight(Float(height))
            self.scrollView.layoutIfNeeded()
            self.animate()
        }.catch { _ in
            print("card step: error after webview loading did finish")
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

    // MARK: Private Helpers

    private func resetWebViewHeight(_ height: Float) {
        stepWebViewHeight.update(offset: height)
    }

    private func getContentHeight(_ webView: WKWebView) -> Promise<Int> {
        return Promise { seal in
            webView.evaluateJavaScript("document.body.scrollHeight;") { res, error in
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

    private func alignImages(in webView: WKWebView) -> Promise<Void> {
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

    private func animate() {
        stepWebView.alpha = 0.0
        UIView.animate(withDuration: 0.33, animations: {
            self.stepWebView.alpha = 1.0
        }, completion: { finished in
            guard finished else {
                return
            }
            self.stepWebView.scrollView.contentOffset = .zero
            self.activityIndicator.stopAnimating()
        })
    }
}

// MARK: - StepViewController: UIScrollViewDelegate -

extension StepViewController: UIScrollViewDelegate {
    func viewForZooming(in: UIScrollView) -> UIView? {
        return nil
    }
}

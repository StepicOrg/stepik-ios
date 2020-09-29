//
//  CardStepViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 22.12.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit
import SnapKit
import WebKit

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

    var baseScrollView: UIScrollView { self.scrollView }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.updateAppearance()
        self.setupWebView()
        self.presenter?.refreshStep()

        self.scrollView.contentInsetAdjustmentBehavior = .never

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.didScreenRotate),
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()

        if self.shouldRefreshOnAppear {
            self.refreshWebView()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.shouldRefreshOnAppear = false
    }

    // MARK: CardStepView
    
    func updateProblem(viewModel: CardStepViewModel) {
        let processor = HTMLProcessor(html: viewModel.htmlText)
        let html = processor
            .injectDefault()
            .inject(script: .fontSize(stepFontSize: viewModel.fontSize))
            .html
        self.stepWebView.loadHTMLString(html, baseURL: URL(fileURLWithPath: Bundle.main.bundlePath))
    }

    func updateQuiz(with controller: UIViewController) {
        self.quizView = controller.view

        self.addChild(controller)
        self.quizPlaceholderView.addSubview(self.quizView!)
        self.quizView!.snp.makeConstraints { $0.edges.equalTo(self.quizPlaceholderView) }

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
                self.scrollView.scrollRectToVisible(
                    CGRect(x: 0, y: quizHint.top.y, width: 1, height: self.scrollView.frame.height),
                    animated: true
                )
            } else {
                let bottomOffset = CGPoint(
                    x: 0,
                    y: self.scrollView.contentSize.height - self.scrollView.bounds.height + self.scrollView.contentInset.bottom
                )
                if bottomOffset.y > 0 {
                    self.scrollView.setContentOffset(bottomOffset, animated: true)
                }
            }
        }
    }

    // MARK: Public API

    func refreshWebView() {
        self.resetWebViewHeight(5.0)

        func reloadContent() -> Promise<Void> {
            Promise { seal in
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

    // MARK: Private API

    private func updateAppearance() {
        self.view.backgroundColor = .clear
        self.quizPlaceholderView.backgroundColor = .clear
    }

    private func setupWebView() {
        let jscript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
        let userScript = WKUserScript(source: jscript, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        let wkUController = WKUserContentController()
        wkUController.addUserScript(userScript)
        let wkWebConfig = WKWebViewConfiguration()
        wkWebConfig.userContentController = wkUController

        self.stepWebView = WKWebView(frame: .zero, configuration: wkWebConfig)
        self.stepWebView.navigationDelegate = self
        self.stepWebView.scrollView.isScrollEnabled = false
        self.stepWebView.scrollView.delegate = self
        self.stepWebView.isOpaque = false
        self.stepWebView.backgroundColor = .clear
        self.scrollView.insertSubview(stepWebView, at: 0)

        self.stepWebView.translatesAutoresizingMaskIntoConstraints = false
        self.stepWebView.snp.makeConstraints { make in
            self.stepWebViewHeight = make.height.equalTo(5).constraint
            make.bottom.equalTo(self.quizPlaceholderView.snp.top)
            make.leading.equalTo(self.scrollView).offset(2)
            make.trailing.equalTo(self.scrollView).offset(-2)
            make.top.equalTo(self.scrollView).offset(5)
        }
    }

    @objc
    private func didScreenRotate() {
        self.refreshWebView()
        self.shouldRefreshOnAppear.toggle()
    }
}

// MARK: - CardStepViewController: WKNavigationDelegate -

extension CardStepViewController: WKNavigationDelegate {
    func resetWebViewHeight(_ height: Float) {
        self.stepWebViewHeight.update(offset: height)
    }

    func getContentHeight(_ webView: WKWebView) -> Promise<Int> {
        Promise { seal in
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
        jsCode += "document.body.style.setProperty('--actionColor', '#\(UIColor.stepikGreen.hexString)');"
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

    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        guard let url = navigationAction.request.url else {
            return decisionHandler(.cancel)
        }

        // Check if the request is an iFrame
        if let text = self.problemText {
            if HTMLParsingUtil.getAlliFrameLinks(text).firstIndex(of: url.absoluteString) != nil {
                return decisionHandler(.allow)
            }
        }

        if url.scheme == "openimg" {
            var urlString = url.absoluteString
            urlString.removeSubrange(urlString.startIndex..<urlString.index(urlString.startIndex, offsetBy: 10))
            if let offset = urlString.indexOf("//") {
                urlString.insert(":", at: urlString.index(urlString.startIndex, offsetBy: offset))
                if let newUrl = URL(string: urlString) {
                    FullscreenImageViewer.show(url: newUrl, from: self)
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

// MARK: - CardStepViewController: UIScrollViewDelegate -

extension CardStepViewController: UIScrollViewDelegate {
    func viewForZooming(in: UIScrollView) -> UIView? {
        // Disable zooming
        return nil
    }
}

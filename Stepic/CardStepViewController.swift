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
import FLKAutoLayout

class CardStepViewController: UIViewController, CardStepView {
    weak var presenter: CardStepPresenter?

    var problemText: String?
    weak var quizView: UIView?

    @IBOutlet weak var scrollView: UIScrollView!
    var stepWebView: WKWebView!
    @IBOutlet weak var quizPlaceholderView: UIView!
    var stepWebViewHeight: NSLayoutConstraint!

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
    }

    @objc func didScreenRotate() {
        alignImages(in: stepWebView).then {
            self.getContentHeight(self.stepWebView)
        }.then { height -> Void in
            self.resetWebViewHeight(Float(height))
            self.scrollView.layoutIfNeeded()
        }.catch { _ in
            print("card step: error after rotation")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        view.setNeedsLayout()
        view.layoutIfNeeded()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
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
        scrollView.addSubview(stepWebView)

        stepWebViewHeight = stepWebView.constrainHeight("5")
        stepWebView.constrainBottomSpace(toView: quizPlaceholderView, predicate: "0")
        stepWebView.alignLeadingEdge(withView: scrollView, predicate: "2")
        stepWebView.alignTrailingEdge(withView: scrollView, predicate: "-2")
        stepWebView.alignTopEdge(withView: scrollView, predicate: "5")
    }

    func updateProblem(with htmlText: String) {
        problemText = htmlText

        let scriptsString = "\(Scripts.localTexScript)\(Scripts.clickableImagesScript)"
        var html = HTMLBuilder.sharedBuilder.buildHTMLStringWith(head: scriptsString, body: problemText!, width: Int(UIScreen.main.bounds.width))
        html = html.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        stepWebView.loadHTMLString(html, baseURL: URL(fileURLWithPath: Bundle.main.bundlePath))
    }

    func updateQuiz(with controller: UIViewController) {
        quizView = controller.view

        self.addChildViewController(controller)
        quizPlaceholderView.addSubview(quizView!)
        quizView!.align(toView: quizPlaceholderView)

        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }

    func scrollToQuizBottom() {
        guard let quizHint = presenter?.calculateQuizHintSize() else {
            return
        }
        scrollView.layoutIfNeeded()

        if quizHint.height > view.frame.height {
            scrollView.scrollRectToVisible(CGRect(x: 0, y: quizHint.top.y, width: 1, height: scrollView.frame.height), animated: true)
        } else {
            let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
            if bottomOffset.y > 0 {
                scrollView.setContentOffset(bottomOffset, animated: true)
            }
        }
    }
}

extension CardStepViewController: WKNavigationDelegate {
    func resetWebViewHeight(_ height: Float) {
        stepWebViewHeight.constant = CGFloat(height)
    }

    func getContentHeight(_ webView: WKWebView) -> Promise<Int> {
        return Promise { fulfill, reject in
            webView.evaluateJavaScript("document.body.scrollHeight;", completionHandler: { res, error in
                if let error = error {
                    return reject(error)
                }

                if let height = res as? Int {
                    fulfill(height)
                } else {
                    fulfill(0)
                }
            })
        }
    }

    func alignImages(in webView: WKWebView) -> Promise<Void> {
        var jsCode = "var imgs = document.getElementsByTagName('img');"
        jsCode += "for (var i = 0; i < imgs.length; i++){ imgs[i].style.marginLeft = (document.body.clientWidth / 2) - (imgs[i].clientWidth / 2) - 8 }"

        return Promise { fulfill, reject in
            webView.evaluateJavaScript(jsCode, completionHandler: { _, error in
                if let error = error {
                    return reject(error)
                }

                fulfill(())
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
        }.then { height -> Void in
            self.resetWebViewHeight(Float(height))
            self.scrollView.layoutIfNeeded()

            self.presenter?.problemDidLoad()
        }.catch { _ in
            print("card step: error after webview loading did finish")
        }
    }
}

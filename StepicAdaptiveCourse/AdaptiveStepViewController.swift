//
//  AdaptiveStepViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 24.03.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import Agrume

class AdaptiveStepViewController: UIViewController, AdaptiveStepView {
    weak var presenter: AdaptiveStepPresenter?
    
    var problemText: String?
    weak var quizView: UIView?

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stepWebView: UIWebView!
    @IBOutlet weak var quizPlaceholderView: UIView!
    @IBOutlet weak var quizPlaceholderViewHeight: NSLayoutConstraint!
    @IBOutlet weak var stepWebViewHeight: NSLayoutConstraint!
    
    var baseScrollView: UIScrollView {
        get {
            return scrollView
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter?.refreshStep()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    deinit {
        print("deinit AdaptiveStepViewController")
    }
    
    func updateProblem(with htmlText: String) {
        problemText = htmlText
        
        let scriptsString = "\(Scripts.localTexScript)\(Scripts.clickableImagesScript)"
        var html = HTMLBuilder.sharedBuilder.buildHTMLStringWith(head: scriptsString, body: problemText!, width: Int(UIScreen.main.bounds.width))
        html = html.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        stepWebView.loadHTMLString(html, baseURL: URL(fileURLWithPath: Bundle.main.bundlePath))
    }
    
    func updateQuiz(with view: UIView) {
        quizView = view
        
        quizPlaceholderView.addSubview(quizView!)
        quizView!.align(to: quizPlaceholderView)
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    func updateQuizHeight(newHeight: CGFloat, completion: (() -> ())?) {
        DispatchQueue.main.async { [weak self] in
            self?.quizPlaceholderViewHeight.constant = newHeight
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                self?.view.layoutIfNeeded()
            }, completion: { _ in
                completion?()
            })
        }
    }
    
    func scrollToQuizBottom(quizHintHeight: CGFloat, quizHintTop: CGPoint) {
        if quizHintHeight > view.frame.height {
            scrollView.scrollRectToVisible(CGRect(x: 0, y: quizHintTop.y, width: 1, height: scrollView.frame.height), animated: true)
        } else {
            let bottomOffset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.bounds.size.height + scrollView.contentInset.bottom)
            if bottomOffset.y > 0 {
                scrollView.setContentOffset(bottomOffset, animated: true)
            }
        }
    }
}

extension AdaptiveStepViewController: UIWebViewDelegate {
    func resetWebViewHeight(_ height: Float) {
        stepWebViewHeight.constant = CGFloat(height)
    }
    
    func getContentHeight(_ webView : UIWebView) -> Int {
        let height = Int(webView.stringByEvaluatingJavaScript(from: "document.body.scrollHeight;") ?? "0") ?? 0
        return height
    }
    
    func alignImages(in webView: UIWebView) {
        var jsCode = "var imgs = document.getElementsByTagName('img');"
        jsCode += "for (var i = 0; i < imgs.length; i++){ imgs[i].style.marginLeft = (document.body.clientWidth / 2) - (imgs[i].clientWidth / 2) - 8 }"
        
        webView.stringByEvaluatingJavaScript(from: jsCode)
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        guard let url = request.url else {
            return false
        }
        
        //Check if the request is an iFrame
        if let text = problemText {
            if HTMLParsingUtil.getAlliFrameLinks(text).index(of: url.absoluteString) != nil {
                return true
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
            return false
        }
        return true
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        presenter?.problemDidLoad()
        
        alignImages(in: webView)
        resetWebViewHeight(Float(getContentHeight(webView)))
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        alignImages(in: stepWebView)
        
        presenter?.needsQuizHeightUpdate()
        resetWebViewHeight(Float(getContentHeight(stepWebView)))
    }
}

//
//  AdaptiveStepViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 24.03.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import Agrume

class AdaptiveStepViewController: UIViewController {

    var isSendButtonHidden: Bool = false
    
    var course: Course!
    var recommendedLesson: Lesson!
    var step: Step!
    
    var quizViewController: ChoiceQuizViewController?
    
    weak var delegate: AdaptiveStepViewControllerDelegate?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stepWebView: UIWebView!
    @IBOutlet weak var quizPlaceholderView: UIView!
    @IBOutlet weak var quizPlaceholderViewHeight: NSLayoutConstraint!
    @IBOutlet weak var stepWebViewHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load problem
        self.loadStepHTML(for: step)
        
        // Set up quiz vc
        self.quizViewController = ChoiceQuizViewController(nibName: "QuizViewController", bundle: nil)
        guard let quizVC = self.quizViewController else {
            print("quizVC init failed")
            delegate?.contentLoadingDidFail()
            return
        }
        
        quizVC.step = self.step
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let quizVC = self.quizViewController else {
            print("quizVC not init")
            delegate?.contentLoadingDidFail()
            return
        }
        
        quizVC.view.layoutIfNeeded()
        quizVC.delegate = self
        
        self.addChildViewController(quizVC)
        self.quizPlaceholderView.addSubview(quizVC.view)
        quizVC.view.align(to: self.quizPlaceholderView)
        
        quizVC.isSubmitButtonHidden = isSendButtonHidden
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    fileprivate func loadStepHTML(for step: Step) {
        if let htmlText = step.block.text {
            let scriptsString = "\(Scripts.localTexScript)\(Scripts.clickableImagesScript)"
            var html = HTMLBuilder.sharedBuilder.buildHTMLStringWith(head: scriptsString, body: htmlText, width: Int(UIScreen.main.bounds.width))
            html = html.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            stepWebView.loadHTMLString(html, baseURL: URL(fileURLWithPath: Bundle.main.bundlePath))
        }
    }
    
    fileprivate func scrollToBottom() {
        guard let quizVC = self.quizViewController else {
            print("quizVC not init")
            delegate?.contentLoadingDidFail()
            return
        }
        
        let hintViewHeight = quizVC.hintView.frame.height
        
        if hintViewHeight > view.frame.height {
            let childStartPoint = quizVC.statusLabel.superview?.convert(quizVC.statusLabel.frame.origin, to: scrollView)
            scrollView.scrollRectToVisible(CGRect(x: 0, y: (childStartPoint?.y)!, width: 1, height: scrollView.frame.height), animated: true)
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
        
        if let text = step.block.text {
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
        alignImages(in: webView)
        resetWebViewHeight(Float(getContentHeight(webView)))
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        alignImages(in: stepWebView)
        
        // Maybe quiz vc should update its height itself ???
        needsHeightUpdate((quizViewController?.expectedQuizHeight ?? 0) + (quizViewController?.heightWithoutQuiz ?? 0), animated: true, breaksSynchronizationControl: false)
        resetWebViewHeight(Float(getContentHeight(stepWebView)))
    }
}

extension AdaptiveStepViewController: QuizControllerDelegate {
    func needsHeightUpdate(_ newHeight: CGFloat, animated: Bool, breaksSynchronizationControl: Bool) {
        DispatchQueue.main.async {
            [weak self] in
            self?.quizPlaceholderViewHeight.constant = newHeight
            if animated {
                UIView.animate(withDuration: 0.2, animations: { [weak self] in
                    self?.view.layoutIfNeeded()
                }, completion: { _ in
                    if self?.quizViewController?.submission?.status != nil {
                        self?.scrollToBottom()
                    }
                })
            } else {
                self?.view.layoutIfNeeded()
                if self?.quizViewController?.submission?.status != nil {
                    self?.scrollToBottom()
                }
            }
            
        }
    }
    
    func submissionDidCorrect() {
        delegate?.stepSubmissionDidCorrect()
    }
    
    func submissionDidWrong() {
        delegate?.stepSubmissionDidWrong()
    }
    
    func submissionDidRetry() {
        delegate?.stepSubmissionDidRetry()
    }
    
    func didWarningPlaceholderShow() {
        delegate?.contentLoadingDidFail()
    }
}

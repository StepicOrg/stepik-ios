//
//  WebStepViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 15.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import Alamofire
import FLKAutoLayout
import SVProgressHUD

class WebStepViewController: UIViewController {

    @IBOutlet weak var stepWebView: UIWebView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var quizPlaceholderView: UIView!
    @IBOutlet weak var stepWebViewHeight: NSLayoutConstraint!

    @IBOutlet weak var quizPlaceholderViewHeight: NSLayoutConstraint!
    
    var parent : StepsViewController!
    
    var nItem : UINavigationItem!
    var didStartLoadingFirstRequest = false
    
    var step : Step!
    var stepId : Int!
    var lesson : Lesson!
    var assignment : Assignment?
    
    var stepUrl : String {
        return "https://stepic.org/lesson/\(lesson.slug)/step/\(stepId)"
    }
    
    private var panG : UIPanGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        stepWebView.delegate = self
        
        stepWebView.scrollView.delegate = self
        stepWebView.scrollView.bounces = true
        stepWebView.scrollView.backgroundColor = UIColor.whiteColor()
        handleQuizType()
        stepWebView.scrollView.showsVerticalScrollIndicator = false
    }
    
    private var panStartedInside : Bool?
    private var memOffsetX : CGFloat?
    private var offsetForPager : CGFloat = 0
    private var didBeginPagerDragging : Bool = false
    
    var rightLimitOffsetX : CGFloat {
        return max(0, getContentWidth(stepWebView) - UIScreen.mainScreen().bounds.width)
    }
    
    func refreshRecognizer() {
        panStartedInside = nil
        memOffsetX = nil
        offsetForPager = 0
        stepWebView.scrollView.scrollEnabled = true
        didBeginPagerDragging = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
                        
        nItem.rightBarButtonItem = nil
        
        loadStepHTML()
                
        SVProgressHUD.dismiss()
    }
    
    private func loadStepHTML() {
        if let htmlText = step.block.text {
            let scriptsString = "\(Scripts.texScript)"
            var html = HTMLBuilder.sharedBuilder.buildHTMLStringWith(head: scriptsString, body: htmlText, width: Int(UIScreen.mainScreen().bounds.width))
            html = html.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            stepWebView.loadHTMLString(html, baseURL: nil)
        }
    }
    
    func initQuizController(quizController : QuizViewController) {
        quizController.delegate = self
        quizController.step = self.step
        self.addChildViewController(quizController)
        quizPlaceholderView.addSubview(quizController.view)
        quizController.view.alignToView(quizPlaceholderView)
        self.view.layoutIfNeeded()
    }
    
    func handleQuizType() {
        switch step.block.name {
        case "text":
            stepWebView.alignBottomEdgeWithView(contentView, predicate: "8")
            break
        case "choice":
            let quizController = ChoiceQuizViewController(nibName: "QuizViewController", bundle: nil)
            initQuizController(quizController)
            break
        case "string":
            let quizController = StringQuizViewController(nibName: "QuizViewController", bundle: nil)
            initQuizController(quizController)
            break
        case "number":
            let quizController = NumberQuizViewController(nibName: "QuizViewController", bundle: nil)
            initQuizController(quizController)
            break
        case "free-answer":
            let quizController = FreeAnswerQuizViewController(nibName: "QuizViewController", bundle: nil)
            initQuizController(quizController)
            break
        case "math":
            let quizController = MathQuizViewController(nibName: "QuizViewController", bundle: nil)
            initQuizController(quizController)
            break
        case "sorting":
            let quizController = SortingQuizViewController(nibName: "QuizViewController", bundle: nil)
            initQuizController(quizController)
            break

        default:
            let quizController = UnknownTypeQuizViewController(nibName: "UnknownTypeQuizViewController", bundle: nil)
            quizController.stepUrl = self.stepUrl
            quizController.delegate = self
            self.addChildViewController(quizController)
            quizPlaceholderView.addSubview(quizController.view)
            quizController.view.alignToView(quizPlaceholderView)
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if let a = assignment {
            ApiDataDownloader.sharedDownloader.didVisitStepWith(id: step.id, assignment: a.id, success: {}) 
        }
    }
    
    @IBAction func solveOnTheWebsitePressed(sender: UIButton) {
//        print(stepUrl)
//        print(NSURL(string: stepUrl))
        
        let url = NSURL(string: stepUrl.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!)!
        
        WebControllerManager.sharedManager.presentWebControllerWithURL(url, inController: self, withKey: "external link", allowsSafari: true, backButtonStyle: BackButtonStyle.Close)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
//        print("entered web view did layout subviews")
        super.viewDidLayoutSubviews()
//        print("did layout subviews")
    }
    
    
    func resetWebViewHeight(height: Float) {
        if height == 0.0 {
            print("\n__________________\nReloading web view after height set to 0.0\n_________________________\n")
            stepWebView.reload()
            return
        }
//        print("entered resetWebViewHeight")
        stepWebViewHeight.constant = CGFloat(height)
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    var additionalOffsetXValue : CGFloat = 0.0

}

extension WebStepViewController : UIWebViewDelegate {
    
    func openInBrowserAlert(url: NSURL) {
        let alert = UIAlertController(title: NSLocalizedString("Link", comment: ""), message: NSLocalizedString("OpenInBrowser", comment: ""), preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Open", comment: ""), style: .Default, handler: { 
            (action) -> Void in
            UIThread.performUI{
                WebControllerManager.sharedManager.presentWebControllerWithURL(url, inController: self, withKey: "external link", allowsSafari: true, backButtonStyle: BackButtonStyle.Close)
            }
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
//        print(request.URLString)
        if didStartLoadingFirstRequest {
            if let url = request.URL { 
                if url.absoluteString != "about:blank" {
//                if url.scheme == "ready" {
//                    resetWebViewHeight(Float(url.host!)!)
//                } else {
                    print("trying to open in browser url -> \(url)")
                    openInBrowserAlert(url) 
                }
//                }
            }
            return false
        } else {
            didStartLoadingFirstRequest = true
            return true
        }
    }
    
    func getContentHeight(webView : UIWebView) -> Int {
        return Int(webView.stringByEvaluatingJavaScriptFromString("document.body.scrollHeight;") ?? "0") ?? 0
//        return Int(webView.scrollView.contentSize.height)
    }
    
    func getContentWidth(webView: UIWebView) -> CGFloat {
        return webView.scrollView.contentSize.width
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        
        print("did finish load called, step id -> \(stepId) height -> \(getContentHeight(webView))")
        resetWebViewHeight(Float(getContentHeight(webView)))
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        stepWebView.reload()
    }
}

extension WebStepViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y != 0 {
            var offset = scrollView.contentOffset;
            offset.y = 0
            scrollView.contentOffset = offset;
        }
    }
}

extension WebStepViewController : QuizControllerDelegate {
    func needsHeightUpdate(newHeight: CGFloat) {
        quizPlaceholderViewHeight.constant = newHeight
        view.layoutIfNeeded()
        quizPlaceholderView.layoutIfNeeded()
    }
}

extension WebStepViewController : UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (otherGestureRecognizer == stepWebView.scrollView.panGestureRecognizer) {
            print("did ask for simultaneous recognition with webview")
            return true
        }
        
        if (otherGestureRecognizer == parent.pagerScrollView.panGestureRecognizer) {
            print("did ask for simultaneous recognition with pagination")
            return true
        }
        
        return false
    }
}
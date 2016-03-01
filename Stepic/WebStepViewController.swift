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
        stepWebView.scrollView.bounces = false
        stepWebView.scrollView.scrollEnabled = false
        stepWebView.scrollView.backgroundColor = UIColor.whiteColor()
        handleQuizType()
        stepWebView.scrollView.showsVerticalScrollIndicator = false
        
        panG = UIPanGestureRecognizer(target: self, action: "didPan:")
        panG.delegate = self
        panG.cancelsTouchesInView = false
        self.view.addGestureRecognizer(panG)
    }
    
    private var shouldTranslateOffsetChange = false
    private var offsetChange : CGFloat = 0
    private var startOffset : CGFloat = 0
    func didPan(sender: UIPanGestureRecognizer) {
        
        if sender.state == UIGestureRecognizerState.Began {
//            print("pan started for step \(stepId)")
            offsetChange = 0
            startOffset = stepWebView.scrollView.contentOffset.x
        }
        
        if shouldTranslateOffsetChange {
//            print("offsetChange was \(offsetChange)")
            var cleanOffset = stepWebView.scrollView.contentOffset.x + offsetChange
//            print("cleanOffset calculated \(cleanOffset)")
            cleanOffset -= sender.translationInView(stepWebView).x
//            print("cleanOffset with current pan offset \(cleanOffset)")
            cleanOffset = max(0, cleanOffset)
            cleanOffset = min(cleanOffset, rightLimitOffsetX)
//            print("normed cleanOffset \(cleanOffset)")
            offsetChange = -cleanOffset + startOffset
//            print("new offsetChange \(offsetChange)")
            stepWebView.scrollView.contentOffset = CGPoint(x: cleanOffset, y: stepWebView.scrollView.contentOffset.y)
        }
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
        resetWebViewHeight(Float(getContentHeight(stepWebView)))
        loadStepHTML()
    }
    
    private func loadStepHTML() {
        if let htmlText = step.block.text {
            let scriptsString = "\(Scripts.localTexScript)"
            var html = HTMLBuilder.sharedBuilder.buildHTMLStringWith(head: scriptsString, body: htmlText, width: Int(UIScreen.mainScreen().bounds.width))
            html = html.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            print("\(NSBundle.mainBundle().bundlePath)")
            stepWebView.loadHTMLString(html, baseURL: NSURL(fileURLWithPath: NSBundle.mainBundle().bundlePath))
        }
    }
    
    func initQuizController(quizController : QuizViewController) {
        quizController.delegate = self
        quizController.step = self.step
        if self.step.hasReview {
            quizController.stepUrl = self.stepUrl
        }
        self.addChildViewController(quizController)
        quizPlaceholderView.addSubview(quizController.view)
        quizController.view.alignToView(quizPlaceholderView)
        self.view.setNeedsLayout()
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
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        if let a = assignment {
            ApiDataDownloader.sharedDownloader.didVisitStepWith(id: step.id, assignment: a.id, success: {}) 
        }
    }
    
    
    //Measured in seconds
    let reloadTimeStandardInterval = 0.5
    let reloadTimeout = 10.0
    
    private func reloadWithCount(count: Int) {
        if Double(count) * reloadTimeStandardInterval > reloadTimeout {
            return
        }
        
        delay(reloadTimeStandardInterval * Double(count), closure: {
            UIThread.performUI{
                self.resetWebViewHeight(Float(self.getContentHeight(self.stepWebView)))
            }
            self.reloadWithCount(count + 1)
        })  
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
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("did layout subviews in web step \(stepId)")
    }
    
    
    func resetWebViewHeight(height: Float) {
//        print("web view \(stepId) resetWebViewHeight loading status: \(stepWebView.loading)")
        if height == 0.0 {
//            print("\n__________________\nReloading web view \(stepId) after height set to 0.0\n_________________________\n")
            stepWebView.reload()
            return
        }
//        print("__________________\n web view \(stepId)  height set to \(height), loading status: \(stepWebView.loading)\n_________________________\n")
        

//        print("entered resetWebViewHeight")
        stepWebViewHeight.constant = CGFloat(height)
//        self.view.setNeedsLayout()
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
        print(request.URLString)
        if didStartLoadingFirstRequest {
            if let url = request.URL { 
                
                if url.scheme != "file" {
                    if url.scheme == "ready" {
                        print("scheme ready reported")
                        resetWebViewHeight(Float(getContentHeight(webView)))
                    } else {
                        print("trying to open in browser url -> \(url)")
                        openInBrowserAlert(url) 
                    }
                } 
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
        self.reloadWithCount(0)
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        resetWebViewHeight(Float(getContentHeight(stepWebView)))
    }
}

extension WebStepViewController : UIScrollViewDelegate {
}

extension WebStepViewController : QuizControllerDelegate {
    func needsHeightUpdate(newHeight: CGFloat) {
        quizPlaceholderViewHeight.constant = newHeight
        view.setNeedsLayout()
        view.layoutIfNeeded()
        quizPlaceholderView.layoutIfNeeded()
    }
}

extension WebStepViewController : UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {

        if (otherGestureRecognizer == parent.pagerScrollView.panGestureRecognizer) {
//            print("did ask \(stepId) for simultaneous recognition with pagination")

            let sender = gestureRecognizer as! UIPanGestureRecognizer
            let locationInView = sender.locationInView(stepWebView)
            if CGRectContainsPoint(stepWebView.bounds, locationInView)  {
//                print("pan \(stepId) located inside webview")
                let vel = sender.velocityInView(self.view)
                let draggedRight = vel.x > 0
//                print("webview content offset -> \(stepWebView.scrollView.contentOffset.x), draggedRight: \(draggedRight)")
                if (stepWebView.scrollView.contentOffset.x == 0 && draggedRight) ||
                    (stepWebView.scrollView.contentOffset.x == rightLimitOffsetX && !draggedRight){
//                        print("offset is an edge one, dragged right state \(draggedRight)")
                        shouldTranslateOffsetChange = false
                        return true
                } else {
                    shouldTranslateOffsetChange = true
                    return false
                }
            } else {
                shouldTranslateOffsetChange = false
                return true
            }
        }
        
        return false
    }
}
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
    
    @IBOutlet weak var discussionCountView: DiscussionCountView!
    @IBOutlet weak var discussionCountViewHeight: NSLayoutConstraint!
    
    
    @IBOutlet weak var prevLessonButton: UIButton!
    @IBOutlet weak var nextLessonButton: UIButton!
    @IBOutlet weak var nextLessonButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var prevLessonButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var discussionToPrevDistance: NSLayoutConstraint!
    @IBOutlet weak var discussionToNextDistance: NSLayoutConstraint!
    @IBOutlet weak var prevToBottomDistance: NSLayoutConstraint!
    @IBOutlet weak var nextToBottomDistance: NSLayoutConstraint!
    
    var nextLessonHandler: (Void->Void)?
    var prevLessonHandler: (Void->Void)?
    
    var parent : StepsViewController!
    
    var nItem : UINavigationItem!
    var didStartLoadingFirstRequest = false
    
    var step : Step!
    var stepId : Int!
    var lesson : Lesson!
    var assignment : Assignment? {
        if let assignments = lesson.unit?.assignments {
            return assignments.filter({ $0.stepId == step.id }).first
        } else {
            return nil
        }
    }
    
    var stepText = ""
    
    var stepUrl : String {
        return "\(StepicApplicationsInfo.stepicURL)/lesson/\(lesson.slug)/step/\(stepId)?from_mobile_app=true"
    }
    
    var scrollHelper : WebViewHorizontalScrollHelper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(WebStepViewController.updatedStepNotification(_:)), name: StepsViewController.stepUpdatedNotification, object: nil)
        
        stepWebView.delegate = self
        
        stepWebView.scrollView.delegate = self
        stepWebView.scrollView.backgroundColor = UIColor.whiteColor()
        scrollHelper = WebViewHorizontalScrollHelper(webView: stepWebView, onView: self.view, pagerPanRecognizer: parent.pagerScrollView.panGestureRecognizer)
        print(self.view.gestureRecognizers)
        
        
        nextLessonButton.setTitle("  \(NSLocalizedString("NextLesson", comment: ""))  ", forState: .Normal)
        prevLessonButton.setTitle("  \(NSLocalizedString("PrevLesson", comment: ""))  ", forState: .Normal)
        
        initialize()
    }
    
    func initialize() {
        
        handleQuizType()
        if let discussionCount = step.discussionsCount {
            discussionCountView.commentsCount = discussionCount
            discussionCountView.showCommentsHandler = {
                [weak self] in
                self?.showComments()
            }
        } else {
            discussionCountViewHeight.constant = 0
        }
        
        if nextLessonHandler == nil {
            nextLessonButton.hidden = true
        } else {
            nextLessonButton.setStepicWhiteStyle()
        }
        
        if prevLessonHandler == nil {
            prevLessonButton.hidden = true
        } else {
            prevLessonButton.setStepicWhiteStyle()
        }
        
        if nextLessonHandler == nil && prevLessonHandler == nil {
            nextLessonButtonHeight.constant = 0
            prevLessonButtonHeight.constant = 0
            discussionToNextDistance.constant = 0
            discussionToPrevDistance.constant = 0
            prevToBottomDistance.constant = 0
            nextToBottomDistance.constant = 0
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        nItem.rightBarButtonItem = nil
        resetWebViewHeight(Float(getContentHeight(stepWebView)))
        loadStepHTML()
    }
    
    func updatedStepNotification(notification: NSNotification) {
        print("did get update step notification")
        initialize()
        loadStepHTML()
    }
    
    private func loadStepHTML() {
        if let htmlText = step.block.text {
            if htmlText == stepText {
                return
            }
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
            stepWebView.constrainBottomSpaceToView(discussionCountView, predicate: "8")
            //            stepWebView.alignBottomEdgeWithView(contentView, predicate: "8")
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
            let stepid = step.id
            performRequest({
                ApiDataDownloader.sharedDownloader.didVisitStepWith(id: stepid, assignment: a.id, success: {
                    [weak self] in
                    if let cstep = self?.step {
                        if cstep.block.name == "text" {
                            NSNotificationCenter.defaultCenter().postNotificationName(StepDoneNotificationKey, object: nil, userInfo: ["id" : cstep.id])
                            UIThread.performUI{
                                cstep.progress?.isPassed = true
                                CoreDataHelper.instance.save()
                            }                    
                        }
                    }
                    })
            })
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
    }
    
    
    func resetWebViewHeight(height: Float) {
        if height == 0.0 {
            stepWebView.reload()
            return
        }
        
        stepWebViewHeight.constant = CGFloat(height)
        UIView.animateWithDuration(0.2, animations: { 
            [weak self] in
            self?.view.layoutIfNeeded() 
            })
    }
    
    var additionalOffsetXValue : CGFloat = 0.0
    
    func showComments() {
        if let discussionProxyId = step.discussionProxyId {
            let vc = DiscussionsViewController(nibName: "DiscussionsViewController", bundle: nil) 
            vc.discussionProxyId = discussionProxyId
            vc.target = self.step.id
            navigationController?.pushViewController(vc, animated: true)
        } else {
            //TODO: Load comments here
        }
    }
    
    @IBAction func prevLessonPressed(sender: UIButton) {
        prevLessonHandler?()
    }
    
    @IBAction func nextLessonPressed(sender: UIButton) {
        nextLessonHandler?()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: StepsViewController.stepUpdatedNotification, object: nil)
    }
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
    func needsHeightUpdate(newHeight: CGFloat, animated: Bool) {
        quizPlaceholderViewHeight.constant = newHeight
        view.setNeedsLayout()
        if animated { 
            UIView.animateWithDuration(0.2, animations: {
                [weak self] in
                self?.view.layoutIfNeeded()
                self?.quizPlaceholderView.layoutIfNeeded()
                })
        } else {
            self.view.layoutIfNeeded()
            self.quizPlaceholderView.layoutIfNeeded()
        }
    }
}
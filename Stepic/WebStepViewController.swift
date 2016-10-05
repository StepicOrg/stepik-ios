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
    
    var nextLessonHandler: ((Void)->Void)?
    var prevLessonHandler: ((Void)->Void)?
    
    var stepsVC : StepsViewController!
    
    var nItem : UINavigationItem!
    var didStartLoadingFirstRequest = false
    
    var step : Step!
    var stepId : Int!
    var lesson : Lesson!
    var assignment : Assignment?
    var lessonSlug: String!

    var startStepId: Int!
    var startStepBlock : ((Void)->Void)!
    var shouldSendViewsBlock : ((Void)->Bool)!
    
    var stepText = ""
    
    var stepUrl : String {
        return "\(StepicApplicationsInfo.stepicURL)/lesson/\(lesson.slug)/step/\(stepId)?from_mobile_app=true"
    }
    
    var scrollHelper : WebViewHorizontalScrollHelper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(WebStepViewController.updatedStepNotification(_:)), name: NSNotification.Name(rawValue: StepsViewController.stepUpdatedNotification), object: nil)
        
        stepWebView.delegate = self
        
        stepWebView.scrollView.delegate = self
        stepWebView.scrollView.backgroundColor = UIColor.white
        scrollHelper = WebViewHorizontalScrollHelper(webView: stepWebView, onView: self.view, pagerPanRecognizer: stepsVC.pagerScrollView.panGestureRecognizer)
        print(self.view.gestureRecognizers)
        
        nextLessonButton.setTitle("  \(NSLocalizedString("NextLesson", comment: ""))  ", for: UIControlState())
        prevLessonButton.setTitle("  \(NSLocalizedString("PrevLesson", comment: ""))  ", for: UIControlState())
        
        initialize()
    }
    
    func sharePressed(_ item: UIBarButtonItem) {
        //        AnalyticsReporter.reportEvent(AnalyticsEvents.Syllabus.shared, parameters: nil)
        let stepid = stepId
        let slug = lessonSlug!
        DispatchQueue.global( priority: DispatchQueue.GlobalQueuePriority.default).async {
            let shareVC = SharingHelper.getSharingController(StepicApplicationsInfo.stepicURL + "/lesson/" + slug + "/step/" + "\(stepid)")
            shareVC.popoverPresentationController?.barButtonItem = item
            DispatchQueue.main.async {
                self.present(shareVC, animated: true, completion: nil)
            }
        }
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
            nextLessonButton.isHidden = true
        } else {
            nextLessonButton.setStepicWhiteStyle()
        }
        
        if prevLessonHandler == nil {
            prevLessonButton.isHidden = true
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let shareBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.action, target: self, action: #selector(WebStepViewController.sharePressed(_:)))
        nItem.rightBarButtonItems = [shareBarButtonItem]

        resetWebViewHeight(Float(getContentHeight(stepWebView)))
        loadStepHTML()
    }
    
    func updatedStepNotification(_ notification: Foundation.Notification) {
        print("did get update step notification")
        initialize()
        loadStepHTML()
    }
    
    fileprivate func loadStepHTML() {
        if let htmlText = step.block.text {
            if htmlText == stepText {
                return
            }
            let scriptsString = "\(Scripts.localTexScript)"
            var html = HTMLBuilder.sharedBuilder.buildHTMLStringWith(head: scriptsString, body: htmlText, width: Int(UIScreen.main.bounds.width))
            html = html.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            print("\(Bundle.main.bundlePath)")
            stepWebView.loadHTMLString(html, baseURL: URL(fileURLWithPath: Bundle.main.bundlePath))
        }
    }
    
    func initQuizController(_ quizController : QuizViewController) {
        quizController.delegate = self
        quizController.step = self.step
        if self.step.hasReview {
            quizController.stepUrl = self.stepUrl
        }
        self.addChildViewController(quizController)
        quizPlaceholderView.addSubview(quizController.view)
        quizController.view.align(to: quizPlaceholderView)
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    func handleQuizType() {
        switch step.block.name {
        case "text":
            stepWebView.constrainBottomSpace(to: discussionCountView, predicate: "8")
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
            quizController.view.align(to: quizPlaceholderView)
            self.view.layoutIfNeeded()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        let stepid = step.id
        print("view did appear for web step with id \(stepid)")

        if stepId - 1 == startStepId {
            startStepBlock()
        }
        
        if shouldSendViewsBlock() {
            performRequest({
                [weak self] in
                ApiDataDownloader.sharedDownloader.didVisitStepWith(id: stepid, assignment: self?.assignment?.id, success: {
                    [weak self] in
                    if let cstep = self?.step {
                        if cstep.block.name == "text" {
                                NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: StepDoneNotificationKey), object: nil, userInfo: ["id" : cstep.id])
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
    
    fileprivate func reloadWithCount(_ count: Int) {
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
    
    @IBAction func solveOnTheWebsitePressed(_ sender: UIButton) {
        //        print(stepUrl)
        //        print(NSURL(string: stepUrl))
        
        let url = URL(string: stepUrl.addingPercentEscapes(using: String.Encoding.utf8)!)!
        
        WebControllerManager.sharedManager.presentWebControllerWithURL(url, inController: self, withKey: "external link", allowsSafari: true, backButtonStyle: BackButtonStyle.close)
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
    
    
    func resetWebViewHeight(_ height: Float) {
        if height == 0.0 {
            stepWebView.reload()
            return
        }
        
        stepWebViewHeight.constant = CGFloat(height)
        UIView.animate(withDuration: 0.2, animations: { 
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
    
    @IBAction func prevLessonPressed(_ sender: UIButton) {
        prevLessonHandler?()
    }
    
    @IBAction func nextLessonPressed(_ sender: UIButton) {
        nextLessonHandler?()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: StepsViewController.stepUpdatedNotification), object: nil)
    }
}

extension WebStepViewController : UIWebViewDelegate {
    
    func openInBrowserAlert(_ url: URL) {
        let alert = UIAlertController(title: NSLocalizedString("Link", comment: ""), message: NSLocalizedString("OpenInBrowser", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Open", comment: ""), style: .default, handler: { 
            (action) -> Void in
            UIThread.performUI{
                WebControllerManager.sharedManager.presentWebControllerWithURL(url, inController: self, withKey: "external link", allowsSafari: true, backButtonStyle: BackButtonStyle.close)
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
//        print(request.URLString)
        if didStartLoadingFirstRequest {
            if let url = request.url { 
                
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
    
    func getContentHeight(_ webView : UIWebView) -> Int {
        return Int(webView.stringByEvaluatingJavaScript(from: "document.body.scrollHeight;") ?? "0") ?? 0
        //        return Int(webView.scrollView.contentSize.height)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        print("did finish load called, step id -> \(stepId) height -> \(getContentHeight(webView))")
        resetWebViewHeight(Float(getContentHeight(webView)))
        self.reloadWithCount(0)
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        resetWebViewHeight(Float(getContentHeight(stepWebView)))
    }
}

extension WebStepViewController : UIScrollViewDelegate {
}

extension WebStepViewController : QuizControllerDelegate {
    func needsHeightUpdate(_ newHeight: CGFloat, animated: Bool) {
        quizPlaceholderViewHeight.constant = newHeight
        view.setNeedsLayout()
        if animated { 
            UIView.animate(withDuration: 0.2, animations: {
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

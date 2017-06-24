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
import Agrume

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
    
    weak var lessonView : LessonView?
    
    var nController : UINavigationController?
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
        return "\(StepicApplicationsInfo.stepicURL)/lesson/\(lesson.slug)/step/\(stepId ?? 1)?from_mobile_app=true"
    }
    
    var scrollHelper : WebViewHorizontalScrollHelper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        stepWebView.delegate = self
        
        stepWebView.scrollView.delegate = self
        stepWebView.scrollView.backgroundColor = UIColor.white
//        stepWebView.backgroundColor = UIColor.white
        
        if let recognizer = lessonView?.pagerGestureRecognizer {
            scrollHelper = WebViewHorizontalScrollHelper(webView: stepWebView, onView: self.view, pagerPanRecognizer: recognizer)
            print(self.view.gestureRecognizers ?? "")
        }
        
        nextLessonButton.setTitle("  \(NSLocalizedString("NextLesson", comment: ""))  ", for: UIControlState())
        prevLessonButton.setTitle("  \(NSLocalizedString("PrevLesson", comment: ""))  ", for: UIControlState())
        
        initialize()
    }
    
    func sharePressed(_ item: UIBarButtonItem) {
        //        AnalyticsReporter.reportEvent(AnalyticsEvents.Syllabus.shared, parameters: nil)
        guard let stepid = stepId, 
            let slug = lessonSlug else {
            return
        }
//        let slug = lessonSlug!
        DispatchQueue.global(qos: .default).async {
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
        
        if let discussionCount = step.discussionsCount {
            discussionCountView.commentsCount = discussionCount
        }
    }
    
    func updatedStepNotification(_ notification: Foundation.Notification) {
        print("did get update step notification")
        initialize()
        loadStepHTML()
    }
    
    fileprivate func loadStepHTML() {
        guard step.block.text != nil else {
            return
        }
        var htmlText = step.block.text!
        if htmlText == stepText {
            return
        }
        if step.block.name == "code" {
            for (index, sample) in (step.options?.samples ?? []).enumerated() {
                htmlText += "<h4>Sample input \(index + 1)</h4>\(sample.input)<h4>Sample output \(index + 1)</h4>\(sample.output)"
            }
        }
        let scriptsString = "\(Scripts.localTexScript)\(Scripts.clickableImagesScript)"
        var html = HTMLBuilder.sharedBuilder.buildHTMLStringWith(head: scriptsString, body: htmlText, width: Int(UIScreen.main.bounds.width))
        html = html.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        print("\(Bundle.main.bundlePath)")
        stepWebView.loadHTMLString(html, baseURL: URL(fileURLWithPath: Bundle.main.bundlePath))
        
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
//        self.view.setNeedsLayout()
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
        case "matching":
            let quizController = MatchingQuizViewController(nibName: "QuizViewController", bundle: nil)
            initQuizController(quizController)
            break
        case "fill-blanks":
            let quizController = FillBlanksQuizViewController(nibName: "QuizViewController", bundle: nil)
            initQuizController(quizController)
            break
        case "code":
            let quizController = CodeQuizViewController(nibName: "QuizViewController", bundle: nil)
            initQuizController(quizController)
            break
        default:
            let quizController = UnknownTypeQuizViewController(nibName: "UnknownTypeQuizViewController", bundle: nil)
            print("unknown type \(step.block.name)")
            quizController.stepUrl = self.stepUrl
            quizController.delegate = self
            self.addChildViewController(quizController)
            quizPlaceholderView.addSubview(quizController.view)
            quizController.view.align(to: quizPlaceholderView)
            self.view.layoutIfNeeded()
        }
    }
    
    fileprivate func animateTabSelection() {
        //Animate the views
        if let cstep = self.step {
            if cstep.block.name == "text" {
                NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: StepDoneNotificationKey), object: nil, userInfo: ["id" : cstep.id])
                DispatchQueue.main.async {
                    cstep.progress?.isPassed = true
                    CoreDataHelper.instance.save()
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        self.view.setNeedsLayout()
//        self.view.layoutIfNeeded()
        
        AnalyticsReporter.reportEvent(AnalyticsEvents.Step.opened, parameters: ["item_name": step.block.name as NSObject])
        
        if step.hasSubmissionRestrictions {
            AnalyticsReporter.reportEvent(AnalyticsEvents.Step.hasRestrictions, parameters: nil)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(WebStepViewController.updatedStepNotification(_:)), name: NSNotification.Name(rawValue: LessonPresenter.stepUpdatedNotification), object: nil)

        let stepid = step.id
        print("view did appear for web step with id \(stepid)")
        
        LastStepGlobalContext.context.stepId = stepid
        
        if stepId - 1 == startStepId {
            startStepBlock()
        }
        
        if shouldSendViewsBlock() {

            //Send view to views
            performRequest({
                [weak self] in
                print("Sending view for step with id \(stepid) & assignment \(String(describing: self?.assignment?.id))")
                _ = ApiDataDownloader.views.create(stepId: stepid, assignment: self?.assignment?.id, success: {
                    [weak self] in
                    self?.animateTabSelection()
                }, error: {
                    [weak self]
                    error in
                    
                    switch error {
                    case .notAuthorized:
                        return
                    default:
                        self?.animateTabSelection()
                        print("initializing post views task")
                        print("user id \(String(describing: AuthInfo.shared.userId)) , token \(String(describing: AuthInfo.shared.token))")
                        if let userId =  AuthInfo.shared.userId,
                            let token = AuthInfo.shared.token {
                            
                            let task = PostViewsExecutableTask(stepId: stepid, assignmentId: self?.assignment?.id, userId: userId)
                            ExecutionQueues.sharedQueues.connectionAvailableExecutionQueue.push(task)
                            
                            let userPersistencyManager = PersistentUserTokenRecoveryManager(baseName: "Users")
                            userPersistencyManager.writeStepicToken(token, userId: userId)
                            
                            let taskPersistencyManager = PersistentTaskRecoveryManager(baseName: "Tasks")
                            taskPersistencyManager.writeTask(task, name: task.id)
                            
                            let queuePersistencyManager = PersistentQueueRecoveryManager(baseName: "Queues")
                            queuePersistencyManager.writeQueue(ExecutionQueues.sharedQueues.connectionAvailableExecutionQueue, key: ExecutionQueues.sharedQueues.connectionAvailableExecutionQueueKey)
                        } else {
                            print("Could not get current user ID or token to post views")
                        }
                    }
                })
            })
            //Update LastStep locally from the context
            if let course = LastStepGlobalContext.context.course, 
                let unitId = LastStepGlobalContext.context.unitId, 
                let stepId = LastStepGlobalContext.context.stepId {
                
                if let lastStep = course.lastStep {
                    lastStep.update(unitId: unitId, stepId: stepId)
                } else {
                    course.lastStep = LastStep(id: course.lastStepId ?? "", unitId: unitId, stepId: stepId)
                }
            } 
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: LessonPresenter.stepUpdatedNotification), object: nil)
    }
    
    //Measured in seconds
    let reloadTimeStandardInterval = 0.5
    let reloadTimeout = 10.0
    
    fileprivate func reloadWithCount(_ count: Int) {
        if Double(count) * reloadTimeStandardInterval > reloadTimeout {
            return
        }
        
        delay(reloadTimeStandardInterval * Double(count), closure: {
            [weak self] in
            DispatchQueue.main.async{
                [weak self] in
                if let s = self {
                    s.resetWebViewHeight(Float(s.getContentHeight(s.stepWebView)))
                }
            }
            self?.reloadWithCount(count + 1)
        })  
    }
    
    @IBAction func solveOnTheWebsitePressed(_ sender: UIButton) {
        //        print(stepUrl)
        //        print(NSURL(string: stepUrl))
        
        let url = URL(string: stepUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
        
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
    
    var webViewUpdatingHeight : Float? = nil
    
    func resetWebViewHeight(_ height: Float) {
        if height == 0.0 {
            stepWebView.reload()
            return
        }
        
        if needsQuizUpdateAttention {
            if isCurrentlyUpdatingHeight {
                print("STEPID: \(self.stepId) Currently updating height in resetWebViewHeight")
                webViewUpdatingHeight = height
                return
            }
            
            isCurrentlyUpdatingHeight = true
        }
        stepWebViewHeight.constant = CGFloat(height)
        UIView.animate(withDuration: 0.2, animations: { 
            [weak self] in
            self?.view.layoutIfNeeded() 
        }, completion: {
            [weak self] 
            completed in
            if (self?.needsQuizUpdateAttention ?? false) {
                self?.isCurrentlyUpdatingHeight = false
                
                if self?.webViewUpdatingHeight == height {
                    self?.webViewUpdatingHeight = nil
                }

                if let h = self?.webViewUpdatingHeight {
                    self?.resetWebViewHeight(h)
                }
            }
        })
    }
    
    var additionalOffsetXValue : CGFloat = 0.0
    
    func showComments() {
        if let discussionProxyId = step.discussionProxyId {
            let vc = DiscussionsViewController(nibName: "DiscussionsViewController", bundle: nil) 
            vc.discussionProxyId = discussionProxyId
            vc.target = self.step.id
            vc.step = self.step
            nController?.pushViewController(vc, animated: true)
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
        print("deinit webstepviewcontroller")
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: LessonPresenter.stepUpdatedNotification), object: nil)
    }
    
    var isCurrentlyUpdatingHeight: Bool = false
    var lastUpdatingQuizHeight: CGFloat? = nil
}

extension WebStepViewController : UIWebViewDelegate {
    
    func openInBrowserAlert(_ url: URL) {
        let alert = UIAlertController(title: NSLocalizedString("Link", comment: ""), message: NSLocalizedString("OpenInBrowser", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Open", comment: ""), style: .default, handler: { 
            (action) -> Void in
            DispatchQueue.main.async{
                [weak self] in
                if let s = self {
                    WebControllerManager.sharedManager.presentWebControllerWithURL(url, inController: s, withKey: "external link", allowsSafari: true, backButtonStyle: BackButtonStyle.close)
                }
            }
        }))
        
        self.present(alert, animated: true, completion: nil)
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
        
        //Check if the request is a navigation inside a lesson
        if url.absoluteString.range(of: "\(lesson.id)/step/") != nil {
            let components = url.pathComponents
            if let index = components.index(of: "step") {
                if index + 1 < components.count {
                    let urlStepIdString = components[index + 1]
                    if let urlStepId = Int(urlStepIdString) {
                        lessonView?.selectTab(index: urlStepId - 1, updatePage: true)
                        return false
                    }
                }
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
        
        if didStartLoadingFirstRequest {
            if url.scheme != "file" {
                if url.scheme == "ready" {
                    print("scheme ready reported")
                    resetWebViewHeight(Float(getContentHeight(webView)))
                } else {
                    print("trying to open in browser url -> \(url)")
                    openInBrowserAlert(url) 
                }
            } 
            return false
        } else {
            didStartLoadingFirstRequest = true
            return true
        }
    }
    
    func getContentHeight(_ webView : UIWebView) -> Int {
        let h = Int(webView.stringByEvaluatingJavaScript(from: "document.body.scrollHeight;") ?? "0") ?? 0
//        if h != 0 {
//            return h + 8
//        } 
        return h
        //        return Int(webView.scrollView.contentSize.height)
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        print("did finish load called, step id -> \(stepId) height -> \(getContentHeight(webView))")
        resetWebViewHeight(Float(getContentHeight(webView)))
        self.reloadWithCount(0)
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        if isCurrentlyUpdatingHeight && needsQuizUpdateAttention {
            delay(0.2, closure: {
                [weak self] in
                if let s = self {
                    s.resetWebViewHeight(Float(s.getContentHeight(s.stepWebView)))
                }
            })
            return
        }
        resetWebViewHeight(Float(getContentHeight(stepWebView)))
    }
    
    var needsQuizUpdateAttention: Bool {
        return step.block.name == "matching"
    }
}

extension WebStepViewController : UIScrollViewDelegate {
}

extension WebStepViewController : QuizControllerDelegate {
    func needsHeightUpdate(_ newHeight: CGFloat, animated: Bool, breaksSynchronizationControl: Bool) {
//        if quizPlaceholderViewHeight.constant == newHeight {
//            return
//        }
        
        if needsQuizUpdateAttention && !breaksSynchronizationControl {
            if newHeight <= self.quizPlaceholderViewHeight.constant {
                print("STEPID: \(self.stepId)  \n\nNot changing equal or less height \(newHeight), return\n\n")
                return
            }
        
            if isCurrentlyUpdatingHeight {
                print("STEPID: \(self.stepId) \n\nIs currently updating height, queuing & returning\n\n")
                if let last = lastUpdatingQuizHeight {
                    if newHeight > last {
                        lastUpdatingQuizHeight = newHeight
                    }
                } else {
                    lastUpdatingQuizHeight = newHeight
                }
                return
            }
        
            isCurrentlyUpdatingHeight = true
            print("STEPID: \(self.stepId) \n\nChanging height to \(newHeight)\n\n")
        }
        
        DispatchQueue.main.async {
            [weak self] in
            self?.quizPlaceholderViewHeight.constant = newHeight
//        view.setNeedsLayout()
            if animated { 
                UIView.animate(withDuration: 0.2, animations: {
                    [weak self] in
                    self?.view.layoutIfNeeded()
                }, completion: {
                    [weak self] 
                    completed in
                    if (self?.needsQuizUpdateAttention ?? false) {
                        self?.isCurrentlyUpdatingHeight = false
                        if self?.lastUpdatingQuizHeight == newHeight {
                            self?.lastUpdatingQuizHeight = nil
                        }
                        if let h = self?.lastUpdatingQuizHeight {
                            self?.needsHeightUpdate(h, animated: animated, breaksSynchronizationControl: false)
                        }
                    }
                })
            } else {
                self?.view.layoutIfNeeded()
                if (self?.needsQuizUpdateAttention ?? false) {

                    self?.isCurrentlyUpdatingHeight = false
                    if self?.lastUpdatingQuizHeight == newHeight {
                        self?.lastUpdatingQuizHeight = nil
                    }
                    if let h = self?.lastUpdatingQuizHeight {
                        self?.needsHeightUpdate(h, animated: animated, breaksSynchronizationControl: false)
                    }
                }
            }
            
        }
    
    }
}

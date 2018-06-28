//
//  WebStepViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 15.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD
import Agrume
import SnapKit

class WebStepViewController: UIViewController {

    @IBOutlet weak var stepWebView: UIWebView!
    @IBOutlet weak var contentView: UIView!

    @IBOutlet weak var quizPlaceholderView: UIView!
    @IBOutlet weak var stepWebViewHeight: NSLayoutConstraint!

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

    var nextLessonHandler: (() -> Void)?
    var prevLessonHandler: (() -> Void)?

    weak var lessonView: LessonView?

    var nController: UINavigationController?
    var nItem: UINavigationItem!
    var didStartLoadingFirstRequest = false

    var quizViewController: QuizViewController?

    var step: Step!
    var stepId: Int!
    var lesson: Lesson!
    var assignment: Assignment?
    var lessonSlug: String!

    var startStepId: Int!
    var startStepBlock : (() -> Void)!
    var shouldSendViewsBlock : (() -> Bool)!

    var stepText = ""

    var stepUrl: String {
        return "\(StepicApplicationsInfo.stepicURL)/lesson/\(lesson.slug)/step/\(stepId ?? 1)?from_mobile_app=true"
    }

    var scrollHelper: WebViewHorizontalScrollHelper!

    override func viewDidLoad() {
        super.viewDidLoad()

        stepWebView.delegate = self

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

    @objc func sharePressed(_ item: UIBarButtonItem) {
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

    @objc func updatedStepNotification(_ notification: Foundation.Notification) {
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
        stepWebView.loadHTMLString(html, baseURL: URL(fileURLWithPath: Bundle.main.bundlePath))
    }

    func initQuizController(_ quizController: QuizViewController?) {
        guard let quizController = quizController else {
            self.quizViewController?.view.removeFromSuperview()
            self.quizViewController?.removeFromParentViewController()
            self.view.layoutIfNeeded()
            return
        }
        quizController.step = self.step
        quizPlaceholderView.addSubview(quizController.view)
        quizController.view.snp.makeConstraints { $0.edges.equalTo(quizPlaceholderView) }
        self.quizViewController?.view.removeFromSuperview()
        self.quizViewController?.removeFromParentViewController()
        self.addChildViewController(quizController)
        quizViewController = quizController
//        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }

    func handleQuizType() {
        switch step.block.name {
        case "text":
            quizViewController = nil
            stepWebView.snp.makeConstraints { $0.bottomMargin.equalTo(discussionCountView).offset(8) }
            break
        case "choice":
            initQuizController(ChoiceQuizViewController(nibName: "QuizViewController", bundle: nil))
            break
        case "string":
            initQuizController(StringQuizViewController(nibName: "QuizViewController", bundle: nil))
            break
        case "number":
            initQuizController(NumberQuizViewController(nibName: "QuizViewController", bundle: nil))
            break
        case "free-answer":
            initQuizController(FreeAnswerQuizViewController(nibName: "QuizViewController", bundle: nil))
            break
        case "math":
            initQuizController(MathQuizViewController(nibName: "QuizViewController", bundle: nil))
            break
        case "sorting":
            initQuizController(SortingQuizViewController(nibName: "QuizViewController", bundle: nil))
            break
        case "matching":
            initQuizController(MatchingQuizViewController(nibName: "QuizViewController", bundle: nil))
            break
        case "fill-blanks":
            initQuizController(FillBlanksQuizViewController(nibName: "QuizViewController", bundle: nil))
            break
        case "code":
            initQuizController(CodeQuizViewController(nibName: "QuizViewController", bundle: nil))
            break
        case "sql":
            initQuizController(SQLQuizViewController(nibName: "QuizViewController", bundle: nil))
            break
        default:
            print("unknown type \(step.block.name)")
            let quizController = UnknownTypeQuizViewController(nibName: "UnknownTypeQuizViewController", bundle: nil)
            quizController.stepUrl = self.stepUrl
            self.addChildViewController(quizController)
            quizPlaceholderView.addSubview(quizController.view)

            quizController.view.snp.makeConstraints { $0.edges.equalTo(quizPlaceholderView) }
            self.view.layoutIfNeeded()
        }
    }

    fileprivate func animateTabSelection() {
        //Animate the views
        if let cstep = self.step {
            if cstep.block.name == "text" {
                NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: StepDoneNotificationKey), object: nil, userInfo: ["id": cstep.id])
                DispatchQueue.main.async {
                    cstep.progress?.isPassed = true
                    CoreDataHelper.instance.save()
                }
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        AnalyticsReporter.reportEvent(AnalyticsEvents.Step.opened, parameters: ["item_name": step.block.name as NSObject, "stepId": step.id])
        AnalyticsReporter.reportAmplitudeEvent(AmplitudeAnalyticsEvents.Steps.stepOpened, parameters: ["step": step.id, "type": step.block.name, "number": stepId - 1])
        if step.hasSubmissionRestrictions {
            AnalyticsReporter.reportEvent(AnalyticsEvents.Step.hasRestrictions, parameters: nil)
        }

        LocalProgressLastViewedUpdater.shared.updateView(for: step)

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
                        if let userId = AuthInfo.shared.userId,
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
            DispatchQueue.main.async {
                [weak self] in
                if let s = self {
                    s.resetWebViewHeight(Float(s.getContentHeight(s.stepWebView)))
                }
            }
            self?.reloadWithCount(count + 1)
        })
    }

    @IBAction func solveOnTheWebsitePressed(_ sender: UIButton) {
        let url = URL(string: stepUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!

        WebControllerManager.sharedManager.presentWebControllerWithURL(url, inController: self, withKey: "external link", allowsSafari: true, backButtonStyle: BackButtonStyle.close)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    var webViewUpdatingHeight: Float?

    func resetWebViewHeight(_ height: Float) {
        if height == 0.0 {
            stepWebView.reload()
            return
        }

        stepWebViewHeight.constant = CGFloat(height)
        self.view.layoutIfNeeded()
    }

    var additionalOffsetXValue: CGFloat = 0.0

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
    var lastUpdatingQuizHeight: CGFloat?
}

extension WebStepViewController : UIWebViewDelegate {

    func openInBrowserAlert(_ url: URL) {
        let alert = UIAlertController(title: NSLocalizedString("Link", comment: ""), message: NSLocalizedString("OpenInBrowser", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Open", comment: ""), style: .default, handler: {
            (_) -> Void in
            DispatchQueue.main.async {
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

    func getContentHeight(_ webView: UIWebView) -> Int {
        let h = Int(webView.stringByEvaluatingJavaScript(from: "document.body.scrollHeight;") ?? "0") ?? 0
        return h
    }

    func webViewDidFinishLoad(_ webView: UIWebView) {

        print("did finish load called, step id -> \(stepId) height -> \(getContentHeight(webView))")
        resetWebViewHeight(Float(getContentHeight(webView)))
        self.reloadWithCount(0)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        resetWebViewHeight(Float(getContentHeight(stepWebView)))
    }
}

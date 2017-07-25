//
//  QuizViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 25.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import Presentr

class QuizViewController: UIViewController {
    
    @IBOutlet weak var sendButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var statusViewHeight: NSLayoutConstraint!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var hintHeight: NSLayoutConstraint!
    @IBOutlet weak var hintView: UIView!
    @IBOutlet weak var hintWebView: UIWebView!
    @IBOutlet weak var hintTextView: UITextView!
    
    @IBOutlet weak var peerReviewHeight: NSLayoutConstraint!
    @IBOutlet weak var peerReviewButton: UIButton!
    
    weak var delegate : QuizControllerDelegate?
    
    var submissionsCount: Int? {
        didSet {
            guard let maxSubmissionsCount = step.maxSubmissionsCount, let submissionsCount = submissionsCount else {
                submissionsLeft = nil
                return
            }
            let left = maxSubmissionsCount - submissionsCount
            if (left > 0 && self.submission?.status != "correct") || step.canEdit {
                sendButton.isEnabled = true
                isSubmitButtonHidden = false
            } else {
                sendButton.isEnabled = false
//                sendButton.setTitle("No submissions left", for: .normal)
//                isSubmitButtonHidden = true
            }
            submissionsLeft = left
        }
    }
    
    var submissionsLeft: Int? {
        didSet {
            guard buttonStateSubmit else {
                return
            }
            if let count = submissionsLeft {
                if count > 0 || step.canEdit {
                    self.sendButton.setTitle(self.submitTitle + " (\(submissionsLeftLocalizable(count: count)))", for: UIControlState())
                } else {
                    self.sendButton.setTitle(NSLocalizedString("NoSubmissionsLeft", comment: ""), for: .normal)
                    self.sendButton.backgroundColor = UIColor.gray
                }
            }
        }
    }
    
    var submitTitle : String {
        return NSLocalizedString("Submit", comment: "")
    }
    
    var tryAgainTitle : String {
        return NSLocalizedString("TryAgain", comment: "")
    }
    
    var correctTitle : String {
        return NSLocalizedString("Correct", comment: "")
    }
    
    var wrongTitle : String {
        return NSLocalizedString("Wrong", comment: "")
    }
    
    var peerReviewText : String {
        return NSLocalizedString("PeerReviewText", comment: "")
    }
    
    let warningViewTitle = NSLocalizedString("ConnectionErrorText", comment: "")
    
    //Activity view here
    lazy var activityView : UIView = self.initActivityView()
    
    lazy var warningView : UIView = self.initWarningView()
    
    func initWarningView() -> UIView {
        //TODO: change warning image!
        let v = PlaceholderView()
        self.view.insertSubview(v, aboveSubview: self.view)
        v.align(to: self.view)
        v.delegate = self
        v.datasource = self
        v.backgroundColor = UIColor.white
        return v
    }
    
    func initActivityView() -> UIView {
        let v = UIView()
        let ai = UIActivityIndicatorView()
        ai.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        ai.constrainWidth("50", height: "50")
        ai.color = UIColor.stepicGreenColor()
        v.backgroundColor = UIColor.white
        v.addSubview(ai)
        ai.alignCenter(with: v)
        ai.startAnimating()
        self.view.insertSubview(v, aboveSubview: self.view)
        v.align(to: self.view)
        v.isHidden = false
        return v
    }
    
    var doesPresentActivityIndicatorView : Bool = false {
        didSet {
            if doesPresentActivityIndicatorView {
                DispatchQueue.main.async {
                    [weak self] in
                    self?.activityView.isHidden = false
                }
            } else {
                DispatchQueue.main.async {
                    [weak self] in
                    self?.activityView.isHidden = true
                }
            }
        }
    }
    
    var doesPresentWarningView : Bool = false {
        didSet {
            if doesPresentWarningView {
                DispatchQueue.main.async {
                    [weak self] in
                    self?.warningView.isHidden = false
                }
                self.delegate?.didWarningPlaceholderShow()
            } else {
                DispatchQueue.main.async {
                    [weak self] in
                    self?.warningView.isHidden = true
                }
            }
        }
    }
    
    
    var attempt : Attempt? {
        didSet {
            if attempt == nil {
                print("ATTEMPT SHOULD NEVER BE SET TO NIL")
                return
            }
            DispatchQueue.main.async {
                [weak self] in
                if let s = self {
                    print("did set attempt id \(String(describing: self?.attempt?.id))")
                    
                    //TODO: Implement in subclass, then it may need a height update
                    s.updateQuizAfterAttemptUpdate()
                }
//                self.view.layoutIfNeeded()
            }
        }
    }
    
    var heightWithoutQuiz : CGFloat {
        return 40 + sendButtonHeight.constant + statusViewHeight.constant + hintHeight.constant + peerReviewHeight.constant
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    var buttonStateSubmit : Bool = true {
        didSet {
            if buttonStateSubmit {
                self.sendButton.setStepicGreenStyle()
                if submissionsLeft != nil && step.hasSubmissionRestrictions {
                    self.sendButton.setTitle(self.submitTitle + " (\(submissionsLeftLocalizable(count: submissionsLeft!)))", for: UIControlState())
                } else {
                    self.sendButton.setTitle(self.submitTitle, for: UIControlState())
                }
            } else {
                self.sendButton.setStepicWhiteStyle()
                self.sendButton.setTitle(self.tryAgainTitle, for: UIControlState())
            }
        }
    }
    
    //Override this in subclass if needed
    var needsToRefreshAttemptWhenWrong : Bool{
        return true
    }
    
    //Override this in subclass
    func updateQuizAfterAttemptUpdate() {
    }
    
    //Override this in subclass
    func updateQuizAfterSubmissionUpdate(reload: Bool = true) {
    }
    
    //Override this in subclass
    var expectedQuizHeight : CGFloat {
        return 0
    }
    
    var needPeerReview : Bool {
        return stepUrl != nil
    }
    
    var stepUrl : String? 
    
    fileprivate func submissionsLeftLocalizable(count: Int) -> String {
        func triesLocalizableFor(count: Int) -> String {
            switch (abs(count) % 10) {
            case 1: return NSLocalizedString("triesLeft1", comment: "")
            case 2, 3, 4: return NSLocalizedString("triesLeft234", comment: "")
            default: return NSLocalizedString("triesLeft567890", comment: "")
            }
        }
        
        return String(format: triesLocalizableFor(count: count), "\(count)")
    }
    
    fileprivate var didGetErrorWhileSendingSubmission = false
    
    fileprivate var hintHeightUpdateBlock : ((Void) -> Int)?
    
    fileprivate func setStatusElements(visible: Bool) {
        statusLabel.isHidden = !visible
        statusImageView.isHidden = !visible
    }
    
    fileprivate func getHintHeightFor(hint: String) -> CGFloat {
        let textView = UITextView()
        textView.text = hint
        textView.font = UIFont(name: "ArialMT", size: 16)
        let fixedWidth = hintTextView.bounds.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        return newSize.height
    }
    
    var submission : Submission? {
        didSet {
            DispatchQueue.main.async {
                [weak self] in
                if let s = self {
                    if s.submission == nil {
                        print("did set submission to nil")
                        s.statusImageView.image = nil
                        s.buttonStateSubmit = true
                        s.view.backgroundColor = UIColor.white
//                        s.sendButton.setTitle(s.submitTitle, for: UIControlState())
                        s.statusViewHeight.constant = 0
                        s.hintHeight.constant = 0
                        s.hintHeightUpdateBlock = nil
                        s.hintView.isHidden = true
                        s.peerReviewHeight.constant = 0
                        s.peerReviewButton.isHidden = true
                        s.setStatusElements(visible: false)
                        
                        if s.didGetErrorWhileSendingSubmission {
                            s.updateQuizAfterSubmissionUpdate(reload: false)   
                            s.didGetErrorWhileSendingSubmission = false
                        } else {
                            s.updateQuizAfterSubmissionUpdate()
                        }
                    } else {
                        print("did set submission id \(String(describing: s.submission?.id))")
                        s.buttonStateSubmit = false
                        
                        if let hint = s.submission?.hint {
                            if hint != "" {
                                s.hintView.isHidden = false
                                if TagDetectionUtil.isWebViewSupportNeeded(hint) {
                                    s.hintHeightUpdateBlock = s.hintHeightWebViewHelper.setTextWithTeX(hint, textColorHex: "#FFFFFF")
                                    s.performHeightUpdates()
                                    s.hintTextView.isHidden = true
                                    s.hintWebView.isHidden = false
                                } else {
                                    s.hintWebView.isHidden = true
                                    s.hintTextView.isHidden = false
                                    s.hintTextView.text = hint
                                    s.hintHeight.constant = s.getHintHeightFor(hint: hint)
                                }
                            } else {
                                s.hintHeight.constant = 0
                            }
                        } else {
                            s.hintHeight.constant = 0
                        }
                        
                        switch s.submission!.status! {
                        case "correct":
                            s.buttonStateSubmit = false
                            s.statusViewHeight.constant = 48
                            s.doesPresentActivityIndicatorView = false
                            s.view.backgroundColor = UIColor.correctQuizBackgroundColor()
                            s.statusImageView.image = Images.correctQuizImage
                            s.statusLabel.text = s.correctTitle
                            s.setStatusElements(visible: true)

                            if s.needPeerReview {
                                s.peerReviewHeight.constant = 40
                                s.peerReviewButton.isHidden = false
                            } else {
                                //TODO: Refactor this!!!!! 
                                NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: StepDoneNotificationKey), object: nil, userInfo: ["id" : s.step.id])
                                DispatchQueue.main.async {
                                    s.step.progress?.isPassed = true
                                    CoreDataHelper.instance.save()
                                }
                            }
                            
                            self?.delegate?.submissionDidCorrect()
                            
                            break
                            
                        case "wrong":
                            if s.needsToRefreshAttemptWhenWrong {
                                s.buttonStateSubmit = false
                            } else {
                                s.buttonStateSubmit = true
                            }
                            s.statusViewHeight.constant = 48
                            s.peerReviewHeight.constant = 0
                            s.peerReviewButton.isHidden = true
                            s.doesPresentActivityIndicatorView = false
                            s.view.backgroundColor = UIColor.wrongQuizBackgroundColor()
                            s.statusImageView.image = Images.wrongQuizImage
                            s.statusLabel.text = s.wrongTitle
                            s.setStatusElements(visible: true)

                            self?.delegate?.submissionDidWrong()
                            
                            break
                            
                        case "evaluation":
                            s.statusViewHeight.constant = 0
                            s.peerReviewHeight.constant = 0
                            s.peerReviewButton.isHidden = true
                            s.doesPresentActivityIndicatorView = true
                            s.statusLabel.text = ""
                            break
                            
                        default: 
                            break
                        }
                        
                        if s.step.hasSubmissionRestrictions {
                            if ((s.submissionsLeft ?? 0) > 0 && s.submission?.status != "correct") || s.step.canEdit {
                                s.sendButton.isEnabled = true
                                s.isSubmitButtonHidden = false
                            } else {
                                s.sendButton.isEnabled = true
                                s.isSubmitButtonHidden = true
                            }
                        }

                        s.updateQuizAfterSubmissionUpdate()
                    }
                }
            }
        }
    }
    
    func handleErrorWhileGettingSubmission() {
    }
    
    var step : Step!
    
    var needNewAttempt: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.setNeedsLayout()
    }
    
    //Measured in seconds
    let reloadTimeStandardInterval = 0.5
    let reloadTimeout = 5.0
    let noReloadTimeout = 1.0
    
    fileprivate func reloadWithCount(_ count: Int, noReloadCount: Int) {
        if Double(count) * reloadTimeStandardInterval > reloadTimeout {
            return
        }
        if Double(noReloadCount) * reloadTimeStandardInterval > noReloadTimeout {
            return 
        }
        delay(reloadTimeStandardInterval * Double(count), closure: {
            [weak self] in
            if self?.countHeight() == true {
                DispatchQueue.main.async {
                    [weak self] in
                    if let expectedHeight = self?.expectedQuizHeight, 
                        let noQuizHeight = self?.heightWithoutQuiz {
                    }
                }
                self?.reloadWithCount(count + 1, noReloadCount: 0)
            } else {
                self?.reloadWithCount(count + 1, noReloadCount: noReloadCount + 1)
            }
            })  
    }    
    
    fileprivate func countHeight() -> Bool {
        var index = 0
        var didChangeHeight = false
        if let h = hintHeightUpdateBlock?() {
            if abs(hintHeight.constant - CGFloat(h)) > 1 { 
                //                print("changed height of cell \(index) from \(cellHeights[index]) to \(h)")
                hintHeight.constant = CGFloat(h)
                didChangeHeight = true
            }
            index += 1
        }
        return didChangeHeight
    }
    
    fileprivate func performHeightUpdates() {
        self.reloadWithCount(0, noReloadCount: 0)
    }
    
    var hintHeightWebViewHelper : CellWebViewHelper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hintView.setRoundedCorners(cornerRadius: 8, borderWidth: 1, borderColor: UIColor.black)
        self.hintHeightWebViewHelper = CellWebViewHelper(webView: hintWebView, heightWithoutWebView: 0)
        self.hintView.backgroundColor = UIColor.black
        self.hintWebView.isUserInteractionEnabled = true
        self.hintWebView.delegate = self
        self.hintTextView.isScrollEnabled = false
        self.hintTextView.backgroundColor = UIColor.clear
        self.hintTextView.textColor = UIColor.white
        self.hintTextView.font = UIFont(name: "ArialMT", size: 16)
        self.hintTextView.isEditable = false
        self.hintTextView.dataDetectorTypes = .all

        
        self.peerReviewButton.setTitle(peerReviewText, for: UIControlState())
        self.peerReviewButton.backgroundColor = UIColor.peerReviewYellowColor()
        self.peerReviewButton.titleLabel?.textAlignment = NSTextAlignment.center
        self.peerReviewButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.peerReviewButton.isHidden = true
        refreshAttempt(step.id, forceCreate: needNewAttempt)
        
        NotificationCenter.default.addObserver(self, selector: #selector(QuizViewController.becameActive), name:
            NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    deinit {
        print("deinit quiz controller for step \(step.id)")
        NotificationCenter.default.removeObserver(self)
    }

    func becameActive() {
        if didTransitionToSettings { 
            didTransitionToSettings = false
            self.notifyPressed(fromPreferences: true)
        }
    }
    
    @IBAction func peerReviewButtonPressed(_ sender: AnyObject) {
        if let stepurl = stepUrl {
            let url = URL(string: stepurl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)!
            
            WebControllerManager.sharedManager.presentWebControllerWithURL(url, inController: self, withKey: "external link", allowsSafari: true, backButtonStyle: BackButtonStyle.close)
        }
    }
    
    fileprivate func retrieveSubmissionsCount(page: Int, success: @escaping ((Int)->Void), error: @escaping ((String) -> Void)) {
        _ = ApiDataDownloader.submissions.retrieve(stepName: step.block.name, stepId: step.id, page: page, success: {
            [weak self]
            submissions, meta in
            guard let s = self else { return }
            
            let count = submissions.count
            if meta.hasNext {
                s.retrieveSubmissionsCount(page: page + 1, success: {
                    nextPagesCnt in
                    success(count + nextPagesCnt)
                    return
                }, error: {
                    errorMsg in
                    error(errorMsg)
                    return
                })
            } else {
                success(count)
                return
            }
        }, error: {
            errorMsg in
            error(errorMsg)
            return
        })
    }
    
    func refreshAttempt(_ stepId: Int, forceCreate: Bool = false) {
        self.doesPresentActivityIndicatorView = true
        performRequest({
            [weak self] in
            guard let s = self else { return }
            
            if forceCreate {
                print("force create new attempt")
                s.createNewAttempt(completion: {
                    s.doesPresentActivityIndicatorView = false
                }, error:  {
                    s.doesPresentActivityIndicatorView = false
                    s.doesPresentWarningView = true
                })
                return
            }
            
            _ = ApiDataDownloader.attempts.retrieve(stepName: s.step.block.name, stepId: stepId, success: {
                attempts, meta in
                if attempts.count == 0 || attempts[0].status != "active" {
                    //Create attempt
                    s.createNewAttempt(completion: {
                        s.doesPresentActivityIndicatorView = false
                        }, error:  {
                            s.doesPresentActivityIndicatorView = false
                            s.doesPresentWarningView = true
                    })
                } else {
                    //Get submission for attempt
                    let currentAttempt = attempts[0]
                    s.attempt = currentAttempt
                    _ = ApiDataDownloader.submissions.retrieve(stepName: s.step.block.name, attemptId: currentAttempt.id!, success: {
                        submissions, meta in
                        if submissions.count == 0 {
                            s.submission = nil
                            //There are no current submissions for attempt
                        } else {
                            //Displaying the last submission
                            s.submission = submissions[0]
                        }
                        s.doesPresentActivityIndicatorView = false
                        }, error: {
                            errorText in
                            s.doesPresentActivityIndicatorView = false
                            print("failed to get submissions")
                            //TODO: Test this
                    })
                }
                s.checkSubmissionRestrictions()
                }, error: {
                    errorText in
                    s.doesPresentActivityIndicatorView = false
                    s.doesPresentWarningView = true
                    //TODO: Test this
            })
        }, error: {
            [weak self] 
            error in
            guard let s = self else { return }
            if error == PerformRequestError.noAccessToRefreshToken {
                AuthInfo.shared.token = nil
                RoutingManager.auth.routeFrom(controller: s, success: {
                    [weak self] in
                    guard let s = self else { return }
                    s.refreshAttempt(s.step.id)
                }, cancel: {
                    [weak self] in
                    guard let s = self else { return }
                    s.refreshAttempt(s.step.id)
                })
            }
        })
    }
    
    fileprivate func checkSubmissionRestrictions() {
        if step.hasSubmissionRestrictions {
            retrieveSubmissionsCount(page: 1, success: {
                [weak self]
                count in
                self?.submissionsCount = count
            }, error: {
                errorMsg in
                print("failed to get submissions count")
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func createNewAttempt(completion: ((Void)->Void)? = nil, error: ((Void)->Void)? = nil) {
        print("creating attempt for step id -> \(self.step.id) name -> \(self.step.block.name)")
        performRequest({
            [weak self] in
            guard let s = self else { return }
            _ = ApiDataDownloader.attempts.create(stepName: s.step.block.name, stepId: s.step.id, success: {
                [weak self]
                attempt in
                guard let s = self else { return }
                s.attempt = attempt
                s.submission = nil
                completion?()
                }, error: {
                    errorText in   
                    print(errorText)
                    error?()
                    //TODO: Test this
            })
            }, error: {
                [weak self] 
                error in
                guard let s = self else { return }
                if error == PerformRequestError.noAccessToRefreshToken {
                    AuthInfo.shared.token = nil
                    RoutingManager.auth.routeFrom(controller: s, success: {
                        [weak self] in
                        guard let s = self else { return }
                        s.refreshAttempt(s.step.id)
                        }, cancel: {
                            [weak self] in
                            guard let s = self else { return }
                            s.refreshAttempt(s.step.id)
                    })
                }
        })

    }
    
    let streakTimePickerPresenter : Presentr = {
        let streakTimePickerPresenter = Presentr(presentationType: .popup)
        return streakTimePickerPresenter
    }()
    
    func selectStreakNotificationTime() {
        let vc = NotificationTimePickerViewController(nibName: "PickerViewController", bundle: nil) as NotificationTimePickerViewController 
        vc.startHour = (PreferencesContainer.notifications.streaksNotificationStartHourUTC + NSTimeZone.system.secondsFromGMT() / 60 / 60 ) % 24
        vc.selectedBlock = {
            [weak self] in 
            if self != nil {
//                s.notificationTimeLabel.text = s.getDisplayingStreakTimeInterval(startHour: PreferencesContainer.notifications.streaksNotificationStartHour)
            }
        }
        customPresentViewController(streakTimePickerPresenter, viewController: vc, animated: true, completion: nil)
    }
    
    private let maxAlertCount = 3
    
    private var didTransitionToSettings = false 
    
    fileprivate func showStreaksSettingsNotificationAlert() {
        let alert = UIAlertController(title: NSLocalizedString("StreakNotificationsAlertTitle", comment: ""), message: NSLocalizedString("StreakNotificationsAlertMessage", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: {
            [weak self]
            action in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
            self?.didTransitionToSettings = true
        }))
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("No", comment: ""), style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    fileprivate func notifyPressed(fromPreferences: Bool) {
        
        guard let settings = UIApplication.shared.currentUserNotificationSettings, settings.types != .none else {
            if !fromPreferences {
                showStreaksSettingsNotificationAlert()
            }
            return
        }
        
        self.selectStreakNotificationTime()
    }
    
    fileprivate var positionPercentageString : String? {
        if let cnt = step.lesson?.stepsArray.count {
            let res = String(format: "%.02f", cnt != 0 ? Double(step.position) / Double(cnt) : -1)
            print(res)
            return res
        }
        return nil
    }
    
    
    func checkCorrect() {
        
        if StepicApplicationsInfo.isAdaptive {
            AnalyticsReporter.reportEvent(AnalyticsEvents.Adaptive.correctAnswer)
        }
        
        if RoutingManager.rate.submittedCorrect() {
            Alerts.rate.present(alert: Alerts.rate.construct(lessonProgress: positionPercentageString), inController: self)
            return
        }
        
        guard QuizDataManager.submission.canShowAlert else {
            return
        }
        
        let alert = Alerts.streaks.construct(notify: {
            [weak self] in
            self?.notifyPressed(fromPreferences: false)
        })
        
        guard let user = AuthInfo.shared.user else { 
            return 
        }
        _ = ApiDataDownloader.userActivities.retrieve(user: user.id, success: {
            [weak self] 
            activity in
            guard activity.currentStreak > 0 else {
                return
            }
            if let s = self {
                QuizDataManager.submission.didShowStreakAlert()
                alert.currentStreak = activity.currentStreak
                Alerts.streaks.present(alert: alert, inController: s)
            }
            }, error: {
                error in
        })
    }
    
    //Measured in seconds
    fileprivate let checkTimeStandardInterval = 0.5
    
    fileprivate func checkSubmission(_ id: Int, time: Int, completion: ((Void)->Void)? = nil) {
        delay(checkTimeStandardInterval * Double(time), closure: {
            [weak self] in
            guard self != nil else { return }
            performRequest({
                [weak self] in
                guard let s = self else { return }
                _ = ApiDataDownloader.submissions.retrieve(stepName: s.step.block.name, submissionId: id, success: {
                    submission in
                    print("did get submission id \(id), with status \(String(describing: submission.status))")
                    if submission.status == "evaluation" {
                        s.checkSubmission(id, time: time + 1, completion: completion)
                    } else {
                        s.submission = submission
                        if submission.status == "correct" {
                            s.checkCorrect()
                            if s.step.hasSubmissionRestrictions && !s.step.canEdit {
                                s.isSubmitButtonHidden = true
                            } else {
                                s.isSubmitButtonHidden = false
                            }
                        }
                        completion?()
                    }
                    }, error: { 
                        errorText in
                        s.didGetErrorWhileSendingSubmission = true
                        s.submission = nil
                        completion?()
                        //TODO: test this
                })
            }, error: {
                [weak self] 
                error in
                guard let s = self else { return }
                if error == PerformRequestError.noAccessToRefreshToken {
                    AuthInfo.shared.token = nil
                    RoutingManager.auth.routeFrom(controller: s, success: {
                        [weak self] in
                        guard let s = self else { return }
                        s.refreshAttempt(s.step.id)
                        }, cancel: {
                            [weak self] in
                            guard let s = self else { return }
                            s.refreshAttempt(s.step.id)
                    })
                }
            })
        })        
    }
    
    fileprivate func submitReply(completion: @escaping ((Void)->Void), error errorHandler: @escaping ((String)->Void)) {        
        let r = getReply()
        let id = attempt!.id!
        performRequest({
            [weak self] in
            guard let s = self else { return }
            _ = ApiDataDownloader.submissions.create(stepName: s.step.block.name, attemptId: id, reply: r, success: {
                submission in
                s.submission = submission
                s.checkSubmission(submission.id!, time: 0, completion: completion)
                }, error: {
                    errorText in
                    errorHandler(errorText)
                    //TODO: test this
            })
        }, error: {
            [weak self] 
            error in
            guard let s = self else { return }
            if error == PerformRequestError.noAccessToRefreshToken {
                AuthInfo.shared.token = nil
                RoutingManager.auth.routeFrom(controller: s, success: {
                    [weak self] in
                    guard let s = self else { return }
                    s.refreshAttempt(s.step.id)
                    }, cancel: {
                        [weak self] in
                        guard let s = self else { return }
                        s.refreshAttempt(s.step.id)
                })
            }
        })
    }
    
    //Override this in the subclass
    func getReply() -> Reply {
        return ChoiceReply(choices: [])
    }
    
    //Override this in the subclass if needed
    func checkReplyReady() -> Bool {
        return true
    }
    
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        sendButton.isEnabled = false
        if buttonStateSubmit {
            submitAttempt()
        } else  {
            retrySubmission()
        }
    }
    
    var submissionAnalyticsParams : [String: Any]? {
        return nil
    }
    
    var submissionPressedBlock : ((Void)->Void)?
    
    public func submitAttempt() {
        submissionPressedBlock?()
        doesPresentActivityIndicatorView = true
        AnalyticsReporter.reportEvent(AnalyticsEvents.Step.Submission.submit, parameters: submissionAnalyticsParams)
        if checkReplyReady() {
            submitReply(completion: {
                [weak self] in
                DispatchQueue.main.async{
                    self?.sendButton.isEnabled = true
                    self?.doesPresentActivityIndicatorView = false
                }
                }, error: {
                    [weak self]
                    errorText in
                    DispatchQueue.main.async{
                        self?.sendButton.isEnabled = true
                        self?.doesPresentActivityIndicatorView = false
                        if let vc = self?.navigationController {
                            Messages.sharedManager.showConnectionErrorMessage(inController: vc)
                        }
                    }
            })
        } else {
            doesPresentActivityIndicatorView = false
            sendButton.isEnabled = true
        }
    }
    
    public func retrySubmission() {
        doesPresentActivityIndicatorView = true
        AnalyticsReporter.reportEvent(AnalyticsEvents.Step.Submission.newAttempt, parameters: nil)
        
        self.delegate?.submissionDidRetry()
        
        createNewAttempt(completion: {
            [weak self] in
            DispatchQueue.main.async{
                self?.sendButton.isEnabled = true
                self?.doesPresentActivityIndicatorView = false
            }
            self?.checkSubmissionRestrictions()
        }, error: {
            [weak self] in
            DispatchQueue.main.async{
                self?.sendButton.isEnabled = true
                self?.doesPresentActivityIndicatorView = false
            }
            if let vc = self?.navigationController {
                Messages.sharedManager.showConnectionErrorMessage(inController: vc)
            }
        })
    }
    
    var isSubmitButtonHidden: Bool = false {
        didSet {
            self.sendButton.isHidden = isSubmitButtonHidden
            self.sendButtonHeight.constant = isSubmitButtonHidden ? 0 : 40
        }
    }
}

extension QuizViewController : PlaceholderViewDataSource {
    func placeholderImage() -> UIImage? {
        return Images.noWifiImage.size100x100
    }
    
    func placeholderButtonTitle() -> String? {
        return NSLocalizedString("TryAgain", comment: "")
    }
    
    func placeholderDescription() -> String? {
        return nil
    }
    
    func placeholderStyle() -> PlaceholderStyle {
        return stepicPlaceholderStyle
    }
    
    func placeholderTitle() -> String? {
        return warningViewTitle
    }
}

extension QuizViewController : PlaceholderViewDelegate {
    func placeholderButtonDidPress() {
        self.doesPresentWarningView = false
        self.refreshAttempt(step.id)
    }
}

extension QuizViewController : UIWebViewDelegate {
    func webView(_ webView: UIWebView, shouldStartLoadWith request: URLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        if let url = request.url {
            if url.isFileURL {
                return true
            }
            WebControllerManager.sharedManager.presentWebControllerWithURL(url, inController: self, withKey: "HintWebController", allowsSafari: true, backButtonStyle: .close)
        }
        return false
    }
}


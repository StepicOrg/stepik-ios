//
//  QuizViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 25.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

class QuizViewController: UIViewController {
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var statusViewHeight: NSLayoutConstraint!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var hintHeight: NSLayoutConstraint!
    @IBOutlet weak var hintView: UIView!
    @IBOutlet weak var hintWebView: UIWebView!
    
    @IBOutlet weak var peerReviewHeight: NSLayoutConstraint!
    @IBOutlet weak var peerReviewButton: UIButton!
    
    var delegate : QuizControllerDelegate?
    
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
                UIThread.performUI{self.activityView.isHidden = false}
                self.delegate?.needsHeightUpdate(150, animated: true)
            } else {
                UIThread.performUI{self.activityView.isHidden = true}
                self.delegate?.needsHeightUpdate(self.heightWithoutQuiz + self.expectedQuizHeight, animated: true)
            }
        }
    }
    
    var doesPresentWarningView : Bool = false {
        didSet {
            if doesPresentWarningView {
                UIThread.performUI{self.warningView.isHidden = false}
                self.delegate?.needsHeightUpdate(200, animated: true)
            } else {
                UIThread.performUI{self.warningView.isHidden = true}
                self.delegate?.needsHeightUpdate(self.heightWithoutQuiz + self.expectedQuizHeight, animated: true)
            }
        }
    }
    
    
    var attempt : Attempt? {
        didSet {
            if attempt == nil {
                print("ATTEMPT SHOULD NEVER BE SET TO NIL")
                return
            }
            UIThread.performUI {
                print("did set attempt id \(self.attempt?.id)")
                
                //TODO: Implement in subclass, then it may need a height update
                self.updateQuizAfterAttemptUpdate()
                self.delegate?.needsHeightUpdate(self.heightWithoutQuiz + self.expectedQuizHeight, animated: true)
                self.view.layoutIfNeeded()
            }
        }
    }
    
    var heightWithoutQuiz : CGFloat {
        return 80 + statusViewHeight.constant + hintHeight.constant + peerReviewHeight.constant
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
                self.sendButton.setTitle(self.submitTitle, for: UIControlState())
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
    
    fileprivate var didGetErrorWhileSendingSubmission = false
    
    fileprivate var hintHeightUpdateBlock : ((Void) -> Int)?
    
    var submission : Submission? {
        didSet {
            UIThread.performUI {                
                if self.submission == nil {
                    print("did set submission to nil")
                    self.statusImageView.image = nil
                    self.buttonStateSubmit = true
                    self.view.backgroundColor = UIColor.white
                    
                    //TODO: Localize
                    self.sendButton.setTitle(self.submitTitle, for: UIControlState())
                    self.statusViewHeight.constant = 0
                    self.hintHeight.constant = 0
                    self.peerReviewHeight.constant = 0
                    self.peerReviewButton.isHidden = true
                    
                    if self.didGetErrorWhileSendingSubmission {
                        self.updateQuizAfterSubmissionUpdate(reload: false)   
                        self.didGetErrorWhileSendingSubmission = false
                    } else {
                        self.updateQuizAfterSubmissionUpdate()
                    }
                } else {
                    print("did set submission id \(self.submission?.id)")
                    self.buttonStateSubmit = false
                    
                    if let hint = self.submission?.hint {
                        if hint != "" {
                            self.hintHeightUpdateBlock = self.hintHeightWebViewHelper.setTextWithTeX(hint, textColorHex: "#FFFFFF")
                            self.performHeightUpdates()
                        } else {
                            self.hintHeight.constant = 0
                        }
                    } else {
                        self.hintHeight.constant = 0
                    }
                    
                    switch self.submission!.status! {
                    case "correct":
                        self.buttonStateSubmit = false
                        self.statusViewHeight.constant = 48
                        self.doesPresentActivityIndicatorView = false
                        self.view.backgroundColor = UIColor.correctQuizBackgroundColor()
                        self.statusImageView.image = Images.correctQuizImage
                        self.statusLabel.text = self.correctTitle
                        
                        if self.needPeerReview {
                            self.peerReviewHeight.constant = 40
                            self.peerReviewButton.isHidden = false
                        } else {
                            //TODO: Refactor this!!!!! 
                            NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: StepDoneNotificationKey), object: nil, userInfo: ["id" : self.step.id])
                            UIThread.performUI{
                                self.step.progress?.isPassed = true
                                CoreDataHelper.instance.save()
                            }
                        }
                        
                        break
                        
                    case "wrong":
                        if self.needsToRefreshAttemptWhenWrong {
                            self.buttonStateSubmit = false
                        } else {
                            self.buttonStateSubmit = true
                        }
                        self.statusViewHeight.constant = 48
                        self.peerReviewHeight.constant = 0
                        self.peerReviewButton.isHidden = true
                        self.doesPresentActivityIndicatorView = false
                        self.view.backgroundColor = UIColor.wrongQuizBackgroundColor()
                        self.statusImageView.image = Images.wrongQuizImage
                        self.statusLabel.text = self.wrongTitle
                        break
                        
                    case "evaluation":
                        self.statusViewHeight.constant = 0
                        self.peerReviewHeight.constant = 0
                        self.peerReviewButton.isHidden = true
                        self.doesPresentActivityIndicatorView = true
                        self.statusLabel.text = ""
                        break
                        
                    default: 
                        break
                    }
                    
                    self.updateQuizAfterSubmissionUpdate()                    
                }
                self.delegate?.needsHeightUpdate(self.heightWithoutQuiz + self.expectedQuizHeight, animated: true)
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func handleErrorWhileGettingSubmission() {
    }
    
    var step : Step!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
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
                UIThread.performUI{
                    if let expectedHeight = self?.expectedQuizHeight, 
                        let noQuizHeight = self?.heightWithoutQuiz {
                        self?.delegate?.needsHeightUpdate(expectedHeight + noQuizHeight, animated: true) 
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
        
        self.peerReviewButton.setTitle(peerReviewText, for: UIControlState())
        self.peerReviewButton.backgroundColor = UIColor.peerReviewYellowColor()
        self.peerReviewButton.titleLabel?.textAlignment = NSTextAlignment.center
        self.peerReviewButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.peerReviewButton.isHidden = true
        refreshAttempt(step.id)
        
        NotificationCenter.default.addObserver(self, selector: #selector(QuizViewController.becameActive), name:
            NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    deinit {
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
            let url = URL(string: stepurl.addingPercentEscapes(using: String.Encoding.utf8)!)!
            
            WebControllerManager.sharedManager.presentWebControllerWithURL(url, inController: self, withKey: "external link", allowsSafari: true, backButtonStyle: BackButtonStyle.close)
        }
    }
    
    func refreshAttempt(_ stepId: Int) {
        self.doesPresentActivityIndicatorView = true
        performRequest({
            ApiDataDownloader.sharedDownloader.getAttemptsFor(stepName: self.step.block.name, stepId: stepId, success: { 
                attempts, meta in
                if attempts.count == 0 || attempts[0].status != "active" {
                    //Create attempt
                    self.createNewAttempt(completion: {
                        self.doesPresentActivityIndicatorView = false
                        }, error:  {
                            self.doesPresentActivityIndicatorView = false
                            self.doesPresentWarningView = true
                    })
                } else {
                    //Get submission for attempt
                    let currentAttempt = attempts[0]
                    self.attempt = currentAttempt
                    ApiDataDownloader.sharedDownloader.getSubmissionsWith(stepName: self.step.block.name, attemptId: currentAttempt.id!, success: {
                        submissions, meta in
                        if submissions.count == 0 {
                            self.submission = nil
                            //There are no current submissions for attempt
                        } else {
                            //Displaying the last submission
                            self.submission = submissions[0]
                        }
                        self.doesPresentActivityIndicatorView = false
                        }, error: {
                            errorText in
                            self.doesPresentActivityIndicatorView = false
                            print("failed to get submissions")
                            //TODO: Test this
                    })
                }
                }, error: {
                    errorText in
                    self.doesPresentActivityIndicatorView = false
                    self.doesPresentWarningView = true
                    //TODO: Test this
            })
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    fileprivate func createNewAttempt(completion: ((Void)->Void)? = nil, error: ((Void)->Void)? = nil) {
        print("creating attempt for step id -> \(self.step.id) name -> \(self.step.block.name)")
        performRequest({
            ApiDataDownloader.sharedDownloader.createNewAttemptWith(stepName: self.step.block.name, stepId: self.step.id, success: {
                attempt in
                self.attempt = attempt
                self.submission = nil
                completion?()
                }, error: {
                    errorText in   
                    print(errorText)
                    error?()
                    //TODO: Test this
            })
        })
    }
    
    let streakTimePickerPresenter : Presentr = {
        let streakTimePickerPresenter = Presentr(presentationType: .popup)
        return streakTimePickerPresenter
    }()
    
    func selectStreakNotificationTime() {
        let vc = NotificationTimePickerViewController(nibName: "NotificationTimePickerViewController", bundle: nil) as NotificationTimePickerViewController 
        vc.startHour = (PreferencesContainer.notifications.streaksNotificationStartHourUTC + NSTimeZone.system.secondsFromGMT() / 60 / 60 ) % 24
        vc.selectedBlock = {
            [weak self] in 
            if let s = self {
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
        guard UIApplication.shared.isRegisteredForRemoteNotifications else {
            if !fromPreferences {
                showStreaksSettingsNotificationAlert()
            }
            return
        }
        
        self.selectStreakNotificationTime()
    }
    
    func checkCorrect() {
        
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
            performRequest({
                ApiDataDownloader.sharedDownloader.getSubmissionFor(stepName: self.step.block.name, submissionId: id, success: {
                    submission in
                    print("did get submission id \(id), with status \(submission.status)")
                    if submission.status == "evaluation" {
                        self.checkSubmission(id, time: time + 1, completion: completion)
                    } else {
                        self.submission = submission
                        if submission.status == "correct" {
                            self.checkCorrect() 
                        }
                        completion?()
                    }
                    }, error: { 
                        errorText in
                        self.didGetErrorWhileSendingSubmission = true
                        self.submission = nil
                        completion?()
                        //TODO: test this
                })
            })
        })        
    }
    
    fileprivate func submitReply(completion: @escaping ((Void)->Void), error errorHandler: @escaping ((String)->Void)) {        
        let r = getReply()
        let id = attempt!.id!
        performRequest({
            ApiDataDownloader.sharedDownloader.createSubmissionFor(stepName: self.step.block.name, attemptId: id, reply: r, success: {
                submission in
                self.submission = submission
                self.checkSubmission(submission.id!, time: 0, completion: completion)
                }, error: {
                    errorText in
                    errorHandler(errorText)
                    //TODO: test this
            })
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
        doesPresentActivityIndicatorView = true
        if buttonStateSubmit {
            AnalyticsReporter.reportEvent(AnalyticsEvents.Step.Submission.submit, parameters: nil)
            if checkReplyReady() {
                submitReply(completion: {
                    [weak self] in
                    UIThread.performUI{
                        self?.sendButton.isEnabled = true
                        self?.doesPresentActivityIndicatorView = false
                    }
                    }, error: {
                        [weak self]
                        errorText in
                        UIThread.performUI{
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
        } else  {
            AnalyticsReporter.reportEvent(AnalyticsEvents.Step.Submission.newAttempt, parameters: nil)
            createNewAttempt(completion: {
                [weak self] in
                UIThread.performUI{
                    self?.sendButton.isEnabled = true
                    self?.doesPresentActivityIndicatorView = false
                }
                }, error: {
                    [weak self] in
                    UIThread.performUI{
                        self?.sendButton.isEnabled = true
                        self?.doesPresentActivityIndicatorView = false
                    }
                    if let vc = self?.navigationController {
                        Messages.sharedManager.showConnectionErrorMessage(inController: vc)
                    }
                })
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


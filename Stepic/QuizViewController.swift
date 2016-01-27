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
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var hintView: UIView!
    
    var delegate : QuizControllerDelegate?
    
    let submitTitle = "Submit"
    let tryAgainTitle = "Try again"
    let correctTitle = "Correct"
    let wrongTitle = "Wrong"
    
    let warningViewTitle = "Could not connect to the internet"
    
    //Activity view here
    lazy var activityView : UIView = self.initActivityView()
    
    lazy var warningView : UIView = self.initWarningView()
    
    func initWarningView() -> UIView {
        let v = WarningView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), delegate: self, text: warningViewTitle, image: Images.warningImage, width: UIScreen.mainScreen().bounds.width - 16)
        self.view.insertSubview(v, aboveSubview: self.view)
        v.alignToView(self.view)
//        v.hidden = false
        return v
    }
    
    func initActivityView() -> UIView {
        let v = UIView()
        let ai = UIActivityIndicatorView()
        ai.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        ai.constrainWidth("50", height: "50")
        ai.color = UIColor.stepicGreenColor()
        v.backgroundColor = UIColor.whiteColor()
        v.addSubview(ai)
        ai.alignCenterWithView(v)
        ai.startAnimating()
        self.view.insertSubview(v, aboveSubview: self.view)
        v.alignToView(self.view)
        v.hidden = false
        return v
    }
    
    var doesPresentActivityIndicatorView : Bool = false {
        didSet {
            if doesPresentActivityIndicatorView {
                UIThread.performUI{self.activityView.hidden = false}
            } else {
                UIThread.performUI{self.activityView.hidden = true}
            }
        }
    }
    
    var doesPresentWarningView : Bool = false {
        didSet {
            if doesPresentWarningView {
                UIThread.performUI{self.warningView.hidden = false}
            } else {
                UIThread.performUI{self.warningView.hidden = true}
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
                self.delegate?.needsHeightUpdate(self.heightWithoutQuiz + self.expectedQuizHeight)
                self.view.layoutIfNeeded()
            }
        }
    }
    
    var heightWithoutQuiz : CGFloat {
        return 80 + statusViewHeight.constant + hintHeight.constant
    }
    
    var buttonStateSubmit : Bool = true {
        didSet {
            if buttonStateSubmit {
                self.sendButton.setStepicGreenStyle()
                self.sendButton.setTitle(self.submitTitle, forState: .Normal)
            } else {
                self.sendButton.setStepicWhiteStyle()
                self.sendButton.setTitle(self.tryAgainTitle, forState: .Normal)
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
    func updateQuizAfterSubmissionUpdate(reload reload: Bool = true) {
    }
    
    //Override this in subclass
    var expectedQuizHeight : CGFloat {
        return 0
    }
    
    private var didGetErrorWhileSendingSubmission = false
    
    var submission : Submission? {
        didSet {
            UIThread.performUI {                
                if self.submission == nil {
                    print("did set submission to nil")
                    self.statusImageView.image = nil
                    self.buttonStateSubmit = true
                    self.view.backgroundColor = UIColor.whiteColor()
                    
                    //TODO: Localize
                    self.sendButton.setTitle(self.submitTitle, forState: .Normal)
                    self.statusViewHeight.constant = 0
                    self.hintHeight.constant = 0
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
                            let height = UILabel.heightForLabelWithText(hint, lines: 0, standardFontOfSize: 14, width: UIScreen.mainScreen().bounds.width - 32)
                            self.hintHeight.constant = height + 16
                            self.hintView.setRoundedCorners(cornerRadius: 8, borderWidth: 1, borderColor: UIColor.blackColor())
                            self.hintLabel.textColor = UIColor.whiteColor()
                            self.hintView.backgroundColor = UIColor.blackColor()
                            self.hintLabel.text = hint
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
                        break
                    case "wrong":
                        if self.needsToRefreshAttemptWhenWrong {
                            self.buttonStateSubmit = false
                        } else {
                            self.buttonStateSubmit = true
                        }
                        self.statusViewHeight.constant = 48
                        self.doesPresentActivityIndicatorView = false
                        self.view.backgroundColor = UIColor.wrongQuizBackgroundColor()
                        self.statusImageView.image = Images.wrongQuizImage
                        self.statusLabel.text = self.wrongTitle
                        break
                    case "evaluation":
                        self.statusViewHeight.constant = 0
                        self.doesPresentActivityIndicatorView = true
                        self.statusLabel.text = ""
                        break
                    default: 
                        break
                    }
                    
                    self.updateQuizAfterSubmissionUpdate()                    
                }
                self.delegate?.needsHeightUpdate(self.heightWithoutQuiz + self.expectedQuizHeight)
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func handleErrorWhileGettingSubmission() {
    }
    
    var step : Step!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshAttempt(step.id)
    }
    
    func refreshAttempt(stepId: Int) {
        self.doesPresentActivityIndicatorView = true
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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func createNewAttempt(completion completion: (Void->Void)? = nil, error: (Void->Void)? = nil) {
        print("creating attempt for step id -> \(self.step.id) name -> \(self.step.block.name)")
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
    }
    
    
    //Measured in seconds
    private let checkTimeStandardInterval = 0.5
    
    private func checkSubmission(id: Int, time: Int, completion: (Void->Void)? = nil) {
        delay(checkTimeStandardInterval * Double(time), closure: {
            ApiDataDownloader.sharedDownloader.getSubmissionFor(stepName: self.step.block.name, submissionId: id, success: {
                submission in
                print("did get submission id \(id), with status \(submission.status)")
                if submission.status == "evaluation" {
                    self.checkSubmission(id, time: time + 1, completion: completion)
                } else {
                    self.submission = submission
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
    }
    
    private func submitReply(completion completion: (Void->Void)? = nil) {        
        let r = getReply()
        
        ApiDataDownloader.sharedDownloader.createSubmissionFor(stepName: self.step.block.name, attemptId: attempt!.id!, reply: r, success: {
            submission in
            self.submission = submission
            self.checkSubmission(submission.id!, time: 0, completion: completion)
            }, error: {
                errorText in
                completion?()
                //TODO: test this
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
    
    @IBAction func sendButtonPressed(sender: UIButton) {
        sendButton.enabled = false
        doesPresentActivityIndicatorView = true
        if buttonStateSubmit {
            if checkReplyReady() {
                submitReply(completion: {
                    UIThread.performUI{
                        self.sendButton.enabled = true
                        self.doesPresentActivityIndicatorView = false
                    }
                })
            } else {
                doesPresentActivityIndicatorView = false
                sendButton.enabled = true
            }
        } else  {
            createNewAttempt(completion: {
                UIThread.performUI{
                    self.sendButton.enabled = true
                    self.doesPresentActivityIndicatorView = false
                }
            })
        }
    }
}

extension QuizViewController : WarningViewDelegate {
    func didPressButton() {
        self.doesPresentWarningView = false
        self.refreshAttempt(step.id)
    }
}

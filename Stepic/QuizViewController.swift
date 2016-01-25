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
    
    var delegate : QuizControllerDelegate?
    
    let submitTitle = "Submit"
    let tryAgainTitle = "Try again"
    let correctTitle = "Correct"
    let wrongTitle = "Wrong"
    
    //Activity view here
    lazy var activityView : UIView = self.initActivityView()
    
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
                print("present activity indicator view")
                UIThread.performUI{self.activityView.hidden = false}
            } else {
                print("dismiss activity indicator view")
                UIThread.performUI{self.activityView.hidden = true}
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
        return 72 + statusViewHeight.constant
    }
    
    var buttonStateSubmit : Bool = true {
        didSet {
            if buttonStateSubmit {
                self.sendButton.setStepicGreenStyle()
            } else {
                self.sendButton.setStepicWhiteStyle()
            }
        }
    }
    
    //Override this in subclass
    func updateQuizAfterAttemptUpdate() {
    }
    
    //Override this in subclass
    func updateQuizAfterSubmissionUpdate() {
    }
    
    //Override this in subclass
    var expectedQuizHeight : CGFloat {
        return 0
    }
    
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
                    self.updateQuizAfterSubmissionUpdate()                    
                } else {
                    
                    print("did set submission id \(self.submission?.id)")
                    self.buttonStateSubmit = false
                    switch self.submission!.status! {
                    case "correct":
                        self.doesPresentActivityIndicatorView = false
                        self.view.backgroundColor = UIColor.correctQuizBackgroundColor()
                        self.statusImageView.image = Images.correctQuizImage
                        self.statusLabel.text = self.correctTitle
                        break
                    case "wrong":
                        self.doesPresentActivityIndicatorView = false
                        self.view.backgroundColor = UIColor.wrongQuizBackgroundColor()
                        self.statusImageView.image = Images.wrongQuizImage
                        self.statusLabel.text = self.wrongTitle
                        break
                    case "evaluation":
                        self.doesPresentActivityIndicatorView = true
                        self.statusLabel.text = ""
                        break
                    default: 
                        break
                    }
                    
                    self.sendButton.setTitle(self.tryAgainTitle, forState: .Normal)
                    
                    self.statusViewHeight.constant = 48
                    self.updateQuizAfterSubmissionUpdate()                    
                }
                self.delegate?.needsHeightUpdate(self.heightWithoutQuiz + self.expectedQuizHeight)
                self.view.layoutIfNeeded()
            }
        }
    }
    
    var step : Step!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refreshAttempt(step.id)
    }
    
    func refreshAttempt(stepId: Int) {
        self.doesPresentActivityIndicatorView = true
        ApiDataDownloader.sharedDownloader.getAttemptsFor(stepName: "choice", stepId: stepId, success: { 
            attempts, meta in
            if attempts.count == 0 || attempts[0].status != "active" {
                //Create attempt
                self.createNewAttempt(completion: {
                    UIThread.performUI {
                        self.doesPresentActivityIndicatorView = false
                    }
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
                    UIThread.performUI {
                        self.doesPresentActivityIndicatorView = false
                    }
                    }, error: {
                        errorText in
                        //TODO: Handle get submissions error
                })
            }
            }, error: {
                errorText in
                //TODO: Handle get attempts error
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func createNewAttempt(completion completion: (Void->Void)? = nil) {
        ApiDataDownloader.sharedDownloader.createNewAttemptWith(stepName: self.step.block.name, stepId: self.step.id, success: {
            attempt in
            self.attempt = attempt
            self.submission = nil
            completion?()
            }, error: {
                errorText in   
                //TODO: Handle attempt creation error
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
                    //TODO: handle submission check error
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
                //TODO: Handle choices submission error
        })
    }
    
    //Override this in the subclass
    func getReply() -> Reply {
        return ChoiceReply(choices: [])
    }
    
    @IBAction func sendButtonPressed(sender: UIButton) {
        sendButton.enabled = false
        doesPresentActivityIndicatorView = true
        if buttonStateSubmit {
            submitReply(completion: {
                UIThread.performUI{
                    self.sendButton.enabled = true
                    self.doesPresentActivityIndicatorView = false
                }
            })
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

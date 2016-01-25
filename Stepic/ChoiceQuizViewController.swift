//
//  ChoiceQuizViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 20.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import BEMCheckBox

class ChoiceQuizViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var statusViewHeight: NSLayoutConstraint!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    
    var delegate : QuizControllerDelegate?
    var choices : [Bool]! = []
    
    let submitTitle = "Submit"
    let againTitle = "Try again"
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
                self.choices = [Bool](count: (self.attempt?.dataset as! ChoiceDataset).options.count, repeatedValue: false)
                print("did set attempt id \(self.attempt?.id)")
                self.tableView.reloadData()
                if self.submission != nil {
                    self.delegate?.needsHeightUpdate(72 + self.tableView.contentSize.height)
                } else {
                    self.delegate?.needsHeightUpdate(120 + self.tableView.contentSize.height)
                }
                self.view.layoutIfNeeded()
            }
        }
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
    
    var submission : Submission? {
        didSet {
            UIThread.performUI {
//                print("did set submission id \(self.submission?.id), reply count -> \((self.submission?.reply as! ChoiceReply).choices.count)")
                self.tableView.reloadData()
                
                if self.submission == nil {
                    self.tableView.userInteractionEnabled = true
                    print("did set submission to nil")
                    self.statusImageView.image = nil
                    self.choices = [Bool](count: (self.attempt?.dataset as! ChoiceDataset).options.count, repeatedValue: false)
                    self.tableView.reloadData()
                    self.buttonStateSubmit = true
                    self.view.backgroundColor = UIColor.whiteColor()
                    
                    //TODO: Localize
                    self.sendButton.setTitle("Submit", forState: .Normal)
                    self.statusViewHeight.constant = 0
                    self.delegate?.needsHeightUpdate(72 + self.tableView.contentSize.height)
                    
                } else {
                    
                    print("did set submission id \(self.submission?.id)")
                    self.tableView.userInteractionEnabled = false
                    self.buttonStateSubmit = false
                    switch self.submission!.status! {
                    case "correct":
                        self.doesPresentActivityIndicatorView = false
                        self.view.backgroundColor = UIColor.correctQuizBackgroundColor()
                        self.statusImageView.image = Images.correctQuizImage
                        break
                    case "wrong":
                        self.doesPresentActivityIndicatorView = false
                        self.view.backgroundColor = UIColor.wrongQuizBackgroundColor()
                        self.statusImageView.image = Images.wrongQuizImage
                        break
                    case "evaluation":
                        self.doesPresentActivityIndicatorView = true
                        //TODO: Show some activity indicators here
                        break
                    default: 
                        break
                    }
                    
                    //TODO: Localize
                    self.sendButton.setTitle("Try Again", forState: .Normal)
                    
                    self.statusLabel.text = self.submission?.status
                    self.statusViewHeight.constant = 48
                    self.delegate?.needsHeightUpdate(120 + self.tableView.contentSize.height)
                    
                }
                
                self.view.layoutIfNeeded()
            }
        }
    }
    
    var step : Step!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        refreshAttempt(step.id)
        tableView.tableFooterView = UIView()
        tableView.scrollEnabled = false
        // Do any additional setup after loading the view.
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
            //Display attempt using dataset
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
        
//        ApiDataDownloader.sharedDownloader.
    }
    
    private func submitChoices(completion completion: (Void->Void)? = nil) {
        print("sending choices \(self.choices)")
        let r = ChoiceReply(choices: self.choices)
        
        ApiDataDownloader.sharedDownloader.createSubmissionFor(stepName: self.step.block.name, attemptId: attempt!.id!, reply: r, success: {
            submission in
            self.submission = submission
            self.checkSubmission(submission.id!, time: 0, completion: completion)
            }, error: {
                errorText in
                //TODO: Handle choices submission error
        })
    }
    
    @IBAction func sendButtonPressed(sender: UIButton) {
        sendButton.enabled = false
        doesPresentActivityIndicatorView = true
        if buttonStateSubmit {
            submitChoices(completion: {
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ChoiceQuizViewController : UITableViewDelegate {

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let a = attempt {
            if let dataset = a.dataset as? ChoiceDataset {
                return max(27, UILabel.heightForLabelWithText(dataset.options[indexPath.row], lines: 0, standardFontOfSize: 14, width: UIScreen.mainScreen().bounds.width - 52)) + 17
//                dataset.options[indexPath.row]
            }
        }
        return 0
    }
    
    func setAllCellsOff() {
        let indexPaths = (0..<self.tableView.numberOfRowsInSection(0)).map({return NSIndexPath(forRow: $0, inSection: 0)})
        for indexPath in indexPaths {
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! ChoiceQuizTableViewCell
            cell.checkBox.on = false
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! ChoiceQuizTableViewCell
        if let dataset = attempt?.dataset as? ChoiceDataset {
            if dataset.isMultipleChoice {
                choices[indexPath.row] = !cell.checkBox.on
                cell.checkBox.setOn(!cell.checkBox.on, animated: true)
            } else {
                setAllCellsOff()
                choices = [Bool](count: (self.attempt?.dataset as! ChoiceDataset).options.count, repeatedValue: false)
                choices[indexPath.row] = !cell.checkBox.on
                cell.checkBox.setOn(!cell.checkBox.on, animated: true)
            }
        }
    }
}

extension ChoiceQuizViewController : BEMCheckBoxDelegate {
    func didTapCheckBox(checkBox: BEMCheckBox) {
        choices[checkBox.tag] = checkBox.on
    }
}

extension ChoiceQuizViewController : UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let a = attempt {
            if let _ = a.dataset as? ChoiceDataset {
                return 1
            }
        }
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let a = attempt {
            if let dataset = a.dataset as? ChoiceDataset {
                return dataset.options.count
            }
        } 
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ChoiceQuizTableViewCell", forIndexPath: indexPath) as! ChoiceQuizTableViewCell
        
        if let a = attempt {
            if let dataset = a.dataset as? ChoiceDataset {
                cell.choiceLabel.text = dataset.options[indexPath.row]
                if dataset.isMultipleChoice {
                    cell.checkBox.boxType = .Square
                } else {
                    cell.checkBox.boxType = .Circle
                }
                cell.checkBox.tag = indexPath.row
                cell.checkBox.delegate = self
                cell.checkBox.userInteractionEnabled = false
                if let s = submission {
                    if let reply = s.reply as? ChoiceReply {
                        cell.checkBox.on = reply.choices[indexPath.row]
                    }
                } else {
                    cell.checkBox.on = false
                }
            }
        }
            
        return cell
    }
}



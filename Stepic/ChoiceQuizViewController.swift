//
//  ChoiceQuizViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 20.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

class ChoiceQuizViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var statusViewHeight: NSLayoutConstraint!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var statusImageView: UIImageView!
    
    var delegate : QuizControllerDelegate?
    
    var attempt : Attempt? {
        didSet {
            UIThread.performUI {
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
    
    var submission : Submission? {
        didSet {
            UIThread.performUI {
                print("did set submission id \(self.submission?.id), reply count -> \((self.submission?.reply as! ChoiceReply).choices.count)")
                self.tableView.reloadData()
                if self.submission == nil {
                    self.statusViewHeight.constant = 0
                    self.sendButton.enabled = true
                    self.delegate?.needsHeightUpdate(72 + self.tableView.contentSize.height)
                } else {
                    self.statusLabel.text = self.submission?.status
                    self.statusViewHeight.constant = 48
                    self.sendButton.enabled = false
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
        ApiDataDownloader.sharedDownloader.getAttemptsFor(stepName: "choice", stepId: stepId, success: { 
            attempts, meta in
            if attempts.count == 0 || attempts[0].status != "active" {
                //Create attempt
                ApiDataDownloader.sharedDownloader.createNewAttemptWith(stepName: self.step.block.name, stepId: self.step.id, success: {
                    attempt in
                    //Display attempt using dataset
                    }, error: {
                        errorText in   
                        //TODO: Handle attempt creation error
                })
            } else {
                //Get submission for attempt
                let currentAttempt = attempts[0]
                self.attempt = currentAttempt
                ApiDataDownloader.sharedDownloader.getSubmissionsWith(stepName: self.step.block.name, attemptId: currentAttempt.id!, success: {
                    submissions, meta in
                    if submissions.count == 0 {
                        //There are no current submissions for attempt
                    } else {
                        //Displaying the last submission
                        self.submission = submissions[0]
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
    
    
    
    @IBAction func sendButtonPressed(sender: UIButton) {
        
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
                
                if let s = submission {
                    if let reply = s.reply as? ChoiceReply {
                        cell.checkBox.on = reply.choices[indexPath.row]
                    }
                }
            }
        }
            
        return cell
    }
}



//
//  ChoiceQuizViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 20.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import BEMCheckBox
import FLKAutoLayout

class ChoiceQuizViewController: QuizViewController {

    var tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        tableView.scrollEnabled = false
        self.containerView.addSubview(tableView)
        tableView.alignToView(self.containerView)
        tableView.backgroundColor = UIColor.clearColor()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.registerNib(UINib(nibName: "ChoiceQuizTableViewCell", bundle: nil), forCellReuseIdentifier: "ChoiceQuizTableViewCell")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    var choices : [Bool] = []
    
    override func updateQuizAfterAttemptUpdate() {
        self.choices = [Bool](count: (self.attempt?.dataset as! ChoiceDataset).options.count, repeatedValue: false)
        self.tableView.reloadData()
        self.view.layoutIfNeeded()
    }
    
    override func updateQuizAfterSubmissionUpdate(reload reload: Bool = true) {
        if self.submission == nil {
            if reload {
                self.choices = [Bool](count: (self.attempt?.dataset as! ChoiceDataset).options.count, repeatedValue: false) 
            }
            self.tableView.userInteractionEnabled = true
        } else {
            self.tableView.userInteractionEnabled = false
        }
        self.tableView.reloadData()
    }
    
    override var expectedQuizHeight : CGFloat {
        return self.tableView.contentSize.height
    }
    
    override func getReply() -> Reply {
        return ChoiceReply(choices: self.choices)
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



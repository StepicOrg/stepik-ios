//
//  SortingQuizViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 27.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import FLKAutoLayout

class SortingQuizViewController: QuizViewController {

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
        tableView.registerNib(UINib(nibName: "SortingQuizTableViewCell", bundle: nil), forCellReuseIdentifier: "SortingQuizTableViewCell")
        tableView.editing = true
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    
    private var orderedOptions : [String] = []
    private var positionForOptionInAttempt : [String : Int] = [:]

    
    override func updateQuizAfterAttemptUpdate() {
//        self.ordering = (0..<(self.attempt?.dataset as! SortingDataset).options.count).map({return $0})
        
        resetOptionsToAttempt()
        
        self.tableView.reloadData()
        self.view.layoutIfNeeded()
    }
    
    private func resetOptionsToAttempt() {
        orderedOptions = []
        positionForOptionInAttempt = [:]
        if let dataset = attempt?.dataset as? SortingDataset {
            self.orderedOptions = dataset.options
            for (index, option) in dataset.options.enumerate() {
                positionForOptionInAttempt[option] = index
            }
        }
    }
    
    override func updateQuizAfterSubmissionUpdate(reload reload: Bool = true) {
        if self.submission == nil {
            if reload {
                resetOptionsToAttempt()
            }
            self.tableView.userInteractionEnabled = true
        } else {
            if let dataset = attempt?.dataset as? SortingDataset {
                var o = [String](count: dataset.options.count, repeatedValue: "")
                if let r = submission?.reply as? SortingReply {
                    print("attempt dataset -> \(dataset.options), \nsubmission ordering -> \(r.ordering)")
                    for (index, order) in r.ordering.enumerate() {
                        o[index] = dataset.options[order]
                    }
                }
                orderedOptions = o
            }
            self.tableView.userInteractionEnabled = false
        }
        self.tableView.reloadData()
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    override var expectedQuizHeight : CGFloat {
        return self.tableView.contentSize.height
    }
    
    override func getReply() -> Reply {
        let r = SortingReply(ordering: orderedOptions.flatMap({return positionForOptionInAttempt[$0]}))
        print(r.ordering)
        return r
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

extension SortingQuizViewController : UITableViewDelegate {
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return max(27, UILabel.heightForLabelWithText(orderedOptions[indexPath.row], lines: 0, standardFontOfSize: 14, width: UIScreen.mainScreen().bounds.width - 32)) + 17
    }
    
    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.None
    }
    
    func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
}

extension SortingQuizViewController : UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if attempt != nil {
            return 1
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderedOptions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SortingQuizTableViewCell", forIndexPath: indexPath) as! SortingQuizTableViewCell
        
        cell.optionLabel?.text = orderedOptions[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let movingOption = orderedOptions[sourceIndexPath.row]
        orderedOptions.removeAtIndex(sourceIndexPath.row)
        orderedOptions.insert(movingOption, atIndex: destinationIndexPath.row)
    }
}

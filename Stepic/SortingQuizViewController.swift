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
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.registerNib(UINib(nibName: "SortingQuizTableViewCell", bundle: nil), forCellReuseIdentifier: "SortingQuizTableViewCell")
        tableView.editing = true
    }
    
    private var orderedOptions : [String] = []
    private var positionForOptionInAttempt : [String : Int] = [:]
//    var ordering : [Int] = [] {
//        didSet {
//            //TODO: Test if this works after += statement or index changing
//            print("did set called")
//            if let dataset = attempt?.dataset as? SortingDataset {
//                for (index, option) in dataset.options.enumerate() {
//                    optionForOrder[index] = option
//                }
//            }
//        }
//    }
    
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
            tableView.editing = true
        } else {
            self.tableView.userInteractionEnabled = false
            tableView.editing = false
        }
        self.tableView.reloadData()
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
//        if sourceIndexPath.row < destinationIndexPath.row {
            orderedOptions.removeAtIndex(sourceIndexPath.row)
            orderedOptions.insert(movingOption, atIndex: destinationIndexPath.row)
//        } else {
//            orderedOptions.insert(movingOption, atIndex: destinationIndexPath.row)
//            orderedOptions.removeAtIndex(sourceIndexPath.row)
//        }
    }
}

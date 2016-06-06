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
    
    var webViewHelper : ControllerQuizWebViewHelper!
    
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
        
        webViewHelper = ControllerQuizWebViewHelper(tableView: tableView, view: view
            , countClosure: 
            {
                [weak self] in
                return self?.optionsCount ?? 0
            }, expectedQuizHeightClosure: {
                [weak self] in
                return self?.expectedQuizHeight ?? 0
            }, noQuizHeightClosure: {
                [weak self] in
                return self?.heightWithoutQuiz ?? 0
            }, delegate: delegate
        )

        
//        self.view.setNeedsLayout()
//        self.view.layoutIfNeeded()
    }
    
    
    private var orderedOptions : [String] = []
    private var positionForOptionInAttempt : [String : Int] = [:]

    var optionsCount: Int {
        return (self.attempt?.dataset as? SortingDataset)?.options.count ?? 0
    }
    
    override func updateQuizAfterAttemptUpdate() {
//        self.ordering = (0..<(self.attempt?.dataset as! SortingDataset).options.count).map({return $0})
        
        resetOptionsToAttempt()

        webViewHelper.initChoicesHeights()
        webViewHelper.updateChoicesHeights()
        
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
//        webViewHelper.initChoicesHeights()
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
        
        webViewHelper.initChoicesHeights()
        for row in 0 ..< self.tableView(self.tableView, numberOfRowsInSection: 0) {
            if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: 0)) as? SortingQuizTableViewCell {
                cell.optionWebView.reload()
            }
        }
        webViewHelper.updateChoicesHeights()
        
//        webViewHelper.updateChoicesHeights()
//        self.view.setNeedsLayout()
//        self.view.layoutIfNeeded()
    }
    
    override var expectedQuizHeight : CGFloat {
        return self.tableView.contentSize.height
    }
    
    override func getReply() -> Reply {
        let r = SortingReply(ordering: orderedOptions.flatMap({return positionForOptionInAttempt[$0]}))
        print(r.ordering)
        return r
    }

    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        webViewHelper.initChoicesHeights()
        for row in 0 ..< self.tableView(self.tableView, numberOfRowsInSection: 0) {
            if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: 0)) as? SortingQuizTableViewCell {
                cell.optionWebView.reload()
            }
        }
        webViewHelper.updateChoicesHeights()
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
        if let a = attempt {
            if let dataset = a.dataset as? SortingDataset {
                //                print("heightForRowAtIndexPath: \(indexPath.row) -> \(cellHeights[indexPath.row])")
                return CGFloat(webViewHelper.cellHeights[indexPath.row])
                //                dataset.options[indexPath.row]
            }
        }
        return 0
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
        
        if let dataset = attempt?.dataset as? SortingDataset {
            webViewHelper.cellHeightUpdateBlocks[indexPath.row] = cell.setHTMLText(orderedOptions[indexPath.row])
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let movingOption = orderedOptions[sourceIndexPath.row]
        orderedOptions.removeAtIndex(sourceIndexPath.row)
        orderedOptions.insert(movingOption, atIndex: destinationIndexPath.row)
    }
}

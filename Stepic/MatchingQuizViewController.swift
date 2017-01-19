//
//  MatchingQuizViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 16.01.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import FLKAutoLayout

class MatchingQuizViewController: QuizViewController {

    var firstTableView = UITableView()
    var secondTableView = UITableView()
        
    var firstWebViewHelper : ControllerQuizWebViewHelper!
    var secondWebViewHelper : ControllerQuizWebViewHelper!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        firstTableView.tableFooterView = UIView()
        secondTableView.tableFooterView = UIView()
        firstTableView.tag = 1
        secondTableView.tag = 2
        
        firstTableView.isScrollEnabled = false
        secondTableView.isScrollEnabled = false
        
        firstTableView.backgroundColor = UIColor.clear
        secondTableView.backgroundColor = UIColor.clear

        firstTableView.delegate = self
        firstTableView.dataSource = self
        secondTableView.delegate = self
        secondTableView.dataSource = self

        self.containerView.addSubview(firstTableView)
        self.containerView.addSubview(secondTableView)
        
        firstTableView.alignTop("0", bottom: "0", to: self.containerView)
        firstTableView.alignLeadingEdge(with: self.containerView, predicate: "0")
        firstTableView.constrainWidth(to: self.containerView, predicate: "*0.5")
        firstTableView.constrainTrailingSpace(to: secondTableView, predicate: "0")
        
        secondTableView.alignTop("0", bottom: "0", to: self.containerView)
        secondTableView.alignTrailingEdge(with: self.containerView, predicate: "0")
//        secondTableView.constrainWidth(to: self.containerView, predicate: "*0.5")
        
        firstTableView.register(UINib(nibName: "SortingQuizTableViewCell", bundle: nil), forCellReuseIdentifier: "SortingQuizTableViewCell")
        secondTableView.register(UINib(nibName: "SortingQuizTableViewCell", bundle: nil), forCellReuseIdentifier: "SortingQuizTableViewCell")

        secondTableView.isEditing = true
        firstTableView.isUserInteractionEnabled = false
        
        firstWebViewHelper = ControllerQuizWebViewHelper(tableView: firstTableView, view: view
            , countClosure: 
            {
                [weak self] in
                return self?.optionsCount ?? 0
            }, expectedQuizHeightClosure: {
                [weak self] in
//                return self?.firstTableView.contentSize.height ?? 0
                return self?.expectedQuizHeight ?? 0
            }, noQuizHeightClosure: {
                [weak self] in
                return self?.heightWithoutQuiz ?? 0
            }, delegate: delegate,
            success: {
                [weak self] in
                self?.finishedCellUpdates(tableViewId: 1)
            }
        )
        
        secondWebViewHelper = ControllerQuizWebViewHelper(tableView: secondTableView, view: view
            , countClosure: 
            {
                [weak self] in
                return self?.optionsCount ?? 0
            }, expectedQuizHeightClosure: {
                [weak self] in
//                return self?.secondTableView.contentSize.height ?? 0
                return self?.expectedQuizHeight ?? 0
            }, noQuizHeightClosure: {
                [weak self] in
                return self?.heightWithoutQuiz ?? 0
            }, delegate: delegate,
               success: {
                [weak self] in
                self?.finishedCellUpdates(tableViewId: 2)
            }

        )
        
        // Do any additional setup after loading the view.
    }

    fileprivate var finishedOneUpdate = false
    fileprivate var finishedBothUpdates = false
    
    fileprivate func finishedCellUpdates(tableViewId: Int) {
        if !finishedOneUpdate {
            finishedOneUpdate = true
        } else {
            finishedBothUpdates = true
            
            if firstWebViewHelper.cellHeights.min() != maxHeight {
                self.firstTableView.beginUpdates()
                self.firstTableView.endUpdates()
            }
            
            if secondWebViewHelper.cellHeights.min() != maxHeight {
                self.secondTableView.beginUpdates()
                self.secondTableView.endUpdates()
            }
            
            self.delegate?.needsHeightUpdate(expectedQuizHeight + heightWithoutQuiz, animated: true) 
        }
    }
    
    fileprivate var orderedOptions : [String] = []
    fileprivate var positionForOptionInAttempt : [String : Int] = [:]
    
    var optionsCount: Int {
        return (self.attempt?.dataset as? MatchingDataset)?.pairs.count ?? 0
    }
    
    override func updateQuizAfterAttemptUpdate() {
        resetOptionsToAttempt()
        
        firstWebViewHelper.initChoicesHeights()
        firstWebViewHelper.updateChoicesHeights()
        
        secondWebViewHelper.initChoicesHeights()
        secondWebViewHelper.updateChoicesHeights()

        self.firstTableView.reloadData()
        self.secondTableView.reloadData()
//        UIThread.performUI {
////            self.view.layoutIfNeeded()
//        }
    }
    
    //TODO: Something strange is happening here, check this
    fileprivate func resetOptionsToAttempt() {
        orderedOptions = []
        positionForOptionInAttempt = [:]
        if let dataset = attempt?.dataset as? MatchingDataset {
            self.orderedOptions = dataset.secondValues
            for (index, option) in dataset.secondValues.enumerated() {
                positionForOptionInAttempt[option] = index
            }
        }
    }
    
    override func updateQuizAfterSubmissionUpdate(reload: Bool = true) {
        if self.submission == nil {
            if reload {
                resetOptionsToAttempt()
            }
            self.secondTableView.isUserInteractionEnabled = true
        } else {
            if let dataset = attempt?.dataset as? MatchingDataset {
                var o = [String](repeating: "", count: dataset.pairs.count)
                if let r = submission?.reply as? MatchingReply {
                    print("attempt dataset -> \(dataset.pairs), \nsubmission ordering -> \(r.ordering)")
                    for (index, order) in r.ordering.enumerated() {
                        o[index] = dataset.secondValues[order]
                    }
                }
                orderedOptions = o
            }
            self.secondTableView.isUserInteractionEnabled = false
        }
        
        self.firstTableView.reloadData()
        self.secondTableView.reloadData()
        
        finishedOneUpdate = false
        finishedBothUpdates = false
        updateHelper(webViewHelper: firstWebViewHelper, tableView: firstTableView)
        updateHelper(webViewHelper: secondWebViewHelper, tableView: secondTableView)
    }
    
    fileprivate func updateHelper(webViewHelper: ControllerQuizWebViewHelper, tableView: UITableView) {
        webViewHelper.initChoicesHeights()
        for row in 0 ..< self.tableView(tableView, numberOfRowsInSection: 0) {
            if let cell = tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? SortingQuizTableViewCell {
                cell.optionWebView.reload()
            }
        }
        webViewHelper.updateChoicesHeights()
    }
    
    override var expectedQuizHeight : CGFloat {
        return CGFloat(maxHeight * optionsCount)
//        return max(self.firstTableView.contentSize.height, self.secondTableView.contentSize.height)
    }
    
    override func getReply() -> Reply {
        let r = MatchingReply(ordering: orderedOptions.flatMap({return positionForOptionInAttempt[$0]}))
        print(r.ordering)
        return r
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        finishedOneUpdate = false
        finishedBothUpdates = false
        updateHelper(webViewHelper: firstWebViewHelper, tableView: firstTableView)
        updateHelper(webViewHelper: secondWebViewHelper, tableView: secondTableView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    var maxHeight : Int {
        return max(firstWebViewHelper.cellHeights.max() ?? 0, secondWebViewHelper.cellHeights.max() ?? 0)
    }
    
}

extension MatchingQuizViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        print("table \(tableView.tag) : HEIGHT for row at \(indexPath) called")
        
        if let a = attempt {
            if !finishedBothUpdates {
                if let dataset = a.dataset as? MatchingDataset {
                    switch tableView.tag {
                    case 1: 
                        return CGFloat(firstWebViewHelper.cellHeights[indexPath.row])
                    case 2:
                        return CGFloat(secondWebViewHelper.cellHeights[indexPath.row])
                    default: 
                        return 0
                    }
                }
            } else {
                return CGFloat(maxHeight)
            }
        }
        return 0
    }
    
    @objc(tableView:canMoveRowAtIndexPath:) func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        switch tableView.tag {
        case 1: 
            return false
        case 2:
            return true
        default: 
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

extension MatchingQuizViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if attempt != nil {
            return 1
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderedOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("table \(tableView.tag) : CELL for row at \(indexPath) called")
        let cell = tableView.dequeueReusableCell(withIdentifier: "SortingQuizTableViewCell", for: indexPath) as! SortingQuizTableViewCell
        
        if let dataset = attempt?.dataset as? MatchingDataset {
            switch tableView.tag {
            case 1:
                firstWebViewHelper.cellHeightUpdateBlocks[(indexPath as NSIndexPath).row] = cell.setHTMLText(dataset.firstValues[(indexPath as NSIndexPath).row])
            case 2:
                cell.sortable = true
                secondWebViewHelper.cellHeightUpdateBlocks[(indexPath as NSIndexPath).row] = cell.setHTMLText(orderedOptions[(indexPath as NSIndexPath).row])
            default:
                break
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movingOption = orderedOptions[(sourceIndexPath as NSIndexPath).row]
        orderedOptions.remove(at: (sourceIndexPath as NSIndexPath).row)
        orderedOptions.insert(movingOption, at: (destinationIndexPath as NSIndexPath).row)
    }
}


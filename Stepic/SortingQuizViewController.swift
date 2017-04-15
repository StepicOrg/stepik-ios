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
        tableView.isScrollEnabled = false
        self.containerView.addSubview(tableView)
        tableView.align(to: self.containerView)
        tableView.backgroundColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "SortingQuizTableViewCell", bundle: nil), forCellReuseIdentifier: "SortingQuizTableViewCell")
        tableView.isEditing = true
        
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
    
    
    fileprivate var orderedOptions : [String] = []
    fileprivate var positionForOptionInAttempt : [String : Int] = [:]

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
    
    fileprivate func resetOptionsToAttempt() {
        orderedOptions = []
        positionForOptionInAttempt = [:]
        if let dataset = attempt?.dataset as? SortingDataset {
            self.orderedOptions = dataset.options
            for (index, option) in dataset.options.enumerated() {
                positionForOptionInAttempt[option] = index
            }
        }
    }
    
    override func updateQuizAfterSubmissionUpdate(reload: Bool = true) {
//        webViewHelper.initChoicesHeights()
        if self.submission == nil {
            if reload {
                resetOptionsToAttempt()
            }
            self.tableView.isUserInteractionEnabled = true
        } else {
            if let dataset = attempt?.dataset as? SortingDataset {
                var o = [String](repeating: "", count: dataset.options.count)
                if let r = submission?.reply as? SortingReply {
                    print("attempt dataset -> \(dataset.options), \nsubmission ordering -> \(r.ordering)")
                    for (index, order) in r.ordering.enumerated() {
                        o[index] = dataset.options[order]
                    }
                }
                orderedOptions = o
            }
            self.tableView.isUserInteractionEnabled = false
        }
        self.tableView.reloadData()
        
        webViewHelper.initChoicesHeights()
        for row in 0 ..< self.tableView(self.tableView, numberOfRowsInSection: 0) {
            if let cell = self.tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? SortingQuizTableViewCell {
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

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        webViewHelper.initChoicesHeights()
        for row in 0 ..< self.tableView(self.tableView, numberOfRowsInSection: 0) {
            if let cell = self.tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? SortingQuizTableViewCell {
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
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let a = attempt {
            if (a.dataset as? SortingDataset) != nil {
                //                print("heightForRowAtIndexPath: \(indexPath.row) -> \(cellHeights[indexPath.row])")
                return CGFloat(webViewHelper.cellHeights[(indexPath as NSIndexPath).row])
                //                dataset.options[indexPath.row]
            }
        }
        return 0
    }
    
    @objc(tableView:canMoveRowAtIndexPath:) func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}

extension SortingQuizViewController : UITableViewDataSource {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "SortingQuizTableViewCell", for: indexPath) as! SortingQuizTableViewCell
        
        if let dataset = attempt?.dataset as? SortingDataset {
            webViewHelper.cellHeightUpdateBlocks[(indexPath as NSIndexPath).row] = cell.setHTMLText(orderedOptions[(indexPath as NSIndexPath).row])
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movingOption = orderedOptions[(sourceIndexPath as NSIndexPath).row]
        orderedOptions.remove(at: (sourceIndexPath as NSIndexPath).row)
        orderedOptions.insert(movingOption, at: (destinationIndexPath as NSIndexPath).row)
    }
}

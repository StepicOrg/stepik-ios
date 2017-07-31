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

    var tableView = FullHeightTableView()
    
    var cellHeights: [CGFloat?] = []
    
    var didReload: Bool = false

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
    }
    
    
    fileprivate var orderedOptions : [String] = []
    fileprivate var positionForOptionInAttempt : [String : Int] = [:]

    var optionsCount: Int {
        return (self.attempt?.dataset as? SortingDataset)?.options.count ?? 0
    }
    
    override func updateQuizAfterAttemptUpdate() {
        resetOptionsToAttempt()

        self.cellHeights = Array(repeating: nil, count: optionsCount)
        didReload = false
        tableView.reloadData()
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
        if self.submission == nil {
            if reload {
                resetOptionsToAttempt()
            }
            self.tableView.isUserInteractionEnabled = true
        } else {
            if let dataset = attempt?.dataset as? SortingDataset {
                var o = [String](repeating: "", count: dataset.options.count)
                if let r = submission?.reply as? SortingReply {
                    for (index, order) in r.ordering.enumerated() {
                        o[index] = dataset.options[order]
                    }
                }
                orderedOptions = o
            }
            self.tableView.isUserInteractionEnabled = false
        }
        self.tableView.reloadData()
    }
    
    override func getReply() -> Reply {
        let r = SortingReply(ordering: orderedOptions.flatMap({return positionForOptionInAttempt[$0]}))
        return r
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: nil) {
            [weak self]
            _ in
            guard let s = self else { return }
            s.cellHeights = Array(repeating: nil, count: s.optionsCount)
            s.didReload = false
            s.tableView.reloadData()
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

extension SortingQuizViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let dataset = attempt?.dataset as? SortingDataset else {
            return 0
        }
        if let height = cellHeights[indexPath.row] {
            return height
        } else {
            return SortingQuizTableViewCell.getHeightForText(text: dataset.options[indexPath.row], width: self.tableView.bounds.width, sortable: true)
        }
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
        guard let dataset = attempt?.dataset as? SortingDataset else {
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SortingQuizTableViewCell", for: indexPath) as! SortingQuizTableViewCell
        
        cell.setHTMLText(orderedOptions[indexPath.row], width: self.tableView.bounds.width, finishedBlock: {
            [weak self]
            newHeight in
            
            guard let s = self else { return }
            if s.didReload { return }
            
            s.cellHeights[indexPath.row] = newHeight
            var sum: CGFloat = 0
            for height in s.cellHeights {
                if height == nil {
                    return
                } else {
                    sum += height!
                }
            }
            UIThread.performUI {
                s.didReload = true
                s.tableView.contentSize = CGSize(width: s.tableView.contentSize.width, height: sum)
                s.tableView.beginUpdates()
                s.tableView.endUpdates()
            }
        })
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movingOption = orderedOptions[(sourceIndexPath as NSIndexPath).row]
        orderedOptions.remove(at: (sourceIndexPath as NSIndexPath).row)
        orderedOptions.insert(movingOption, at: (destinationIndexPath as NSIndexPath).row)
    }
}

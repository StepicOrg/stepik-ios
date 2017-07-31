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

    var firstTableView = FullHeightTableView(frame: CGRect.zero, style: UITableViewStyle.plain)
    var secondTableView = FullHeightTableView(frame: CGRect.zero, style: UITableViewStyle.plain)

    var firstUpdateFinished: Bool = false
    var secondUpdateFinished: Bool = false
    
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
        
        secondTableView.alignTop("0", bottom: "0", to: self.containerView)
        secondTableView.alignTrailingEdge(with: self.containerView, predicate: "0")
        secondTableView.constrainWidth(to: self.containerView, predicate: "*0.5")
        
        firstTableView.register(UINib(nibName: "SortingQuizTableViewCell", bundle: nil), forCellReuseIdentifier: "SortingQuizTableViewCell")
        secondTableView.register(UINib(nibName: "SortingQuizTableViewCell", bundle: nil), forCellReuseIdentifier: "SortingQuizTableViewCell")
        
        secondTableView.isEditing = true
        firstTableView.isUserInteractionEnabled = false
        
        // Do any additional setup after loading the view.
    }
    
    fileprivate var orderedOptions : [String] = []
    fileprivate var optionsPermutation : [Int] = []
    fileprivate var positionForOptionInAttempt : [String : Int] = [:]
    fileprivate var firstCellHeights: [CGFloat?] = []
    fileprivate var secondCellHeights: [CGFloat?] = []
    
    var optionsCount: Int {
        return (self.attempt?.dataset as? MatchingDataset)?.pairs.count ?? 0
    }
    
    override func updateQuizAfterAttemptUpdate() {
        guard let _ = attempt?.dataset as? MatchingDataset else {
            return
        }
        
        resetOptionsToAttempt()
        
        self.firstCellHeights = Array(repeating: nil, count: optionsCount)
        self.secondCellHeights = Array(repeating: nil, count: optionsCount)

        self.firstTableView.reloadData()
        self.secondTableView.reloadData()
    }
    
    //TODO: Something strange is happening here, check this
    fileprivate func resetOptionsToAttempt() {
        orderedOptions = []
        positionForOptionInAttempt = [:]
        optionsPermutation = []
        if let dataset = attempt?.dataset as? MatchingDataset {
            self.orderedOptions = dataset.secondValues
            for (index, option) in dataset.secondValues.enumerated() {
                optionsPermutation += [index]
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
                    optionsPermutation = r.ordering
                }
                orderedOptions = o
            }
            self.secondTableView.isUserInteractionEnabled = false
        }
        
        self.firstTableView.reloadData()
        self.secondTableView.reloadData()
    }
    
    var updatingWithReload = false
    
    override func getReply() -> Reply {
        let r = MatchingReply(ordering: optionsPermutation)
        print(r.ordering)
        return r
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: nil) {
            [weak self]
            _ in
            guard let s = self else { return }
            s.firstCellHeights = Array(repeating: nil, count: s.optionsCount)
            s.secondCellHeights = Array(repeating: nil, count: s.optionsCount)
            s.firstUpdateFinished = false
            s.secondUpdateFinished = false
            s.firstTableView.reloadData()
            s.secondTableView.reloadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func maxCellHeight(options: [String], heights: [CGFloat?], sortable: Bool) -> CGFloat {
        
        var max : CGFloat = 0
        
        for (index, height) in heights.enumerated() {
            if let h = height {
                if h > max {
                    max = h
                }
            } else {
                let h = SortingQuizTableViewCell.getHeightForText(text: options[index], width: self.view.bounds.width / 2, sortable: sortable)
                if h > max {
                    max = h
                }
            }
        }
        
        return max
    }
    
    var maxHeight : CGFloat {
        guard let dataset = attempt?.dataset as? MatchingDataset else {
            return 0
        }
        return max(maxCellHeight(options: dataset.firstValues, heights: firstCellHeights, sortable: false), maxCellHeight(options: dataset.secondValues, heights: secondCellHeights, sortable: true))
    }
}

extension MatchingQuizViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return maxHeight
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
    
    fileprivate func updateTableHeight(table: UITableView) {
        table.contentSize = CGSize(width: table.contentSize.width, height: maxHeight * CGFloat(optionsCount))
        table.beginUpdates()
        table.endUpdates()
    }
    
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

        guard let dataset = attempt?.dataset as? MatchingDataset else {
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SortingQuizTableViewCell", for: indexPath) as! SortingQuizTableViewCell
        
        switch tableView.tag {
        case 1:
            cell.setHTMLText(dataset.firstValues[indexPath.row], width: self.firstTableView.bounds.width, finishedBlock: {
                [weak self]
                newHeight in
                
                guard let s = self else { return }
                if s.firstUpdateFinished { return }
                
                s.firstCellHeights[indexPath.row] = newHeight
                var sum: CGFloat = 0
                for height in s.firstCellHeights {
                    if height == nil {
                        return
                    } else {
                        sum += height!
                    }
                }
                UIThread.performUI {
                    s.firstUpdateFinished = true
                    s.updateTableHeight(table: s.firstTableView)
                    s.updateTableHeight(table: s.secondTableView)
                }
            })
        case 2:
            cell.sortable = true
            cell.setHTMLText(orderedOptions[indexPath.row], width: self.secondTableView.bounds.width, finishedBlock: {
                [weak self]
                newHeight in
                
                guard let s = self else { return }
                if s.secondUpdateFinished { return }
                
                s.secondCellHeights[indexPath.row] = newHeight
                var sum: CGFloat = 0
                for height in s.secondCellHeights {
                    if height == nil {
                        return
                    } else {
                        sum += height!
                    }
                }
                UIThread.performUI {
                    s.secondUpdateFinished = true
                    s.updateTableHeight(table: s.secondTableView)
                    s.updateTableHeight(table: s.firstTableView)
                }
            })
        default:
            break
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movingOption = orderedOptions[(sourceIndexPath as NSIndexPath).row]
        let movingIndex = optionsPermutation[sourceIndexPath.row]
        optionsPermutation.remove(at: sourceIndexPath.row)
        optionsPermutation.insert(movingIndex, at: destinationIndexPath.row)
        orderedOptions.remove(at: (sourceIndexPath as NSIndexPath).row)
        orderedOptions.insert(movingOption, at: (destinationIndexPath as NSIndexPath).row)
    }
}


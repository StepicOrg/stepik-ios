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
import Foundation 

class ChoiceQuizViewController: QuizViewController {

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
        
        tableView.registerNib(UINib(nibName: "ChoiceQuizTableViewCell", bundle: nil), forCellReuseIdentifier: "ChoiceQuizTableViewCell")
        tableView.registerClass(ChoiceQuizLabelTableViewCell.self, forCellReuseIdentifier: "ChoiceQuizLabelTableViewCell")
        tableView.registerClass(ChoiceQuizWebViewTableViewCell.self, forCellReuseIdentifier: "ChoiceQuizWebViewTableViewCell")

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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    var choices : [Bool] = []
    
    var optionsCount: Int {
        return (self.attempt?.dataset as? ChoiceDataset)?.options.count ?? 0
    }
    
    override func updateQuizAfterAttemptUpdate() {
        self.choices = [Bool](count: optionsCount, repeatedValue: false)
        webViewHelper.initChoicesHeights()
        webViewHelper.updateChoicesHeights()
    }
    
        
    override func updateQuizAfterSubmissionUpdate(reload reload: Bool = true) {
        if self.submission == nil {
            if reload {
                self.choices = [Bool](count: optionsCount, repeatedValue: false) 
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
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
                
        webViewHelper.initChoicesHeights()
        for row in 0 ..< self.tableView(self.tableView, numberOfRowsInSection: 0) {
            if let cell = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: row, inSection: 0)) as? ChoiceQuizWebViewTableViewCell {
                cell.choiceWebView.reload()
            }
        }
        webViewHelper.updateChoicesHeights()
    }
    
}

extension ChoiceQuizViewController : UITableViewDelegate {

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let a = attempt {
            if let dataset = a.dataset as? ChoiceDataset {
//                print("heightForRowAtIndexPath: \(indexPath.row) -> \(cellHeights[indexPath.row])")
                return CGFloat(webViewHelper.cellHeights[indexPath.row])
//                dataset.options[indexPath.row]
            }
        }
        return 0
    }
    
    func setAllCellsOff() {
        let indexPaths = (0..<self.tableView.numberOfRowsInSection(0)).map({return NSIndexPath(forRow: $0, inSection: 0)})
        for indexPath in indexPaths {
            let cell = tableView.cellForRowAtIndexPath(indexPath) as? ChoiceQuizWebViewTableViewCell
            if cell == nil {
//                print("\nsetAllCellsOff() cell at indexPath(\(indexPath)) is nil!!!\n")
            }
            cell?.checkBox.on = false
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        reactOnSelection(tableView, didSelectRowAtIndexPath: indexPath)
    }
    
    private func reactOnSelection(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //TODO: REFACTOR THIS!!!!!!!!!!!!!!!!!!!!!
        let cellUnknown = tableView.cellForRowAtIndexPath(indexPath) 
        if cellUnknown is ChoiceQuizLabelTableViewCell {
            let cell = cellUnknown as! ChoiceQuizLabelTableViewCell
            if let dataset = attempt?.dataset as? ChoiceDataset {
                if dataset.isMultipleChoice {
                    choices[indexPath.row] = !cell.checkBox.on
                    cell.checkBox.setOn(!cell.checkBox.on, animated: true)
                } else {
                    setAllCellsOff()
                    choices = [Bool](count: optionsCount, repeatedValue: false)
                    choices[indexPath.row] = !cell.checkBox.on
                    cell.checkBox.setOn(!cell.checkBox.on, animated: true)
                }
            }
        } else {
            let cell = cellUnknown as! ChoiceQuizWebViewTableViewCell
            if let dataset = attempt?.dataset as? ChoiceDataset {
                if dataset.isMultipleChoice {
                    choices[indexPath.row] = !cell.checkBox.on
                    cell.checkBox.setOn(!cell.checkBox.on, animated: true)
                } else {
                    setAllCellsOff()
                    choices = [Bool](count: optionsCount, repeatedValue: false)
                    choices[indexPath.row] = !cell.checkBox.on
                    cell.checkBox.setOn(!cell.checkBox.on, animated: true)
                }
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
//        print("in cellForRowAtIndexPath : \(indexPath.row)")
        if let a = attempt {
            if let dataset = a.dataset as? ChoiceDataset {
                //TODO: REFACTOR THIS!!!
                if TagDetectionUtil.isWebViewSupportNeeded(dataset.options[indexPath.row]) {
                    let cell = tableView.dequeueReusableCellWithIdentifier("ChoiceQuizWebViewTableViewCell", forIndexPath: indexPath) as! ChoiceQuizWebViewTableViewCell
                    webViewHelper.cellHeightUpdateBlocks[indexPath.row] = cell.webViewHelper.setTextWithTeX(dataset.options[indexPath.row])
//                    if dataset.isMultipleChoice {
//                        cell.checkBox.boxType = .Square
//                    } else {
//                        cell.checkBox.boxType = .Circle
//                    }
//                    cell.checkBox.tag = indexPath.row
//                    cell.checkBox.delegate = self
//                    cell.checkBox.userInteractionEnabled = false
//                    if let s = submission {
//                        if let reply = s.reply as? ChoiceReply {
//                            cell.checkBox.on = reply.choices[indexPath.row]
//                        }
//                    } else {
//                        cell.checkBox.on = self.choices[indexPath.row]
//                    }
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCellWithIdentifier("ChoiceQuizLabelTableViewCell", forIndexPath: indexPath) as! ChoiceQuizLabelTableViewCell
                    webViewHelper.cellHeightUpdateBlocks[indexPath.row] = cell.setHTMLText(dataset.options[indexPath.row])
//                    if dataset.isMultipleChoice {
//                        cell.checkBox.boxType = .Square
//                    } else {
//                        cell.checkBox.boxType = .Circle
//                    }
//                    cell.checkBox.tag = indexPath.row
//                    cell.checkBox.delegate = self
//                    cell.checkBox.userInteractionEnabled = false
//                    if let s = submission {
//                        if let reply = s.reply as? ChoiceReply {
//                            cell.checkBox.on = reply.choices[indexPath.row]
//                        }
//                    } else {
//                        cell.checkBox.on = self.choices[indexPath.row]
//                    }
                    return cell
                }
            }
        }
            
        return UITableViewCell()
    }
}



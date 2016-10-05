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
        tableView.isScrollEnabled = false
        self.containerView.addSubview(tableView)
        tableView.align(to: self.containerView)
        tableView.backgroundColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UINib(nibName: "ChoiceQuizTableViewCell", bundle: nil), forCellReuseIdentifier: "ChoiceQuizTableViewCell")

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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    var choices : [Bool] = []
    
    var optionsCount: Int {
        return (self.attempt?.dataset as? ChoiceDataset)?.options.count ?? 0
    }
    
    override func updateQuizAfterAttemptUpdate() {
        self.choices = [Bool](repeating: false, count: optionsCount)
        webViewHelper.initChoicesHeights()
        webViewHelper.updateChoicesHeights()
    }
    
        
    override func updateQuizAfterSubmissionUpdate(reload: Bool = true) {
        if self.submission == nil {
            if reload {
                self.choices = [Bool](repeating: false, count: optionsCount) 
            }
            self.tableView.isUserInteractionEnabled = true
        } else {
            self.tableView.isUserInteractionEnabled = false
        }
        self.tableView.reloadData()
    }
    
    override var expectedQuizHeight : CGFloat {
        return self.tableView.contentSize.height
    }
    
    override func getReply() -> Reply {
        return ChoiceReply(choices: self.choices)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
                
        webViewHelper.initChoicesHeights()
        for row in 0 ..< self.tableView(self.tableView, numberOfRowsInSection: 0) {
            if let cell = self.tableView.cellForRow(at: IndexPath(row: row, section: 0)) as? ChoiceQuizTableViewCell {
                cell.choiceWebView.reload()
            }
        }
        webViewHelper.updateChoicesHeights()
    }
    
}

extension ChoiceQuizViewController : UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let _ = attempt?.dataset as? ChoiceDataset {
            return CGFloat(webViewHelper.cellHeights[(indexPath as NSIndexPath).row])
        }
        return 0
    }
    
    func setAllCellsOff() {
        let indexPaths = (0..<self.tableView.numberOfRows(inSection: 0)).map({return IndexPath(row: $0, section: 0)})
        for indexPath in indexPaths {
            let cell = tableView.cellForRow(at: indexPath) as? ChoiceQuizTableViewCell
            if cell == nil {
//                print("\nsetAllCellsOff() cell at indexPath(\(indexPath)) is nil!!!\n")
            }
            cell?.checkBox.on = false
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        reactOnSelection(tableView, didSelectRowAtIndexPath: indexPath)
    }
    
    fileprivate func reactOnSelection(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ChoiceQuizTableViewCell {
            if let dataset = attempt?.dataset as? ChoiceDataset {
                if dataset.isMultipleChoice {
                    choices[(indexPath as NSIndexPath).row] = !cell.checkBox.on
                    cell.checkBox.setOn(!cell.checkBox.on, animated: true)
                } else {
                    setAllCellsOff()
                    choices = [Bool](repeating: false, count: optionsCount)
                    choices[(indexPath as NSIndexPath).row] = !cell.checkBox.on
                    cell.checkBox.setOn(!cell.checkBox.on, animated: true)
                }
            }
        }
    }
}

extension ChoiceQuizViewController : BEMCheckBoxDelegate {
    func didTap(_ checkBox: BEMCheckBox) {
        choices[checkBox.tag] = checkBox.on
    }
}

extension ChoiceQuizViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if let _ = attempt?.dataset as? ChoiceDataset {
            return 1
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let dataset = attempt?.dataset as? ChoiceDataset {
            return dataset.options.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let dataset = attempt?.dataset as? ChoiceDataset {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChoiceQuizTableViewCell", for:indexPath) as! ChoiceQuizTableViewCell
            webViewHelper.cellHeightUpdateBlocks[(indexPath as NSIndexPath).row] = cell.setHTMLText(dataset.options[(indexPath as NSIndexPath).row])
            if dataset.isMultipleChoice {
                cell.checkBox.boxType = .square
            } else {
                cell.checkBox.boxType = .circle
            }
            cell.checkBox.tag = (indexPath as NSIndexPath).row
            cell.checkBox.delegate = self
            cell.checkBox.isUserInteractionEnabled = false                
            if let reply = submission?.reply as? ChoiceReply {
                cell.checkBox.on = reply.choices[(indexPath as NSIndexPath).row]
            } else {
                cell.checkBox.on = self.choices[(indexPath as NSIndexPath).row]
            }
            return cell
        } 
            
        return UITableViewCell()
    }
}



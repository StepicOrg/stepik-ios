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

    var tableView = FullHeightTableView()
    
    var latexSupportNeeded : Bool = false
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
        
        tableView.register(UINib(nibName: "ChoiceQuizTableViewCell", bundle: nil), forCellReuseIdentifier: "ChoiceQuizTableViewCell")
        tableView.register(UINib(nibName: "TextChoiceQuizTableViewCell", bundle: nil), forCellReuseIdentifier: "TextChoiceQuizTableViewCell")
    }
    
    fileprivate func hasTagsInDataset(dataset: ChoiceDataset) -> Bool {
        for option in dataset.options {
            if TagDetectionUtil.isWebViewSupportNeeded(option) {
                return true
            }
        }
        return false
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
        guard let dataset = attempt?.dataset as? ChoiceDataset else {
            return
        }

        self.choices = [Bool](repeating: false, count: optionsCount)
        latexSupportNeeded = hasTagsInDataset(dataset: dataset)
        
        if latexSupportNeeded {
            self.cellHeights = Array(repeating: nil, count: optionsCount)
        } else {
            tableView.reloadData()
        }
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
    
    override func getReply() -> Reply {
        return ChoiceReply(choices: self.choices)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if latexSupportNeeded {
            self.cellHeights = Array(repeating: nil, count: optionsCount)
            didReload = false
            tableView.reloadData()
        } else {
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
    
    var isSubview: Bool = false
    func updatesEnded() {
        guard isSubview == false else { return }
        self.containerView.addSubview(tableView)
        tableView.align(to: self.containerView)
        isSubview = true
    }
    
}

extension ChoiceQuizViewController : UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let dataset = attempt?.dataset as? ChoiceDataset else {
            return 0
        }
        if latexSupportNeeded {
            if let height = cellHeights[indexPath.row] {
                return height
            } else {
                return 0.5
            }
        } else {
            return CGFloat(TextChoiceQuizTableViewCell.getHeightForText(text: dataset.options[indexPath.row], width: self.view.bounds.width))
        }
    }
    
    func setAllCellsOff() {
        let indexPaths = (0..<self.tableView.numberOfRows(inSection: 0)).map({return IndexPath(row: $0, section: 0)})
        for indexPath in indexPaths {
            if let cell = tableView.cellForRow(at: indexPath) as? ChoiceQuizTableViewCell {
                cell.checkBox.on = false
            }
            if let cell = tableView.cellForRow(at: indexPath) as? TextChoiceQuizTableViewCell {
                cell.checkBox.on = false
            }
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
        
        if let cell = tableView.cellForRow(at: indexPath) as? TextChoiceQuizTableViewCell {
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
        guard let dataset = attempt?.dataset as? ChoiceDataset else {
            return UITableViewCell()
        }
        if latexSupportNeeded {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ChoiceQuizTableViewCell", for:indexPath) as! ChoiceQuizTableViewCell
            _ = cell.setHTMLText(dataset.options[(indexPath as NSIndexPath).row], finishedBlock: {
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
                    s.updatesEnded()
                }
            })
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
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "TextChoiceQuizTableViewCell", for:indexPath) as! TextChoiceQuizTableViewCell
            cell.setHTMLText(dataset.options[indexPath.row])
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
    }
}



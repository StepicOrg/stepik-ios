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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }
    
    var choices : [Bool] = []
    
    override func updateQuizAfterAttemptUpdate() {
        self.choices = [Bool](count: (self.attempt?.dataset as! ChoiceDataset).options.count, repeatedValue: false)
        self.cellHeights = [Int](count: (self.attempt?.dataset as! ChoiceDataset).options.count, repeatedValue: 1)
        print((self.attempt?.dataset as! ChoiceDataset).options.count)
        initHeightUpdateBlocks()
        self.tableView.reloadData()
        performHeightUpdates()
        self.view.layoutIfNeeded()
    }
    
    private func initHeightUpdateBlocks() {
        cellHeightUpdateBlocks = []
        for _ in 0..<(self.attempt?.dataset as! ChoiceDataset).options.count {
            cellHeightUpdateBlocks += [{
                return 1
            }]
        }
    }
    
    //Measured in seconds
    let reloadTimeStandardInterval = 0.5
    let reloadTimeout = 5.0
    let noReloadTimeout = 1.0
    
    private func reloadWithCount(count: Int, noReloadCount: Int) {
        if Double(count) * reloadTimeStandardInterval > reloadTimeout {
            return
        }
        if Double(noReloadCount) * reloadTimeStandardInterval > noReloadTimeout {
            return 
        }
        delay(reloadTimeStandardInterval * Double(count), closure: {
            [weak self] in
            if self?.countHeights() == true {
                UIThread.performUI{
                    self?.tableView.reloadData() 
                    if let expectedHeight = self?.expectedQuizHeight, 
                        let noQuizHeight = self?.heightWithoutQuiz {
                        self?.delegate?.needsHeightUpdate(expectedHeight + noQuizHeight, animated: true) 
                    }
                }
                self?.reloadWithCount(count + 1, noReloadCount: 0)
            } else {
                self?.reloadWithCount(count + 1, noReloadCount: noReloadCount + 1)
            }
        })  
    }    
    
    private func performHeightUpdates() {
        self.reloadWithCount(0, noReloadCount: 0)
    }
    
    private func countHeights() -> Bool {
        var index = 0
        var didChangeHeight = false
        for updateBlock in cellHeightUpdateBlocks {
            let h = updateBlock()
            if abs(cellHeights[index] - h) > 1 { 
                print("changed height of cell \(index) from \(cellHeights[index]) to \(h)")
                cellHeights[index] = h
                didChangeHeight = true
            }
            index += 1
        }
        return didChangeHeight
    }
    
    override func updateQuizAfterSubmissionUpdate(reload reload: Bool = true) {
        if self.submission == nil {
            if reload {
                self.choices = [Bool](count: (self.attempt?.dataset as! ChoiceDataset).options.count, repeatedValue: false) 
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    var cellHeightUpdateBlocks : [(Void->Int)] = []
    var cellHeights : [Int] = []
}

extension ChoiceQuizViewController : UITableViewDelegate {

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let a = attempt {
            if let dataset = a.dataset as? ChoiceDataset {
                print("heightForRowAtIndexPath: \(indexPath.row) -> \(cellHeights[indexPath.row])")
                return CGFloat(cellHeights[indexPath.row])
//                dataset.options[indexPath.row]
            }
        }
        return 0
    }
    
    func setAllCellsOff() {
        let indexPaths = (0..<self.tableView.numberOfRowsInSection(0)).map({return NSIndexPath(forRow: $0, inSection: 0)})
        for indexPath in indexPaths {
            let cell = tableView.cellForRowAtIndexPath(indexPath) as? ChoiceQuizTableViewCell
            if cell == nil {
                print("\nsetAllCellsOff() cell at indexPath(\(indexPath)) is nil!!!\n")
            }
            cell?.checkBox.on = false
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        reactOnSelection(tableView, didSelectRowAtIndexPath: indexPath)
    }
    
    private func reactOnSelection(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! ChoiceQuizTableViewCell
        if let dataset = attempt?.dataset as? ChoiceDataset {
            if dataset.isMultipleChoice {
                choices[indexPath.row] = !cell.checkBox.on
                cell.checkBox.setOn(!cell.checkBox.on, animated: true)
            } else {
                setAllCellsOff()
                choices = [Bool](count: (self.attempt?.dataset as! ChoiceDataset).options.count, repeatedValue: false)
                choices[indexPath.row] = !cell.checkBox.on
                cell.checkBox.setOn(!cell.checkBox.on, animated: true)
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
        let cell = tableView.dequeueReusableCellWithIdentifier("ChoiceQuizTableViewCell", forIndexPath: indexPath) as! ChoiceQuizTableViewCell
        print("in cellForRowAtIndexPath : \(indexPath.row)")
        if let a = attempt {
            if let dataset = a.dataset as? ChoiceDataset {
                cellHeightUpdateBlocks[indexPath.row] = cell.setTextWithTeX(dataset.options[indexPath.row])
                if dataset.isMultipleChoice {
                    cell.checkBox.boxType = .Square
                } else {
                    cell.checkBox.boxType = .Circle
                }
                cell.checkBox.tag = indexPath.row
                cell.checkBox.delegate = self
                cell.checkBox.userInteractionEnabled = false
                cell.tapHandler = {
                    [weak self] in
                    self?.reactOnSelection(tableView, didSelectRowAtIndexPath: indexPath)

                }
                if let s = submission {
                    if let reply = s.reply as? ChoiceReply {
                        cell.checkBox.on = reply.choices[indexPath.row]
                    }
                } else {
                    cell.checkBox.on = false
                }
            }
        }
            
        return cell
    }
}



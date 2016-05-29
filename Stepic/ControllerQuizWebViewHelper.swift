//
//  ControllerQuizWebViewHelper.swift
//  Stepic
//
//  Created by Alexander Karpov on 29.05.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

class ControllerQuizWebViewHelper {
    
    private var tableView: UITableView
    private var view: UIView
    private var countClosure : (Void -> Int)
    private var expectedQuizHeightClosure : (Void -> CGFloat)
    private var noQuizHeightClosure : (Void -> CGFloat)
    private var delegate : QuizControllerDelegate?
    
    private var optionsCount : Int {
        return countClosure()
    }
    
    private var expectedQuizHeight : CGFloat {
        return expectedQuizHeightClosure()
    }
    
    private var heightWithoutQuiz : CGFloat {
        return noQuizHeightClosure()
    }
    
    
    init(tableView: UITableView, view: UIView, countClosure: (Void -> Int), expectedQuizHeightClosure: (Void -> CGFloat), noQuizHeightClosure: (Void -> CGFloat), delegate: QuizControllerDelegate?) {
        self.tableView = tableView
        self.view = view
        self.countClosure = countClosure
        self.expectedQuizHeightClosure = expectedQuizHeightClosure
        self.noQuizHeightClosure = noQuizHeightClosure
        self.delegate = delegate
    }
    
    func initChoicesHeights() {
        self.cellHeights = [Int](count: optionsCount, repeatedValue: 1)
    }
    
    func updateChoicesHeights() {
        initHeightUpdateBlocks()
        self.tableView.reloadData()
        performHeightUpdates()
        self.view.layoutIfNeeded()
    }
    
    private func initHeightUpdateBlocks() {
        cellHeightUpdateBlocks = []
        for _ in 0 ..< optionsCount {
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
                //                print("changed height of cell \(index) from \(cellHeights[index]) to \(h)")
                cellHeights[index] = h
                didChangeHeight = true
            }
            index += 1
        }
        return didChangeHeight
    }
    
    var cellHeightUpdateBlocks : [(Void->Int)] = []
    var cellHeights : [Int] = []
}
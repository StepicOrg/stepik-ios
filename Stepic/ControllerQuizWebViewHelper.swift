//
//  ControllerQuizWebViewHelper.swift
//  Stepic
//
//  Created by Alexander Karpov on 29.05.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

class ControllerQuizWebViewHelper {
    
    fileprivate weak var tableView: UITableView?
    fileprivate weak var view: UIView?
    fileprivate var countClosure : ((Void) -> Int)
    fileprivate var expectedQuizHeightClosure : ((Void) -> CGFloat)
    fileprivate var noQuizHeightClosure : ((Void) -> CGFloat)
    fileprivate weak var delegate : QuizControllerDelegate?
    fileprivate var successBlock : ((Void) -> Void)?
    
    fileprivate var optionsCount : Int {
        return countClosure()
    }
    
    fileprivate var expectedQuizHeight : CGFloat {
        return expectedQuizHeightClosure()
    }
    
    fileprivate var heightWithoutQuiz : CGFloat {
        return noQuizHeightClosure()
    }
    
//    fileprivate var finishedCells : [Int] = []
    
    init(tableView: UITableView, view: UIView, countClosure: @escaping ((Void) -> Int), expectedQuizHeightClosure: @escaping ((Void) -> CGFloat), noQuizHeightClosure: @escaping ((Void) -> CGFloat), delegate: QuizControllerDelegate?, success: ((Void) -> Void)? = nil) {
        self.tableView = tableView
        self.view = view
        self.countClosure = countClosure
        self.expectedQuizHeightClosure = expectedQuizHeightClosure
        self.noQuizHeightClosure = noQuizHeightClosure
        self.delegate = delegate
        self.successBlock = success
    }
    
    func initChoicesHeights() {
        self.cellHeights = [Int](repeating: 1, count: optionsCount)
    }
    
    func updateChoicesHeights() {
//        finishedCells = []
        initHeightUpdateBlocks()
        self.tableView?.reloadData()
        performHeightUpdates()
    }
    
    fileprivate func initHeightUpdateBlocks() {
        cellHeightUpdateBlocks = []
        for _ in 0 ..< optionsCount {
            cellHeightUpdateBlocks += [{
                return 1
                }]
        }
    }
    
    //Measured in seconds
    let reloadTimeStandardInterval = 0.5
    let reloadTimeout = 2.5
    let noReloadTimeout = 1.0
    
    fileprivate func reloadWithCount(_ count: Int, noReloadCount: Int) {
        
        if Double(count) * reloadTimeStandardInterval > reloadTimeout {
//            UIThread.performUI{
//                self.view.layoutIfNeeded()
                self.successBlock?()
//            }
            return
        }
        
        if Double(noReloadCount) * reloadTimeStandardInterval > noReloadTimeout {
//            UIThread.performUI{
//                self.view.layoutIfNeeded()
                self.successBlock?()
//            }
            return 
        }
        
        delay(reloadTimeStandardInterval * Double(count), closure: {
            [weak self] in
            if self?.countHeights() == true {
//                UIThread.performUI{
                    self?.tableView?.reloadData() 
                    if let expectedHeight = self?.expectedQuizHeight, 
                        let noQuizHeight = self?.heightWithoutQuiz {
                        print("needs height update called from controllerwebviewhelper")
                        self?.delegate?.needsHeightUpdate(expectedHeight + noQuizHeight, animated: true, breaksSynchronizationControl: false) 
                    }
//                }
                self?.reloadWithCount(count + 1, noReloadCount: 0)
            } else {
                self?.reloadWithCount(count + 1, noReloadCount: noReloadCount + 1)
            }
        })  
    }    
    
    fileprivate func performHeightUpdates() {
        self.reloadWithCount(0, noReloadCount: 0)
    }
    
    fileprivate func countHeights() -> Bool {
        var index = 0
        var didChangeHeight = false
        for updateBlock in cellHeightUpdateBlocks {
            let h = updateBlock()
            if abs(cellHeights[index] - h) > 1 { 
                //                print("changed height of cell \(index) from \(cellHeights[index]) to \(h)")
                cellHeights[index] = h
                didChangeHeight = true
//                if let id = finishedCells.index(of: index) {
//                    finishedCells.remove(at: id)
//                }
            } else {
//                if finishedCells.index(of: index) != nil {
//                    finishedCells += [index]
//                }
            }
            index += 1
        }
        return didChangeHeight
    }
    
    var cellHeightUpdateBlocks : [((Void)->Int)] = []
    var cellHeights : [Int] = []
    
    deinit {
        print("in deinit controller web view helper")
    }
}

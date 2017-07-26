//
//  ControllerQuizWebViewHelper.swift
//  Stepic
//
//  Created by Alexander Karpov on 29.05.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

class ControllerQuizWebViewHelper {
    
    fileprivate weak var tableView: FullHeightTableView?
    fileprivate var countClosure : ((Void) -> Int)
    fileprivate var successBlock : ((Void) -> Void)?
    
    fileprivate var optionsCount : Int {
        return countClosure()
    }
    
    init(tableView: FullHeightTableView, countClosure: @escaping ((Void) -> Int), success: ((Void) -> Void)? = nil) {
        self.tableView = tableView
        self.countClosure = countClosure
        self.successBlock = success
    }
    
    func initChoicesHeights() {
        self.cellHeights = [Int](repeating: 1, count: optionsCount)
    }
    
    func updateChoicesHeights() {
        initHeightUpdateBlocks()
        self.tableView?.reloadData()
        performHeightUpdates()
    }
    
    fileprivate func initHeightUpdateBlocks() {
        cellHeightUpdateBlocks = []
        for _ in 0 ..< optionsCount {
            cellHeightUpdateBlocks += [{
                return 0
            }]
        }
    }
    
    //Measured in seconds
    let reloadTimeStandardInterval = 0.5
    let reloadTimeout = 2.5
    let noReloadTimeout = 1.0
    
    fileprivate func reloadWithCount(_ count: Int, noReloadCount: Int) {
        
        if Double(count) * reloadTimeStandardInterval > reloadTimeout {
                self.successBlock?()
            return
        }
        
        if Double(noReloadCount) * reloadTimeStandardInterval > noReloadTimeout {
                self.successBlock?()
            return
        }
        
        delay(reloadTimeStandardInterval * Double(count), closure: {
            [weak self] in
            if self?.countHeights() == true {
                self?.tableView?.reloadData()
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
                cellHeights[index] = h
                didChangeHeight = true
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

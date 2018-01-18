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

    var dataset: MatchingDataset?
    var reply: MatchingReply?

    var firstTableView = FullHeightTableView(frame: CGRect.zero, style: UITableViewStyle.plain)
    var secondTableView = FullHeightTableView(frame: CGRect.zero, style: UITableViewStyle.plain)

    var firstUpdateFinished: Bool = false
    var secondUpdateFinished: Bool = false

    func cellWidth(forTableView tableView: UITableView) -> CGFloat {
        if #available(iOS 11.0, *) {
            return tableView.bounds.width - CGFloat(view.safeAreaInsets.left + view.safeAreaInsets.right) / 2
        } else {
            return tableView.bounds.width
        }
    }

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

        firstTableView.alignTop("0", bottom: "0", toView: self.containerView)
        firstTableView.alignLeadingEdge(withView: self.containerView, predicate: "0")
        firstTableView.constrainWidth(toView: self.containerView, predicate: "*0.5")

        secondTableView.alignTop("0", bottom: "0", toView: self.containerView)
        secondTableView.alignTrailingEdge(withView: self.containerView, predicate: "0")
        secondTableView.constrainWidth(toView: self.containerView, predicate: "*0.5")

        firstTableView.register(UINib(nibName: "SortingQuizTableViewCell", bundle: nil), forCellReuseIdentifier: "SortingQuizTableViewCell")
        secondTableView.register(UINib(nibName: "SortingQuizTableViewCell", bundle: nil), forCellReuseIdentifier: "SortingQuizTableViewCell")

        secondTableView.isEditing = true
        firstTableView.isUserInteractionEnabled = false
    }

    fileprivate var orderedOptions: [String] = []
    fileprivate var optionsPermutation: [Int] = []
    fileprivate var positionForOptionInAttempt: [String : Int] = [:]
    fileprivate var firstCellHeights: [CGFloat?] = []
    fileprivate var secondCellHeights: [CGFloat?] = []

    var optionsCount: Int {
        return dataset?.pairs.count ?? 0
    }

    override func display(dataset: Dataset) {
        guard let dataset = dataset as? MatchingDataset else {
            return
        }

        self.dataset = dataset
        resetOptionsToDataset()

        self.firstCellHeights = Array(repeating: nil, count: optionsCount)
        self.secondCellHeights = Array(repeating: nil, count: optionsCount)

        self.firstTableView.reloadData()
        self.secondTableView.reloadData()

        self.secondTableView.isUserInteractionEnabled = true
    }

    override func display(reply: Reply, withStatus status: SubmissionStatus) {
        guard let reply = reply as? MatchingReply else {
            return
        }

        self.reply = reply
        display(reply: reply)
        self.secondTableView.isUserInteractionEnabled = false
    }

    override func display(reply: Reply) {
        guard let reply = reply as? MatchingReply else {
            return
        }

        guard let dataset = dataset else {
            return
        }

        var o = [String](repeating: "", count: dataset.pairs.count)
        for (index, order) in reply.ordering.enumerated() {
            o[index] = dataset.secondValues[order]
        }
        optionsPermutation = reply.ordering
        orderedOptions = o

        self.firstTableView.reloadData()
        self.secondTableView.reloadData()
    }

    fileprivate func resetOptionsToDataset() {
        orderedOptions = []
        positionForOptionInAttempt = [:]
        optionsPermutation = []
        if let dataset = dataset {
            self.orderedOptions = dataset.secondValues
            for (index, option) in dataset.secondValues.enumerated() {
                optionsPermutation += [index]
                positionForOptionInAttempt[option] = index
            }
        }
    }

    override func getReply() -> Reply? {
        return MatchingReply(ordering: optionsPermutation)
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

        var max: CGFloat = 0

        for (index, height) in heights.enumerated() {
            if let h = height {
                if h > max {
                    max = h
                }
            } else {
                let h = SortingQuizTableViewCell.getHeightForText(text: options[index], width: sortable ? cellWidth(forTableView: secondTableView) : cellWidth(forTableView: firstTableView), sortable: sortable)
                if h > max {
                    max = h
                }
            }
        }

        return max
    }

    var maxHeight: CGFloat {
        guard let dataset = dataset else {
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
        print("started updating table height for \(table.tag) | height -> \(table.bounds.height), content size -> \(table.contentSize)")
        table.invalidateIntrinsicContentSize()
        table.contentSize = CGSize(width: table.contentSize.width, height: maxHeight * CGFloat(optionsCount))
        table.beginUpdates()
        table.endUpdates()
        containerView.layoutIfNeeded()
        print("finished updating table height for \(table.tag) | height -> \(table.bounds.height), content size -> \(table.contentSize)")
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return dataset != nil ? 1 : 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderedOptions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let dataset = dataset else {
            return UITableViewCell()
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: "SortingQuizTableViewCell", for: indexPath) as! SortingQuizTableViewCell

        switch tableView.tag {
        case 1:
            cell.setHTMLText(dataset.firstValues[indexPath.row], width: cellWidth(forTableView: firstTableView), finishedBlock: {
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
            cell.setHTMLText(orderedOptions[indexPath.row], width: cellWidth(forTableView: secondTableView), finishedBlock: {
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

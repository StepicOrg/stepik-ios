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

    var dataset: SortingDataset?
    var reply: SortingReply?

    var cellHeights: [CGFloat?] = []

    var cellWidth: CGFloat {
        if #available(iOS 11.0, *) {
            return tableView.bounds.width - view.safeAreaInsets.left - view.safeAreaInsets.right
        } else {
            return tableView.bounds.width
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        tableView.isScrollEnabled = false
        self.containerView.addSubview(tableView)
        tableView.align(toView: self.containerView)
        tableView.backgroundColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "SortingQuizTableViewCell", bundle: nil), forCellReuseIdentifier: "SortingQuizTableViewCell")
        tableView.isEditing = true
    }

    fileprivate var orderedOptions: [String] = []
    fileprivate var positionForOptionInAttempt: [String : Int] = [:]

    var optionsCount: Int {
        return dataset?.options.count ?? 0
    }

    override func display(dataset: Dataset) {
        guard let dataset = dataset as? SortingDataset else {
            return
        }

        self.dataset = dataset

        resetOptionsToDataset()

        self.cellHeights = Array(repeating: nil, count: optionsCount)
        tableView.reloadData()
        self.tableView.isUserInteractionEnabled = true
    }

    override func display(reply: Reply, withStatus status: SubmissionStatus) {
        guard let reply = reply as? SortingReply else {
            return
        }

        self.reply = reply
        self.display(reply: reply)
        self.tableView.isUserInteractionEnabled = false
    }

    override func display(reply: Reply) {
        guard let reply = reply as? SortingReply else {
            return
        }

        guard let dataset = dataset else {
            return
        }

        var o = [String](repeating: "", count: dataset.options.count)
        for (index, order) in reply.ordering.enumerated() {
            o[index] = dataset.options[order]
        }
        orderedOptions = o
        self.tableView.reloadData()
    }

    fileprivate func resetOptionsToDataset() {
        orderedOptions = []
        positionForOptionInAttempt = [:]

        if let dataset = dataset {
            self.orderedOptions = dataset.options
            for (index, option) in dataset.options.enumerated() {
                positionForOptionInAttempt[option] = index
            }
        }
    }

    override func getReply() -> Reply? {
        let r = SortingReply(ordering: orderedOptions.compactMap { positionForOptionInAttempt[$0] })
        return r
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: nil) {
            [weak self]
            _ in
            guard let s = self else { return }
            s.cellHeights = Array(repeating: nil, count: s.optionsCount)
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
        guard let dataset = dataset else {
            return 0
        }
        if let height = cellHeights[indexPath.row] {
            return height
        } else {
            return SortingQuizTableViewCell.getHeightForText(text: dataset.options[indexPath.row], width: cellWidth, sortable: true)
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

        cell.setHTMLText(orderedOptions[indexPath.row], width: cellWidth, finishedBlock: {
            [weak self]
            newHeight in

            guard let s = self else { return }

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

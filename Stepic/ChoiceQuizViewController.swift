//
//  ChoiceQuizViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 20.01.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import BEMCheckBox
import Foundation
import SnapKit
import UIKit

final class ChoiceQuizViewController: QuizViewController {
    var tableView = FullHeightTableView()

    var dataset: ChoiceDataset?
    var reply: ChoiceReply?

    var cellHeights: [CGFloat?] = []

    var cellWidth: CGFloat {
        return tableView.bounds.width - view.safeAreaInsets.left - view.safeAreaInsets.right
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        tableView.isScrollEnabled = false
        self.containerView.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalTo(self.containerView) }
        tableView.backgroundColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(UINib(nibName: "ChoiceQuizTableViewCell", bundle: nil), forCellReuseIdentifier: "ChoiceQuizTableViewCell")
    }

    private func hasTagsInDataset(dataset: ChoiceDataset) -> Bool {
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

    var choices: [Bool] = []

    var optionsCount: Int {
        return dataset?.options.count ?? 0
    }

    override func display(dataset: Dataset) {
        guard let dataset = dataset as? ChoiceDataset else {
            return
        }

        self.dataset = dataset

        self.choices = [Bool](repeating: false, count: optionsCount)
        self.cellHeights = Array(repeating: nil, count: optionsCount)
        tableView.reloadData()
        tableView.invalidateIntrinsicContentSize()
        containerView.invalidateIntrinsicContentSize()
        self.view.invalidateIntrinsicContentSize()
        containerView.setNeedsLayout()
        containerView.layoutIfNeeded()
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        self.tableView.isUserInteractionEnabled = true
    }

    override func display(reply: Reply, withStatus status: SubmissionStatus) {
        guard let reply = reply as? ChoiceReply else {
            return
        }

        self.reply = reply

        display(reply: reply)
        self.tableView.isUserInteractionEnabled = false
    }

    override func display(reply: Reply) {
        guard let reply = reply as? ChoiceReply else {
            return
        }

        self.choices = reply.choices
        self.tableView.reloadData()
        self.tableView.invalidateIntrinsicContentSize()
        containerView.invalidateIntrinsicContentSize()
        self.view.invalidateIntrinsicContentSize()
        containerView.setNeedsLayout()
        containerView.layoutIfNeeded()
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
    }

    override func getReply() -> Reply? {
        if self.choices.contains(true) || dataset?.isMultipleChoice == true {
            return ChoiceReply(choices: self.choices)
        } else {
            return nil
        }
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
}

extension ChoiceQuizViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let dataset = dataset else {
            return 0
        }
        if let height = cellHeights[indexPath.row] {
            return height
        } else {
            return ChoiceQuizTableViewCell.getHeightForText(text: dataset.options[indexPath.row], width: cellWidth)
        }
    }

    func setAllCellsOff() {
        let indexPaths = (0..<self.tableView.numberOfRows(inSection: 0)).map({ IndexPath(row: $0, section: 0) })
        for indexPath in indexPaths {
            if let cell = tableView.cellForRow(at: indexPath) as? ChoiceQuizTableViewCell {
                cell.checkBox.on = false
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        reactOnSelection(tableView, didSelectRowAtIndexPath: indexPath)
    }

    private func reactOnSelection(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ChoiceQuizTableViewCell {
            if let dataset = dataset {
                if dataset.isMultipleChoice {
                    choices[indexPath.row] = !cell.checkBox.on
                    cell.checkBox.setOn(!cell.checkBox.on, animated: true)
                } else {
                    setAllCellsOff()
                    choices = [Bool](repeating: false, count: optionsCount)
                    choices[indexPath.row] = !cell.checkBox.on
                    cell.checkBox.setOn(!cell.checkBox.on, animated: true)
                }
            }
        }
    }
}

extension ChoiceQuizViewController: BEMCheckBoxDelegate {
    func didTap(_ checkBox: BEMCheckBox) {
        choices[checkBox.tag] = checkBox.on
    }
}

extension ChoiceQuizViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataset != nil ? 1 : 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let dataset = dataset {
            return dataset.options.count
        }
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let dataset = self.dataset else {
            return UITableViewCell()
        }

        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ChoiceQuizTableViewCell",
            for: indexPath
        ) as? ChoiceQuizTableViewCell else {
            return UITableViewCell()
        }

        cell.setHTMLText(dataset.options[indexPath.row], width: cellWidth, finishedBlock: { [weak self] newHeight in
            guard let strongSelf = self else {
                return
            }

            strongSelf.cellHeights[indexPath.row] = newHeight

            var sum: CGFloat = 0
            for height in strongSelf.cellHeights {
                if height == nil {
                    return
                } else {
                    sum += height!
                }
            }

            DispatchQueue.main.async {
                strongSelf.tableView.contentSize = CGSize(width: strongSelf.tableView.contentSize.width, height: sum)
                strongSelf.tableView.beginUpdates()
                strongSelf.tableView.endUpdates()
                strongSelf.containerView.layoutIfNeeded()
            }
        })

        if dataset.isMultipleChoice {
            cell.checkBox.boxType = .square
        } else {
            cell.checkBox.boxType = .circle
        }

        cell.checkBox.tag = indexPath.row
        cell.checkBox.delegate = self
        cell.checkBox.isUserInteractionEnabled = false
        cell.checkBox.on = self.choices[indexPath.row]

        return cell
    }
}

//
//  TVChoiceQuizViewController.swift
//  Stepic
//
//  Created by Александр Пономарев on 22.01.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class TVChoiceQuizViewController: TVQuizViewController {

    var tableView = FullHeightTableView()

    var dataset: ChoiceDataset?
    var reply: ChoiceReply?

    var cellHeights: [CGFloat?] = []

    var didReload: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        tableView.isScrollEnabled = false
        self.containerView.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.align(to: self.containerView)
        tableView.backgroundColor = UIColor.clear
        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(UINib(nibName: TVChoiceQuizTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: TVChoiceQuizTableViewCell.reuseIdentifier)
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
        didReload = false
        tableView.reloadData()
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
    }

    override func getReply() -> Reply {
        return ChoiceReply(choices: self.choices)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: nil) {
            [weak self]
            _ in
            guard let s = self else { return }
            s.cellHeights = Array(repeating: nil, count: s.optionsCount)
            s.didReload = false
            s.tableView.reloadData()
        }
    }
}

extension TVChoiceQuizViewController : UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let dataset = dataset else {
            return 0
        }
        if let height = cellHeights[indexPath.row] {
            return height
        } else {
            let i = TVChoiceQuizTableViewCell.getHeightForText(text: dataset.options[indexPath.row], width: tableView.bounds.width)
            return i
        }
    }

    func setAllCellsOffExceptCell(withIndex index: Int) {

        let totalRows = tableView.numberOfRows(inSection: 0)

        for row in 0..<totalRows {
            let indexPath = IndexPath(row: row, section: 0)

            if let cell = tableView.cellForRow(at: indexPath) as? TVChoiceQuizTableViewCell, indexPath.row != index {
                cell.setStatus(to: .off)
            }
        }
    }
}

extension TVChoiceQuizViewController : CheckStatusDelegate {
    func statusWillChange(_ cell: TVChoiceQuizTableViewCell, to: CheckStatus) {
        guard let dataset = dataset else { return }

        if !dataset.isMultipleChoice && to == .on {
            setAllCellsOffExceptCell(withIndex: cell.index)
            choices = [Bool](repeating: false, count: optionsCount)
        }

        cell.setStatus(to: to)
        choices[cell.index] = to == .on ? true : false
    }
}

extension TVChoiceQuizViewController : UITableViewDataSource {
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
        guard let dataset = dataset else {
            return UITableViewCell()
        }

        let cell = tableView.dequeueReusableCell(withIdentifier: TVChoiceQuizTableViewCell.reuseIdentifier, for:indexPath) as! TVChoiceQuizTableViewCell

        cell.setup(text: dataset.options[indexPath.row], width: self.tableView.bounds.width, finishedBlock: {
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
            }
        })

        cell.index = indexPath.row
        cell.delegate = self
        cell.checkBox.isUserInteractionEnabled = false
        cell.setStatus(to: self.choices[indexPath.row] ? .on : .off)
        return cell
    }
}

//
//  MenuViewController.swift
//  Stepic
//
//  Created by Ostrenkiy on 30.08.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import SnapKit
import UIKit

class MenuViewController: UIViewController {
    lazy var tableView = StepikTableView()

    var interfaceManager: MenuUIManager?

    var menu: Menu? {
        didSet {
            self.menu?.delegate = self
            self.tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { $0.edges.equalTo(self.view) }

        self.tableView.separatorStyle = .none

        self.tableView.tableFooterView = UIView()
        self.tableView.delegate = self
        self.tableView.dataSource = self

        self.tableView.estimatedRowHeight = 80.0
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.contentInsetAdjustmentBehavior = .never

        self.interfaceManager = MenuUIManager(tableView: tableView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.menu?.willAppear()
    }
}

// MARK: - MenuViewController: MenuDelegate -

extension MenuViewController: MenuDelegate {
    func getMenuIndexPath(from index: Int) -> IndexPath { IndexPath(row: index, section: 0) }

    func update(at index: Int) {
        self.tableView.reloadRows(at: [self.getMenuIndexPath(from: index)], with: .automatic)
    }

    func insert(at index: Int) {
        self.tableView.insertRows(at: [self.getMenuIndexPath(from: index)], with: .automatic)
    }

    func remove(at index: Int) {
        let indexPath = self.getMenuIndexPath(from: index)
        self.interfaceManager?.prepareToRemove(at: indexPath)
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

// MARK: - MenuViewController: UITableViewDataSource -

extension MenuViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        self.menu != nil ? 1 : 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.menu?.blocks.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let block = self.menu?.blocks[safe: indexPath.row],
              let interfaceManager = self.interfaceManager else {
            return UITableViewCell()
        }

        return interfaceManager.getCell(forblock: block, indexPath: indexPath)
    }
}

// MARK: - MenuViewController: UITableViewDelegate -

extension MenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        guard let interfaceManager = self.interfaceManager,
              let block = self.menu?.blocks[safe: indexPath.row] else {
            return false
        }

        return interfaceManager.shouldSelect(block: block, indexPath: indexPath)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let block = self.menu?.blocks[safe: indexPath.row] {
            self.interfaceManager?.didSelect(block: block, indexPath: indexPath)
        }
    }
}

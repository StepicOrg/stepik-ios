//
//  SplitTestGroupsListSplitTestGroupsListViewController.swift
//  stepik-ios
//
//  Created by Ivan Magda on 20/12/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

protocol SplitTestGroupsListViewControllerProtocol: class {
    func displayGroups(viewModel: SplitTestGroupsList.ShowGroups.ViewModel)
}

final class SplitTestGroupsListViewController: UITableViewController {
    private static let cellReuseIdentifier = "SplitTestGroupsTableViewCellIdentifier"

    let interactor: SplitTestGroupsListInteractorProtocol
    private var state: SplitTestGroupsList.ViewControllerState {
        didSet {
            self.updateState()
        }
    }
    private var groups = [SplitTestGroupViewModel]()

    private lazy var emptyResultLabel: UILabel = {
        let label = UILabel(frame: CGRect(origin: .zero, size: self.tableView.bounds.size))
        label.text = NSLocalizedString("StaffEmptySplitTestGroupsTitle", comment: "")
        label.textAlignment = .center
        return label
    }()

    init(
        interactor: SplitTestGroupsListInteractorProtocol,
        initialState: SplitTestGroupsList.ViewControllerState = .emptyResult
    ) {
        self.interactor = interactor
        self.state = initialState

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: SplitTestGroupsListViewController.cellReuseIdentifier
        )
        self.tableView.tableFooterView = UIView()

        self.interactor.getGroups(request: .init())
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if case .emptyResult = self.state {
            return 0
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.groups.count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: SplitTestGroupsListViewController.cellReuseIdentifier,
            for: indexPath
        )

        let group = self.groups[indexPath.row]
        cell.textLabel?.text = group.title
        cell.accessoryType = group.isSelected ? .checkmark : .none

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    private func updateState() {
        switch self.state {
        case .emptyResult:
            self.tableView.backgroundView = self.emptyResultLabel
        case .result(let data):
            self.tableView.backgroundView = nil
            self.groups = data
        }
        self.tableView.reloadData()
    }
}

extension SplitTestGroupsListViewController: SplitTestGroupsListViewControllerProtocol {
    func displayGroups(viewModel: SplitTestGroupsList.ShowGroups.ViewModel) {
        self.state = viewModel.state
    }
}

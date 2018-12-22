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
    func displayGroupChange(viewModel: SplitTestGroupsList.SelectGroup.ViewModel)
}

final class SplitTestGroupsListViewController: UITableViewController {
    let interactor: SplitTestGroupsListInteractorProtocol
    private var state: SplitTestGroupsList.ViewControllerState {
        didSet {
            self.updateState()
        }
    }
    private var viewModels = [SplitTestGroupViewModel]()

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

        self.tableView.register(cellClass: SplitTestTableViewCell.self)
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
        return self.viewModels.count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell: SplitTestTableViewCell = tableView.dequeueReusableCell(for: indexPath)

        let viewModel = self.viewModels[indexPath.row]
        cell.title = viewModel.title
        cell.accessoryType = viewModel.isChecked ? .checkmark : .none

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let selectedUniqueIdentifier = self.viewModels[indexPath.row].uniqueIdentifier
        self.interactor.selectGroup(
            request: .init(viewModelUniqueIdentifier: selectedUniqueIdentifier)
        )
    }

    private func updateState() {
        switch self.state {
        case .emptyResult:
            self.tableView.backgroundView = self.emptyResultLabel
        case .result(let data):
            self.tableView.backgroundView = nil
            self.viewModels = data
        }
        self.tableView.reloadData()
    }
}

extension SplitTestGroupsListViewController: SplitTestGroupsListViewControllerProtocol {
    func displayGroups(viewModel: SplitTestGroupsList.ShowGroups.ViewModel) {
        self.display(newState: viewModel.state)
    }

    func displayGroupChange(viewModel: SplitTestGroupsList.SelectGroup.ViewModel) {
        self.display(newState: viewModel.state)
    }

    private func display(newState: SplitTestGroupsList.ViewControllerState) {
        self.state = newState
    }
}

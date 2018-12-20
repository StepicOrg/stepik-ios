//
//  ActiveSplitTestsListViewController.swift
//  stepik-ios
//
//  Created by Ivan Magda on 20/12/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

protocol ActiveSplitTestsListViewControllerProtocol: class {
    func displaySplitTests(viewModel: ActiveSplitTestsList.ShowSplitTests.ViewModel)
}

final class ActiveSplitTestsListViewController: UITableViewController {
    private static let cellReuseIdentifier = "ActiveSplitTestTableViewCellIdentifier"

    let interactor: ActiveSplitTestsListInteractorProtocol
    private var state: ActiveSplitTestsList.ViewControllerState {
        didSet {
            self.updateState()
        }
    }
    private var splitTests = [SplitTestViewModel]()

    private lazy var emptyResultLabel: UILabel = {
        let label = UILabel(frame: CGRect(origin: .zero, size: self.tableView.bounds.size))
        label.text = NSLocalizedString("StaffEmptySplitTestsTitle", comment: "")
        label.textAlignment = .center
        return label
    }()

    init(
        interactor: ActiveSplitTestsListInteractorProtocol,
        initialState: ActiveSplitTestsList.ViewControllerState = .emptyResult
    ) {
        self.interactor = interactor
        self.state = initialState

        super.init(nibName: nil, bundle: nil)

        self.title = NSLocalizedString("StaffActiveSplitTestsListTitle", comment: "")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: ActiveSplitTestsListViewController.cellReuseIdentifier
        )
        self.tableView.tableFooterView = UIView()

        self.updateState()
        self.interactor.getSplitTests(request: .init())
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        if case .emptyResult = self.state {
            return 0
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.splitTests.count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ActiveSplitTestsListViewController.cellReuseIdentifier,
            for: indexPath
        )

        cell.textLabel?.text = self.splitTests[indexPath.row].title
        cell.accessoryType = .disclosureIndicator

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.presentSplitTestGroups(viewModel: self.splitTests[indexPath.row])
    }

    private func updateState() {
        switch self.state {
        case .emptyResult:
            self.tableView.backgroundView = self.emptyResultLabel
        case .result(let data):
            self.tableView.backgroundView = nil
            self.splitTests = data
        }
        self.tableView.reloadData()
    }

    private func presentSplitTestGroups(viewModel: SplitTestViewModel) {
        let uniqueIdentifier = viewModel.uniqueIdentifier
        let assembly = SplitTestGroupsListAssembly(splitTestUniqueIdentifier: uniqueIdentifier)
        let viewController = assembly.makeModule()
        viewController.title = viewModel.title

        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

extension ActiveSplitTestsListViewController: ActiveSplitTestsListViewControllerProtocol {
    func displaySplitTests(viewModel: ActiveSplitTestsList.ShowSplitTests.ViewModel) {
        self.state = viewModel.state
    }
}

//
//  SplitTestGroupsListSplitTestGroupsListViewController.swift
//  stepik-ios
//
//  Created by Ivan Magda on 20/12/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

protocol SplitTestGroupsListViewControllerProtocol: class {
    func displaySomething(viewModel: SplitTestGroupsList.Something.ViewModel)
}

final class SplitTestGroupsListViewController: UIViewController {
    let interactor: SplitTestGroupsListInteractorProtocol
    private var state: SplitTestGroupsList.ViewControllerState

    init(
        interactor: SplitTestGroupsListInteractorProtocol,
        initialState: SplitTestGroupsList.ViewControllerState = .loading
    ) {
        self.interactor = interactor
        self.state = initialState

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: ViewController lifecycle

    override func loadView() {
        let view = SplitTestGroupsListView(
            frame: UIScreen.main.bounds
        )
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.someAction()
    }

    // MARK: Requests logic

    private func someAction() {
        self.interactor.doSomeAction(
            request: SplitTestGroupsList.Something.Request()
        )
    }
}

extension SplitTestGroupsListViewController: SplitTestGroupsListViewControllerProtocol {
    func displaySomething(viewModel: SplitTestGroupsList.Something.ViewModel) {
        display(newState: viewModel.state)
    }

    func display(newState: SplitTestGroupsList.ViewControllerState) {
        self.state = newState
    }
}

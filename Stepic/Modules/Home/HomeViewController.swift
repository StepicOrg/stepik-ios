//
//  HomeHomeViewController.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 17/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

protocol HomeViewControllerProtocol: class {
    func displaySomething(viewModel: Home.Something.ViewModel)
}

final class HomeViewController: UIViewController {
    let interactor: HomeInteractorProtocol
    private var state: Home.ViewControllerState

    init(
        interactor: HomeInteractorProtocol,
        initialState: Home.ViewControllerState = .loading
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
        let view = HomeView(
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
            request: Home.Something.Request()
        )
    }
}

extension HomeViewController: HomeViewControllerProtocol {
    func displaySomething(viewModel: Home.Something.ViewModel) {
        display(newState: viewModel.state)
    }

    func display(newState: Home.ViewControllerState) {
        self.state = newState
    }
}

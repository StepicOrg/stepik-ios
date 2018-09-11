//
//  TagsTagsViewController.swift
//  stepik-ios
//
//  Created by Stepik on 11/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

protocol TagsViewControllerProtocol: class {
    func displaySomething(viewModel: Tags.Something.ViewModel)
}

final class TagsViewController: UIViewController {
    let interactor: TagsInteractorProtocol
    private var state: Tags.ViewControllerState

    init(
        interactor: TagsInteractorProtocol, 
        initialState: Tags.ViewControllerState = .loading
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
        let view = TagsView(
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
            request: Tags.Something.Request()
        )
    }
}

extension TagsViewController: TagsViewControllerProtocol {
    func displaySomething(viewModel: Tags.Something.ViewModel) {
        display(newState: viewModel.state)
    }

    func display(newState: Tags.ViewControllerState) {
        self.state = newState
    }
}
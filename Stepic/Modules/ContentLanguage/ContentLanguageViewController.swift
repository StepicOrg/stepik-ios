//
//  ContentLanguageContentLanguageViewController.swift
//  stepik-ios
//
//  Created by Stepik on 11/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

protocol ContentLanguageViewControllerProtocol: class {
    func displaySomething(viewModel: ContentLanguage.Something.ViewModel)
}

final class ContentLanguageViewController: UIViewController {
    let interactor: ContentLanguageInteractorProtocol
    private var state: ContentLanguage.ViewControllerState

    init(
        interactor: ContentLanguageInteractorProtocol, 
        initialState: ContentLanguage.ViewControllerState = .loading
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
        let view = ContentLanguageView(
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
            request: ContentLanguage.Something.Request()
        )
    }
}

extension ContentLanguageViewController: ContentLanguageViewControllerProtocol {
    func displaySomething(viewModel: ContentLanguage.Something.ViewModel) {
        display(newState: viewModel.state)
    }

    func display(newState: ContentLanguage.ViewControllerState) {
        self.state = newState
    }
}
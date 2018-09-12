//
//  ContentLanguageSwitchContentLanguageSwitchViewController.swift
//  stepik-ios
//
//  Created by Vladislav Kiryukhin on 12/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

protocol ContentLanguageSwitchViewControllerProtocol: class {
    func displayLanguages(viewModel: ContentLanguageSwitch.ShowLanguages.ViewModel)
}

final class ContentLanguageSwitchViewController: UIViewController {
    let interactor: ContentLanguageSwitchInteractorProtocol
    private var state: ContentLanguageSwitch.ViewControllerState

    lazy var contentLanguageSwitchView = self.view as? ContentLanguageSwitchView

    init(
        interactor: ContentLanguageSwitchInteractorProtocol,
        initialState: ContentLanguageSwitch.ViewControllerState = .loading
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
        let view = ContentLanguageSwitchView(
            frame: UIScreen.main.bounds
        )
        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadLanguagesList()
    }

    // MARK: Requests logic

    private func loadLanguagesList() {
        self.interactor.showLanguages(request: ContentLanguageSwitch.ShowLanguages.Request())
    }
}

extension ContentLanguageSwitchViewController: ContentLanguageSwitchViewControllerProtocol {
    func displayLanguages(viewModel: ContentLanguageSwitch.ShowLanguages.ViewModel) {
        if case let ContentLanguageSwitch.ViewControllerState.result(data) = viewModel.state {
            self.contentLanguageSwitchView?.configure(viewModels: data)
        }
    }
}

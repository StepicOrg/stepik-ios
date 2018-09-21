//
//  ExploreExplorePresenter.swift
//  stepik-ios
//
//  Created by Stepik on 10/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

protocol ExplorePresenterProtocol {
    func presentContent(response: Explore.LoadContent.Response)
    func presentLanguageSwitchBlock(response: Explore.CheckLanguageSwitchAvailability.Response)
}

final class ExplorePresenter: ExplorePresenterProtocol {
    weak var viewController: ExploreViewControllerProtocol?

    func presentContent(response: Explore.LoadContent.Response) {
        self.viewController?.displayContent(
            viewModel: .init(state: .normal(contentLanguage: response.contentLanguage))
        )
    }

    func presentLanguageSwitchBlock(response: Explore.CheckLanguageSwitchAvailability.Response) {
        self.viewController?.displayLanguageSwitchBlock(
            viewModel: .init(isHidden: response.isHidden)
        )
    }
}

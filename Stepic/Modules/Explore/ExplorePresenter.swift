//
//  ExploreExplorePresenter.swift
//  stepik-ios
//
//  Created by Stepik on 10/09/2018.
//  Copyright 2018 Stepik. All rights reserved.
//

import UIKit

protocol ExplorePresenterProtocol: BaseExplorePresenterProtocol {
    func presentContent(response: Explore.LoadContent.Response)
    func presentLanguageSwitchBlock(response: Explore.CheckLanguageSwitchAvailability.Response)
    func presentStoriesBlock(response: Explore.UpdateStoriesVisibility.Response)
}

final class ExplorePresenter: BaseExplorePresenter, ExplorePresenterProtocol {
    lazy var exploreViewController = self.viewController as? ExploreViewControllerProtocol

    func presentContent(response: Explore.LoadContent.Response) {
        self.exploreViewController?.displayContent(
            viewModel: .init(state: .normal(contentLanguage: response.contentLanguage))
        )
    }

    func presentLanguageSwitchBlock(response: Explore.CheckLanguageSwitchAvailability.Response) {
        self.exploreViewController?.displayLanguageSwitchBlock(
            viewModel: .init(isHidden: false)
        )
    }

    func presentStoriesBlock(response: Explore.UpdateStoriesVisibility.Response) {
        self.exploreViewController?.displayStoriesBlock(
            viewModel: .init(isHidden: response.isHidden)
        )
    }
}

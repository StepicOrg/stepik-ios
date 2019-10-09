//
//  StoryAssembly.swift
//  stepik-stories
//
//  Created by Ostrenkiy on 04.08.2018.
//  Copyright © 2018 Ostrenkiy. All rights reserved.
//

import UIKit

final class StoryAssembly: Assembly {
    private let story: Story
    private weak var navigationDelegate: StoryNavigationDelegate?

    init(story: Story, navigationDelegate: StoryNavigationDelegate) {
        self.story = story
        self.navigationDelegate = navigationDelegate
    }

    func makeModule() -> UIViewController {
        let viewController = StoryViewController()

        let urlNavigator = URLNavigator(
            presentingController: viewController,
            deepLinkRoutingService: DeepLinkRoutingService()
        )

        let presenter = StoryPresenter(
            view: viewController,
            story: self.story,
            storyPartViewFactory: StoryPartViewFactory(urlNavigationDelegate: urlNavigator),
            urlNavigator: urlNavigator,
            navigationDelegate: self.navigationDelegate
        )

        viewController.presenter = presenter

        return viewController
    }
}

final class URLNavigator: StoryURLNavigationDelegate {
    weak var presentingController: UIViewController?
    let deepLinkRoutingService: DeepLinkRoutingService

    init(presentingController: UIViewController?, deepLinkRoutingService: DeepLinkRoutingService) {
        self.presentingController = presentingController
        self.deepLinkRoutingService = deepLinkRoutingService
    }

    func open(url: URL) {
        self.deepLinkRoutingService.route(path: url.absoluteString, from: self.presentingController)
    }
}

protocol Assembly {
    func makeModule() -> UIViewController
}

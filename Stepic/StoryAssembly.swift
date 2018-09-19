//
//  StoryAssembly.swift
//  stepik-stories
//
//  Created by Ostrenkiy on 04.08.2018.
//  Copyright © 2018 Ostrenkiy. All rights reserved.
//

import Foundation
import UIKit

class StoryAssembly: Assembly {

    var story: Story
    weak var navigationDelegate: StoryNavigationDelegate?

    init(story: Story, navigationDelegate: StoryNavigationDelegate) {
        self.story = story
        self.navigationDelegate = navigationDelegate
    }

    func makeModule() -> UIViewController {
        let vc = StoryViewController()

        let urlNavigator = URLNavigator(presentingController: vc, deepLinkRoutingService: DeepLinkRoutingService())
        vc.presenter = StoryPresenter(view: vc, story: story, storyPartViewFactory: StoryPartViewFactory(urlNavigationDelegate: urlNavigator), urlNavigator: urlNavigator, navigationDelegate: navigationDelegate)
        return vc
    }
}

class URLNavigator: StoryURLNavigationDelegate {
    weak var presentingController: UIViewController?
    var deepLinkRoutingService: DeepLinkRoutingService

    init(presentingController: UIViewController?, deepLinkRoutingService: DeepLinkRoutingService) {
        self.presentingController = presentingController
        self.deepLinkRoutingService = deepLinkRoutingService
    }

    func open(url: URL) {
        deepLinkRoutingService.route(path: url.absoluteString, from: presentingController)
//        DeepLinkRouter.routeFromDeepLink(url: url, presentFrom: presentingController, isModal: true, withDelay: false)
    }
}

protocol Assembly {
    func makeModule() -> UIViewController
}

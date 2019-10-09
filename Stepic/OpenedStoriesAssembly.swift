//
//  OpenedStoriesAssembly.swift
//  Stepic
//
//  Created by Ostrenkiy on 10.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class OpenedStoriesAssembly: Assembly {
    private let stories: [Story]
    private let startPosition: Int

    init(stories: [Story], startPosition: Int) {
        self.stories = stories
        self.startPosition = startPosition
    }

    func makeModule() -> UIViewController {
        let viewController = OpenedStoriesPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
        viewController.presenter = OpenedStoriesPresenter(
            view: viewController,
            stories: self.stories, startPosition: self.startPosition
        )

        return viewController
    }
}

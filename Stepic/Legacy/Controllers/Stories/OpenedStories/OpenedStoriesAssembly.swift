//
//  OpenedStoriesAssembly.swift
//  Stepic
//
//  Created by Ostrenkiy on 10.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class OpenedStoriesAssembly: Assembly {
    weak var moduleOutput: OpenedStoriesOutputProtocol?

    private let stories: [Story]
    private let startPosition: Int
    private let storyOpenSource: StoryOpenSource

    init(
        stories: [Story],
        startPosition: Int,
        storyOpenSource: StoryOpenSource,
        moduleOutput: OpenedStoriesOutputProtocol? = nil
    ) {
        self.stories = stories
        self.startPosition = startPosition
        self.storyOpenSource = storyOpenSource
        self.moduleOutput = moduleOutput
    }

    func makeModule() -> UIViewController {
        let viewController = OpenedStoriesPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal,
            options: nil
        )
        let presenter = OpenedStoriesPresenter(
            view: viewController,
            stories: self.stories,
            startPosition: self.startPosition,
            storyOpenSource: self.storyOpenSource,
            analytics: StepikAnalytics.shared
        )

        presenter.moduleOutput = self.moduleOutput
        viewController.presenter = presenter

        return viewController
    }
}

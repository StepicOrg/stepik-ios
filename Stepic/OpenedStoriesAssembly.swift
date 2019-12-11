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

    init(stories: [Story], startPosition: Int, moduleOutput: OpenedStoriesOutputProtocol?) {
        self.stories = stories
        self.startPosition = startPosition
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
            stories: self.stories, startPosition: self.startPosition
        )
        
        presenter.moduleOutput = self.moduleOutput
        viewController.presenter = presenter

        return viewController
    }
}

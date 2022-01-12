//
//  StoriesAssembly.swift
//  stepik-stories
//
//  Created by Ostrenkiy on 06.08.2018.
//  Copyright © 2018 Ostrenkiy. All rights reserved.
//

import UIKit

final class StoriesAssembly: Assembly {
    weak var moduleOutput: StoriesOutputProtocol?

    private let storyOpenSource: StoryOpenSource

    init(storyOpenSource: StoryOpenSource, output: StoriesOutputProtocol? = nil) {
        self.storyOpenSource = storyOpenSource
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let viewController = StoriesViewController()
        let presenter = StoriesPresenter(
            view: viewController,
            storyTemplatesNetworkService: StoryTemplatesNetworkService(storyTemplatesAPI: StoryTemplatesAPI()),
            contentLanguageService: ContentLanguageService(),
            userAccountService: UserAccountService(),
            personalOffersService: PersonalOffersService(
                storageRecordsNetworkService: StorageRecordsNetworkService(storageRecordsAPI: StorageRecordsAPI())
            )
        )
        presenter.moduleOutput = self.moduleOutput
        viewController.presenter = presenter
        viewController.storyOpenSource = self.storyOpenSource

        return viewController
    }
}

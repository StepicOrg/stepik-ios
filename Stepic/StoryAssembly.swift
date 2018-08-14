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

    func buildModule() -> UIViewController {
        let vc = StoryViewController()
        vc.presenter = StoryPresenter(view: vc, story: story, navigationDelegate: navigationDelegate)
        return vc
    }
}

protocol Assembly {
    func buildModule() -> UIViewController
}

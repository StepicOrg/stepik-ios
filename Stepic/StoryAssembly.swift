//
//  StoryAssembly.swift
//  stepik-stories
//
//  Created by Ostrenkiy on 04.08.2018.
//  Copyright © 2018 Ostrenkiy. All rights reserved.
//

import Foundation
import UIKit

class LazyStoryAssembly {
    init(buildBlock: (() -> StoryViewController?)?) {
        self.buildModule = buildBlock
    }

    var buildModule: (() -> StoryViewController?)?
}

class StoryAssembly: Assembly {

    var story: Story
    var prevStoryLazyAssembly: LazyStoryAssembly
    var nextStoryLazyAssembly: LazyStoryAssembly

    init(
        story: Story,
        prevStoryLazyAssembly: LazyStoryAssembly,
        nextStoryLazyAssembly: LazyStoryAssembly
    ) {
        self.story = story
        self.prevStoryLazyAssembly = prevStoryLazyAssembly
        self.nextStoryLazyAssembly = nextStoryLazyAssembly
    }

    func buildModule() -> UIViewController {
        let vc = StoryViewController()
        vc.presenter = StoryPresenter(
            view: vc, story: story,
            prevStoryLazyAssembly: prevStoryLazyAssembly,
            nextStoryLazyAssembly: nextStoryLazyAssembly
        )
        return vc
    }
}

protocol Assembly {
    func buildModule() -> UIViewController
}

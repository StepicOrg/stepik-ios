//
//  OpenedStoriesAssembly.swift
//  Stepic
//
//  Created by Ostrenkiy on 10.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

class OpenedStoriesAssembly: Assembly {

    var stories: [Story]
    var startPosition: Int

    init(stories: [Story], startPosition: Int) {
        self.stories = stories
        self.startPosition = startPosition
    }

    func makeModule() -> UIViewController {
        let vc = OpenedStoriesPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        vc.presenter = OpenedStoriesPresenter(view: vc, stories: stories, startPosition: startPosition)
        return vc
    }
}

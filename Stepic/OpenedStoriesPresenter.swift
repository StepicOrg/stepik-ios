//
//  OpenedStoriesPresenter.swift
//  Stepic
//
//  Created by Ostrenkiy on 10.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

protocol OpenedStoriesViewProtocol: class {
    func set(module: UIViewController)
    func set(heroID: String)
}

protocol OpenedStoriesPresenterProtocol: class {
    func refresh()
    var nextModule: UIViewController? { get }
    var prevModule: UIViewController? { get }
    var currentModule: UIViewController { get }
}

class OpenedStoriesPresenter: OpenedStoriesPresenterProtocol {
    weak var view: OpenedStoriesViewProtocol?

    var stories: [Story]

    var moduleForStoryID: [Int: UIViewController] = [:]

    var nextModule: UIViewController? {
        guard let story = stories[safe: currentPosition + 1] else {
            return nil
        }
        return getModule(story: story)
    }

    var prevModule: UIViewController? {
        guard let story = stories[safe: currentPosition - 1] else {
            return nil
        }
        return getModule(story: story)
    }

    var currentModule: UIViewController {
        let story = stories[currentPosition]
        return getModule(story: story)
    }

    var currentPosition: Int

    init(view: OpenedStoriesViewProtocol, stories: [Story], startPosition: Int) {
        self.view = view
        self.stories = stories
        self.currentPosition = startPosition
        NotificationCenter.default.addObserver(self, selector: #selector(OpenedStoriesPresenter.storyDidAppear(_:)), name: .storyDidAppear, object: nil)
    }

    func refresh() {
        view?.set(module: currentModule)
    }

    private func getModule(story: Story) -> UIViewController {
        if let module = moduleForStoryID[story.id] {
            return module
        } else {
            let module = buildModule(for: story)
            moduleForStoryID[story.id] = module
            return module
        }
    }

    private func buildModule(for story: Story) -> UIViewController {
        return StoryAssembly(story: story).buildModule()
    }

    @objc
    func storyDidAppear(_ notification: Foundation.Notification) {
        guard let storyID = (notification as NSNotification).userInfo?["id"] as? Int,
            let position = stories.index(where: {$0.id == storyID}) else {
                return
        }
        view?.set(heroID: "story_\(storyID)")
        currentPosition = position
    }
}

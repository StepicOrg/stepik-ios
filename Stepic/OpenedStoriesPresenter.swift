//
//  OpenedStoriesPresenter.swift
//  Stepic
//
//  Created by Ostrenkiy on 10.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

protocol OpenedStoriesViewProtocol: class {
    func set(module: UIViewController, direction: UIPageViewController.NavigationDirection, animated: Bool)
    func close()
}

protocol OpenedStoriesPresenterProtocol: class {
    var nextModule: UIViewController? { get }
    var prevModule: UIViewController? { get }
    var currentModule: UIViewController { get }

    func onSwipeDismiss()
    func refresh()
}

class OpenedStoriesPresenter: OpenedStoriesPresenterProtocol {
    weak var view: OpenedStoriesViewProtocol?

    var stories: [Story]

    var moduleForStoryID: [Int: UIViewController] = [:]

    var nextModule: UIViewController? {
        if let story = self.stories[safe: self.currentPosition + 1] {
            return self.getModule(story: story)
        }
        return nil
    }

    var prevModule: UIViewController? {
        if let story = self.stories[safe: self.currentPosition - 1] {
            self.getModule(story: story)
        }
        return nil
    }

    var currentModule: UIViewController {
        let story = self.stories[self.currentPosition]
        return self.getModule(story: story)
    }

    var currentPosition: Int

    init(view: OpenedStoriesViewProtocol, stories: [Story], startPosition: Int) {
        self.view = view
        self.stories = stories
        self.currentPosition = startPosition

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(OpenedStoriesPresenter.storyDidAppear(_:)),
            name: .storyDidAppear,
            object: nil
        )
    }

    func refresh() {
        self.view?.set(module: self.currentModule, direction: .forward, animated: false)
    }

    func onSwipeDismiss() {
        AmplitudeAnalyticsEvents.Stories.storyClosed(id: stories[currentPosition].id, type: .swipe).send()
    }

    private func getModule(story: Story) -> UIViewController {
        if let module = self.moduleForStoryID[story.id] {
            return module
        } else {
            let module = self.makeModule(for: story)
            self.moduleForStoryID[story.id] = module
            return module
        }
    }

    private func makeModule(for story: Story) -> UIViewController {
        return StoryAssembly(story: story, navigationDelegate: self).makeModule()
    }

    @objc
    func storyDidAppear(_ notification: Foundation.Notification) {
        guard let storyID = (notification as NSNotification).userInfo?["id"] as? Int,
              let position = self.stories.index(where: { $0.id == storyID }) else {
            return
        }
        self.currentPosition = position
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension OpenedStoriesPresenter: StoryNavigationDelegate {
    func didFinishForward() {
        if let nextModule = self.nextModule {
            self.view?.set(module: nextModule, direction: .forward, animated: true)
        } else {
            self.view?.close()
        }
    }

    func didFinishBack() {
        if let prevModule = self.prevModule {
            self.view?.set(module: prevModule, direction: .reverse, animated: true)
        } else {
            self.view?.close()
        }
    }
}

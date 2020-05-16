//
//  OpenedStoriesPresenter.swift
//  Stepic
//
//  Created by Ostrenkiy on 10.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

protocol OpenedStoriesViewProtocol: AnyObject {
    func set(module: UIViewController, direction: UIPageViewController.NavigationDirection, animated: Bool)
    func close()
}

protocol OpenedStoriesOutputProtocol: AnyObject {
    func handleOpenedStoriesStatusBarStyleUpdate(_ statusBarStyle: UIStatusBarStyle)
}

protocol OpenedStoriesPresenterProtocol: AnyObject {
    var nextModule: UIViewController? { get }
    var prevModule: UIViewController? { get }
    var currentModule: UIViewController { get }

    func onSwipeDismiss()
    func refresh()

    func setStatusBarStyle(_ statusBarStyle: UIStatusBarStyle)
}

class OpenedStoriesPresenter: OpenedStoriesPresenterProtocol {
    weak var view: OpenedStoriesViewProtocol?
    weak var moduleOutput: OpenedStoriesOutputProtocol?

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
            return self.getModule(story: story)
        }
        return nil
    }

    var currentModule: UIViewController {
        let story = self.stories[self.currentPosition]
        return self.getModule(story: story)
    }

    var currentPosition: Int

    private let analytics: Analytics

    init(view: OpenedStoriesViewProtocol, stories: [Story], startPosition: Int, analytics: Analytics) {
        self.view = view
        self.stories = stories
        self.currentPosition = startPosition
        self.analytics = analytics

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

    func setStatusBarStyle(_ statusBarStyle: UIStatusBarStyle) {
        self.moduleOutput?.handleOpenedStoriesStatusBarStyleUpdate(statusBarStyle)
    }

    func onSwipeDismiss() {
        if let story = self.stories[safe: self.currentPosition] {
            self.analytics.send(.storiesStoryClosed(id: story.id, type: .swipe))
        }
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
        StoryAssembly(story: story, navigationDelegate: self).makeModule()
    }

    @objc
    func storyDidAppear(_ notification: Foundation.Notification) {
        guard let storyID = (notification as NSNotification).userInfo?["id"] as? Int,
              let position = self.stories.firstIndex(where: { $0.id == storyID }) else {
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

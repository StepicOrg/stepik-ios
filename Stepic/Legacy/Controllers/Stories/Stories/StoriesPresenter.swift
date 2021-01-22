//
//  StoriesPresenter.swift
//  stepik-stories
//
//  Created by Ostrenkiy on 08.08.2018.
//  Copyright © 2018 Ostrenkiy. All rights reserved.
//

import Foundation

enum StoriesViewState {
    case normal
    case empty
    case loading
}

protocol StoriesViewProtocol: AnyObject {
    func set(state: StoriesViewState)
    func set(stories: [Story])
    func updateStory(index: Int)
}

protocol StoriesPresenterProtocol: AnyObject {
    func refresh()
}

protocol StoriesOutputProtocol: AnyObject {
    func hideStories()
    func handleStoriesStatusBarStyleUpdate(_ statusBarStyle: UIStatusBarStyle)
}

final class StoriesPresenter: StoriesPresenterProtocol {
    weak var view: StoriesViewProtocol?
    weak var moduleOutput: StoriesOutputProtocol?

    var stories: [Story] = []
    var storyTemplatesAPI: StoryTemplatesAPI

    init(view: StoriesViewProtocol, storyTemplatesAPI: StoryTemplatesAPI) {
        self.view = view
        self.storyTemplatesAPI = storyTemplatesAPI

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(StoriesPresenter.storyDidAppear(_:)),
            name: .storyDidAppear,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc
    private func storyDidAppear(_ notification: Foundation.Notification) {
        guard let storyID = (notification as NSNotification).userInfo?["id"] as? Int,
              let index = self.stories.firstIndex(where: { $0.id == storyID }) else {
            return
        }

        self.stories[index].isViewed.value = true
        self.view?.updateStory(index: index)
    }

    func refresh() {
        self.view?.set(state: .loading)

        var isPublished: Bool?
        if AuthInfo.shared.user?.profileEntity?.isStaff != true {
            isPublished = true
        }

        self.storyTemplatesAPI.retrieve(
            isPublished: isPublished,
            language: ContentLanguageService().globalContentLanguage,
            maxVersion: StepikApplicationsInfo.Versions.stories ?? 0
        ).done { [weak self] stories in
            guard let strongSelf = self else {
                return
            }

            strongSelf.stories = stories.filter {
                $0.isSupported
            }.sorted(by: {
                $0.position >= $1.position
            }).sorted(by: {
                !($0.isViewed.value) || ($1.isViewed.value)
            })

            strongSelf.view?.set(state: strongSelf.stories.isEmpty ? .empty : .normal)
            strongSelf.view?.set(stories: strongSelf.stories)

            if strongSelf.stories.isEmpty {
                strongSelf.moduleOutput?.hideStories()
            }
        }.catch { [weak self] _ in
            guard let strongSelf = self else {
                return
            }

            strongSelf.view?.set(state: strongSelf.stories.isEmpty ? .empty : .normal)
        }
    }
}

// MARK: - StoriesPresenter: OpenedStoriesOutputProtocol -

extension StoriesPresenter: OpenedStoriesOutputProtocol {
    func handleOpenedStoriesStatusBarStyleUpdate(_ statusBarStyle: UIStatusBarStyle) {
        self.moduleOutput?.handleStoriesStatusBarStyleUpdate(statusBarStyle)
    }
}

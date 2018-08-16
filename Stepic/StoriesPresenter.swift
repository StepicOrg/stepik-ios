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

protocol StoriesViewProtocol: class {
    func set(state: StoriesViewState)
    func set(stories: [Story])
    func updateStory(index: Int)
}

protocol StoriesPresenterProtocol: class {
    func refresh()
}

class StoriesPresenter: StoriesPresenterProtocol {

    var stories: [Story] = []
    weak var view: StoriesViewProtocol?
    var storyTemplatesAPI: StoryTemplatesAPI

    init(view: StoriesViewProtocol, storyTemplatesAPI: StoryTemplatesAPI) {
        self.view = view
        self.storyTemplatesAPI = storyTemplatesAPI
        NotificationCenter.default.addObserver(self, selector: #selector(StoriesPresenter.storyDidAppear(_:)), name: .storyDidAppear, object: nil)
    }

    @objc
    func storyDidAppear(_ notification: Foundation.Notification) {
        guard let storyID = (notification as NSNotification).userInfo?["id"] as? Int,
            let index = stories.index(where: {$0.id == storyID}) else {
            return
        }

        stories[index].isViewed.value = true
        view?.updateStory(index: index)
    }

    func refresh() {
        view?.set(state: .loading)

        storyTemplatesAPI.retrieve(isPublished: true).done { [weak self] stories, _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.stories = stories
            strongSelf.view?.set(state: strongSelf.stories.isEmpty ? .empty : .normal)
            strongSelf.view?.set(stories: strongSelf.stories)
        }.catch { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.view?.set(state: strongSelf.stories.isEmpty ? .empty : .normal)
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

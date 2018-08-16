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

        //TODO: update cell's viewed state here
        stories[index].isViewed.value = true
        view?.updateStory(index: index)
    }

    let mockedStories: [Story] = [
//        Story(
//            id: 1,
//            coverPath: "https://placeimg.com/100/100/tech",
//            title: "Something about tech",
//            isViewed: false,
//            parts: [
//                ImageStoryPart(type: "image", position: 0, duration: 15, imagePath: "https://placeimg.com/401/800/tech"),
//                ImageStoryPart(type: "image", position: 1, duration: 15, imagePath: "https://placeimg.com/402/800/tech"),
//                ImageStoryPart(type: "image", position: 2, duration: 15, imagePath: "https://placeimg.com/403/800/tech"),
//                ImageStoryPart(type: "image", position: 3, duration: 15, imagePath: "https://placeimg.com/404/800/tech")
//                ]
//        ), Story(
//            id: 2,
//            coverPath: "https://placeimg.com/100/100/nature",
//            title: "Nature beauty",
//            isViewed: false,
//            parts: [
//                ImageStoryPart(type: "image", position: 0, duration: 15, imagePath: "https://placeimg.com/401/800/nature"),
//                ImageStoryPart(type: "image", position: 1, duration: 15, imagePath: "https://placeimg.com/402/800/nature"),
//                ImageStoryPart(type: "image", position: 2, duration: 15, imagePath: "https://placeimg.com/403/800/nature"),
//                ImageStoryPart(type: "image", position: 3, duration: 15, imagePath: "https://placeimg.com/404/800/nature")
//                ]
//        ), Story(
//            id: 3,
//            coverPath: "https://placeimg.com/100/100/animals",
//            title: "Wow animals",
//            isViewed: false,
//            parts: [
//                ImageStoryPart(type: "image", position: 0, duration: 15, imagePath: "https://placeimg.com/401/800/animals"),
//                ImageStoryPart(type: "image", position: 1, duration: 15, imagePath: "https://placeimg.com/402/800/animals"),
//                ImageStoryPart(type: "image", position: 2, duration: 15, imagePath: "https://placeimg.com/403/800/animals"),
//                ImageStoryPart(type: "image", position: 3, duration: 15, imagePath: "https://placeimg.com/404/800/animals")
//                ]
//        ), Story(
//            id: 4,
//            coverPath: "https://placeimg.com/100/100/architecture",
//            title: "Architecture & Urbanism",
//            isViewed: false,
//            parts: [
//                ImageStoryPart(type: "image", position: 0, duration: 15, imagePath: "https://placeimg.com/401/800/architecture"),
//                ImageStoryPart(type: "image", position: 1, duration: 15, imagePath: "https://placeimg.com/402/800/architecture"),
//                ImageStoryPart(type: "image", position: 2, duration: 15, imagePath: "https://placeimg.com/403/800/architecture"),
//                ImageStoryPart(type: "image", position: 3, duration: 15, imagePath: "https://placeimg.com/404/800/architecture")
//                ]
//        ), Story(
//            id: 5,
//            coverPath: "https://placeimg.com/100/100/people",
//            title: "People",
//            isViewed: false,
//            parts: [
//                ImageStoryPart(type: "image", position: 0, duration: 15, imagePath: "https://placeimg.com/401/800/people"),
//                ImageStoryPart(type: "image", position: 1, duration: 15, imagePath: "https://placeimg.com/402/800/people"),
//                ImageStoryPart(type: "image", position: 2, duration: 15, imagePath: "https://placeimg.com/403/800/people"),
//                ImageStoryPart(type: "image", position: 3, duration: 15, imagePath: "https://placeimg.com/404/800/people")
//            ]
//        )
    ]

    func refresh() {
        view?.set(state: .loading)

        storyTemplatesAPI.retrieve(isPublished: true).done { [weak self] stories, _ in
            guard let strongSelf = self else {
                return
            }
            strongSelf.stories = stories
            strongSelf.view?.set(state: strongSelf.stories.isEmpty ? .empty : .normal)
            strongSelf.view?.set(stories: strongSelf.stories)
        }.catch {
            _ in
            //TODO: Show error state here
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

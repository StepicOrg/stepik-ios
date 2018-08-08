//
//  StoriesPresenter.swift
//  stepik-stories
//
//  Created by Ostrenkiy on 08.08.2018.
//  Copyright © 2018 Ostrenkiy. All rights reserved.
//

import Foundation
import Nuke

enum StoriesViewState {
    case normal
    case empty
    case loading
}

protocol StoriesViewProtocol: class {
    func set(state: StoriesViewState)
    func set(stories: [Story])
    func showIfNotVisible(index: Int)
}

protocol StoriesPresenterProtocol: class {
    func refresh()
    func stopPreheat()
}

class StoriesPresenter: StoriesPresenterProtocol {
    var stories: [Story] = []
    weak var view: StoriesViewProtocol?

    private let preheater = ImagePreheater(pipeline: ImagePipeline.shared)

    init(view: StoriesViewProtocol) {
        self.view = view
        NotificationCenter.default.addObserver(self, selector: #selector(StoriesPresenter.storyDidAppear(_:)), name: .storyDidAppear, object: nil)
    }

    @objc
    func storyDidAppear(_ notification: Foundation.Notification) {
        guard let storyID = (notification as NSNotification).userInfo?["id"] as? Int,
            let index = stories.index(where: {$0.id == storyID}) else {
            return
        }

        //TODO: update cell's viewed state here
        view?.showIfNotVisible(index: index)
    }

    private func preheatFirstImages(stories: [Story]) {
        preheater.stopPreheating()

        let requests: [ImageRequest] = stories.compactMap {
            guard let path = ($0.parts.first as? ImageStoryPartProtocol)?.imagePath else {
                return nil
            }
            let url = URL(fileURLWithPath: path)
            var request = ImageRequest(url: url)
            request.priority = .high

            return request
        }

        preheater.startPreheating(with: requests)
    }

    let mockedStories: [Story] = [
        Story(
            id: 1,
            coverPath: "https://placeimg.com/100/100/tech",
            title: "Something about tech",
            isViewed: false,
            parts: [
                ImageStoryPart(type: "image", position: 0, duration: 15, imagePath: "https://placeimg.com/401/800/tech"),
                ImageStoryPart(type: "image", position: 1, duration: 15, imagePath: "https://placeimg.com/402/800/tech"),
                ImageStoryPart(type: "image", position: 2, duration: 15, imagePath: "https://placeimg.com/403/800/tech"),
                ImageStoryPart(type: "image", position: 3, duration: 15, imagePath: "https://placeimg.com/404/800/tech")
                ]
        ), Story(
            id: 2,
            coverPath: "https://placeimg.com/100/100/nature",
            title: "Nature beauty",
            isViewed: false,
            parts: [
                ImageStoryPart(type: "image", position: 0, duration: 15, imagePath: "https://placeimg.com/401/800/nature"),
                ImageStoryPart(type: "image", position: 1, duration: 15, imagePath: "https://placeimg.com/402/800/nature"),
                ImageStoryPart(type: "image", position: 2, duration: 15, imagePath: "https://placeimg.com/403/800/nature"),
                ImageStoryPart(type: "image", position: 3, duration: 15, imagePath: "https://placeimg.com/404/800/nature")
                ]
        ), Story(
            id: 3,
            coverPath: "https://placeimg.com/100/100/animals",
            title: "Wow animals",
            isViewed: false,
            parts: [
                ImageStoryPart(type: "image", position: 0, duration: 15, imagePath: "https://placeimg.com/401/800/animals"),
                ImageStoryPart(type: "image", position: 1, duration: 15, imagePath: "https://placeimg.com/402/800/animals"),
                ImageStoryPart(type: "image", position: 2, duration: 15, imagePath: "https://placeimg.com/403/800/animals"),
                ImageStoryPart(type: "image", position: 3, duration: 15, imagePath: "https://placeimg.com/404/800/animals")
                ]
        ), Story(
            id: 4,
            coverPath: "https://placeimg.com/100/100/architecture",
            title: "Architecture & Urbanism",
            isViewed: false,
            parts: [
                ImageStoryPart(type: "image", position: 0, duration: 15, imagePath: "https://placeimg.com/401/800/architecture"),
                ImageStoryPart(type: "image", position: 1, duration: 15, imagePath: "https://placeimg.com/402/800/architecture"),
                ImageStoryPart(type: "image", position: 2, duration: 15, imagePath: "https://placeimg.com/403/800/architecture"),
                ImageStoryPart(type: "image", position: 3, duration: 15, imagePath: "https://placeimg.com/404/800/architecture")
                ]
        ), Story(
            id: 5,
            coverPath: "https://placeimg.com/100/100/people",
            title: "People",
            isViewed: false,
            parts: [
                ImageStoryPart(type: "image", position: 0, duration: 15, imagePath: "https://placeimg.com/401/800/people"),
                ImageStoryPart(type: "image", position: 1, duration: 15, imagePath: "https://placeimg.com/402/800/people"),
                ImageStoryPart(type: "image", position: 2, duration: 15, imagePath: "https://placeimg.com/403/800/people"),
                ImageStoryPart(type: "image", position: 3, duration: 15, imagePath: "https://placeimg.com/404/800/people")
            ]
        )
    ]

    func refresh() {
        view?.set(state: .loading)
        self.stories = mockedStories
        delay(2.0, closure: {
            [weak self] in
            guard let `self` = self else {
                return
            }
            self.view?.set(state: self.stories.isEmpty ? .empty : .normal)
            self.preheatFirstImages(stories: self.stories)
            self.view?.set(stories: self.stories)
        })
    }

    func stopPreheat() {
        preheater.stopPreheating()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        stopPreheat()
    }
}

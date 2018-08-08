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
    
    func refresh() {
        view?.set(state: .loading)
        self.stories = mockedStories
        delay(0.5, closure: {
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
        stopPreheat()
    }
}

//
//  StoryPresenter.swift
//  stepik-stories
//
//  Created by Ostrenkiy on 04.08.2018.
//  Copyright © 2018 Ostrenkiy. All rights reserved.
//

import Foundation
import PromiseKit

protocol StoryViewProtocol: class {
    func animate(view: UIView & UIStoryPartViewProtocol)
    func animateProgress(segment: Int, duration: TimeInterval)
    func pause(segment: Int)
    func resume(segment: Int)
    func set(segment: Int, completed: Bool)
    func close()
}

protocol StoryPresenterProtocol: class {
    func animate()
    func finishedAnimating()
    func skip()
    func rewind()
    func pause()
    func resume()
    var storyPartsCount: Int { get }
    var storyID: Int { get }
    func didAppear()
}

extension NSNotification.Name {
    static let storyDidAppear = NSNotification.Name("storyDidAppear")
}

class StoryPresenter: StoryPresenterProtocol {
    weak var view: StoryViewProtocol?
    weak var navigationDelegate: StoryNavigationDelegate?

    private var storyPartViewFactory: StoryPartViewFactory
    private var story: Story

    private var partToAnimate: Int = 0
    private var viewForIndex: [Int: UIView & UIStoryPartViewProtocol] = [:]

    var storyID: Int {
        return story.id
    }

    var storyPartsCount: Int {
        return story.parts.count
    }

    func finishedAnimating() {
        partToAnimate += 1
        animate()
    }

    init(view: StoryViewProtocol, story: Story, storyPartViewFactory: StoryPartViewFactory, navigationDelegate: StoryNavigationDelegate?) {
        self.view = view
        self.story = story
        self.storyPartViewFactory = storyPartViewFactory
        self.navigationDelegate = navigationDelegate
    }

    func animate() {
        if partToAnimate < 0 {
            showPreviousStory()
            return
        }
        if partToAnimate >= story.parts.count {
            showNextStory()
            return
        }

        let animatingStoryPart = story.parts[partToAnimate]

        if let viewToAnimate = viewForIndex[partToAnimate] {
            view?.animate(view: viewToAnimate)
            view?.animateProgress(segment: partToAnimate, duration: animatingStoryPart.duration)
        } else {
            guard var viewToAnimate = storyPartViewFactory.makeView(storyPart: animatingStoryPart) else {
                return
            }
            viewToAnimate.completion = {
                [weak self] in
                guard let strongSelf = self else {
                    return
                }
                if strongSelf.partToAnimate == animatingStoryPart.position {
                    strongSelf.view?.animateProgress(segment: strongSelf.partToAnimate, duration: animatingStoryPart.duration)
                }
            }
            view?.animate(view: viewToAnimate)
        }
    }

    func didAppear() {
        NotificationCenter.default.post(name: .storyDidAppear, object: nil, userInfo: ["id": storyID])
    }

    private func showPreviousStory() {
        navigationDelegate?.didFinishBack()
    }

    private func showNextStory() {
        navigationDelegate?.didFinishForward()
    }

    func skip() {
        view?.set(segment: partToAnimate, completed: true)
        partToAnimate += 1
        animate()
    }

    func rewind() {
        view?.set(segment: partToAnimate, completed: false)
        partToAnimate -= 1
        animate()
    }

    func pause() {
        view?.pause(segment: partToAnimate)
    }

    func resume() {
        view?.resume(segment: partToAnimate)
    }
}

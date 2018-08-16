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
    func unpause(segment: Int)
    func set(segment: Int, completed: Bool)
    func close()
//    func transitionNext(destinationVC: StoryViewController)
//    func transitionPrev(destinationVC: StoryViewController)
}

protocol StoryPresenterProtocol: class {
    func animate()
    func finishedAnimating()
    func skip()
    func rewind()
    func pause()
    func unpause()
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

    init(view: StoryViewProtocol, story: Story, storyPartViewFactory: StoryPartViewFactory, navigationDelegate: StoryNavigationDelegate?) {
        self.view = view
        self.story = story
        self.storyPartViewFactory = storyPartViewFactory
        self.navigationDelegate = navigationDelegate
    }

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

    func animate() {
        guard 0 <= partToAnimate && partToAnimate < story.parts.count else {
            if partToAnimate < 0 {
                showPreviousStory()
                return
            } else {
                showNextStory()
                return
            }
        }

        let animatingStoryPart = story.parts[partToAnimate]

        if let viewToAnimate = viewForIndex[partToAnimate] {
            view?.animate(view: viewToAnimate)
            view?.animateProgress(segment: partToAnimate, duration: animatingStoryPart.duration)
        } else {
            var viewToAnimate = storyPartViewFactory.buildView(storyPart: animatingStoryPart)
            viewToAnimate?.completion = {
                [weak self] in
                guard let strongSelf = self else {
                    return
                }
                if strongSelf.partToAnimate == animatingStoryPart.position {
                    strongSelf.view?.animateProgress(segment: strongSelf.partToAnimate, duration: animatingStoryPart.duration)
                }
            }
            if let viewToAnimate = viewToAnimate {
                view?.animate(view: viewToAnimate)
            }
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

    func unpause() {
        view?.unpause(segment: partToAnimate)
    }
}

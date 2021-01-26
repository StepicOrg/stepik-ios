//
//  StoryPresenter.swift
//  stepik-stories
//
//  Created by Ostrenkiy on 04.08.2018.
//  Copyright © 2018 Ostrenkiy. All rights reserved.
//

import Foundation
import PromiseKit

protocol StoryViewProtocol: AnyObject {
    func animate(view: UIView & UIStoryPartViewProtocol)
    func animateProgress(segment: Int, duration: TimeInterval)
    func pause(segment: Int)
    func resume(segment: Int)
    func set(segment: Int, completed: Bool)
    func close()
}

protocol StoryPresenterProtocol: AnyObject {
    var storyPartsCount: Int { get }
    var storyID: Int { get }

    func animate()
    func finishedAnimating()
    func skip()
    func rewind()
    func pause()
    func resume()
    func didAppear()
    func onClosePressed()
}

extension NSNotification.Name {
    static let storyDidAppear = NSNotification.Name("storyDidAppear")
}

final class StoryPresenter: StoryPresenterProtocol {
    weak var view: StoryViewProtocol?
    weak var navigationDelegate: StoryNavigationDelegate?

    private var storyPartViewFactory: StoryPartViewFactory
    private var urlNavigator: URLNavigator
    private var story: Story

    private let storyOpenSource: StoryOpenSource

    private let storyPartsReactionsPersistenceService: StoryPartsReactionsPersistenceServiceProtocol
    private let analytics: Analytics

    private var partToAnimate: Int = 0
    private var viewForIndex: [Int: UIView & UIStoryPartViewProtocol] = [:]
    private var shouldRestartSegment = false

    var storyID: Int { self.story.id }

    var storyPartsCount: Int { self.story.parts.count }

    func finishedAnimating() {
        self.partToAnimate += 1
        self.animate()
    }

    init(
        view: StoryViewProtocol,
        story: Story,
        storyPartViewFactory: StoryPartViewFactory,
        urlNavigator: URLNavigator,
        navigationDelegate: StoryNavigationDelegate?,
        storyPartsReactionsPersistenceService: StoryPartsReactionsPersistenceServiceProtocol,
        storyOpenSource: StoryOpenSource,
        analytics: Analytics
    ) {
        self.view = view
        self.story = story
        self.storyPartViewFactory = storyPartViewFactory
        self.navigationDelegate = navigationDelegate
        self.urlNavigator = urlNavigator
        self.storyPartsReactionsPersistenceService = storyPartsReactionsPersistenceService
        self.storyOpenSource = storyOpenSource
        self.analytics = analytics
    }

    func animate() {
        if self.partToAnimate < 0 {
            self.showPreviousStory()
            return
        }
        if self.partToAnimate >= self.story.parts.count {
            self.showNextStory()
            return
        }

        let animatingStoryPart = self.story.parts[partToAnimate]

        if let viewToAnimate = self.viewForIndex[partToAnimate] {
            self.view?.animate(view: viewToAnimate)
            self.view?.animateProgress(segment: self.partToAnimate, duration: animatingStoryPart.duration)
        } else {
            guard var viewToAnimate = self.storyPartViewFactory.makeView(storyPart: animatingStoryPart) else {
                return
            }

            viewToAnimate.completion = { [weak self] in
                guard let strongSelf = self else {
                    return
                }

                if strongSelf.partToAnimate == animatingStoryPart.position {
                    strongSelf.view?.animateProgress(
                        segment: strongSelf.partToAnimate,
                        duration: animatingStoryPart.duration
                    )
                }
            }
            viewToAnimate.onDidChangeReaction = { [weak self] reaction in
                guard let strongSelf = self else {
                    return
                }

                if strongSelf.partToAnimate == animatingStoryPart.position {
                    strongSelf.saveStoryPartReaction(reaction: reaction, storyPart: animatingStoryPart).done { _ in }
                    strongSelf.analytics.send(
                        .storyReactionPressed(
                            id: animatingStoryPart.storyID,
                            position: animatingStoryPart.position,
                            reaction: reaction
                        )
                    )
                }
            }

            self.fetchStoryPartReaction(animatingStoryPart).done { [weak viewToAnimate] reaction in
                viewToAnimate?.setReaction(reaction?.storyReaction)
            }

            self.view?.animate(view: viewToAnimate)
        }

        self.analytics.send(.storyPartOpened(id: self.storyID, position: animatingStoryPart.position))
    }

    func didAppear() {
        self.analytics.send(.storyOpened(id: self.storyID, source: self.storyOpenSource))
        NotificationCenter.default.post(name: .storyDidAppear, object: nil, userInfo: ["id": self.storyID])

        if self.shouldRestartSegment {
            self.shouldRestartSegment = false
            self.animate()
        }
    }

    private func showPreviousStory() {
        self.analytics.send(.storyClosed(id: self.storyID, type: .automatic))
        self.navigationDelegate?.didFinishBack()

        self.partToAnimate = 0
        self.shouldRestartSegment = true
    }

    private func showNextStory() {
        self.analytics.send(.storyClosed(id: self.storyID, type: .automatic))
        self.navigationDelegate?.didFinishForward()

        self.partToAnimate = self.story.parts.count - 1
        self.shouldRestartSegment = true
    }

    func skip() {
        self.view?.set(segment: self.partToAnimate, completed: true)
        self.partToAnimate += 1
        self.animate()
    }

    func rewind() {
        self.view?.set(segment: self.partToAnimate, completed: false)
        self.partToAnimate -= 1
        self.animate()
    }

    func pause() {
        self.view?.pause(segment: self.partToAnimate)
    }

    func resume() {
        self.view?.resume(segment: self.partToAnimate)
    }

    func onClosePressed() {
        self.analytics.send(.storyClosed(id: self.storyID, type: .cross))
        self.view?.close()
    }

    private func fetchStoryPartReaction(_ storyPart: StoryPart) -> Guarantee<StoryPartReaction?> {
        Guarantee { seal in
            self.storyPartsReactionsPersistenceService.fetch(storyID: storyPart.storyID).done { reactions in
                let reactionOrNil = reactions.first(where: { $0.position == storyPart.position })
                seal(reactionOrNil)
            }
        }
    }

    private func saveStoryPartReaction(reaction: StoryReaction, storyPart: StoryPart) -> Guarantee<Void> {
        self.storyPartsReactionsPersistenceService.save(reaction: reaction, for: storyPart).asVoid()
    }
}

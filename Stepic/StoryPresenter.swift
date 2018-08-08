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
    func animate(view: UIView & UIStoryViewProtocol)
    func animateProgress(segment: Int, duration: TimeInterval)
    func pause(segment: Int)
    func unpause(segment: Int)
    func set(segment: Int, completed: Bool)
    func close()
    func transitionNext(destinationVC: StoryViewController)
    func transitionPrev(destinationVC: StoryViewController)
}

protocol StoryPresenterProtocol: class {
    func animate()
    func finishedAnimating()
    func skip()
    func rewind()
    func pause()
    func unpause()
    var storyPartsCount: Int { get }
    var storyId: Int { get }
    func getNextStory() -> StoryViewController?
    func getPrevStory() -> StoryViewController?
}

class StoryPresenter: StoryPresenterProtocol {
    weak var view: StoryViewProtocol?
    private var story: Story
    
    private var prevStoryLazyAssembly: LazyStoryAssembly
    private var nextStoryLazyAssembly: LazyStoryAssembly
    
    private var nextModule: StoryViewController?
    private var prevModule: StoryViewController?
    
    private var partToAnimate: Int = 0
    private var viewForIndex: [Int: UIView & UIStoryViewProtocol] = [:]

    init(
        view: StoryViewProtocol,
        story: Story,
        prevStoryLazyAssembly: LazyStoryAssembly,
        nextStoryLazyAssembly: LazyStoryAssembly
    ) {
        self.view = view
        self.story = story
        self.prevStoryLazyAssembly = prevStoryLazyAssembly
        self.nextStoryLazyAssembly = nextStoryLazyAssembly
    }
    
    var storyId: Int {
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
        
        let animatingStoryPart = story.parts[partToAnimate] as! ImageStoryPart
        
        if let viewToAnimate = viewForIndex[partToAnimate] {
            view?.animate(view: viewToAnimate)
            view?.animateProgress(segment: partToAnimate, duration: animatingStoryPart.duration)
        } else {
            let viewToAnimate: ImageStoryView = .fromNib()
            viewToAnimate.imagePath = animatingStoryPart.imagePath
            viewToAnimate.completion =  {
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
    
    func getPrevStory() -> StoryViewController? {
        if prevModule == nil {
            prevModule = prevStoryLazyAssembly.buildModule?()
        }
        return prevModule
    }
    
    func getNextStory() -> StoryViewController? {
        if nextModule == nil {
            nextModule = nextStoryLazyAssembly.buildModule?()
        }
        return nextModule
    }
    
    private func showPreviousStory() {
        guard let module = getPrevStory() else {
            view?.close()
            return
        }
        
        view?.transitionPrev(destinationVC: module)
    }
    
    private func showNextStory() {
        guard let module = getNextStory() else {
            view?.close()
            return
        }
        
        view?.transitionNext(destinationVC: module)
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

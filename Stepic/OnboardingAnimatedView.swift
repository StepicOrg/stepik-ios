//
//  OnboardingAnimatedView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 12.12.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import Lottie

class OnboardingAnimatedView: UIView {
    private let autoFlipAnimationDuration = 0.3

    private let animationSegmentsNames = [
        "onboardingAnimation1",
        "onboardingAnimation2",
        "onboardingAnimation3",
        "onboardingAnimation4"
    ]
    private var animationViews: [LOTAnimationView] = []
    private var currentSegmentIndex = 0

    private var prevPercent = 0.0
    private var shouldFinishSegment = false
    private var shouldFragmentBeMirrored = false
    private var hasFragmentOverscroll = false

    override func awakeFromNib() {
        super.awakeFromNib()

        clipsToBounds = false

        (0..<animationSegmentsNames.count).forEach { index in
            let view = LOTAnimationView(name: animationSegmentsNames[index])
            view.contentMode = .scaleAspectFill
            view.isHidden = true
            view.clipsToBounds = false
            self.addSubview(view)
            animationViews.append(view)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        animationViews.forEach { view in
            view.frame = self.bounds
        }
    }

    func start() {
        currentSegmentIndex = 0
        currentView?.play()
    }

    private var currentView: LOTAnimationView? {
        animationViews.forEach { $0.isHidden = $0 != animationViews[currentSegmentIndex] }
        return animationViews[currentSegmentIndex]
    }

    func flip(percent: Double, didInteractionFinished: Bool) {
        let currentSegmentPercent = percent - Double(Int(percent))

        if fabs(prevPercent - currentSegmentPercent) > 0.5 {
            // A large gap between previous and current percentage -> avoid page skipping, start new segment
            prevPercent = currentSegmentPercent <= 0.5 ? 0.0 : 1.0
            shouldFragmentBeMirrored = currentSegmentPercent > 0.5
            hasFragmentOverscroll = false
            shouldFinishSegment = false
        }

        if prevPercent < 0.5 && currentSegmentPercent >= 0.5 {
            // Flip by increase, next fragment should be mirrored
            // Just increment segment if there is no overscroll
            if currentSegmentIndex + 1 < animationViews.count && !hasFragmentOverscroll {
                currentSegmentIndex += 1
                shouldFragmentBeMirrored = true
            } else {
                hasFragmentOverscroll = true
            }
        } else if prevPercent > 0.5 && currentSegmentPercent <= 0.5 {
            // Flip by decrease, previous fragment should not be mirrored
            if currentSegmentIndex - 1 >= 0 && !hasFragmentOverscroll {
                currentSegmentIndex -= 1
                shouldFragmentBeMirrored = false
            } else {
                hasFragmentOverscroll = true
            }
        }

        // Layer transformation
        var transform = CATransform3DIdentity
        transform.m34 = 1.0 / -800

        let angle = (hasFragmentOverscroll ? CGFloat.pi : 0) + (-CGFloat.pi * CGFloat(currentSegmentPercent))
        currentView?.layer.transform = CATransform3DRotate(transform, angle, 0.0, 1.0, 0.0)

        prevPercent = currentSegmentPercent

        if didInteractionFinished {
            shouldFinishSegment = true
        }

        if (currentSegmentPercent >= 0.99 || currentSegmentPercent <= 0.1) && shouldFinishSegment {
            currentView?.animationProgress = 0.0
            currentView?.play()
            shouldFinishSegment = false

            // Control can skip some data -> prevent unsync
            var calculatedPage = Int(round(percent))
            if calculatedPage != currentSegmentIndex {
                // Prevent overscroll or invalid data
                calculatedPage = min(max(calculatedPage, 0), animationViews.count - 1)
                flip(to: calculatedPage)
            }
        }
    }

    func flip(to segmentIndex: Int) {
        transitionToSegment(from: currentSegmentIndex, to: segmentIndex, next: segmentIndex > currentSegmentIndex)
        currentSegmentIndex = segmentIndex
    }

    private func transitionToSegment(from fromIndex: Int, to toIndex: Int, next: Bool = true) {
        guard fromIndex != toIndex else {
            return
        }

        let fView = animationViews[fromIndex]
        let sView = animationViews[toIndex]

        fView.layer.transform = CATransform3DIdentity
        sView.layer.transform = CATransform3DIdentity

        sView.isHidden = false
        UIView.transition(from: fView, to: sView, duration: autoFlipAnimationDuration, options: next ? .transitionFlipFromLeft : .transitionFlipFromRight, completion: { _ in
            fView.isHidden = true
            sView.animationProgress = 0.0
            sView.play()
        })
    }

}

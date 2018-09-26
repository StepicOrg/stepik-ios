//
//  SwipeInteractionController.swift
//  Stepic
//
//  Created by Ostrenkiy on 13.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class SwipeInteractionController: UIPercentDrivenInteractiveTransition {
    var interactionInProgress = false

    private var shouldCompleteTransition = false
    private weak var viewController: UIViewController!
    private var onFinish: (() -> Void)?

    init(viewController: UIViewController, onFinish: (() -> Void)?) {
        super.init()
        self.viewController = viewController
        self.onFinish = onFinish
        prepareGestureRecognizer(in: viewController.view)
    }

    private func prepareGestureRecognizer(in view: UIView) {
        let gesture = UIPanGestureRecognizer(target: self,
                                                       action: #selector(handleGesture(_:)))
        view.addGestureRecognizer(gesture)
        gesture.delegate = self
    }

    @objc func handleGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let superView = gestureRecognizer.view?.superview else {
            return
        }
        let translation = gestureRecognizer.translation(in: superView)
        var progress = translation.y / 400
        progress = min(max(CGFloat(progress), 0.0), 1.0)

        switch gestureRecognizer.state {

        case .began:
            interactionInProgress = true
            viewController.dismiss(animated: true, completion: nil)

        case .changed:
            shouldCompleteTransition = progress > 0.35
            update(progress)

        case .cancelled:
            interactionInProgress = false
            cancel()

        case .ended:
            interactionInProgress = false
            if shouldCompleteTransition {
                finish()
                onFinish?()
            } else {
                cancel()
            }
        default:
            break
        }
    }
}

extension SwipeInteractionController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let pan = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = pan.translation(in: pan.view)
            let angle = atan2(translation.y, translation.x)
            return abs(angle - .pi / 2.0) < (.pi / 8.0)
        }
        return false
    }
}

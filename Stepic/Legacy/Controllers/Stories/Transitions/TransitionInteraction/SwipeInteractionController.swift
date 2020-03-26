//
//  SwipeInteractionController.swift
//  Stepic
//
//  Created by Ostrenkiy on 13.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class SwipeInteractionController: UIPercentDrivenInteractiveTransition {
    var interactionInProgress = false

    private var shouldCompleteTransition = false
    private weak var viewController: UIViewController!
    private var onFinish: (() -> Void)?

    init(viewController: UIViewController, onFinish: (() -> Void)?) {
        super.init()

        self.viewController = viewController
        self.onFinish = onFinish

        self.prepareGestureRecognizer(in: viewController.view)
    }

    private func prepareGestureRecognizer(in view: UIView) {
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handleGesture(_:)))
        view.addGestureRecognizer(gestureRecognizer)
        gestureRecognizer.delegate = self
    }

    @objc
    private func handleGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let superView = gestureRecognizer.view?.superview else {
            return
        }

        let translation = gestureRecognizer.translation(in: superView)
        var progress = translation.y / 400
        progress = min(max(CGFloat(progress), 0.0), 1.0)

        switch gestureRecognizer.state {
        case .began:
            self.interactionInProgress = true
            self.viewController.dismiss(animated: true, completion: nil)
        case .changed:
            self.shouldCompleteTransition = progress > 0.35
            self.update(progress)
        case .cancelled:
            self.interactionInProgress = false
            self.cancel()
        case .ended:
            self.interactionInProgress = false
            if self.shouldCompleteTransition {
                self.finish()
                self.onFinish?()
            } else {
                self.cancel()
            }
        default:
            break
        }
    }
}

extension SwipeInteractionController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translation(in: panGestureRecognizer.view)
            let angle = atan2(translation.y, translation.x)
            return abs(angle - .pi / 2.0) < (.pi / 8.0)
        }
        return false
    }
}

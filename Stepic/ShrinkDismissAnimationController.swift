//
//  ShrinkDismissAnimationController.swift
//  Stepic
//
//  Created by Ostrenkiy on 13.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class ShrinkDismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    let interactionController: SwipeInteractionController?

    private let destinationFrame: CGRect

    init(destinationFrame: CGRect, interactionController: SwipeInteractionController?) {
        self.destinationFrame = destinationFrame
        self.interactionController = interactionController
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let toVC = transitionContext.viewController(forKey: .to),
            let fromVC = transitionContext.viewController(forKey: .from),
            let snapshot = fromVC.view.snapshotView(afterScreenUpdates: true)
            else {
                return
        }

        let containerView = transitionContext.containerView

        snapshot.frame = fromVC.view.frame
        snapshot.layer.masksToBounds = true
        snapshot.layer.cornerRadius = 0
        fromVC.view.isHidden = true

        containerView.addSubview(snapshot)

        let duration = transitionDuration(using: transitionContext)

        UIView.animate(withDuration: duration, animations: {
            snapshot.frame = self.destinationFrame
            snapshot.alpha = 0
            snapshot.layer.cornerRadius = 16
        }, completion: {
            _ in
            fromVC.view.isHidden = false
            snapshot.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}

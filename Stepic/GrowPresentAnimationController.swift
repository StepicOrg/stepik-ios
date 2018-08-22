//
//  GrowPresentAnimationController.swift
//  Stepic
//
//  Created by Ostrenkiy on 13.08.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class GrowPresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    private let originFrame: CGRect

    init(originFrame: CGRect) {
        self.originFrame = originFrame
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to) else {
                return
        }

        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toVC)

        toVC.view.frame = originFrame
        toVC.view.layer.masksToBounds = true
        toVC.view.alpha = 0

        containerView.addSubview(toVC.view)
        let duration = transitionDuration(using: transitionContext)

        UIView.animate(withDuration: duration, animations: {
            toVC.view.frame = finalFrame
            toVC.view.layoutSubviews()
            toVC.view.alpha = 1
        }, completion: {
            _ in
            toVC.view.alpha = 1
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }

}

//
//  StyledNavigationViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 03.09.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import FLKAutoLayout

class StyledNavigationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setupShadowView()
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setStatusBarStyle()
        navigationBar.barTintColor = UIColor.mainLight
        navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationBar.shadowImage = UIImage()
        navigationBar.isTranslucent = false
        let fontSize: CGFloat = 17.0
        let titleFont = UIFont.systemFont(ofSize: fontSize, weight: UIFontWeightRegular)
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.mainDark, NSFontAttributeName: titleFont]
        navigationBar.tintColor = UIColor.mainDark
    }

    func setStatusBarStyle() {
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
    }

    var customShadowView: UIView?
    var customShadowTrailing: NSLayoutConstraint?
    var customShadowLeading: NSLayoutConstraint?

    func setupShadowView() {
        let v = UIView()
        navigationBar.addSubview(v)
        v.backgroundColor = UIColor.lightGray
        _ = v.constrainHeight("0.5")
        _ = v.alignBottomEdge(withView: navigationBar, predicate: "0.5")
        self.customShadowLeading = v.alignLeadingEdge(withView: navigationBar, predicate: "0")
        self.customShadowTrailing = v.alignTrailingEdge(withView: navigationBar, predicate: "0")
        customShadowView = v
        customShadowView?.alpha = 1
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: {
            [weak self]
            _ in
            self?.navigationBar.layoutSubviews()
            }, completion: nil)
    }

    func animateShadowChange(for presentedController: UIViewController) {
        guard let coordinator = topViewController?.transitionCoordinator else {
            return
        }

        //Detect, if animation moves inside our controller
        let inside: Bool = topViewController == presentedController

        //Hide shadow view, if we are moving inside
        var targetAlpha: CGFloat = 1
        if inside {
            targetAlpha = 0
        }

        //Saving previous values in case animation is not completed
        let prevTrailing: CGFloat = customShadowTrailing?.constant ?? 0
        let prevLeading: CGFloat = customShadowLeading?.constant ?? 0

        //Initializing animation values
        if lastAction == .push && inside {
            //leading: 0, <- trailing
            customShadowLeading?.constant = 0
            customShadowTrailing?.constant = 0
            navigationBar.layoutSubviews()
            customShadowTrailing?.constant = -navigationBar.frame.width
        }
        if lastAction == .push && !inside {
            // 0 <- leading, trailing: 0
            customShadowLeading?.constant = navigationBar.frame.width
            customShadowTrailing?.constant = 0
            navigationBar.layoutSubviews()
            customShadowLeading?.constant = 0
        }
        if lastAction == .pop && inside {
            //leading -> trailing: 0
            customShadowLeading?.constant = 0
            customShadowTrailing?.constant = 0
            navigationBar.layoutSubviews()
            customShadowLeading?.constant = navigationBar.frame.width
        }
        if lastAction == .pop && !inside {
            //leading: 0, trailing -> 0
            customShadowLeading?.constant = 0
            customShadowTrailing?.constant = -navigationBar.frame.width
            navigationBar.layoutSubviews()
            customShadowTrailing?.constant = 0
        }

        //Animate alongside push/pop transition
        coordinator.animate(alongsideTransition: {
            [weak self]
            _ in
            self?.navigationBar.layoutSubviews()
            self?.customShadowView?.alpha = targetAlpha
        }, completion: {
            [weak self]
            coordinator in
            if coordinator.isCancelled {
                self?.customShadowTrailing?.constant = prevTrailing
                self?.customShadowLeading?.constant = prevLeading
                self?.navigationBar.layoutSubviews()
            }
        })
    }

    var lastAction: NavigationAction = .push

    override func popViewController(animated: Bool) -> UIViewController? {
        lastAction = .pop
        return super.popViewController(animated: animated)
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        lastAction = .push
        super.pushViewController(viewController, animated: animated)
    }
}

enum NavigationAction {
    case push, pop
}

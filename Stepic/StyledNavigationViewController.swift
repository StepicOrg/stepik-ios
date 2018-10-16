//
//  StyledNavigationViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 03.09.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

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
        let titleFont = UIFont.systemFont(ofSize: fontSize, weight: UIFont.Weight.regular)
        navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.mainDark, NSAttributedStringKey.font: titleFont]
        navigationBar.tintColor = UIColor.mainDark
    }

    func setStatusBarStyle() {
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
    }

    var customShadowView: UIView?
    var customShadowTrailing: Constraint?
    var customShadowLeading: Constraint?

    func setupShadowView() {
        let v = UIView()
        navigationBar.addSubview(v)
        v.backgroundColor = UIColor.lightGray

        v.snp.makeConstraints { make -> Void in
            make.height.equalTo(0.5)
            make.bottom.equalTo(navigationBar).offset(0.5)

            self.customShadowLeading = make.leading.equalTo(navigationBar).constraint
            self.customShadowTrailing = make.trailing.equalTo(navigationBar).constraint
        }

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

    func changeShadowAlpha(_ alpha: CGFloat) {
        navigationBar.layoutSubviews()
        customShadowView?.alpha = alpha
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
        let prevTrailing: CGFloat = customShadowTrailing?.layoutConstraints.first?.constant ?? 0
        let prevLeading: CGFloat = customShadowLeading?.layoutConstraints.first?.constant ?? 0

        //Initializing animation values
        if lastAction == .push && inside {
            //leading: 0, <- trailing
            customShadowLeading?.update(offset: 0)
            customShadowTrailing?.update(offset: 0)
            navigationBar.layoutSubviews()
            customShadowTrailing?.update(offset: -navigationBar.frame.width)
        }
        if lastAction == .push && !inside {
            // 0 <- leading, trailing: 0
            customShadowLeading?.update(offset: navigationBar.frame.width)
            customShadowTrailing?.update(offset: 0)
            navigationBar.layoutSubviews()
            customShadowLeading?.update(offset: 0)
        }
        if lastAction == .pop && inside {
            //leading -> trailing: 0
            customShadowLeading?.update(offset: 0)
            customShadowTrailing?.update(offset: 0)
            navigationBar.layoutSubviews()
            customShadowLeading?.update(offset: navigationBar.frame.width)
        }
        if lastAction == .pop && !inside {
            //leading: 0, trailing -> 0
            customShadowLeading?.update(offset: 0)
            customShadowTrailing?.update(offset: -navigationBar.frame.width)
            navigationBar.layoutSubviews()
            customShadowTrailing?.update(offset: 0)
        }

        //Animate alongside push/pop transition
        coordinator.animate(alongsideTransition: {
            [weak self]
            _ in
            self?.changeShadowAlpha(targetAlpha)
        }, completion: {
            [weak self]
            coordinator in
            if coordinator.isCancelled {
                self?.customShadowTrailing?.update(offset: prevTrailing)
                self?.customShadowLeading?.update(offset: prevLeading)
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

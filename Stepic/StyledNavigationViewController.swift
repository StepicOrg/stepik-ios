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
        _ = v.alignBottomEdge(with: navigationBar, predicate: "0.5")
        self.customShadowLeading = v.alignLeadingEdge(with: navigationBar, predicate: "0").first as? NSLayoutConstraint
        self.customShadowTrailing = v.alignTrailingEdge(with: navigationBar, predicate: "0").first as? NSLayoutConstraint
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

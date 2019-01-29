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
    static let backgroundColor = UIColor.mainLight
    static let lightTintColor = UIColor.white
    static let darkTintColor = UIColor.mainDark

    private var currentShadowAlpha: CGFloat {
        return self.customShadowView?.alpha ?? 0
    }

    private lazy var statusBarView: UIView = {
        let view = UIView(frame: UIApplication.shared.statusBarFrame)
        view.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
        return view
    }()

    private lazy var titleFont: UIFont = {
        let fontSize: CGFloat = 17.0
        let titleFont = UIFont.systemFont(ofSize: fontSize, weight: UIFont.Weight.regular)
        return titleFont
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(statusBarView)

        setupShadowView()
        // Do any additional setup after loading the view.
    }

    func hideBackButtonTitle() {
        // Search for controller before last in stack
        if let parentViewController = self.viewControllers.dropLast().last {
            parentViewController.navigationItem.backBarButtonItem = UIBarButtonItem(
                title: "",
                style: .plain,
                target: nil,
                action: nil
            )
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setStatusBarStyle()
        changeNavigationBarAlpha(1.0)
        changeTitleAlpha(1.0)

        navigationBar.tintColor = StyledNavigationViewController.darkTintColor
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
            self?.statusBarView.frame = UIApplication.shared.statusBarFrame
        }, completion: nil)
    }

    func changeNavigationBarAlpha(_ alpha: CGFloat) {
        let color = StyledNavigationViewController.backgroundColor
            .withAlphaComponent(alpha)

        navigationBar.isTranslucent = true
        navigationBar.backgroundColor = color
        navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationBar.shadowImage = UIImage()

        statusBarView.backgroundColor = color
    }

    func changeTintColor(progress: CGFloat) {
        navigationBar.tintColor = self.makeTransitionColor(
            from: StyledNavigationViewController.lightTintColor,
            to: StyledNavigationViewController.darkTintColor,
            progress: progress
        )
    }

    func changeShadowAlpha(_ alpha: CGFloat) {
        navigationBar.layoutSubviews()
        customShadowView?.alpha = alpha
    }

    func changeTitleAlpha(_ alpha: CGFloat) {
        self.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.font: self.titleFont,
            NSAttributedStringKey.foregroundColor: UIColor.mainDark.withAlphaComponent(alpha)
        ]
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

        guard targetAlpha != self.currentShadowAlpha else {
            return
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
        let poppedViewController = super.popViewController(animated: animated)
        self.resetAlphaAppearance(viewController: poppedViewController, animated: animated)
        return poppedViewController
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        lastAction = .push
        self.resetAlphaAppearance(viewController: viewController, animated: animated)
        super.pushViewController(viewController, animated: animated)
    }

    private func resetAlphaAppearance(viewController: UIViewController?, animated: Bool) {
        self.changeTitleAlpha(1.0)
        self.changeNavigationBarAlpha(1.0)
        self.changeTintColor(progress: 1.0)

        if let viewController = viewController, animated {
            self.animateShadowChange(for: viewController)
        } else {
            self.changeShadowAlpha(1.0)
        }
    }

    private func makeTransitionColor(from sourceColor: UIColor, to targetColor: UIColor, progress: CGFloat) -> UIColor {
        let percentage = max(min(progress, 1), 0)

        var fRed: CGFloat = 0
        var fBlue: CGFloat = 0
        var fGreen: CGFloat = 0
        var fAlpha: CGFloat = 0

        var tRed: CGFloat = 0
        var tBlue: CGFloat = 0
        var tGreen: CGFloat = 0
        var tAlpha: CGFloat = 0

        sourceColor.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha)
        targetColor.getRed(&tRed, green: &tGreen, blue: &tBlue, alpha: &tAlpha)

        let red: CGFloat = (percentage * (tRed - fRed)) + fRed
        let green: CGFloat = (percentage * (tGreen - fGreen)) + fGreen
        let blue: CGFloat = (percentage * (tBlue - fBlue)) + fBlue
        let alpha: CGFloat = (percentage * (tAlpha - fAlpha)) + fAlpha

        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

enum NavigationAction {
    case push, pop
}

//
//  AuthNavigationViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 01.09.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

final class AuthNavigationViewController: UINavigationController {
    private let streaksAlertPresentationManager = StreaksAlertPresentationManager(source: .login)
    private let notificationSuggestionManager = NotificationSuggestionManager()
    private let userActivitiesAPI = UserActivitiesAPI()
    private let splitTestingService: SplitTestingServiceProtocol = SplitTestingService(
        analyticsService: AnalyticsUserProperties(),
        storage: UserDefaults.standard
    )

    enum Controller {
        case social
        case email(email: String?)
        case registration
    }

    weak var source: UIViewController? {
        didSet {
            streaksAlertPresentationManager.controller = source
        }
    }
    var success: (() -> Void)?
    var cancel: (() -> Void)?

    var canDismiss = true

    override func viewDidLoad() {
        super.viewDidLoad()
        streaksAlertPresentationManager.controller = source
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), for: .default)
    }

    private func checkStreaksNotifications() {
        guard let userId = AuthInfo.shared.userId else {
            return
        }

        if SubscribeNotificationsOnLaunchSplitTest.shouldParticipate {
            let subscribeSplitTest = self.splitTestingService.fetchSplitTest(
                SubscribeNotificationsOnLaunchSplitTest.self
            )
            if !subscribeSplitTest.currentGroup.shouldShowOnFirstLaunch {
                self.suggestStreakForUserWithId(userId)
            }
        } else {
            self.suggestStreakForUserWithId(userId)
        }
    }

    private func suggestStreakForUserWithId(_ userId: Int) {
        self.userActivitiesAPI.retrieve(user: userId).done { userActivity in
            let canShowAlert = self.notificationSuggestionManager.canShowAlert(
                context: .streak,
                after: .login
            )
            if canShowAlert && userActivity.didSolveThisWeek {
                self.streaksAlertPresentationManager.suggestStreak(
                    streak: userActivity.currentStreak
                )
            }
        }.catch { error in
            print("\(#file) \(#function) \(error)")
        }
    }

    // Maybe create Router layer?
    func dismissAfterSuccess() {
        checkStreaksNotifications()
        self.dismiss(animated: true, completion: { [weak self] in
            self?.success?()
        })
    }

    func route(from fromController: Controller, to toController: Controller?) {
        if toController == nil {
            // Close action
            switch fromController {
            case .registration:
                popViewController(animated: true)
            default:
                if canDismiss {
                    dismiss(animated: true, completion: { [weak self] in
                        self?.cancel?()
                    })
                }
            }

            return
        }

        var vcs = viewControllers

        switch toController! {
        case .registration:
            // Push registration controller
            let vc = ControllerHelper.instantiateViewController(identifier: "Registration", storyboardName: "Auth")
            pushViewController(vc, animated: true)
        case .email(let email):
            // Replace top view controller
            let vc = ControllerHelper.instantiateViewController(identifier: "EmailAuth", storyboardName: "Auth")
            if let vc = vc as? EmailAuthViewController {
                vc.prefilledEmail = email
                vcs[vcs.count - 1] = vc
                setViewControllers(vcs, animated: true)
            }
        case .social:
            // Replace top view controller
            vcs[vcs.count - 1] = ControllerHelper.instantiateViewController(identifier: "SocialAuth", storyboardName: "Auth")
            setViewControllers(vcs, animated: true)
        }
    }

    // Disable landscape for iPhones with diagonal <= 4.7
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return DeviceInfo.current.diagonal > 4.7 ? .all : .portrait
    }

    override var shouldAutorotate: Bool {
        return DeviceInfo.current.diagonal > 4.7
    }
}

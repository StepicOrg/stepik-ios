//
//  AuthNavigationViewController.swift
//  Stepic
//
//  Created by Alexander Karpov on 01.09.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit

final class AuthNavigationViewController: UINavigationController {

    var streaksAlertPresentationManager = StreaksAlertPresentationManager(source: .login)
    var streaksNotificationSuggestionManager = NotificationSuggestionManager()

    weak var source: UIViewController? {
        didSet {
            streaksAlertPresentationManager.controller = source
        }
    }
    var success: (() -> Void)?
    var cancel: (() -> Void)?

    lazy var router: AuthRouter = {
        AuthRouter(navigationController: self, delegate: self)
    }()

    // Disable landscape for iPhones with diagonal <= 4.7
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return DeviceInfo.current.diagonal > 4.7 ? .all : .portrait
    }

    override var shouldAutorotate: Bool {
        return DeviceInfo.current.diagonal > 4.7
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        streaksAlertPresentationManager.controller = source
        navigationBar.shadowImage = UIImage()
        navigationBar.setBackgroundImage(UIImage(), for: .default)

        if let topViewController = topViewController as? SocialAuthViewController {
            topViewController.delegate = router
            topViewController.presenter = SocialAuthPresenter(authAPI: ApiDataDownloader.auth, stepicsAPI: ApiDataDownloader.stepics, notificationStatusesAPI: NotificationStatusesAPI(), view: topViewController)
        }
    }

    private func checkStreaksNotifications() {
        guard let userId = AuthInfo.shared.userId else {
            return
        }
        let userActivitiesAPI = UserActivitiesAPI()
        checkToken().then {
            userActivitiesAPI.retrieve(user: userId)
        }.done { userActivity -> Void in
            if userActivity.didSolveThisWeek && self.streaksNotificationSuggestionManager.canShowAlert(context: .streak, after: .login) {
                self.streaksNotificationSuggestionManager.didShowAlert(context: .streak)
                self.streaksAlertPresentationManager.suggestStreak(streak: userActivity.currentStreak)
            }
        }
    }
}

// MARK: - AuthNavigationViewController: AuthRouterDelegate -

extension AuthNavigationViewController: AuthRouterDelegate {
    func authRouterWillStartDismiss(_ authRouter: AuthRouter, withState state: AuthRouter.State) {
        switch state {
        case .success:
            checkStreaksNotifications()
        case .cancel:
            break
        }
    }

    func authRouterDidEndDismiss(_ authRouter: AuthRouter, withState state: AuthRouter.State) {
        switch state {
        case .success:
            success?()
        case .cancel:
            cancel?()
        }
    }
}

//
//  NotificationAlertConstructor.swift
//  Stepic
//
//  Created by Alexander Karpov on 02.05.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import UIKit
import CRToast

class NotificationAlertConstructor {
    fileprivate init() {}
    static let sharedConstructor = NotificationAlertConstructor()

    func getNotificationAlertController() -> UIAlertController {
        let alert = UIAlertController(title: NSLocalizedString("EnableNotificationsTitle", comment: ""), message: NSLocalizedString("EnableNotificationsMessage", comment: ""), preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: {
            _ in
            NotificationRegistrator.shared.registerForRemoteNotifications(UIApplication.shared)
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("Later", comment: ""), style: .cancel, handler: {
            _ in
        }))

        return alert
    }

    func getOpenCommentNotificationViaSafariAlertController(_ success: @escaping (() -> Void)) -> UIAlertController {
        let alert = UIAlertController(title: NSLocalizedString("NewCommentAlertTitle", comment: ""), message: NSLocalizedString("NewCommentAlertMessage", comment: ""), preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: NSLocalizedString("Yes", comment: ""), style: .default, handler: {
            _ in
            success()
        }))

        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: {
            _ in
        }))

        return alert
    }

    func presentStreakNotificationFake(_ text: String, subtitleText: String, success: @escaping (() -> Void)) {
        let responder = CRToastInteractionResponder(interactionType: CRToastInteractionType.tap, automaticallyDismiss: true, block: {
                _ in
                success()
            }
        )

        let toastOptions: [AnyHashable: Any] = [
            kCRToastImageKey: Images.streak.white,
            kCRToastTextKey: text,
            kCRToastSubtitleTextKey: subtitleText,
            kCRToastTextAlignmentKey: NSTextAlignment.left,
            kCRToastSubtitleTextAlignmentKey: NSTextAlignment.left,
            kCRToastSubtitleTextColorKey: UIColor.lightGray,
            kCRToastNotificationTypeKey: NSNumber(value: CRToastType.navigationBar.rawValue),
            kCRToastNotificationPresentationTypeKey: NSNumber(value: CRToastPresentationType.cover.rawValue),
            kCRToastUnderStatusBarKey: true,
            kCRToastAnimationInTypeKey: NSNumber(value: CRToastAnimationType.gravity.rawValue),
            kCRToastAnimationOutTypeKey: NSNumber(value: CRToastAnimationType.gravity.rawValue),
            kCRToastAnimationInDirectionKey: NSNumber(value: CRToastAnimationDirection.top.rawValue),
            kCRToastAnimationOutDirectionKey: NSNumber(value: CRToastAnimationDirection.top.rawValue),
            kCRToastAnimationInTimeIntervalKey: 0.3,
            kCRToastTimeIntervalKey: NSNumber(value: 10.0),
            kCRToastAnimationOutTimeIntervalKey: 0.3,
            kCRToastSubtitleTextMaxNumberOfLinesKey: 3,
            kCRToastTextMaxNumberOfLinesKey: 3,
            kCRToastImageContentModeKey: NSNumber(value: UIViewContentMode.scaleAspectFit.rawValue),
            kCRToastBackgroundColorKey: UIColor.black,
            kCRToastInteractionRespondersKey: [responder]
        ]

        CRToastManager.showNotification(options: toastOptions) {
            print("show notification completed!")
        }
    }

    func presentNotificationFake(_ text: String, success: @escaping (() -> Void)) {

        let responder = CRToastInteractionResponder(interactionType: CRToastInteractionType.tap, automaticallyDismiss: true, block: {
                _ in
                success()
            }
        )

        let toastOptions: [AnyHashable: Any] = [
            kCRToastImageKey: Images.boundedStepicIcon,
            kCRToastTextKey: text,
            kCRToastNotificationTypeKey: NSNumber(value: CRToastType.navigationBar.rawValue),
            kCRToastNotificationPresentationTypeKey: NSNumber(value: CRToastPresentationType.cover.rawValue),
            kCRToastUnderStatusBarKey: true,
            kCRToastAnimationInTypeKey: NSNumber(value: CRToastAnimationType.gravity.rawValue),
            kCRToastAnimationOutTypeKey: NSNumber(value: CRToastAnimationType.gravity.rawValue),
            kCRToastAnimationInDirectionKey: NSNumber(value: CRToastAnimationDirection.top.rawValue),
            kCRToastAnimationOutDirectionKey: NSNumber(value: CRToastAnimationDirection.top.rawValue),
            kCRToastAnimationInTimeIntervalKey: 0.3,
            kCRToastTimeIntervalKey: 5.0,
            kCRToastAnimationOutTimeIntervalKey: 0.3,
            kCRToastTextMaxNumberOfLinesKey: 2,
            kCRToastImageContentModeKey: NSNumber(value: UIViewContentMode.scaleAspectFit.rawValue),
            kCRToastBackgroundColorKey: UIColor.black,
            kCRToastInteractionRespondersKey: [responder]
        ]

        CRToastManager.showNotification(options: toastOptions) {
            print("show notification completed!")
        }

    }
}

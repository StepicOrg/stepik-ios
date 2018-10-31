//
//  NotificationsRegistrationServiceProtocol.swift
//  Stepic
//
//  Created by Ivan Magda on 26/10/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

/// The centralized point for registration with Apple Push Notifications service (APNs).
protocol NotificationsRegistrationServiceProtocol: class {
    /// A set of methods that are called by the instance of the
    /// `NotificationsRegistrationServiceProtocol` object in response to lifetime events.
    var delegate: NotificationsRegistrationServiceDelegate? { get set }

    /// Responsible for custom alerts presentation.
    ///
    /// There are two types of alerts that may be presented:
    /// - permission
    /// - settings
    ///
    /// See `NotificationsRegistrationServiceAlertType`.
    var presenter: NotificationsRegistrationPresentationServiceProtocol? { get set }

    /// Register to receive remote notifications via APNs.
    /// Registration process with APNs will start only when user has already granted permissions.
    /// Call this method each time when app launches.
    func renewDeviceToken()

    /// Register to receive remote notifications via APNs.
    /// Call this method to initiate the registration process with Apple Push Notification service.
    func registerForRemoteNotifications()

    /// Tells that the app successfully registered with Apple Push Notification service (APNs).
    ///
    /// - Parameter deviceToken: A globally unique token that identifies this device to APNs.
    func handleDeviceToken(_ deviceToken: Data)

    /// Tells that Apple Push Notification service cannot successfully complete the registration process.
    ///
    /// - Parameter error: Encapsulates information why registration did not succeed.
    func handleRegistrationError(_ error: Error)

    /// Tells that the types of local and remote notifications that can be used to get the user’s attention.
    ///
    /// - Parameter notificationSettings: The user’s specified notification settings.
    func handleRegisteredNotificationSettings(_ notificationSettings: UIUserNotificationSettings)

    /// Register the device with our notification provider server.
    ///
    /// - Parameters:
    ///   - registrationToken: An Firebase Messaging scoped token for the firebase app.
    ///   - forceCreation: Controls whether to create a new device instance or get cached one.
    func registerDevice(_ registrationToken: String, forceCreation: Bool)
}

extension NotificationsRegistrationServiceProtocol {
    func registerDevice(_ registrationToken: String) {
        self.registerDevice(registrationToken, forceCreation: false)
    }
}

/// Represents types of alerts that may be presented by the presenter.
///
/// - permission: Custom alert for asking some kind of permission from the user
/// (Remote notifications, streak notifications, personal deadlines).
/// - settings: Custom alert that prompts user to go to the application settings to enable notifications.
enum NotificationsRegistrationServiceAlertType {
    case permission
    case settings
}

/// The presentation layer of the notifications registration service.
/// It's responsible for preparation and presentations of the custom alerts.
protocol NotificationsRegistrationPresentationServiceProtocol {
    var onPositiveCallback: (() -> Void)? { get set }
    var onCancelCallback: (() -> Void)? { get set }

    /// The main point for presenting custom alerts.
    ///
    /// - Parameters:
    ///   - alertType: The purpose of presenting: `settings` or `permission`. (See `NotificationsRegistrationServiceAlertType`)
    ///   - controller: From view controller to present.
    func presentAlert(
        for alertType: NotificationsRegistrationServiceAlertType,
        inController controller: UIViewController
    )
}

/// The delegate of a `NotificationsRegistrationServiceProtocol` object must adopt the `NotificationsRegistrationServiceDelegate` protocol.
/// Methods of the protocol allow the delegate to manage presenting alerts and respond to the lifetime events.
protocol NotificationsRegistrationServiceDelegate: class {
    /// Asks the delegate if the alert should be shown.
    ///
    /// - Parameters:
    ///   - notificationsRegistrationService: The NotificationsRegistrationService object that is making this request.
    ///   - alertType: An type of the alert that was requested.
    /// - Returns: `true` if the notificationsRegistrationService should show alert, otherwise false. The default value is true.
    func notificationsRegistrationService(
        _ notificationsRegistrationService: NotificationsRegistrationServiceProtocol,
        shouldPresentAlertFor alertType: NotificationsRegistrationServiceAlertType
    ) -> Bool

    /// Tells the delegate that the alert is now was presented and now should be visible.
    ///
    /// - Parameters:
    ///   - notificationsRegistrationService: The NotificationsRegistrationService object informing the delegate about the alert presenting.
    ///   - alertType: An type of the alert that was presented.
    func notificationsRegistrationService(
        _ notificationsRegistrationService: NotificationsRegistrationServiceProtocol,
        didPresentAlertFor alertType: NotificationsRegistrationServiceAlertType
    )

    /// Tells the delegate that the app successfully registered with Apple Push Notification service (APNs).
    ///
    /// - Parameter notificationsRegistrationService: The NotificationsRegistrationService object informing the delegate about the registration status.
    func notificationsRegistrationServiceDidSuccessfullyRegisterWithAPNs(
        _ notificationsRegistrationService: NotificationsRegistrationServiceProtocol
    )

    /// Tells the delegate when Apple Push Notification service cannot successfully complete the registration process.
    ///
    /// - Parameters:
    ///   - notificationsRegistrationService: The NotificationsRegistrationService object informing the delegate about the registration status.
    ///   - error: An `Error` object that encapsulates information why registration did not succeed.
    func notificationsRegistrationServiceDidFailRegisterWithAPNs(
        _ notificationsRegistrationService: NotificationsRegistrationServiceProtocol,
        error: Error
    )
}

extension NotificationsRegistrationServiceDelegate {
    func notificationsRegistrationService(
        _ notificationsRegistrationService: NotificationsRegistrationServiceProtocol,
        shouldPresentAlertFor alertType: NotificationsRegistrationServiceAlertType
    ) -> Bool {
        return true
    }

    func notificationsRegistrationService(
        _ notificationsRegistrationService: NotificationsRegistrationServiceProtocol,
        didPresentAlertFor alertType: NotificationsRegistrationServiceAlertType
    ) {
    }

    func notificationsRegistrationServiceDidSuccessfullyRegisterWithAPNs(
        _ notificationsRegistrationService: NotificationsRegistrationServiceProtocol
    ) {
    }

    func notificationsRegistrationServiceDidFailRegisterWithAPNs(
        _ notificationsRegistrationService: NotificationsRegistrationServiceProtocol,
        error: Error
    ) {
    }
}

// MARK: - NotificationsRegistrationServiceProtocol (NotificationCenter) -

extension Foundation.Notification.Name {
    static let notificationsRegistrationServiceDidUpdatePermissionStatus = Foundation.Notification
        .Name("notificationsRegistrationServiceDidUpdatePermissionStatus")
}

extension NotificationsRegistrationServiceProtocol {
    func postCurrentPermissionStatus() {
        NotificationPermissionStatus.current.done { status in
            NotificationCenter.default.post(
                name: .notificationsRegistrationServiceDidUpdatePermissionStatus,
                object: status
            )
        }
    }
}

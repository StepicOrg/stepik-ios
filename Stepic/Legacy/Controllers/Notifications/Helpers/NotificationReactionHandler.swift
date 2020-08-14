//
//  NotificationReactionHandler.swift
//  Stepic
//
//  Created by Alexander Karpov on 13.05.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

final class NotificationReactionHandler {
    private let userAccountService: UserAccountServiceProtocol

    init(userAccountService: UserAccountServiceProtocol = UserAccountService()) {
        self.userAccountService = userAccountService
    }

    func handle(with notification: Notification) {
        guard self.userAccountService.isAuthorized else {
            return
        }

        if notification.action == .issuedCertificate,
           let currentUserID = self.userAccountService.currentUserID {
            let route = DeepLinkRoute.certificates(userID: currentUserID)
            DeepLinkRoutingService().route(route, fallbackPath: route.path)
        } else {
            let deepLinkRoutingService = DeepLinkRoutingService(courseViewSource: .notification)

            switch notification.type {
            case .comments:
                deepLinkRoutingService.route(.notifications(section: .comments))
            case .learn:
                deepLinkRoutingService.route(.notifications(section: .learning))
            case .default:
                deepLinkRoutingService.route(.notifications(section: .all))
            case .review:
                deepLinkRoutingService.route(.notifications(section: .reviews))
            case .teach:
                deepLinkRoutingService.route(.notifications(section: .teaching))
            }
        }
    }
}

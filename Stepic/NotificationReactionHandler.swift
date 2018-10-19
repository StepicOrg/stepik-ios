//
//  NotificationReactionHandler.swift
//  Stepic
//
//  Created by Alexander Karpov on 13.05.16.
//  Copyright © 2016 Alex Karpov. All rights reserved.
//

import Foundation

final class NotificationReactionHandler {
    func handle(with notification: Notification) {
        if !AuthInfo.shared.isAuthorized {
            return
        }

        if notification.action == .issuedCertificate {
            return TabBarRouter(tab: .certificates).route()
        }

        switch notification.type {
        case .comments:
            DeepLinkRoutingService().route(.notifications(section: .comments))
        case .learn:
            DeepLinkRoutingService().route(.notifications(section: .learning))
        case .default:
            DeepLinkRoutingService().route(.notifications(section: .all))
        case .review:
            DeepLinkRoutingService().route(.notifications(section: .reviews))
        case .teach:
            DeepLinkRoutingService().route(.notifications(section: .teaching))
        }
    }
}

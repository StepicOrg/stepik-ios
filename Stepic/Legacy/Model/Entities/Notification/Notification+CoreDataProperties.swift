//
//  Notification+CoreDataProperties.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 26.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import CoreData
import Foundation

extension Notification {
    @NSManaged public var managedId: NSNumber?
    @NSManaged public var managedStatus: String?
    @NSManaged public var managedIsMuted: NSNumber?
    @NSManaged public var managedIsFavorite: NSNumber?
    @NSManaged public var managedTime: Date?
    @NSManaged public var managedType: String?
    @NSManaged public var managedAction: String?
    @NSManaged public var managedLevel: String?
    @NSManaged public var managedPriority: String?
    @NSManaged public var managedHtmlText: String?

    static var oldEntity: NSEntityDescription {
        NSEntityDescription.entity(forEntityName: "Notification", in: CoreDataHelper.shared.context)!
    }

    convenience init() {
        self.init(entity: Notification.oldEntity, insertInto: CoreDataHelper.shared.context)
    }

    var id: Int {
        get {
             managedId?.intValue ?? -1
        }
        set {
            managedId = newValue as NSNumber?
        }
    }

    var htmlText: String? {
        get {
             managedHtmlText
        }
        set {
            managedHtmlText = newValue
        }
    }

    var time: Date? {
        get {
             managedTime
        }
        set {
            managedTime = newValue
        }
    }

    var status: NotificationStatus {
        get {
            if let status = managedStatus {
                return NotificationStatus(rawValue: status) ?? .unread
            }
            return .unread
        }
        set {
            managedStatus = newValue.rawValue
        }
    }

    var isMuted: Bool {
        get {
             managedIsMuted?.boolValue ?? false
        }
        set {
            managedIsMuted = newValue as NSNumber?
        }
    }

    var isFavorite: Bool {
        get {
             managedIsFavorite?.boolValue ?? false
        }
        set {
            managedIsFavorite = newValue as NSNumber?
        }
    }

    var type: NotificationType {
        get {
            if let type = managedType {
                return NotificationType(rawValue: type) ?? .`default`
            }
            return .`default`
        }
        set {
            managedType = newValue.rawValue
        }
    }

    var action: NotificationAction {
        get {
            if let action = managedAction {
                return NotificationAction(rawValue: action) ?? .unknown
            }
            return .unknown
        }
        set {
            managedAction = newValue.rawValue
        }
    }

    // Maybe it will be helpful in the future
    var priority: String? {
        get {
             managedPriority
        }
        set {
            managedPriority = newValue
        }
    }

    // Maybe it will be helpful in the future
    var level: String? {
        get {
             managedLevel
        }
        set {
            managedLevel = newValue
        }
    }
}

//
//  Notification+CoreDataProperties.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 26.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import CoreData

extension Notification {
    @NSManaged public var managedId: NSNumber?
    @NSManaged public var managedIsUnread: NSNumber?
    @NSManaged public var managedIsMuted: NSNumber?
    @NSManaged public var managedIsFavorite: NSNumber?
    @NSManaged public var managedTime: Date?
    @NSManaged public var managedType: String?
    @NSManaged public var managedAction: String?
    @NSManaged public var managedLevel: String?
    @NSManaged public var managedPriority: String?
    @NSManaged public var managedHtmlText: String?

    class var oldEntity: NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: "Notification", in: CoreDataHelper.instance.context)!
    }

    convenience init() {
        self.init(entity: Notification.oldEntity, insertInto: CoreDataHelper.instance.context)
    }

    var id: Int {
        get {
            return managedId?.intValue ?? -1
        }
        set {
            managedId = newValue as NSNumber?
        }
    }

    var htmlText: String? {
        get {
            return managedHtmlText
        }
        set {
            managedHtmlText = newValue
        }
    }

    var time: Date? {
        get {
            return managedTime
        }
        set {
            managedTime = newValue
        }
    }

    var isUnread: Bool {
        get {
            return managedIsUnread?.boolValue ?? false
        }
        set {
            managedIsUnread = newValue as NSNumber?
        }
    }

    var isMuted: Bool {
        get {
            return managedIsMuted?.boolValue ?? false
        }
        set {
            managedIsMuted = newValue as NSNumber?
        }
    }

    var isFavorite: Bool {
        get {
            return managedIsFavorite?.boolValue ?? false
        }
        set {
            managedIsFavorite = newValue as NSNumber?
        }
    }

    var type: Type {
        get {
            if let type = managedType {
                return Type(rawValue: type) ?? .`default`
            }
            return .`default`
        }
        set {
            managedType = newValue.rawValue
        }
    }

    var action: Action {
        get {
            if let action = managedAction {
                return Action(rawValue: action) ?? .unknown
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
            return managedPriority
        }
        set {
            managedPriority = newValue
        }
    }

    // Maybe it will be helpful in the future
    var level: String? {
        get {
            return managedLevel
        }
        set {
            managedLevel = newValue
        }
    }

    enum `Type`: String {
        case comments = "comments"
        case learn = "learn"
        case `default` = "default"
        case review = "review"
        case teach = "teach"
    }

    enum Action: String {
        case opened = "opened"
        case replied = "replied"
        case softDeadlineApproach = "soft_deadline_approach"
        case hardDeadlineApproach = "hard_deadline_approach"
        case unknown = "unknown"
    }
}

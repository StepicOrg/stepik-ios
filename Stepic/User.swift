//
//  User.swift
//  Stepic
//
//  Created by Alexander Karpov on 03.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import CoreData
import Foundation
import SwiftyJSON

@objc
final class User: NSManagedObject, IDFetchable {
    typealias IdType = Int

    var isGuest: Bool { self.level == 0 }

    /// Returns true if joinDate is less than in 5 minutes from now.
    var didJustRegister: Bool {
        if let joinDate = self.joinDate {
            return Date().timeIntervalSince(joinDate) < 5 * 60
        }
        return false
    }

    required convenience init(json: JSON) {
        self.init()
        self.initialize(json)
    }

    func initialize(_ json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.profile = json[JSONKey.profile.rawValue].intValue
        self.isPrivate = json[JSONKey.isPrivate.rawValue].boolValue
        self.isOrganization = json[JSONKey.isOrganization.rawValue].boolValue
        self.bio = json[JSONKey.shortBio.rawValue].stringValue
        self.details = json[JSONKey.shortBio.rawValue].stringValue
        self.firstName = json[JSONKey.firstName.rawValue].stringValue
        self.lastName = json[JSONKey.lastName.rawValue].stringValue
        self.avatarURL = json[JSONKey.avatar.rawValue].stringValue
        self.level = json[JSONKey.level.rawValue].intValue
        self.joinDate = Parser.shared.dateFromTimedateJSON(json[JSONKey.joinDate.rawValue])
    }

    func update(json: JSON) {
        self.initialize(json)
    }

    static func fetchById(_ id: Int) -> [User]? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")

        let predicate = NSPredicate(format: "managedId== %@", id as NSNumber)

        request.predicate = predicate

        do {
            let results = try CoreDataHelper.shared.context.fetch(request)
            return results as? [User]
        } catch {
            return nil
        }
    }

    static func removeAllExcept(_ user: User) {
        if let fetchedUsers = fetchById(user.id) {
            for fetchedUser in fetchedUsers {
                if fetchedUser != user {
                    CoreDataHelper.shared.deleteFromStore(fetchedUser, save: false)
                }
            }
            CoreDataHelper.shared.save()
        }
    }

    static func fetch(_ ids: [Int]) -> [User] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")

        let idPredicates = ids.map {
            NSPredicate(format: "managedId == %@", $0 as NSNumber)
        }
        request.predicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: idPredicates)
        do {
            guard let results = try CoreDataHelper.shared.context.fetch(request) as? [User] else {
                return []
            }
            return results
        } catch {
            return []
        }
    }

    enum JSONKey: String {
        case id
        case profile
        case isPrivate = "is_private"
        case isOrganization = "is_organization"
        case shortBio = "short_bio"
        case details
        case firstName = "first_name"
        case lastName = "last_name"
        case avatar
        case level
        case joinDate = "join_date"
    }
}

struct UserInfo {
    var id: Int
    var avatarURL: String
    var firstName: String
    var lastName: String

    init(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.avatarURL = json[JSONKey.avatar.rawValue].stringValue
        self.firstName = json[JSONKey.firstName.rawValue].stringValue
        self.lastName = json[JSONKey.lastName.rawValue].stringValue
    }

    enum JSONKey: String {
        case id
        case avatar
        case firstName = "first_name"
        case lastName = "last_name"
    }
}

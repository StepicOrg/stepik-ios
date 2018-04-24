//
//  User.swift
//  Stepic
//
//  Created by Alexander Karpov on 03.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

@objc
class User: NSManagedObject, JSONSerializable {

    typealias IdType = Int

    convenience required init(json: JSON) {
        self.init()
        initialize(json)
    }

    func initialize(_ json: JSON) {
        id = json["id"].intValue
        profile = json["profile"].intValue
        isPrivate = json["is_private"].boolValue
        bio = json["short_bio"].stringValue
        details = json["details"].stringValue
        firstName = json["first_name"].stringValue
        lastName = json["last_name"].stringValue
        avatarURL = json["avatar"].stringValue
        level = json["level"].intValue
    }

    func update(json: JSON) {
        initialize(json)
    }

    var isGuest: Bool {
        return level == 0
    }

    static func fetchById(_ id: Int) -> [User]? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")

        let predicate = NSPredicate(format: "managedId== %@", id as NSNumber)

        request.predicate = predicate

        do {
            let results = try CoreDataHelper.instance.context.fetch(request)
            return results as? [User]
        } catch {
            return nil
        }
    }

    //synchronous 
    static func removeAllExcept(_ user: User) {
        if let fetchedUsers = fetchById(user.id) {
            for fetchedUser in fetchedUsers {
                if fetchedUser != user {
                    CoreDataHelper.instance.deleteFromStore(fetchedUser, save: false)
                }
            }
            CoreDataHelper.instance.save()
        }
    }

    static func fetch(_ ids: [Int]) -> [User] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "User")

        let idPredicates = ids.map {
            NSPredicate(format: "managedId == %@", $0 as NSNumber)
        }
        request.predicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: idPredicates)
        do {
            guard let results = try CoreDataHelper.instance.context.fetch(request) as? [User] else {
                return []
            }
            return results
        } catch {
            return []
        }
    }
}

struct UserInfo {
    var id: Int
    var avatarURL: String
    var firstName: String
    var lastName: String
    init(json: JSON) {
        id = json["id"].intValue
        avatarURL = json["avatar"].stringValue
        firstName = json["first_name"].stringValue
        lastName = json["last_name"].stringValue
    }
}

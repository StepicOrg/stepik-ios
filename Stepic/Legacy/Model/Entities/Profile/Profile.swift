//
//  Profile.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 24.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import CoreData
import Foundation
import SwiftyJSON

final class Profile: NSManagedObject, JSONSerializable {
    typealias IdType = Int

    var json: JSON {
        [
            JSONKey.id.rawValue: self.id,
            JSONKey.firstName.rawValue: self.firstName,
            JSONKey.lastName.rawValue: self.lastName,
            JSONKey.subscribedForMail.rawValue: self.subscribedForMail,
            JSONKey.shortBio.rawValue: self.shortBio,
            JSONKey.details.rawValue: self.details,
            JSONKey.isVoteNotificationsEnabled.rawValue: self.isVoteNotificationsEnabled
        ]
    }

    required convenience init(json: JSON) {
        self.init()
        self.initialize(json)
    }

    func initialize(_ json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.firstName = json[JSONKey.firstName.rawValue].stringValue
        self.lastName = json[JSONKey.lastName.rawValue].stringValue
        self.subscribedForMail = json[JSONKey.subscribedForMail.rawValue].boolValue
        self.isVoteNotificationsEnabled = json[JSONKey.isVoteNotificationsEnabled.rawValue].boolValue
        self.isStaff = json[JSONKey.isStaff.rawValue].boolValue
        self.shortBio = json[JSONKey.shortBio.rawValue].stringValue
        self.details = json[JSONKey.details.rawValue].stringValue
        self.emailAddressesArray = json[JSONKey.emailAddresses.rawValue].arrayObject as? [Int] ?? []
    }

    func update(json: JSON) {
        self.initialize(json)
    }

    static func fetchById(_ id: Int) -> [Profile]? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Profile")
        let predicate = NSPredicate(format: "managedId== %@", id as NSNumber)
        request.predicate = predicate
        do {
            let results = try CoreDataHelper.shared.context.fetch(request)
            return results as? [Profile]
        } catch {
            return nil
        }
    }

    enum JSONKey: String {
        case id
        case firstName = "first_name"
        case lastName = "last_name"
        case subscribedForMail = "subscribed_for_mail"
        case isStaff = "is_staff"
        case shortBio = "short_bio"
        case details
        case emailAddresses = "email_addresses"
        case isVoteNotificationsEnabled = "is_vote_notifications_enabled"
    }
}

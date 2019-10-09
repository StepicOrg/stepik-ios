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

    convenience required init(json: JSON) {
        self.init()
        self.initialize(json)
    }

    func initialize(_ json: JSON) {
        self.id = json["id"].intValue
        self.firstName = json["first_name"].stringValue
        self.lastName = json["last_name"].stringValue
        self.subscribedForMail = json["subscribed_for_mail"].boolValue
        self.isStaff = json["is_staff"].boolValue
        self.shortBio = json["short_bio"].stringValue
        self.details = json["details"].stringValue
        self.emailAddressesArray = json["email_addresses"].arrayObject as? [Int] ?? []
    }

    func update(json: JSON) {
        self.initialize(json)
    }

    var json: JSON {
        return [
            "id": self.id as AnyObject,
            "first_name": self.firstName as AnyObject,
            "last_name": self.lastName as AnyObject,
            "subscribed_for_mail": self.subscribedForMail as AnyObject,
            "short_bio": self.shortBio as AnyObject,
            "details": self.details as AnyObject
        ]
    }

    static func fetchById(_ id: Int) -> [Profile]? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Profile")
        let predicate = NSPredicate(format: "managedId== %@", id as NSNumber)
        request.predicate = predicate
        do {
            let results = try CoreDataHelper.instance.context.fetch(request)
            return results as? [Profile]
        } catch {
            return nil
        }
    }
}

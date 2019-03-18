//
//  Profile.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 24.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

class Profile: NSManagedObject, JSONSerializable {
    typealias IdType = Int

    convenience required init(json: JSON) {
        self.init()
        initialize(json)
    }

    func initialize(_ json: JSON) {
        id = json["id"].intValue
        firstName = json["first_name"].stringValue
        lastName = json["last_name"].stringValue
        subscribedForMail = json["subscribed_for_mail"].boolValue
        isStaff = json["is_staff"].boolValue
    }

    func update(json: JSON) {
        initialize(json)
    }

    var json: JSON {
        return [
            "id": id as AnyObject,
            "first_name": firstName as AnyObject,
            "last_name": lastName as AnyObject,
            "subscribed_for_mail": subscribedForMail as AnyObject
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

//
//  Notification+FetchMethods.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 13.10.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Foundation
import CoreData

extension Notification {
    static func fetch(_ id: Int) -> Notification? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Notification")
        request.predicate = NSPredicate(format: "managedId == %@", id as NSNumber)
        do {
            guard let results = try CoreDataHelper.instance.context.fetch(request) as? [Notification] else {
                return nil
            }
            return results.first
        } catch {
            return nil
        }
    }

    static func fetch(type: NotificationType) -> [Notification]? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Notification")
        request.predicate = NSPredicate(format: "managedType == %@", type.rawValue as NSString)

        do {
            guard let results = try CoreDataHelper.instance.context.fetch(request) as? [Notification] else {
                return nil
            }
            return results
        } catch {
            return nil
        }
    }
}

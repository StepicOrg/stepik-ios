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
    static func fetch(_ ids: [Int]) -> [Notification] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Notification")

        let idPredicates = ids.map {
            NSPredicate(format: "managedId == %@", $0 as NSNumber)
        }
        request.predicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: idPredicates)
        do {
            guard let results = try CoreDataHelper.instance.context.fetch(request) as? [Notification] else {
                return []
            }
            return results
        } catch {
            return []
        }
    }

    static func fetch(id: Int) -> Notification? {
        return fetch([id]).first
    }

    static func fetch(type: NotificationType?, offset: Int = 0, limit: Int = 10) -> [Notification]? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Notification")
        request.fetchLimit = limit
        request.fetchOffset = offset

        if let type = type {
            request.predicate = NSPredicate(format: "managedType == %@", type.rawValue as NSString)
        } else {
            request.predicate = NSPredicate(value: true)
        }

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

//
//  DatabaseFetchService.swift
//  Stepic
//
//  Created by Ostrenkiy on 28.03.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import PromiseKit
import SwiftyJSON
import CoreData

class DatabaseFetchService {
    static func fetchAsync<T: IDFetchable>(entityName: String, ids: [T.IdType]) -> Promise<[T]> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let descriptor = NSSortDescriptor(key: "managedId", ascending: false)

        let idPredicates = ids.map {
            NSPredicate(format: "managedId == %@", $0.fetchValue)
        }
        let predicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.or, subpredicates: idPredicates)

        request.predicate = predicate
        request.sortDescriptors = [descriptor]

        return Promise<[T]> {
            fulfill, _ in
            let asyncRequest = NSAsynchronousFetchRequest(fetchRequest: request, completionBlock: {
                results in
                guard let courses = results.finalResult as? [T] else {
                    fulfill([])
                    return
                }
                fulfill(courses)
            })
            _ = try? CoreDataHelper.instance.context.execute(asyncRequest)
        }
    }
}

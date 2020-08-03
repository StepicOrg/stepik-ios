//
//  DatabaseFetchService.swift
//  Stepic
//
//  Created by Ostrenkiy on 28.03.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import CoreData
import Foundation
import PromiseKit
import SwiftyJSON

@available(*, deprecated, message: "Legacy class, should be refactored")
final class DatabaseFetchService {
    static func fetchAsync<T: IDFetchable>(entityName: String, ids: [T.IdType]) -> Guarantee<[T]> {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let descriptor = NSSortDescriptor(key: "managedId", ascending: false)

        let idPredicates = ids.map { NSPredicate(format: "managedId == %@", $0.fetchValue) }
        let compoundPredicate = NSCompoundPredicate(type: .or, subpredicates: idPredicates)

        request.predicate = compoundPredicate
        request.sortDescriptors = [descriptor]

        return Guarantee<[T]> { seal in
            DispatchQueue.doWorkOnMain {
                let context = CoreDataHelper.shared.context
                context.performAndWait {
                    do {
                        let finalResult = try context.fetch(request) as? [T]
                        seal(finalResult ?? [])
                    } catch {
                        seal([])
                    }
                }
            }
        }
    }
}

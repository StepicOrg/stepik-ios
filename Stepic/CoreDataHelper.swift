//
//  CoreDataHelper.swift
//  Stepic
//
//  Created by Alexander Karpov on 28.09.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import CoreData
import MagicalRecord

class CoreDataHelper: NSObject {
    static var instance = CoreDataHelper()

    let coordinator: NSPersistentStoreCoordinator
    let model: NSManagedObjectModel
    let context: NSManagedObjectContext
    var storeURL: URL

    fileprivate override init() {
        let modelURL = Bundle.main.url(forResource: "Model", withExtension: "momd")!
        model = NSManagedObjectModel(contentsOf: modelURL)!
        let fileManager = FileManager.default
        let docsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).last! as URL
        storeURL = docsURL.appendingPathComponent("base.sqlite")

        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)

        do {
            _ = try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: [NSMigratePersistentStoresAutomaticallyOption: true,
                NSInferMappingModelAutomaticallyOption: true])
        } catch {
            print("STORE IS NIL")
            abort()
        }

        context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        super.init()
    }

    let lockQueue = DispatchQueue(label: "com.test.LockQueue", attributes: [])

    func save() {
        lockQueue.sync {
            [weak self] in
            self?.context.perform({
                [weak self] in
                do {
                    try self?.context.save()
                } catch {
                    print("SAVING ERROR")
                }
            })
        }
    }

//    private var objectsToDelete : [NSManagedObject] = []

    func deleteFromStore(_ object: NSManagedObject, save s: Bool = true) {
        lockQueue.sync {
            [weak self] in
            self?.context.perform({
                [weak self] in
                self?.context.delete(object)
                if s == true {
                    self?.save()
                }
            })
        }
    }

//    func deleteAllPending() {
//        for obj in objectsToDelete {
//            CoreDataHelper.instance.context.deleteObject(obj)
//        }
//        CoreDataHelper.instance.save()
//    }

}

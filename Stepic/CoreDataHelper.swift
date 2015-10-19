//
//  CoreDataHelper.swift
//  Stepic
//
//  Created by Alexander Karpov on 28.09.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit
import CoreData

class CoreDataHelper: NSObject {
    static var instance = CoreDataHelper()
    
    let coordinator : NSPersistentStoreCoordinator
    let model : NSManagedObjectModel
    let context : NSManagedObjectContext
    
    private override init() {
        let modelURL = NSBundle.mainBundle().URLForResource("Model", withExtension: "momd")!
        model = NSManagedObjectModel(contentsOfURL: modelURL)!
        let fileManager = NSFileManager.defaultManager()
        let docsURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last! as NSURL
        let storeURL = docsURL.URLByAppendingPathComponent("base.sqlite")
        
        coordinator = NSPersistentStoreCoordinator(managedObjectModel: model)
        
        do {
            _ = try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
        }
        catch {
            print("STORE IS NIL")
            abort()
        }

        
        context = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
        context.persistentStoreCoordinator = coordinator
        super.init()
    }
    
    func save() {
        do {
            try context.save()
        }
        catch {
            print("SAVING ERROR")
        }
    }
    
    private var objectsToDelete : [NSManagedObject] = []
    
    func deleteBeforeAppFinish(object: NSManagedObject) {
        context.deleteObject(object)
        save()
//        if !objectsToDelete.contains(object) {
//            objectsToDelete += [object]
//        }
    }
    
    func deleteAllPending() {
        for obj in objectsToDelete {
            CoreDataHelper.instance.context.deleteObject(obj)
        }
        CoreDataHelper.instance.save()
    }
    
}

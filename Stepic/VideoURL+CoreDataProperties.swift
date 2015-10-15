//
//  VideoURL+CoreDataProperties.swift
//  Stepic
//
//  Created by Alexander Karpov on 14.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension VideoURL {

    @NSManaged var managedQuality: String?
    @NSManaged var managedURL: String?
    @NSManaged var managedVideo: Video?

    class var entity : NSEntityDescription {
        return NSEntityDescription.entityForName("VideoURL", inManagedObjectContext: CoreDataHelper.instance.context)!
    }

    convenience init() {
        self.init(entity: VideoURL.entity, insertIntoManagedObjectContext: CoreDataHelper.instance.context)
    }

    var quality : String {
        set(value){
            self.managedQuality = value
        }
        get {
            return managedQuality ?? ""
        }
    }

    var url : String {
        set(value){
            self.managedURL = value
        }
        get {
            return managedURL ?? ""
        }
    }
}
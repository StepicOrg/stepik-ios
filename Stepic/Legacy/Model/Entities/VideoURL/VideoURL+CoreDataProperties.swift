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

import CoreData
import Foundation

extension VideoURL {
    @NSManaged var managedQuality: String?
    @NSManaged var managedURL: String?
    @NSManaged var managedVideo: Video?

    static var oldEntity: NSEntityDescription {
        NSEntityDescription.entity(forEntityName: "VideoURL", in: CoreDataHelper.shared.context)!
    }

    static var fetchRequest: NSFetchRequest<VideoURL> {
        NSFetchRequest<VideoURL>(entityName: "VideoURL")
    }

    convenience init() {
        self.init(entity: VideoURL.oldEntity, insertInto: CoreDataHelper.shared.context)
    }

    var quality: String {
        set(value) {
            self.managedQuality = value
        }
        get {
             managedQuality ?? ""
        }
    }

    var url: String {
        set(value) {
            self.managedURL = value
        }
        get {
             managedURL ?? ""
        }
    }
}

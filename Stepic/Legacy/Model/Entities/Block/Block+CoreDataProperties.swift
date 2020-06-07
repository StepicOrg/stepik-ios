//
//  Block+CoreDataProperties.swift
//  Stepic
//
//  Created by Alexander Karpov on 12.10.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import CoreData
import Foundation
import UIKit

extension Block {
    @NSManaged var managedName: String?
    @NSManaged var managedText: String?

    @NSManaged var managedVideo: Video?
    @NSManaged var managedStep: Step?

    static var oldEntity: NSEntityDescription {
        NSEntityDescription.entity(forEntityName: "Block", in: CoreDataHelper.shared.context)!
    }

    static var fetchRequest: NSFetchRequest<Block> {
        NSFetchRequest<Block>(entityName: "Block")
    }

    convenience init() {
        self.init(entity: Block.oldEntity, insertInto: CoreDataHelper.shared.context)
    }

    var name: String {
        get {
            self.managedName ?? "undefined"
        }
        set {
            self.managedName = newValue
        }
    }

    var text: String? {
        get {
            self.managedText
        }
        set {
            self.managedText = newValue
        }
    }

    var video: Video? {
        get {
            self.managedVideo
        }
        set {
            self.managedVideo = newValue
        }
    }
}

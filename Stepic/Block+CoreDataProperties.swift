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

import Foundation
import CoreData

extension Block {

    @NSManaged var managedAnimation: String?
    @NSManaged var managedName: String?
    @NSManaged var managedText: String?
    
    @NSManaged var managedVideo: Video?
    
    @NSManaged var managedStep: Step?

    class var entity : NSEntityDescription {
        return NSEntityDescription.entityForName("Block", inManagedObjectContext: CoreDataHelper.instance.context)!
    }
    
    convenience init() {
        self.init(entity: Block.entity, insertIntoManagedObjectContext: CoreDataHelper.instance.context)
    }
    
    var name : String {
        get {
            return managedName ?? "no name"
        }
        set(value) {
            managedName = value
        }
    }
    
    var text : String? {
        get {
            return managedText
        }
        set(value) {
            managedText = value
        }
    }
    
    var video : Video? {
        get {
            return managedVideo
        }
        set(value) {
            managedVideo = value
        }
    }
    
    var animation : String? {
        get {
            return managedAnimation 
        }
        
        set(value) {
            managedAnimation = value
        }
    }
    
    var type : BlockTypes {
        get {
            return BlockTypes(rawValue: name) ?? .Text
        }
    }
    
    var image : UIImage {
        var resultName = "ic_theory"
        switch (name) {
        case "text" : resultName = "ic_theory"
        case "schulte" : resultName = "ic_table"
        default: resultName = "ic_\(name)"
        }
        
        if let img = UIImage(named: resultName) {
            return img
        } else {
            print("Unknown image name -> \(resultName)")
            return UIImage(named: "ic_theory")!
        }
    }
}

enum BlockTypes : String {
    case Text = "text", Video = "video", Animation = "animation"
}
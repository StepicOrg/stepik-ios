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

    class var oldEntity : NSEntityDescription {
        return NSEntityDescription.entity(forEntityName: "Block", in: CoreDataHelper.instance.context)!
    }
    
    convenience init() {
        self.init(entity: Block.oldEntity, insertInto: CoreDataHelper.instance.context)
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
        case "animation" : resultName = "ic_animation"
        case "video" : resultName = "video"
        case "text" : resultName = "ic_theory"
        case "code", "dataset", "admin" : resultName = "ic_admin"
        default: resultName = "easy_quiz"
        }
        
        if let img = UIImage(named: resultName) {
            return img
        } else {
            print("Unknown image name -> \(resultName)")
            return UIImage(named: "ic_theory")!
        }
    }
    
//    var image : UIImage {
//        var resultName = "ic_theory"
//        switch (name) {
//        case "text" : resultName = "ic_theory"
//        case "schulte" : resultName = "ic_table"
//        default: resultName = "ic_\(name)"
//        }
//        
//        if let img = UIImage(named: resultName) {
//            return img
//        } else {
//            print("Unknown image name -> \(resultName)")
//            return UIImage(named: "ic_theory")!
//        }
//    }
}

enum BlockTypes : String {
    case Text = "text", Video = "video", Animation = "animation"
}

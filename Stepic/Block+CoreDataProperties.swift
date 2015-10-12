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
    @NSManaged var managedVideo: String?
    
    @NSManaged var managedStep: Step?

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
    
    var video : String? {
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
}

enum BlockTypes : String {
    case Text = "text", Video = "video", Animation = "animation"
}
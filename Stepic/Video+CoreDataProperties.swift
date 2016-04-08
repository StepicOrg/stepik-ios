//
//  Video+CoreDataProperties.swift
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

extension Video {

    @NSManaged var managedId: NSNumber?
    @NSManaged var managedThumbnailURL: String?
    @NSManaged var managedStatus: String?    
    @NSManaged var managedPlayTime: NSNumber?
    @NSManaged var managedURLs: NSOrderedSet?
    @NSManaged var managedBlock: Block?
//    @NSManaged var managedCachedPath: String?
    @NSManaged var managedCachedQuality : NSNumber?
    
    class var entity : NSEntityDescription {
        return NSEntityDescription.entityForName("Video", inManagedObjectContext: CoreDataHelper.instance.context)!
    }
    
    convenience init() {
        self.init(entity: Video.entity, insertIntoManagedObjectContext: CoreDataHelper.instance.context)
    }
    
    var id : Int {
        set(newId){
            self.managedId = newId
        }
        get {
            return managedId?.integerValue ?? -1
        }
    }

    var thumbnailURL : String {
        set(value){
            self.managedThumbnailURL = value
        }
        get {
            return managedThumbnailURL ?? ""
        }
    }
    
    var status : String {
        set(value){
            self.managedStatus = value
        }
        get {
            return managedStatus ?? ""
        }
    }
    
    var urls : [VideoURL] {
        get {
            return (managedURLs?.array as? [VideoURL]) ?? []
        }
        set(value) {
            managedURLs = NSOrderedSet(array: value)
        }
    }
    
    var cachedQuality : String? {
        get {
            if let cq = managedCachedQuality {
                return String(cq)
            } else {
                return nil
            }
        }
        set(value) {
            if let v = value {
                managedCachedQuality = Int(v)
            } else {
                managedCachedQuality = nil
            }
            loadingQuality = value
        }
    }
    
    var playTime: NSTimeInterval {
        get {
            if let time = managedPlayTime {
                return time.doubleValue
            } else {
                return 0.0
            }
        }
        
        set(time) {
            managedPlayTime = time
        }
    }
    
//    var cachedPath : String? {
//        get {
//            return managedCachedPath
//        }
//    }
    
//    var isCached : Bool {
//        return self.state == VideoState.Cached
//    }
//    
//    var isDownloading : Bool {
//        return self.state == VideoState.Downloading
//    }
}

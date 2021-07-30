import CoreData

extension Video {
    @NSManaged var managedId: NSNumber?
    @NSManaged var managedThumbnailURL: String?
    @NSManaged var managedStatus: String?
    @NSManaged var managedPlayTime: NSNumber?
    @NSManaged var managedURLs: NSOrderedSet?
    @NSManaged var managedBlock: Block?
//    @NSManaged var managedCachedPath: String?
    @NSManaged var managedCachedQuality: NSNumber?

    var id: Int {
        set(newId) {
            self.managedId = newId as NSNumber?
        }
        get {
            managedId?.intValue ?? -1
        }
    }

    var thumbnailURL: String {
        set(value) {
            self.managedThumbnailURL = value
        }
        get {
            managedThumbnailURL ?? ""
        }
    }

    var status: String {
        set(value) {
            self.managedStatus = value
        }
        get {
            managedStatus ?? ""
        }
    }

    var urls: [VideoURL] {
        get {
            (managedURLs?.array as? [VideoURL]) ?? []
        }
        set(value) {
            managedURLs = NSOrderedSet(array: value)
        }
    }

    var cachedQuality: String? {
        get {
            if let cq = managedCachedQuality {
                return String(describing: cq)
            } else {
                return nil
            }
        }
        set(value) {
            if let v = value {
                if v == "0" {
                    print("setting cachedQuality to 0")
                    managedCachedQuality = nil
                } else {
                    managedCachedQuality = Int(v) as NSNumber?
                }
            } else {
                managedCachedQuality = nil
            }
        }
    }

    var playTime: TimeInterval {
        get {
            if let time = managedPlayTime {
                return time.doubleValue
            } else {
                return 0.0
            }
        }

        set(time) {
            managedPlayTime = time as NSNumber?
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

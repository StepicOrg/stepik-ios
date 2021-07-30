import CoreData

extension VideoURL {
    @NSManaged var managedQuality: String?
    @NSManaged var managedURL: String?
    @NSManaged var managedVideo: Video?

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

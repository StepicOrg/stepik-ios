import CoreData
import Foundation

extension MobileTier {
    @NSManaged var managedId: String
    @NSManaged var managedCourseId: NSNumber
    @NSManaged var managedPriceTier: String?
    @NSManaged var managedPromoTier: String?

    @NSManaged var managedCourse: Course?

    var id: String {
        get {
            self.managedId
        }
        set {
            self.managedId = newValue
        }
    }

    var courseID: Course.IdType {
        get {
            self.managedCourseId.intValue
        }
        set {
            self.managedCourseId = NSNumber(value: newValue)
        }
    }

    var priceTier: String? {
        get {
            self.managedPriceTier
        }
        set {
            self.managedPriceTier = newValue
        }
    }

    var promoTier: String? {
        get {
            self.managedPromoTier
        }
        set {
            self.managedPromoTier = newValue
        }
    }

    var course: Course? {
        get {
            self.managedCourse
        }
        set {
            self.managedCourse = newValue
        }
    }
}

import CoreData

extension CourseBenefit {
    @NSManaged var managedId: NSNumber?
    @NSManaged var managedUserId: NSNumber?
    @NSManaged var managedCourseId: NSNumber?
    @NSManaged var managedTime: Date?
    @NSManaged var managedStatusString: String?
    @NSManaged var managedAmount: NSNumber?
    @NSManaged var managedCurrencyCode: String?
    @NSManaged var managedTotalIncome: NSNumber?
    @NSManaged var managedPaymentAmount: NSNumber?
    @NSManaged var managedBuyerId: NSNumber?
    @NSManaged var managedIsZLinkUsed: NSNumber?
    @NSManaged var managedPromoCode: String?

    @NSManaged var managedCourse: Course?
    @NSManaged var managedBuyer: User?

    var id: IdType {
        get {
            self.managedId?.intValue ?? -1
        }
        set {
            self.managedId = NSNumber(value: newValue)
        }
    }

    var userID: User.IdType {
        get {
            self.managedUserId?.intValue ?? -1
        }
        set {
            self.managedUserId = NSNumber(value: newValue)
        }
    }

    var courseID: Course.IdType {
        get {
            self.managedCourseId?.intValue ?? -1
        }
        set {
            self.managedCourseId = NSNumber(value: newValue)
        }
    }

    var time: Date? {
        get {
            self.managedTime
        }
        set {
            self.managedTime = newValue
        }
    }

    var statusString: String {
        get {
            self.managedStatusString ?? ""
        }
        set {
            self.managedStatusString = newValue
        }
    }

    var amount: Float {
        get {
            self.managedAmount?.floatValue ?? 0
        }
        set {
            self.managedAmount = NSNumber(value: newValue)
        }
    }

    var currencyCode: String {
        get {
            self.managedCurrencyCode ?? "RUB"
        }
        set {
            self.managedCurrencyCode = newValue
        }
    }

    @available(*, deprecated, message: "Removed from API")
    var totalIncome: Float {
        get {
            self.managedTotalIncome?.floatValue ?? 0
        }
        set {
            self.managedTotalIncome = NSNumber(value: newValue)
        }
    }

    var paymentAmount: Float {
        get {
            self.managedPaymentAmount?.floatValue ?? 0
        }
        set {
            self.managedPaymentAmount = NSNumber(value: newValue)
        }
    }

    var buyerID: User.IdType {
        get {
            self.managedBuyerId?.intValue ?? -1
        }
        set {
            self.managedBuyerId = NSNumber(value: newValue)
        }
    }

    var isZLinkUsed: Bool {
        get {
            self.managedIsZLinkUsed?.boolValue ?? false
        }
        set {
            self.managedIsZLinkUsed = NSNumber(value: newValue)
        }
    }

    var promoCode: String? {
        get {
            self.managedPromoCode
        }
        set {
            self.managedPromoCode = newValue
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

    var buyer: User? {
        get {
            self.managedBuyer
        }
        set {
            self.managedBuyer = newValue
        }
    }
}

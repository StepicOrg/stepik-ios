import CoreData

extension CourseBenefitSummary {
    @NSManaged var managedId: NSNumber?
    @NSManaged var managedBeginPaymentDate: Date?
    @NSManaged var managedCurrentDate: Date?
    @NSManaged var managedTotalIncome: NSNumber?
    @NSManaged var managedTotalTurnover: NSNumber?
    @NSManaged var managedTotalUserIncome: NSNumber?
    @NSManaged var managedMonthIncome: NSNumber?
    @NSManaged var managedMonthTurnover: NSNumber?
    @NSManaged var managedMonthUserIncome: NSNumber?
    @NSManaged var managedCurrencyCode: String?

    @NSManaged var managedCourse: Course?

    var id: Int {
        get {
            self.managedId?.intValue ?? -1
        }
        set {
            self.managedId = NSNumber(value: newValue)
        }
    }

    var beginPaymentDate: Date? {
        get {
            self.managedBeginPaymentDate
        }
        set {
            self.managedBeginPaymentDate = newValue
        }
    }

    var currentDate: Date? {
        get {
            self.managedCurrentDate
        }
        set {
            self.managedCurrentDate = newValue
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

    var totalTurnover: Float {
        get {
            self.managedTotalTurnover?.floatValue ?? 0
        }
        set {
            self.managedTotalTurnover = NSNumber(value: newValue)
        }
    }

    var totalUserIncome: Float {
        get {
            self.managedTotalUserIncome?.floatValue ?? 0
        }
        set {
            self.managedTotalUserIncome = NSNumber(value: newValue)
        }
    }

    @available(*, deprecated, message: "Removed from API")
    var monthIncome: Float {
        get {
            self.managedMonthIncome?.floatValue ?? 0
        }
        set {
            self.managedMonthIncome = NSNumber(value: newValue)
        }
    }

    var monthTurnover: Float {
        get {
            self.managedMonthTurnover?.floatValue ?? 0
        }
        set {
            self.managedMonthTurnover = NSNumber(value: newValue)
        }
    }

    var monthUserIncome: Float {
        get {
            self.managedMonthUserIncome?.floatValue ?? 0
        }
        set {
            self.managedMonthUserIncome = NSNumber(value: newValue)
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

    var course: Course? {
        get {
            self.managedCourse
        }
        set {
            self.managedCourse = newValue
        }
    }
}

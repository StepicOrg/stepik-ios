import CoreData
import Foundation

extension CourseBenefitByMonth {
    @NSManaged var managedId: String?
    @NSManaged var managedUserId: NSNumber?
    @NSManaged var managedDateString: String?
    @NSManaged var managedYearNumber: NSNumber?
    @NSManaged var managedMonthNumber: NSNumber?
    @NSManaged var managedCountPayments: NSNumber?
    @NSManaged var managedCountZPayments: NSNumber?
    @NSManaged var managedCountNonZPayments: NSNumber?
    @NSManaged var managedCountRefunds: NSNumber?
    @NSManaged var managedCurrencyCode: String?
    @NSManaged var managedTotalTurnover: NSNumber?
    @NSManaged var managedTotalUserIncome: NSNumber?

    @NSManaged var managedUser: User?
    @NSManaged var managedCourse: Course?

    static var oldEntity: NSEntityDescription {
        NSEntityDescription.entity(forEntityName: "CourseBenefitByMonth", in: CoreDataHelper.shared.context)!
    }

    static var defaultSortDescriptors: [NSSortDescriptor] {
        [NSSortDescriptor(key: #keyPath(managedId), ascending: false)]
    }

    static var fetchRequest: NSFetchRequest<CourseBenefitByMonth> {
        NSFetchRequest<CourseBenefitByMonth>(entityName: "CourseBenefitByMonth")
    }

    convenience init() {
        self.init(entity: Self.oldEntity, insertInto: CoreDataHelper.shared.context)
    }

    var id: String {
        get {
            self.managedId ?? ""
        }
        set {
            self.managedId = newValue
        }
    }

    var userID: Int {
        get {
            self.managedUserId?.intValue ?? 0
        }
        set {
            self.managedUserId = NSNumber(value: newValue)
        }
    }

    var dateString: String {
        get {
            self.managedDateString ?? ""
        }
        set {
            self.managedDateString = newValue
        }
    }

    var yearNumber: Int {
        get {
            self.managedYearNumber?.intValue ?? 0
        }
        set {
            self.managedYearNumber = NSNumber(value: newValue)
        }
    }

    var monthNumber: Int {
        get {
            self.managedMonthNumber?.intValue ?? 0
        }
        set {
            self.managedMonthNumber = NSNumber(value: newValue)
        }
    }

    var countPayments: Int {
        get {
            self.managedCountPayments?.intValue ?? 0
        }
        set {
            self.managedCountPayments = NSNumber(value: newValue)
        }
    }

    var countZPayments: Int {
        get {
            self.managedCountZPayments?.intValue ?? 0
        }
        set {
            self.managedCountZPayments = NSNumber(value: newValue)
        }
    }

    var countNonZPayments: Int {
        get {
            self.managedCountNonZPayments?.intValue ?? 0
        }
        set {
            self.managedCountNonZPayments = NSNumber(value: newValue)
        }
    }

    var countRefunds: Int {
        get {
            self.managedCountRefunds?.intValue ?? 0
        }
        set {
            self.managedCountRefunds = NSNumber(value: newValue)
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

    var user: User? {
        get {
            self.managedUser
        }
        set {
            self.managedUser = newValue
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

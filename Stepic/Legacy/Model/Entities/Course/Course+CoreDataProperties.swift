import CoreData

extension Course {
    @NSManaged var managedId: NSNumber?
    @NSManaged var managedCourseDescription: String?
    @NSManaged var managedTitle: String?
    @NSManaged var managedBeginDate: Date?
    @NSManaged var managedEndDate: Date?
    @NSManaged var managedBeginDateSource: Date?
    @NSManaged var managedEndDateSource: Date?
    @NSManaged var managedImageURL: String?
    @NSManaged var managedEnrolled: NSNumber?
    @NSManaged var managedFeatured: NSNumber?
    @NSManaged var managedPublic: NSNumber?
    @NSManaged var managedIsProctored: NSNumber?
    @NSManaged var managedIsFavorite: NSNumber?
    @NSManaged var managedIsArchived: NSNumber?
    @NSManaged var managedIsInWishlist: NSNumber?
    @NSManaged var managedLearnersCount: NSNumber?
    @NSManaged var managedPreviewLessonId: NSNumber?
    @NSManaged var managedPreviewUnitId: NSNumber?
    @NSManaged var managedReadiness: NSNumber?

    @NSManaged var managedScheduleType: String?
    @NSManaged var managedSummary: String?
    @NSManaged var managedReviewSummaryId: NSNumber?
    @NSManaged var managedWorkload: String?
    @NSManaged var managedIntroURL: String?
    @NSManaged var managedFormat: String?
    @NSManaged var managedAudience: String?
    @NSManaged var managedRequirements: String?
    @NSManaged var managedSlug: String?
    @NSManaged var managedProgressId: String?
    @NSManaged var managedLastStepId: String?
    @NSManaged var managedTimeToComplete: NSNumber?
    @NSManaged var managedLanguageCode: String?
    @NSManaged var managedTotalUnits: NSNumber?

    @NSManaged var managedCertificate: String?
    @NSManaged var managedCertificateRegularThreshold: NSNumber?
    @NSManaged var managedCertificateDistinctionThreshold: NSNumber?
    @NSManaged var managedIsCertificateAutoIssued: NSNumber?
    @NSManaged var managedIsCertificateIssued: NSNumber?
    @NSManaged var managedWithCertificate: NSNumber?

    @NSManaged var managedSectionsArray: NSObject?
    @NSManaged var managedInstructorsArray: NSObject?
    @NSManaged var managedAuthorsArray: NSObject?
    @NSManaged var managedAnnouncementsArray: NSObject?

    @NSManaged var managedIsPaid: NSNumber?
    @NSManaged var managedDisplayPrice: String?
    @NSManaged var managedDisplayPriceIAP: String?
    @NSManaged var managedPriceTier: NSNumber?
    @NSManaged var managedCurrencyCode: String?

    @NSManaged var managedDefaultPromoCodeName: String?
    @NSManaged var managedDefaultPromoCodePrice: NSNumber?
    @NSManaged var managedDefaultPromoCodeDiscount: NSNumber?
    @NSManaged var managedDefaultPromoCodeExpireDate: Date?

    @NSManaged var managedCanViewRevenue: NSNumber?
    @NSManaged var managedCanCreateAnnouncements: NSNumber

    // MARK: Relationships
    @NSManaged var managedAuthors: NSOrderedSet?
    @NSManaged var managedCertificateEntity: Certificate?
    @NSManaged var managedInstructors: NSOrderedSet?
    @NSManaged var managedIntroVideo: Video?
    @NSManaged var managedLastCodeLanguage: LastCodeLanguage?
    @NSManaged var managedLastStep: LastStep?
    @NSManaged var managedProgress: Progress?
    @NSManaged var managedReviewSummary: CourseReviewSummary?
    @NSManaged var managedSections: NSOrderedSet?
    @NSManaged var managedUserCourse: UserCourse?
    @NSManaged var managedCoursePurchases: NSOrderedSet?
    @NSManaged var managedCourseBenefitSummaries: NSSet?
    @NSManaged var managedCourseBenefits: NSOrderedSet?
    @NSManaged var managedCourseBenefitByMonths: NSOrderedSet?
    @NSManaged var managedCourseBeneficiaries: NSSet?
    @NSManaged var managedAnnouncements: NSSet?
    @NSManaged var managedWishlistEntries: NSOrderedSet?

    var id: Int {
        set(newId) {
            self.managedId = newId as NSNumber?
        }
        get {
            managedId?.intValue ?? -1
        }
    }

    var learnersCount: Int? {
        set(newCount) {
            self.managedLearnersCount = newCount as NSNumber?
        }
        get {
            managedLearnersCount?.intValue
        }
    }

    var previewLessonID: Lesson.IdType? {
        get {
            self.managedPreviewLessonId?.intValue
        }
        set {
            if let newValue = newValue {
                self.managedPreviewLessonId = NSNumber(value: newValue)
            } else {
                self.managedPreviewLessonId = nil
            }
        }
    }

    var previewUnitID: Unit.IdType? {
        get {
            self.managedPreviewUnitId?.intValue
        }
        set {
            self.managedPreviewUnitId = newValue as NSNumber?
        }
    }

    @available(*, deprecated, message: "Use `lessons_count` instead. https://vyahhi.myjetbrains.com/youtrack/issue/EDY-9837#focus=streamItem-74-64368.0-0")
    var totalUnits: Int {
        get {
            self.managedTotalUnits?.intValue ?? 0
        }
        set {
            self.managedTotalUnits = newValue as NSNumber?
        }
    }

    var reviewSummaryId: Int? {
        get {
            managedReviewSummaryId?.intValue
        }
        set(value) {
            managedReviewSummaryId = value as NSNumber?
        }
    }

    var courseDescription: String {
        set(description) {
            self.managedCourseDescription = description
        }
        get {
            managedCourseDescription ?? ""
        }
    }

    var scheduleType: String? {
        set(value) {
            self.managedScheduleType = value
        }
        get {
            managedScheduleType
        }
    }

    var title: String {
        set(title) {
            self.managedTitle = title
        }
        get {
            managedTitle ?? ""
        }
    }

    var beginDate: Date? {
        set(date) {
            self.managedBeginDate = date
        }
        get {
            managedBeginDate
        }
    }

    var endDate: Date? {
        set(date) {
            self.managedEndDate = date
        }
        get {
            managedEndDate
        }
    }

    var beginDateSource: Date? {
        get {
            self.managedBeginDateSource
        }
        set {
            self.managedBeginDateSource = newValue
        }
    }

    var endDateSource: Date? {
        get {
            self.managedEndDateSource
        }
        set {
            self.managedEndDateSource = newValue
        }
    }

    var coverURLString: String {
        set(url) {
            self.managedImageURL = url
        }
        get {
            managedImageURL ?? "http://www.yoprogramo.com/wp-content/uploads/2015/08/human-error-in-finance-640x324.jpg"
        }
    }

    var progressId: String? {
        get {
            managedProgressId
        }
        set(value) {
            managedProgressId = value
        }
    }

    var slug: String? {
        set(slug) {
            self.managedSlug = slug
        }
        get {
            managedSlug
        }
    }

    var lastStepId: String? {
        set(id) {
            self.managedLastStepId = id
        }
        get {
            managedLastStepId
        }
    }

    var enrolled: Bool {
        set(enrolled) {
            self.managedEnrolled = enrolled as NSNumber?
        }
        get {
            managedEnrolled?.boolValue ?? false
        }
    }

    var featured: Bool {
        set(featured) {
            self.managedFeatured = featured as NSNumber?
        }
        get {
            managedFeatured?.boolValue ?? false
        }
    }

    var isProctored: Bool {
        get {
            self.managedIsProctored?.boolValue ?? false
        }
        set {
            self.managedIsProctored = NSNumber(value: newValue)
        }
    }

    var isFavorite: Bool {
        get {
            self.managedIsFavorite?.boolValue ?? false
        }
        set {
            self.managedIsFavorite = NSNumber(value: newValue)
        }
    }

    var isArchived: Bool {
        get {
            self.managedIsArchived?.boolValue ?? false
        }
        set {
            self.managedIsArchived = NSNumber(value: newValue)
        }
    }

    var isInWishlist: Bool {
        get {
            self.managedIsInWishlist?.boolValue ?? false
        }
        set {
            self.managedIsInWishlist = NSNumber(value: newValue)
        }
    }

    var isPublic: Bool {
        set(isPublic) {
            self.managedPublic = isPublic as NSNumber?
        }
        get {
            managedPublic?.boolValue ?? false
        }
    }

    var isPaid: Bool {
        set {
            self.managedIsPaid = newValue as NSNumber?
        }
        get {
            managedIsPaid?.boolValue ?? false
        }
    }

    var displayPrice: String? {
        get {
            self.managedDisplayPrice
        }
        set {
            self.managedDisplayPrice = newValue
        }
    }

    var displayPriceIAP: String? {
        get {
            self.managedDisplayPriceIAP
        }
        set {
            self.managedDisplayPriceIAP = newValue
        }
    }

    var priceTier: Int? {
        get {
            self.managedPriceTier?.intValue
        }
        set {
            self.managedPriceTier = newValue as NSNumber?
        }
    }

    var currencyCode: String? {
        get {
            self.managedCurrencyCode
        }
        set {
            self.managedCurrencyCode = newValue
        }
    }

    var readiness: Float? {
        set {
            self.managedReadiness = newValue as NSNumber?
        }
        get {
            self.managedReadiness?.floatValue
        }
    }

    var summary: String {
        set(value) {
            self.managedSummary = value
        }
        get {
            managedSummary ?? ""
        }
    }

    var workload: String {
        set(value) {
            self.managedWorkload = value
        }
        get {
            managedWorkload ?? ""
        }
    }

    var introURL: String {
        set(value) {
            self.managedIntroURL = value
        }
        get {
            //YOU ARE GETTING RICK ROLLED HERE
//            return (managedIntroURL != nil && managedIntroURL != "") ? managedIntroURL! : "https://player.vimeo.com/video/2619976"
            return (managedIntroURL != nil && managedIntroURL != "") ? managedIntroURL! : ""
        }
    }

    var format: String {
        set(value) {
            self.managedFormat = value
        }
        get {
            managedFormat ?? ""
        }
    }

    var audience: String {
        set(value) {
            self.managedAudience = value
        }
        get {
            managedAudience ?? ""
        }
    }

    var certificate: String {
        set(value) {
            self.managedCertificate = value
        }
        get {
            managedCertificate ?? ""
        }
    }

    var certificateEntity: Certificate? {
        get {
            self.managedCertificateEntity
        }
        set {
            self.managedCertificateEntity = newValue
        }
    }

    var certificateRegularThreshold: Int? {
        get {
            self.managedCertificateRegularThreshold?.intValue
        }
        set {
            self.managedCertificateRegularThreshold = newValue as NSNumber?
        }
    }

    var certificateDistinctionThreshold: Int? {
        get {
            self.managedCertificateDistinctionThreshold?.intValue
        }
        set {
            self.managedCertificateDistinctionThreshold = newValue as NSNumber?
        }
    }

    var isCertificatesAutoIssued: Bool {
        set {
            self.managedIsCertificateAutoIssued = newValue as NSNumber?
        }
        get {
            self.managedIsCertificateAutoIssued?.boolValue ?? false
        }
    }

    var isCertificateIssued: Bool {
        get {
            self.managedIsCertificateIssued?.boolValue ?? false
        }
        set {
            self.managedIsCertificateIssued = newValue as NSNumber?
        }
    }

    var isWithCertificate: Bool {
        get {
            self.managedWithCertificate?.boolValue ?? false
        }
        set {
            self.managedWithCertificate = NSNumber(value: newValue)
        }
    }

    var requirements: String {
        set(value) {
            self.managedRequirements = value
        }
        get {
            managedRequirements ?? ""
        }
    }

    var timeToComplete: Int? {
        get {
            self.managedTimeToComplete?.intValue
        }
        set {
            self.managedTimeToComplete = newValue as NSNumber?
        }
    }

    var languageCode: String {
        get {
            self.managedLanguageCode ?? ""
        }
        set {
            self.managedLanguageCode = newValue
        }
    }

    var defaultPromoCodeName: String? {
        get {
            self.managedDefaultPromoCodeName
        }
        set {
            self.managedDefaultPromoCodeName = newValue
        }
    }

    var defaultPromoCodePrice: Float? {
        get {
            self.managedDefaultPromoCodePrice?.floatValue
        }
        set {
            self.managedDefaultPromoCodePrice = newValue as NSNumber?
        }
    }

    var defaultPromoCodeDiscount: Float? {
        get {
            self.managedDefaultPromoCodeDiscount?.floatValue
        }
        set {
            self.managedDefaultPromoCodeDiscount = newValue as NSNumber?
        }
    }

    var defaultPromoCodeExpireDate: Date? {
        get {
            self.managedDefaultPromoCodeExpireDate
        }
        set {
            self.managedDefaultPromoCodeExpireDate = newValue
        }
    }

    var canViewRevenue: Bool {
        get {
            self.managedCanViewRevenue?.boolValue ?? false
        }
        set {
            self.managedCanViewRevenue = NSNumber(value: newValue)
        }
    }

    var canCreateAnnouncements: Bool {
        get {
            self.managedCanCreateAnnouncements.boolValue
        }
        set {
            self.managedCanCreateAnnouncements = NSNumber(value: newValue)
        }
    }

    var progress: Progress? {
        get {
            managedProgress
        }
        set(value) {
            managedProgress = value
        }
    }

    var lastStep: LastStep? {
        get {
            managedLastStep
        }
        set(value) {
            managedLastStep = value
        }
    }

    var lastCodeLanguage: LastCodeLanguage? {
        get {
            self.managedLastCodeLanguage
        }
        set {
            self.managedLastCodeLanguage = newValue
        }
    }

    var instructors: [User] {
        get {
            (managedInstructors?.array as? [User]) ?? []
        }
        set(instructors) {
            managedInstructors = NSOrderedSet(array: instructors)
        }
    }

    func addInstructor(_ instructor: User) {
        let mutableItems = managedInstructors?.mutableCopy() as! NSMutableOrderedSet
        mutableItems.add(instructor)
        managedInstructors = mutableItems.copy() as? NSOrderedSet
    }

    var sectionsArray: [Section.IdType] {
        get {
            self.managedSectionsArray as? [Section.IdType] ?? []
        }
        set {
            self.managedSectionsArray = NSArray(array: newValue)
        }
    }

    var instructorsArray: [User.IdType] {
        get {
            self.managedInstructorsArray as? [User.IdType] ?? []
        }
        set {
            self.managedInstructorsArray = NSArray(array: newValue)
        }
    }

    var sections: [Section] {
        get {
            (managedSections?.array as? [Section]) ?? []
        }

        set(sections) {
            managedSections = NSOrderedSet(array: sections)
        }
    }

    var authorsArray: [User.IdType] {
        get {
            self.managedAuthorsArray as? [User.IdType] ?? []
        }
        set {
            self.managedAuthorsArray = NSArray(array: newValue)
        }
    }

    var announcementsArray: [Announcement.IdType] {
        get {
            self.managedAnnouncementsArray as? [Announcement.IdType] ?? []
        }
        set {
            self.managedAnnouncementsArray = NSArray(array: newValue)
        }
    }

    var authors: [User] {
        get {
            (self.managedAuthors?.array as? [User]) ?? []
        }
        set {
            self.managedAuthors = NSOrderedSet(array: newValue)
        }
    }

    var introVideo: Video? {
        get {
            managedIntroVideo
        }
        set(value) {
            managedIntroVideo = value
        }
    }

    var reviewSummary: CourseReviewSummary? {
        get {
            managedReviewSummary
        }
        set(value) {
            managedReviewSummary = value
        }
    }

    var purchases: [CoursePurchase] {
        get {
            (self.managedCoursePurchases?.array as? [CoursePurchase]) ?? []
        }
        set {
            self.managedCoursePurchases = NSOrderedSet(array: newValue)
        }
    }

    var userCourse: UserCourse? {
        get {
            self.managedUserCourse
        }
        set {
            self.managedUserCourse = newValue
        }
    }

    var courseBenefitSummaries: [CourseBenefitSummary] {
        get {
            self.managedCourseBenefitSummaries?.allObjects as! [CourseBenefitSummary]
        }
        set {
            self.managedCourseBenefitSummaries = NSSet(array: newValue)
        }
    }

    var courseBenefits: [CourseBenefit] {
        get {
            self.managedCourseBenefits?.array as? [CourseBenefit] ?? []
        }
        set {
            self.managedCourseBenefits = NSOrderedSet(array: newValue)
        }
    }

    var courseBenefitByMonths: [CourseBenefitByMonth] {
        get {
            self.managedCourseBenefitByMonths?.array as? [CourseBenefitByMonth] ?? []
        }
        set {
            self.managedCourseBenefitByMonths = NSOrderedSet(array: newValue)
        }
    }

    var courseBeneficiaries: [CourseBeneficiary] {
        get {
            self.managedCourseBeneficiaries?.allObjects as! [CourseBeneficiary]
        }
        set {
            self.managedCourseBeneficiaries = NSSet(array: newValue)
        }
    }

    var announcements: [Announcement] {
        get {
            self.managedAnnouncements?.allObjects as! [Announcement]
        }
        set {
            self.managedAnnouncements = NSSet(array: newValue)
        }
    }

    var wishlistEntries: [WishlistEntryEntity] {
        get {
            self.managedWishlistEntries?.array as? [WishlistEntryEntity] ?? []
        }
        set {
            self.managedWishlistEntries = NSOrderedSet(array: newValue)
        }
    }

    func addSection(_ section: Section) {
        let mutableItems = managedSections?.mutableCopy() as! NSMutableOrderedSet
        mutableItems.add(section)
        managedSections = mutableItems.copy() as? NSOrderedSet
    }

    func addAuthor(_ author: User) {
        let mutableItems = self.managedAuthors?.mutableCopy() as! NSMutableOrderedSet
        mutableItems.add(author)
        self.managedAuthors = mutableItems.copy() as? NSOrderedSet
    }
}

import CoreData

extension User {
    @NSManaged var managedId: NSNumber?
    @NSManaged var managedProfile: NSNumber?
    @NSManaged var managedPrivate: NSNumber?
    @NSManaged var managedActive: NSNumber?
    @NSManaged var managedGuest: NSNumber?
    @NSManaged var managedOrganization: NSNumber?
    @NSManaged var managedBio: String?
    @NSManaged var managedDetails: String?
    @NSManaged var managedFirstName: String?
    @NSManaged var managedLastName: String?
    @NSManaged var managedAvatarURL: String?
    @NSManaged var managedCover: String?
    @NSManaged var managedKnowledge: NSNumber?
    @NSManaged var managedKnowledgeRank: NSNumber?
    @NSManaged var managedReputation: NSNumber?
    @NSManaged var managedReputationRank: NSNumber?
    @NSManaged var managedJoinDate: Date?
    @NSManaged var managedCreatedCoursesArray: NSObject?
    @NSManaged var managedCreatedCoursesCount: NSNumber?
    @NSManaged var managedSolvedStepsCount: NSNumber?
    @NSManaged var managedCreatedLessonsCount: NSNumber?
    @NSManaged var managedIssuedCertificatesCount: NSNumber?
    @NSManaged var managedFollowersCount: NSNumber?
    @NSManaged var managedSocialProfilesArray: NSObject?

    @NSManaged var managedInstructedCourses: NSSet?
    @NSManaged var managedAuthoredCourses: NSSet?
    @NSManaged var managedAttempts: NSSet?
    @NSManaged var managedSocialProfiles: NSOrderedSet?
    @NSManaged var managedBuyerCourseBenefits: NSSet?
    @NSManaged var managedCourseBenefitByMonths: NSSet?
    @NSManaged var managedCourseBeneficiaries: NSSet?
    @NSManaged var managedSearchResults: NSSet?
    @NSManaged var managedAnnouncements: NSSet?
    @NSManaged var managedWishlistEntries: NSOrderedSet?

    @NSManaged var managedProfileEntity: Profile?
    @NSManaged var managedUserCourse: UserCourse?

    var id: Int {
        set(value) {
            managedId = value as NSNumber?
        }
        get {
            managedId?.intValue ?? 0
        }
    }

    var profile: Int {
        set(value) {
            managedProfile = value as NSNumber?
        }
        get {
            managedProfile?.intValue ?? 0
        }
    }

    var joinDate: Date? {
        set(value) {
            managedJoinDate = value
        }
        get {
            managedJoinDate
        }
    }

    var isPrivate: Bool {
        set(value) {
            self.managedPrivate = value as NSNumber?
        }
        get {
            self.managedPrivate?.boolValue ?? false
        }
    }

    /// Designates whether this user should be treated as active.
    var isActive: Bool {
        get {
            self.managedActive?.boolValue ?? true
        }
        set {
            self.managedActive = NSNumber(value: newValue)
        }
    }

    var isGuest: Bool {
        get {
            self.managedGuest?.boolValue ?? false
        }
        set {
            self.managedGuest = NSNumber(value: newValue)
        }
    }

    var isOrganization: Bool {
        get {
            self.managedOrganization?.boolValue ?? false
        }
        set {
            self.managedOrganization = newValue as NSNumber?
        }
    }

    var bio: String {
        set(value) {
            managedBio = value
        }
        get {
            managedBio ?? "No bio"
        }
    }

    var details: String {
        get {
            self.managedDetails ?? ""
        }
        set {
            self.managedDetails = newValue
        }
    }

    var firstName: String {
        set(value) {
            managedFirstName = value
        }
        get {
            managedFirstName ?? "No first name"
        }
    }

    var lastName: String {
        set(value) {
            managedLastName = value
        }
        get {
            managedLastName ?? "No last name"
        }
    }

    var shortName: String {
        let firstName = self.firstName.trimmed()
        return firstName.isEmpty ? "User" : firstName
    }

    var fullName: String {
        "\(self.firstName) \(self.lastName)".trimmed()
    }

    var avatarURL: String {
        set(value) {
            managedAvatarURL = value
        }
        get {
            managedAvatarURL ?? "http://www.yoprogramo.com/wp-content/uploads/2015/08/human-error-in-finance-640x324.jpg"
        }
    }

    var cover: String? {
        get {
            self.managedCover
        }
        set {
            self.managedCover = newValue
        }
    }

    var knowledge: Int {
        get {
            self.managedKnowledge?.intValue ?? 0
        }
        set {
            self.managedKnowledge = newValue as NSNumber?
        }
    }

    var knowledgeRank: Int {
        get {
            self.managedKnowledgeRank?.intValue ?? 0
        }
        set {
            self.managedKnowledgeRank = newValue as NSNumber?
        }
    }

    var reputation: Int {
        get {
            self.managedReputation?.intValue ?? 0
        }
        set {
            self.managedReputation = newValue as NSNumber?
        }
    }

    var reputationRank: Int {
        get {
            self.managedReputationRank?.intValue ?? 0
        }
        set {
            self.managedReputationRank = newValue as NSNumber?
        }
    }


    var socialProfilesArray: [SocialProfile.IdType] {
        get {
            self.managedSocialProfilesArray as? [SocialProfile.IdType] ?? []
        }
        set {
            self.managedSocialProfilesArray = NSArray(array: newValue)
        }
    }

    var createdCoursesArray: [Course.IdType] {
        get {
            self.managedCreatedCoursesArray as? [Course.IdType] ?? []
        }
        set {
            self.managedCreatedCoursesArray = NSArray(array: newValue)
        }
    }

    var createdCoursesCount: Int {
        get {
            self.managedCreatedCoursesCount?.intValue ?? 0
        }
        set {
            self.managedCreatedCoursesCount = newValue as NSNumber?
        }
    }

    var solvedStepsCount: Int {
        get {
            self.managedSolvedStepsCount?.intValue ?? 0
        }
        set {
            self.managedSolvedStepsCount = newValue as NSNumber?
        }
    }

    var createdLessonsCount: Int {
        get {
            self.managedCreatedLessonsCount?.intValue ?? 0
        }
        set {
            self.managedCreatedLessonsCount = newValue as NSNumber?
        }
    }

    var issuedCertificatesCount: Int {
        get {
            self.managedIssuedCertificatesCount?.intValue ?? 0
        }
        set {
            self.managedIssuedCertificatesCount = newValue as NSNumber?
        }
    }

    var followersCount: Int {
        get {
            self.managedFollowersCount?.intValue ?? 0
        }
        set {
            self.managedFollowersCount = newValue as NSNumber?
        }
    }

    var attempts: [AttemptEntity] {
        get {
            self.managedAttempts?.allObjects as! [AttemptEntity]
        }
        set {
            self.managedAttempts = NSSet(array: newValue)
        }
    }

    var instructedCourses: [Course] {
        get {
            managedInstructedCourses?.allObjects as! [Course]
        }
    }

    var socialProfiles: [SocialProfile] {
        get {
            (self.managedSocialProfiles?.array as? [SocialProfile]) ?? []
        }
        set {
            self.managedSocialProfiles = NSOrderedSet(array: newValue)
        }
    }

    var profileEntity: Profile? {
        get {
            managedProfileEntity
        }
        set(value) {
            managedProfileEntity = value
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

    var buyerCourseBenefits: [CourseBenefit] {
        get {
            self.managedBuyerCourseBenefits?.allObjects as! [CourseBenefit]
        }
        set {
            self.managedBuyerCourseBenefits = NSSet(array: newValue)
        }
    }

    var courseBenefitByMonths: [CourseBenefitByMonth] {
        get {
            self.managedCourseBenefitByMonths?.allObjects as! [CourseBenefitByMonth]
        }
        set {
            self.managedCourseBenefitByMonths = NSSet(array: newValue)
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

    var searchResults: [SearchResult] {
        get {
            self.managedSearchResults?.allObjects as! [SearchResult]
        }
        set {
            self.managedSearchResults = NSSet(array: newValue)
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

    var authoredCourses: [Course] {
        get {
            self.managedAuthoredCourses?.allObjects as! [Course]
        }
    }

    func addInstructedCourse(_ course: Course) {
        var mutableItems = managedInstructedCourses?.allObjects as! [Course]
        mutableItems += [course]
        managedInstructedCourses = NSSet(array: mutableItems)
    }

    func addAuthoredCourse(_ course: Course) {
        var mutableItems = self.managedAuthoredCourses?.allObjects as! [Course]
        mutableItems += [course]
        self.managedAuthoredCourses = NSSet(array: mutableItems)
    }
}

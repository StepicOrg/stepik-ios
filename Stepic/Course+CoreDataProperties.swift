//
//  Course+CoreDataProperties.swift
//  
//
//  Created by Alexander Karpov on 25.09.15.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import CoreData
import Foundation

extension Course {
    @NSManaged var managedId: NSNumber?
    @NSManaged var managedBeginDate: Date?
    @NSManaged var managedCourseDescription: String?
    @NSManaged var managedTitle: String?
    @NSManaged var managedEndDate: Date?
    @NSManaged var managedImageURL: String?
    @NSManaged var managedEnrolled: NSNumber?
    @NSManaged var managedFeatured: NSNumber?
    @NSManaged var managedPublic: NSNumber?
    @NSManaged var managedLearnersCount: NSNumber?
    @NSManaged var managedReadiness: NSNumber?

    @NSManaged var managedScheduleType: String?
    @NSManaged var managedSummary: String?
    @NSManaged var managedReviewSummaryId: NSNumber?
    @NSManaged var managedWorkload: String?
    @NSManaged var managedIntroURL: String?
    @NSManaged var managedFormat: String?
    @NSManaged var managedAudience: String?
    @NSManaged var managedCertificate: String?
    @NSManaged var managedCertificateRegularThreshold: NSNumber?
    @NSManaged var managedCertificateDistinctionThreshold: NSNumber?
    @NSManaged var managedRequirements: String?
    @NSManaged var managedSlug: String?
    @NSManaged var managedProgressId: String?
    @NSManaged var managedLastStepId: String?
    @NSManaged var managedTimeToComplete: NSNumber?
    @NSManaged var managedLanguageCode: String?
    @NSManaged var managedTotalUnits: NSNumber?

    @NSManaged var managedSectionsArray: NSObject?
    @NSManaged var managedInstructorsArray: NSObject?
    @NSManaged var managedAuthorsArray: NSObject?

    @NSManaged var managedIsCertificateAutoIssued: NSNumber?
    @NSManaged var managedIsPaid: NSNumber?
    @NSManaged var managedDisplayPrice: String?

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

    static var oldEntity: NSEntityDescription {
        NSEntityDescription.entity(forEntityName: "Course", in: CoreDataHelper.instance.context)!
    }

    convenience init() {
        self.init(entity: Course.oldEntity, insertInto: CoreDataHelper.instance.context)
    }

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

    var beginDate: Date? {
        set(date) {
            self.managedBeginDate = date
        }
        get {
             managedBeginDate
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

    var endDate: Date? {
        set(date) {
            self.managedEndDate = date
        }
        get {
             managedEndDate
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

    var isPublic: Bool {
        set(isPublic) {
            self.managedPublic = isPublic as NSNumber?
        }
        get {
             managedPublic?.boolValue ?? false
        }
    }

    var isCertificatesAutoIssued: Bool {
        set {
            self.managedIsCertificateAutoIssued = newValue as NSNumber?
        }
        get {
             managedIsCertificateAutoIssued?.boolValue ?? false
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
        set {
            self.managedDisplayPrice = newValue
        }
        get {
             managedDisplayPrice
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

    var sectionsArray: [Int] {
        set(value) {
            self.managedSectionsArray = value as NSObject?
        }
        get {
             (self.managedSectionsArray as? [Int]) ?? []
        }
    }

    var instructorsArray: [Int] {
        set(value) {
            self.managedInstructorsArray = value as NSObject?
        }
        get {
             (self.managedInstructorsArray as? [Int]) ?? []
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

    var authorsArray: [Int] {
        get {
             (self.managedAuthorsArray as? [Int]) ?? []
        }
        set {
            self.managedAuthorsArray = newValue as NSObject?
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

    var canWriteReview: Bool {
        if let progress = self.progress {
            return (Double(progress.numberOfStepsPassed) * 100.0 / Double(progress.numberOfSteps)) >= 80.0
        }
        return false
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

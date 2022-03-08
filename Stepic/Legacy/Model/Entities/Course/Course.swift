import CoreData
import PromiseKit
import SwiftyJSON

@objc
final class Course: NSManagedObject, ManagedObject, IDFetchable {
    typealias IdType = Int

    var sectionDeadlines: [SectionDeadline]? {
        (PersonalDeadlineLocalStorageManager().getRecord(for: self)?.data as? DeadlineStorageRecordData)?.deadlines
    }

    var metaInfo: String {
        if let progress = self.progress {
            let percentage = progress.numberOfSteps != 0
                ? Int(Double(progress.numberOfStepsPassed) / Double(progress.numberOfSteps) * 100)
                : 100
            return "\(NSLocalizedString("PassedPercent", comment: "")) \(percentage)%"
        } else {
            return ""
        }
    }

    var nearestDeadlines: (nearest: Date?, second: Date?)? {
        if sections.isEmpty {
            return nil
        }

        var deadlinesSet = Set<TimeInterval>()
        for section in sections {
            if let soft = section.softDeadline {
                deadlinesSet.insert(soft.timeIntervalSince1970)
            }
            if let hard = section.hardDeadline {
                deadlinesSet.insert(hard.timeIntervalSince1970)
            }
        }

        let deadlines = deadlinesSet.sorted()

        for (index, deadline) in deadlines.enumerated() {
            if deadline > Date().timeIntervalSince1970 {
                if index + 1 < deadlines.count {
                    return (
                        nearest: Date(timeIntervalSince1970: deadline),
                        second: Date(timeIntervalSince1970: deadlines[index + 1])
                    )
                } else {
                    return (nearest: Date(timeIntervalSince1970: deadline), second: nil)
                }
            }
        }

        return (nearest: nil, second: nil)
    }

    var canContinue: Bool {
        self.totalUnits > 0
            && self.scheduleType != "upcoming"
            && self.scheduleType != "ended"
            && (self.isEnabled || !self.canEditCourse)
    }

    var canWriteReview: Bool {
        if let progress = self.progress {
            return (Double(progress.numberOfStepsPassed) * 100.0 / Double(progress.numberOfSteps)) >= 80.0
        }
        return false
    }

    var isPurchased: Bool {
        self.purchases.contains(where: { $0.isActive })
    }

    var anyCertificateThreshold: Int? {
        self.certificateRegularThreshold ?? self.certificateDistinctionThreshold
    }

    var defaultPromoCode: PromoCode? {
        if let defaultPromoCodeName = self.defaultPromoCodeName,
           let defaultPromoCodePrice = self.defaultPromoCodePrice {
            return PromoCode(
                courseID: self.id,
                name: defaultPromoCodeName,
                price: defaultPromoCodePrice,
                currencyCode: self.currencyCode ?? "RUB",
                expireDate: self.defaultPromoCodeExpireDate
            )
        }
        return nil
    }

    required convenience init(json: JSON) {
        self.init(entity: Self.entity, insertInto: CoreDataHelper.shared.context)
        self.update(json: json)
    }

    func update(json: JSON) {
        self.id = json[JSONKey.id.rawValue].intValue
        self.title = json[JSONKey.title.rawValue].stringValue
        self.courseDescription = json[JSONKey.description.rawValue].stringValue
        self.coverURLString = "\(StepikApplicationsInfo.stepikURL)" + json[JSONKey.cover.rawValue].stringValue

        self.beginDate = Parser.dateFromTimedateJSON(json[JSONKey.beginDate.rawValue])
        self.endDate = Parser.dateFromTimedateJSON(json[JSONKey.endDate.rawValue])
        self.beginDateSource = Parser.dateFromTimedateJSON(json[JSONKey.beginDateSource.rawValue])
        self.endDateSource = Parser.dateFromTimedateJSON(json[JSONKey.endDateSource.rawValue])

        self.enrolled = json[JSONKey.enrollment.rawValue].int != nil
        self.featured = json[JSONKey.isFeatured.rawValue].boolValue
        self.isPublic = json[JSONKey.isPublic.rawValue].boolValue
        self.isFavorite = json[JSONKey.isFavorite.rawValue].boolValue
        self.isArchived = json[JSONKey.isArchived.rawValue].boolValue
        self.isInWishlist = json[JSONKey.isInWishlist.rawValue].boolValue
        self.isProctored = json[JSONKey.isProctored.rawValue].boolValue
        self.isEnabled = json[JSONKey.isEnabled.rawValue].bool ?? true
        self.readiness = json[JSONKey.readiness.rawValue].float

        self.summary = json[JSONKey.summary.rawValue].stringValue
        self.workload = json[JSONKey.workload.rawValue].stringValue
        self.introURL = json[JSONKey.intro.rawValue].stringValue
        self.format = json[JSONKey.courseFormat.rawValue].stringValue
        self.audience = json[JSONKey.targetAudience.rawValue].stringValue
        self.requirements = json[JSONKey.requirements.rawValue].stringValue
        self.slug = json[JSONKey.slug.rawValue].string
        self.progressID = json[JSONKey.progress.rawValue].string
        self.lastStepID = json[JSONKey.lastStep.rawValue].string
        self.scheduleType = json[JSONKey.scheduleType.rawValue].string
        self.learnersCount = json[JSONKey.learnersCount.rawValue].int
        self.totalUnits = json[JSONKey.totalUnits.rawValue].intValue
        self.reviewSummaryID = json[JSONKey.reviewSummary.rawValue].int
        self.sectionsArray = json[JSONKey.sections.rawValue].arrayObject as! [Int]
        self.instructorsArray = json[JSONKey.instructors.rawValue].arrayObject as! [Int]
        self.authorsArray = json[JSONKey.authors.rawValue].arrayObject as? [Int] ?? []
        self.announcementsArray = json[JSONKey.announcements.rawValue].arrayObject as? [Int] ?? []
        self.acquiredSkillsArray = json[JSONKey.acquiredSkills.rawValue].arrayObject as? [String] ?? []
        self.timeToComplete = json[JSONKey.timeToComplete.rawValue].int
        self.languageCode = json[JSONKey.language.rawValue].stringValue
        self.isPaid = json[JSONKey.isPaid.rawValue].boolValue
        self.displayPrice = json[JSONKey.displayPrice.rawValue].string
        self.priceTier = json[JSONKey.priceTier.rawValue].int
        self.currencyCode = json[JSONKey.currencyCode.rawValue].string
        self.previewLessonID = json[JSONKey.previewLesson.rawValue].int
        self.previewUnitID = json[JSONKey.previewUnit.rawValue].int

        self.certificate = json[JSONKey.certificate.rawValue].stringValue
        self.certificateRegularThreshold = json[JSONKey.certificateRegularThreshold.rawValue].int
        self.certificateDistinctionThreshold = json[JSONKey.certificateDistinctionThreshold.rawValue].int
        self.isCertificatesAutoIssued = json[JSONKey.isCertificateAutoIssued.rawValue].boolValue
        self.isCertificateIssued = json[JSONKey.isCertificateIssued.rawValue].boolValue
        self.isWithCertificate = json[JSONKey.withCertificate.rawValue].boolValue

        self.defaultPromoCodeName = json[JSONKey.defaultPromoCodeName.rawValue].string
        self.defaultPromoCodePrice = json[JSONKey.defaultPromoCodePrice.rawValue].decimalNumber?.floatValue
        self.defaultPromoCodeDiscount = json[JSONKey.defaultPromoCodeDiscount.rawValue].decimalNumber?.floatValue
        self.defaultPromoCodeExpireDate = Parser.dateFromTimedateJSON(json[JSONKey.defaultPromoCodeExpireDate.rawValue])

        if let _ = json[JSONKey.introVideo.rawValue].null {
            self.introVideo = nil
        } else {
            self.introVideo = Video(json: json[JSONKey.introVideo.rawValue])
        }

        if let actionsDictionary = json[JSONKey.actions.rawValue].dictionary {
            self.canViewRevenue =
                actionsDictionary[JSONKey.viewRevenue.rawValue]?.dictionary?[JSONKey.enabled.rawValue]?.bool ?? false
            self.canCreateAnnouncements = actionsDictionary[JSONKey.createAnnouncements.rawValue]?.string != nil
            self.canEditCourse = actionsDictionary[JSONKey.editCourse.rawValue]?.string != nil
            self.canBeBought =
                actionsDictionary[JSONKey.canBeBought.rawValue]?.dictionary?[JSONKey.enabled.rawValue]?.bool ?? false
        } else {
            self.canViewRevenue = false
            self.canCreateAnnouncements = false
            self.canEditCourse = false
            self.canBeBought = false
        }
    }

    @available(*, deprecated, message: "Legacy")
    static func getAllCourses(enrolled: Bool? = nil) -> [Course] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Course")
        var predicate = NSPredicate(value: true)

        if let enrolled = enrolled {
            let enrolledPredicate = NSPredicate(format: "managedEnrolled == %@", enrolled as NSNumber)
            predicate = NSCompoundPredicate(type: .and, subpredicates: [predicate, enrolledPredicate])
        }

        request.predicate = predicate

        do {
            let results = try CoreDataHelper.shared.context.fetch(request)
            return results as! [Course]
        } catch {
            print("Error while getting courses")
            return []
        }
    }

    // MARK: Inner Types

    enum JSONKey: String {
        case id
        case title
        case description
        case cover
        case beginDate = "begin_date"
        case endDate = "end_date"
        case beginDateSource = "begin_date_source"
        case endDateSource = "end_date_source"
        case enrollment
        case isFeatured = "is_featured"
        case isPublic = "is_public"
        case isFavorite = "is_favorite"
        case isArchived = "is_archived"
        case isInWishlist = "is_in_wishlist"
        case readiness
        case summary
        case workload
        case intro
        case courseFormat = "course_format"
        case targetAudience = "target_audience"
        case certificate
        case certificateRegularThreshold = "certificate_regular_threshold"
        case certificateDistinctionThreshold = "certificate_distinction_threshold"
        case isCertificateAutoIssued = "is_certificate_auto_issued"
        case isCertificateIssued = "is_certificate_issued"
        case withCertificate = "with_certificate"
        case requirements
        case slug
        case progress
        case lastStep = "last_step"
        case scheduleType = "schedule_type"
        case learnersCount = "learners_count"
        case totalUnits = "total_units"
        case reviewSummary = "review_summary"
        case sections
        case instructors
        case authors
        case timeToComplete = "time_to_complete"
        case language
        case isPaid = "is_paid"
        case displayPrice = "display_price"
        case currencyCode = "currency_code"
        case introVideo = "intro_video"
        case priceTier = "price_tier"
        case previewLesson = "preview_lesson"
        case previewUnit = "preview_unit"
        case isProctored = "is_proctored"
        case isEnabled = "is_enabled"
        case canBeBought = "can_be_bought"
        case defaultPromoCodeName = "default_promo_code_name"
        case defaultPromoCodePrice = "default_promo_code_price"
        case defaultPromoCodeDiscount = "default_promo_code_discount"
        case defaultPromoCodeExpireDate = "default_promo_code_expire_date"
        case actions
        case viewRevenue = "view_revenue"
        case enabled
        case editCourse = "edit_course"
        case createAnnouncements = "create_announcements"
        case announcements
        case acquiredSkills = "acquired_skills"
    }
}

import Foundation
import PromiseKit

protocol LogoutDataClearServiceProtocol: AnyObject {
    func clearCurrentUserData() -> Guarantee<Void>
}

final class LogoutDataClearService: LogoutDataClearServiceProtocol {
    private let downloadsDeletionService: DownloadsDeletionServiceProtocol
    // Persistence
    private let assignmentsPersistenceService: AssignmentsPersistenceServiceProtocol
    private let attemptsPersistenceService: AttemptsPersistenceServiceProtocol
    private let blocksPersistenceService: BlocksPersistenceServiceProtocol
    private let certificatesPersistenceService: CertificatesPersistenceServiceProtocol
    private let codeLimitsPersistenceService: CodeLimitsPersistenceServiceProtocol
    private let codeSamplesPersistenceService: CodeSamplesPersistenceServiceProtocol
    private let codeTemplatePersistenceService: CodeTemplatesPersistenceServiceProtocol
    private let courseBeneficiariesPersistenceService: CourseBeneficiariesPersistenceServiceProtocol
    private let courseBenefitByMonthsPersistenceService: CourseBenefitByMonthsPersistenceServiceProtocol
    private let courseBenefitsPersistenceService: CourseBenefitsPersistenceServiceProtocol
    private let courseBenefitSummariesPersistenceService: CourseBenefitSummariesPersistenceServiceProtocol
    private let coursesPersistenceService: CoursesPersistenceServiceProtocol
    private let coursePurchasesPersistenceService: CoursePurchasesPersistenceServiceProtocol
    private let courseReviewsPersistenceService: CourseReviewsPersistenceServiceProtocol
    private let discussionThreadsPersistenceService: DiscussionThreadsPersistenceServiceProtocol
    private let emailAddressesPersistenceService: EmailAddressesPersistenceServiceProtocol
    private let examSessionsPersistenceService: ExamSessionsPersistenceServiceProtocol
    private let lastCodeLanguagePersistenceService: LastCodeLanguagePersistenceServiceProtocol
    private let lastStepPersistenceService: LastStepPersistenceServiceProtocol
    private let lessonsPersistenceService: LessonsPersistenceServiceProtocol
    private let notificationsPersistenceService: NotificationsPersistenceServiceProtocol
    private let proctorSessionsPersistenceService: ProctorSessionsPersistenceServiceProtocol
    private let profilesPersistenceService: ProfilesPersistenceServiceProtocol
    private let progressesPersistenceService: ProgressesPersistenceServiceProtocol
    private let searchQueryResultsPersistenceService: SearchQueryResultsPersistenceServiceProtocol
    private let searchResultsPersistenceService: SearchResultsPersistenceServiceProtocol
    private let sectionsPersistenceService: SectionsPersistenceServiceProtocol
    private let socialProfilesPersistenceService: SocialProfilesPersistenceServiceProtocol
    private let stepOptionsPersistenceService: StepOptionsPersistenceServiceProtocol
    private let stepsPersistenceService: StepsPersistenceServiceProtocol
    private let storyPartsReactionsPersistenceService: StoryPartsReactionsPersistenceServiceProtocol
    private let submissionsPersistenceService: SubmissionsPersistenceServiceProtocol
    private let unitsPersistenceService: UnitsPersistenceServiceProtocol
    private let userActivitiesPersistenceService: UserActivitiesPersistenceServiceProtocol
    private let userCoursesPersistenceService: UserCoursesPersistenceServiceProtocol
    private let videosPersistenceService: VideosPersistenceServiceProtocol
    private let videoURLsPersistenceService: VideoURLsPersistenceServiceProtocol
    // Notifications
    private let notificationsRegistrationService: NotificationsRegistrationServiceProtocol
    private let notificationsService: NotificationsService
    private let notificationsBadgesManager: NotificationsBadgesManager

    private let spotlightIndexingService: SpotlightIndexingServiceProtocol
    private let analyticsUserProperties: AnalyticsUserProperties
    private let deviceDefaults: DeviceDefaults
    private let wishlistService: WishlistServiceProtocol

    private let synchronizationQueue = DispatchQueue(
        label: "com.AlexKarpov.Stepic.LogoutDataClearQueue",
        qos: .userInitiated
    )
    private let semaphore = DispatchSemaphore(value: 1)

    // swiftlint:disable line_length
    init(
        downloadsDeletionService: DownloadsDeletionServiceProtocol = DownloadsDeletionService(),
        assignmentsPersistenceService: AssignmentsPersistenceServiceProtocol = AssignmentsPersistenceService(),
        attemptsPersistenceService: AttemptsPersistenceServiceProtocol = AttemptsPersistenceService(),
        blocksPersistenceService: BlocksPersistenceServiceProtocol = BlocksPersistenceService(),
        certificatesPersistenceService: CertificatesPersistenceServiceProtocol = CertificatesPersistenceService(),
        codeLimitsPersistenceService: CodeLimitsPersistenceServiceProtocol = CodeLimitsPersistenceService(),
        codeSamplesPersistenceService: CodeSamplesPersistenceServiceProtocol = CodeSamplesPersistenceService(),
        codeTemplatePersistenceService: CodeTemplatesPersistenceServiceProtocol = CodeTemplatesPersistenceService(),
        courseBeneficiariesPersistenceService: CourseBeneficiariesPersistenceServiceProtocol = CourseBeneficiariesPersistenceService(),
        courseBenefitByMonthsPersistenceService: CourseBenefitByMonthsPersistenceServiceProtocol = CourseBenefitByMonthsPersistenceService(),
        courseBenefitsPersistenceService: CourseBenefitsPersistenceServiceProtocol = CourseBenefitsPersistenceService(),
        courseBenefitSummariesPersistenceService: CourseBenefitSummariesPersistenceServiceProtocol = CourseBenefitSummariesPersistenceService(),
        coursesPersistenceService: CoursesPersistenceServiceProtocol = CoursesPersistenceService(),
        coursePurchasesPersistenceService: CoursePurchasesPersistenceServiceProtocol = CoursePurchasesPersistenceService(),
        courseReviewsPersistenceService: CourseReviewsPersistenceServiceProtocol = CourseReviewsPersistenceService(),
        discussionThreadsPersistenceService: DiscussionThreadsPersistenceServiceProtocol = DiscussionThreadsPersistenceService(),
        emailAddressesPersistenceService: EmailAddressesPersistenceServiceProtocol = EmailAddressesPersistenceService(),
        examSessionsPersistenceService: ExamSessionsPersistenceServiceProtocol = ExamSessionsPersistenceService(),
        lastCodeLanguagePersistenceService: LastCodeLanguagePersistenceServiceProtocol = LastCodeLanguagePersistenceService(),
        lastStepPersistenceService: LastStepPersistenceServiceProtocol = LastStepPersistenceService(),
        lessonsPersistenceService: LessonsPersistenceServiceProtocol = LessonsPersistenceService(),
        notificationsPersistenceService: NotificationsPersistenceServiceProtocol = NotificationsPersistenceService(),
        proctorSessionsPersistenceService: ProctorSessionsPersistenceServiceProtocol = ProctorSessionsPersistenceService(),
        profilesPersistenceService: ProfilesPersistenceServiceProtocol = ProfilesPersistenceService(),
        progressesPersistenceService: ProgressesPersistenceServiceProtocol = ProgressesPersistenceService(),
        searchQueryResultsPersistenceService: SearchQueryResultsPersistenceServiceProtocol = SearchQueryResultsPersistenceService(),
        searchResultsPersistenceService: SearchResultsPersistenceServiceProtocol = SearchResultsPersistenceService(),
        sectionsPersistenceService: SectionsPersistenceServiceProtocol = SectionsPersistenceService(),
        socialProfilesPersistenceService: SocialProfilesPersistenceServiceProtocol = SocialProfilesPersistenceService(),
        stepOptionsPersistenceService: StepOptionsPersistenceServiceProtocol = StepOptionsPersistenceService(),
        stepsPersistenceService: StepsPersistenceServiceProtocol = StepsPersistenceService(),
        storyPartsReactionsPersistenceService: StoryPartsReactionsPersistenceServiceProtocol = StoryPartsReactionsPersistenceService(),
        submissionsPersistenceService: SubmissionsPersistenceServiceProtocol = SubmissionsPersistenceService(),
        unitsPersistenceService: UnitsPersistenceServiceProtocol = UnitsPersistenceService(),
        userActivitiesPersistenceService: UserActivitiesPersistenceServiceProtocol = UserActivitiesPersistenceService(),
        userCoursesPersistenceService: UserCoursesPersistenceServiceProtocol = UserCoursesPersistenceService(),
        videosPersistenceService: VideosPersistenceServiceProtocol = VideosPersistenceService(),
        videoURLsPersistenceService: VideoURLsPersistenceServiceProtocol = VideoURLsPersistenceService(),
        notificationsRegistrationService: NotificationsRegistrationServiceProtocol = NotificationsRegistrationService(),
        notificationsService: NotificationsService = NotificationsService(),
        spotlightIndexingService: SpotlightIndexingServiceProtocol = SpotlightIndexingService.shared,
        analyticsUserProperties: AnalyticsUserProperties = .shared,
        notificationsBadgesManager: NotificationsBadgesManager = .shared,
        deviceDefaults: DeviceDefaults = .sharedDefaults,
        wishlistService: WishlistServiceProtocol = WishlistService.default
    ) {
        self.downloadsDeletionService = downloadsDeletionService
        self.assignmentsPersistenceService = assignmentsPersistenceService
        self.attemptsPersistenceService = attemptsPersistenceService
        self.blocksPersistenceService = blocksPersistenceService
        self.certificatesPersistenceService = certificatesPersistenceService
        self.codeLimitsPersistenceService = codeLimitsPersistenceService
        self.codeSamplesPersistenceService = codeSamplesPersistenceService
        self.codeTemplatePersistenceService = codeTemplatePersistenceService
        self.courseBeneficiariesPersistenceService = courseBeneficiariesPersistenceService
        self.courseBenefitByMonthsPersistenceService = courseBenefitByMonthsPersistenceService
        self.courseBenefitsPersistenceService = courseBenefitsPersistenceService
        self.courseBenefitSummariesPersistenceService = courseBenefitSummariesPersistenceService
        self.coursesPersistenceService = coursesPersistenceService
        self.coursePurchasesPersistenceService = coursePurchasesPersistenceService
        self.courseReviewsPersistenceService = courseReviewsPersistenceService
        self.discussionThreadsPersistenceService = discussionThreadsPersistenceService
        self.emailAddressesPersistenceService = emailAddressesPersistenceService
        self.examSessionsPersistenceService = examSessionsPersistenceService
        self.lastCodeLanguagePersistenceService = lastCodeLanguagePersistenceService
        self.lastStepPersistenceService = lastStepPersistenceService
        self.lessonsPersistenceService = lessonsPersistenceService
        self.notificationsPersistenceService = notificationsPersistenceService
        self.proctorSessionsPersistenceService = proctorSessionsPersistenceService
        self.profilesPersistenceService = profilesPersistenceService
        self.progressesPersistenceService = progressesPersistenceService
        self.searchQueryResultsPersistenceService = searchQueryResultsPersistenceService
        self.searchResultsPersistenceService = searchResultsPersistenceService
        self.sectionsPersistenceService = sectionsPersistenceService
        self.socialProfilesPersistenceService = socialProfilesPersistenceService
        self.stepOptionsPersistenceService = stepOptionsPersistenceService
        self.stepsPersistenceService = stepsPersistenceService
        self.storyPartsReactionsPersistenceService = storyPartsReactionsPersistenceService
        self.submissionsPersistenceService = submissionsPersistenceService
        self.unitsPersistenceService = unitsPersistenceService
        self.userActivitiesPersistenceService = userActivitiesPersistenceService
        self.userCoursesPersistenceService = userCoursesPersistenceService
        self.videosPersistenceService = videosPersistenceService
        self.videoURLsPersistenceService = videoURLsPersistenceService
        self.notificationsRegistrationService = notificationsRegistrationService
        self.notificationsService = notificationsService
        self.spotlightIndexingService = spotlightIndexingService
        self.analyticsUserProperties = analyticsUserProperties
        self.notificationsBadgesManager = notificationsBadgesManager
        self.deviceDefaults = deviceDefaults
        self.wishlistService = wishlistService
    }

    func clearCurrentUserData() -> Guarantee<Void> {
        Guarantee { seal in
            self.synchronizationQueue.async { [weak self] in
                guard let strongSelf = self else {
                    return seal(())
                }

                strongSelf.semaphore.wait()
                DispatchQueue.main.async {
                    strongSelf.clearData().done {
                        seal(())
                        strongSelf.semaphore.signal()
                    }
                }
            }
        }
    }

    private func clearData() -> Guarantee<Void> {
        when(
            guarantees: [
                self.notificationsRegistrationService.unregisterForRemoteNotifications(),
                self.downloadsDeletionService.deleteAllDownloads(),
                self.clearCourseListPersistenceStorages()
            ]
        ).then { () -> Guarantee<Void> in
            self.clearDatabase()
        }.done {
            self.analyticsUserProperties.clearUserDependentProperties()
            self.notificationsBadgesManager.set(number: 0)

            self.deviceDefaults.deviceId = nil
            self.wishlistService.removeAll()

            self.notificationsService.removeAllLocalNotifications()
            self.spotlightIndexingService.deleteAllSearchableItems()
        }
    }

    // TODO: Refactor this
    private func clearDatabase() -> Guarantee<Void> {
        Guarantee { seal in
            firstly { () -> Guarantee<Void?> in
                Guarantee(self.coursesPersistenceService.unenrollAll(), fallback: nil)
            }.then { _ -> Guarantee<Void?> in
                Guarantee(self.assignmentsPersistenceService.deleteAll(), fallback: nil)
            }.then { _ -> Guarantee<Void?> in
                Guarantee(self.attemptsPersistenceService.deleteAll(), fallback: nil)
            }.then { _ -> Guarantee<Void?> in
                Guarantee(self.blocksPersistenceService.deleteAll(), fallback: nil)
            }.then { _ -> Guarantee<Void?> in
                Guarantee(self.certificatesPersistenceService.deleteAll(), fallback: nil)
            }.then { _ -> Guarantee<Void?> in
                Guarantee(self.codeLimitsPersistenceService.deleteAll(), fallback: nil)
            }.then { _ -> Guarantee<Void?> in
                Guarantee(self.codeSamplesPersistenceService.deleteAll(), fallback: nil)
            }.then { _ -> Guarantee<Void?> in
                Guarantee(self.codeTemplatePersistenceService.deleteAll(), fallback: nil)
            }.then { _ -> Guarantee<Void?> in
                Guarantee(self.courseBeneficiariesPersistenceService.deleteAll(), fallback: nil)
            }.then { _ -> Guarantee<Void?> in
                Guarantee(self.courseBenefitByMonthsPersistenceService.deleteAll(), fallback: nil)
            }.then { _ -> Guarantee<Void?> in
                Guarantee(self.courseBenefitsPersistenceService.deleteAll(), fallback: nil)
            }.then { _ -> Guarantee<Void?> in
                Guarantee(self.courseBenefitSummariesPersistenceService.deleteAll(), fallback: nil)
            }.then { _ -> Guarantee<Void?> in
                Guarantee(self.coursePurchasesPersistenceService.deleteAll(), fallback: nil)
            }.then { _ -> Guarantee<Void?> in
                Guarantee(self.courseReviewsPersistenceService.deleteAll(), fallback: nil)
            }.then { _ -> Guarantee<Void?> in
                Guarantee(self.discussionThreadsPersistenceService.deleteAll(), fallback: nil)
            }.then { _ -> Guarantee<Void?> in
                Guarantee(self.emailAddressesPersistenceService.deleteAll(), fallback: nil)
            }.then { _ -> Guarantee<Void?> in
                Guarantee(self.examSessionsPersistenceService.deleteAll(), fallback: nil)
            }.then { _ -> Guarantee<Void?> in
                Guarantee(self.lastCodeLanguagePersistenceService.deleteAll(), fallback: nil)
            }.then { _ -> Guarantee<Void?> in
                Guarantee(self.lastStepPersistenceService.deleteAll(), fallback: nil)
            }.then { _ -> Guarantee<Void?> in
                Guarantee(self.lessonsPersistenceService.deleteAll(), fallback: nil)
            }.then { _ -> Guarantee<Void?> in
                Guarantee(self.notificationsPersistenceService.deleteAll(), fallback: nil)
            }.then { _ -> Guarantee<Void?> in
                Guarantee(self.proctorSessionsPersistenceService.deleteAll(), fallback: nil)
            }.then { _ -> Guarantee<Void?> in
                Guarantee(self.profilesPersistenceService.deleteAll(), fallback: nil)
            }.then { _ -> Guarantee<Void?> in
                Guarantee(self.progressesPersistenceService.deleteAll(), fallback: nil)
            }.then { _ -> Guarantee<Void?> in
                Guarantee(self.searchQueryResultsPersistenceService.deleteAll(), fallback: nil)
            }.then { _ -> Guarantee<Void?> in
                Guarantee(self.searchResultsPersistenceService.deleteAll(), fallback: nil)
            }.then { _ -> Guarantee<Void?> in
                Guarantee(self.sectionsPersistenceService.deleteAll(), fallback: nil)
            }.then { _ -> Guarantee<Void?> in
                Guarantee(self.socialProfilesPersistenceService.deleteAll(), fallback: nil)
            }.then { _ -> Guarantee<Void?> in
                Guarantee(self.stepsPersistenceService.deleteAll(), fallback: nil)
            }.then { _ -> Guarantee<Void?> in
                Guarantee(self.stepOptionsPersistenceService.deleteAll(), fallback: nil)
            }.then { _ -> Guarantee<Void?> in
                Guarantee(self.storyPartsReactionsPersistenceService.deleteAll(), fallback: nil)
            }.then { _ -> Guarantee<Void?> in
                Guarantee(self.submissionsPersistenceService.deleteAll(), fallback: nil)
            }.then { _ -> Guarantee<Void?> in
                Guarantee(self.unitsPersistenceService.deleteAll(), fallback: nil)
            }.then { _ -> Guarantee<Void?> in
                Guarantee(self.userActivitiesPersistenceService.deleteAll(), fallback: nil)
            }.then { _ -> Guarantee<Void?> in
                Guarantee(self.userCoursesPersistenceService.deleteAll(), fallback: nil)
            }.then { _ -> Guarantee<Void?> in
                Guarantee(self.videosPersistenceService.deleteAll(), fallback: nil)
            }.then { _ -> Guarantee<Void?> in
                Guarantee(self.videoURLsPersistenceService.deleteAll(), fallback: nil)
            }.done { _ in
                CoreDataHelper.shared.save()
                seal(())
            }
        }
    }

    private func clearCourseListPersistenceStorages() -> Guarantee<Void> {
        Guarantee { seal in
            let courseListTypes: [CourseListType] = [
                EnrolledCourseListType(),
                FavoriteCourseListType(),
                ArchivedCourseListType(),
                VisitedCourseListType()
            ]

            for courseListType in courseListTypes {
                let persistenceService = CourseListServicesFactory(type: courseListType).makePersistenceService()
                persistenceService?.update(newCachedList: [])
            }

            seal(())
        }
    }
}

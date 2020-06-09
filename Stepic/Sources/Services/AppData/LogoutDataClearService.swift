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
    private let coursesPersistenceService: CoursesPersistenceServiceProtocol
    private let courseReviewsPersistenceService: CourseReviewsPersistenceServiceProtocol
    private let discussionThreadsPersistenceService: DiscussionThreadsPersistenceServiceProtocol
    private let emailAddressesPersistenceService: EmailAddressesPersistenceServiceProtocol
    private let lastCodeLanguagePersistenceService: LastCodeLanguagePersistenceServiceProtocol
    private let lastStepPersistenceService: LastStepPersistenceServiceProtocol
    private let lessonsPersistenceService: LessonsPersistenceServiceProtocol
    private let notificationsPersistenceService: NotificationsPersistenceServiceProtocol
    private let profilesPersistenceService: ProfilesPersistenceServiceProtocol
    private let progressesPersistenceService: ProgressesPersistenceServiceProtocol
    private let sectionsPersistenceService: SectionsPersistenceServiceProtocol
    private let stepOptionsPersistenceService: StepOptionsPersistenceServiceProtocol
    private let stepsPersistenceService: StepsPersistenceServiceProtocol
    private let submissionsPersistenceService: SubmissionsPersistenceServiceProtocol
    private let unitsPersistenceService: UnitsPersistenceServiceProtocol
    private let userActivitiesPersistenceService: UserActivitiesPersistenceServiceProtocol
    private let userCoursePersistenceService: UserCoursePersistenceServiceProtocol
    private let videosPersistenceService: VideosPersistenceServiceProtocol
    private let videoURLsPersistenceService: VideoURLsPersistenceServiceProtocol
    // Notifications
    private let notificationsRegistrationService: NotificationsRegistrationServiceProtocol
    private let notificationsService: NotificationsService
    private let notificationsBadgesManager: NotificationsBadgesManager

    private let spotlightIndexingService: SpotlightIndexingServiceProtocol
    private let analyticsUserProperties: AnalyticsUserProperties
    private let deviceDefaults: DeviceDefaults

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
        coursesPersistenceService: CoursesPersistenceServiceProtocol = CoursesPersistenceService(),
        courseReviewsPersistenceService: CourseReviewsPersistenceServiceProtocol = CourseReviewsPersistenceService(),
        discussionThreadsPersistenceService: DiscussionThreadsPersistenceServiceProtocol = DiscussionThreadsPersistenceService(),
        emailAddressesPersistenceService: EmailAddressesPersistenceServiceProtocol = EmailAddressesPersistenceService(),
        lastCodeLanguagePersistenceService: LastCodeLanguagePersistenceServiceProtocol = LastCodeLanguagePersistenceService(),
        lastStepPersistenceService: LastStepPersistenceServiceProtocol = LastStepPersistenceService(),
        lessonsPersistenceService: LessonsPersistenceServiceProtocol = LessonsPersistenceService(),
        notificationsPersistenceService: NotificationsPersistenceServiceProtocol = NotificationsPersistenceService(),
        profilesPersistenceService: ProfilesPersistenceServiceProtocol = ProfilesPersistenceService(),
        progressesPersistenceService: ProgressesPersistenceServiceProtocol = ProgressesPersistenceService(),
        sectionsPersistenceService: SectionsPersistenceServiceProtocol = SectionsPersistenceService(),
        stepsPersistenceService: StepsPersistenceServiceProtocol = StepsPersistenceService(),
        stepOptionsPersistenceService: StepOptionsPersistenceServiceProtocol = StepOptionsPersistenceService(),
        submissionsPersistenceService: SubmissionsPersistenceServiceProtocol = SubmissionsPersistenceService(),
        unitsPersistenceService: UnitsPersistenceServiceProtocol = UnitsPersistenceService(),
        userActivitiesPersistenceService: UserActivitiesPersistenceServiceProtocol = UserActivitiesPersistenceService(),
        userCoursePersistenceService: UserCoursePersistenceServiceProtocol = UserCoursePersistenceService(),
        videosPersistenceService: VideosPersistenceServiceProtocol = VideosPersistenceService(),
        videoURLsPersistenceService: VideoURLsPersistenceServiceProtocol = VideoURLsPersistenceService(),
        notificationsRegistrationService: NotificationsRegistrationServiceProtocol = NotificationsRegistrationService(),
        notificationsService: NotificationsService = NotificationsService(),
        spotlightIndexingService: SpotlightIndexingServiceProtocol = SpotlightIndexingService.shared,
        analyticsUserProperties: AnalyticsUserProperties = .shared,
        notificationsBadgesManager: NotificationsBadgesManager = .shared,
        deviceDefaults: DeviceDefaults = .sharedDefaults
    ) {
        self.downloadsDeletionService = downloadsDeletionService
        self.assignmentsPersistenceService = assignmentsPersistenceService
        self.attemptsPersistenceService = attemptsPersistenceService
        self.blocksPersistenceService = blocksPersistenceService
        self.certificatesPersistenceService = certificatesPersistenceService
        self.codeLimitsPersistenceService = codeLimitsPersistenceService
        self.codeSamplesPersistenceService = codeSamplesPersistenceService
        self.codeTemplatePersistenceService = codeTemplatePersistenceService
        self.coursesPersistenceService = coursesPersistenceService
        self.courseReviewsPersistenceService = courseReviewsPersistenceService
        self.discussionThreadsPersistenceService = discussionThreadsPersistenceService
        self.emailAddressesPersistenceService = emailAddressesPersistenceService
        self.lastCodeLanguagePersistenceService = lastCodeLanguagePersistenceService
        self.lastStepPersistenceService = lastStepPersistenceService
        self.lessonsPersistenceService = lessonsPersistenceService
        self.notificationsPersistenceService = notificationsPersistenceService
        self.profilesPersistenceService = profilesPersistenceService
        self.progressesPersistenceService = progressesPersistenceService
        self.sectionsPersistenceService = sectionsPersistenceService
        self.stepsPersistenceService = stepsPersistenceService
        self.stepOptionsPersistenceService = stepOptionsPersistenceService
        self.submissionsPersistenceService = submissionsPersistenceService
        self.unitsPersistenceService = unitsPersistenceService
        self.userActivitiesPersistenceService = userActivitiesPersistenceService
        self.userCoursePersistenceService = userCoursePersistenceService
        self.videosPersistenceService = videosPersistenceService
        self.videoURLsPersistenceService = videoURLsPersistenceService
        self.notificationsRegistrationService = notificationsRegistrationService
        self.notificationsService = notificationsService
        self.spotlightIndexingService = spotlightIndexingService
        self.analyticsUserProperties = analyticsUserProperties
        self.notificationsBadgesManager = notificationsBadgesManager
        self.deviceDefaults = deviceDefaults
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
        firstly { () -> Guarantee<Void> in
            self.notificationsRegistrationService.unregisterForRemoteNotifications()
        }.then { () -> Guarantee<Void> in
            self.downloadsDeletionService.deleteAllDownloads()
        }.then { () -> Guarantee<Void> in
            self.clearDatabase()
        }.done {
            self.analyticsUserProperties.clearUserDependentProperties()
            self.notificationsBadgesManager.set(number: 0)

            self.deviceDefaults.deviceId = nil

            self.notificationsService.removeAllLocalNotifications()
            self.spotlightIndexingService.deleteAllSearchableItems()
        }
    }

    private func clearDatabase() -> Guarantee<Void> {
        Guarantee { seal in
            firstly { () -> Guarantee<[Course]> in
                self.coursesPersistenceService.fetchEnrolled()
            }.then { (enrolledCourses: [Course]) -> Guarantee<[Result<Void>]> in
                for course in enrolledCourses {
                    course.enrolled = false
                }

                return when(
                    resolved: [
                        self.assignmentsPersistenceService.deleteAll(),
                        self.attemptsPersistenceService.deleteAll(),
                        self.blocksPersistenceService.deleteAll(),
                        self.certificatesPersistenceService.deleteAll(),
                        self.codeLimitsPersistenceService.deleteAll(),
                        self.codeSamplesPersistenceService.deleteAll(),
                        self.codeTemplatePersistenceService.deleteAll(),
                        self.courseReviewsPersistenceService.deleteAll(),
                        self.discussionThreadsPersistenceService.deleteAll(),
                        self.emailAddressesPersistenceService.deleteAll(),
                        self.lastCodeLanguagePersistenceService.deleteAll(),
                        self.lastStepPersistenceService.deleteAll(),
                        self.lessonsPersistenceService.deleteAll(),
                        self.notificationsPersistenceService.deleteAll(),
                        self.profilesPersistenceService.deleteAll(),
                        self.progressesPersistenceService.deleteAll(),
                        self.sectionsPersistenceService.deleteAll(),
                        self.stepsPersistenceService.deleteAll(),
                        self.stepOptionsPersistenceService.deleteAll(),
                        self.submissionsPersistenceService.deleteAll(),
                        self.unitsPersistenceService.deleteAll(),
                        self.userActivitiesPersistenceService.deleteAll(),
                        self.userCoursePersistenceService.deleteAll(),
                        self.videosPersistenceService.deleteAll(),
                        self.videoURLsPersistenceService.deleteAll()
                    ]
                )
            }.done { _ in
                CoreDataHelper.shared.save()
                seal(())
            }
        }
    }
}

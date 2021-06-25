import Foundation
import PromiseKit

protocol LessonFinishedStepsPanModalInteractorProtocol {
    func doModalLoad(request: LessonFinishedStepsPanModal.ModalLoad.Request)
    func doModalAction(request: LessonFinishedStepsPanModal.ModalAction.Request)
}

final class LessonFinishedStepsPanModalInteractor: LessonFinishedStepsPanModalInteractorProtocol {
    weak var moduleOutput: LessonFinishedStepsPanModalOutputProtocol?

    private let presenter: LessonFinishedStepsPanModalPresenterProtocol
    private let provider: LessonFinishedStepsPanModalProviderProtocol

    private let courseID: Course.IdType
    private var currentCourse: Course?

    private let analytics: Analytics
    private var shouldOpenedAnalyticsEventSend = true

    init(
        courseID: Course.IdType,
        presenter: LessonFinishedStepsPanModalPresenterProtocol,
        provider: LessonFinishedStepsPanModalProviderProtocol,
        analytics: Analytics
    ) {
        self.courseID = courseID
        self.presenter = presenter
        self.provider = provider
        self.analytics = analytics
    }

    func doModalLoad(request: LessonFinishedStepsPanModal.ModalLoad.Request) {
        self.provider
            .fetchCourseFromNetworkOrCache()
            .compactMap { $0 }
            .then { course -> Guarantee<(Course, CourseReview?)> in
                Guarantee(
                    self.provider.fetchCourseReviewFromNetworkOrCache(),
                    fallback: nil
                ).map { (course, $0?.flatMap({ $0 })) }
            }
            .done { course, courseReviewOrNil in
                self.currentCourse = course

                if let courseReview = courseReviewOrNil {
                    courseReview.course = course
                    CoreDataHelper.shared.save()
                }

                self.sendOpenedAnalyticsEventIfNeeded()
                self.presenter.presentModal(response: .init(course: course, courseReview: courseReviewOrNil))
            }
            .catch { error in
                print("LessonFinishedStepsPanModalInteractor :: failed load data with error = \(error)")
            }
    }

    func doModalAction(request: LessonFinishedStepsPanModal.ModalAction.Request) {
        guard let targetAction = LessonFinishedStepsPanModal.ActionType(rawValue: request.actionUniqueIdentifier),
              let currentCourse = self.currentCourse else {
            return
        }

        switch targetAction {
        case .backToAssignments:
            self.analytics.send(.finishedStepsBackToAssignmentsPressed(course: currentCourse))
            self.presenter.presentBackToAssignments(response: .init())
        case .leaveReview:
            self.analytics.send(.finishedStepsLeaveReviewPressed(course: currentCourse))
            self.moduleOutput?.handleLessonFinishedStepsPanModalLeaveReviewAction()
        case .findNewCourse:
            self.analytics.send(.finishedStepsFindNewCoursePressed(course: currentCourse))
            self.moduleOutput?.handleLessonFinishedStepsPanModalFindNewCourseAction()
        case .shareResult:
            self.analytics.send(.finishedStepsSharePressed(course: currentCourse))
            self.presenter.presentShareResult(response: .init(course: currentCourse))
        case .viewCertificate:
            self.analytics.send(.finishedStepsViewCertificatePressed(course: currentCourse))

            if let certificate = currentCourse.certificateEntity {
                self.presenter.presentCertificate(response: .init(certificate: certificate))
            }
        }
    }

    private func sendOpenedAnalyticsEventIfNeeded() {
        guard self.shouldOpenedAnalyticsEventSend,
              let currentCourse = self.currentCourse else {
            return
        }

        self.shouldOpenedAnalyticsEventSend = false
        self.analytics.send(.finishedStepsScreenOpened(course: currentCourse))
    }
}

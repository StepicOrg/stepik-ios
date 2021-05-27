import Foundation
import PromiseKit

protocol LessonFinishedStepsPanModalInteractorProtocol {
    func doModalLoad(request: LessonFinishedStepsPanModal.ModalLoad.Request)
    func doShareResultPresentation(request: LessonFinishedStepsPanModal.ShareResultPresentation.Request)
    func doCertificatePresentation(request: LessonFinishedStepsPanModal.CertificatePresentation.Request)
    func doLeaveReviewPresentation(request: LessonFinishedStepsPanModal.LeaveReviewPresentation.Request)
    func doFindNewCoursePresentation(request: LessonFinishedStepsPanModal.FindNewCoursePresentation.Request)
}

final class LessonFinishedStepsPanModalInteractor: LessonFinishedStepsPanModalInteractorProtocol {
    weak var moduleOutput: LessonFinishedStepsPanModalOutputProtocol?

    private let presenter: LessonFinishedStepsPanModalPresenterProtocol
    private let provider: LessonFinishedStepsPanModalProviderProtocol

    private let courseID: Course.IdType
    private var currentCourse: Course?

    init(
        courseID: Course.IdType,
        presenter: LessonFinishedStepsPanModalPresenterProtocol,
        provider: LessonFinishedStepsPanModalProviderProtocol
    ) {
        self.courseID = courseID
        self.presenter = presenter
        self.provider = provider
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

                self.presenter.presentModal(response: .init(course: course, courseReview: courseReviewOrNil))
            }
            .catch { error in
                print("LessonFinishedStepsPanModalInteractor :: failed load data with error = \(error)")
            }
    }

    func doShareResultPresentation(request: LessonFinishedStepsPanModal.ShareResultPresentation.Request) {
        if let currentCourse = self.currentCourse {
            self.presenter.presentShareResult(response: .init(course: currentCourse))
        }
    }

    func doCertificatePresentation(request: LessonFinishedStepsPanModal.CertificatePresentation.Request) {
        if let certificate = self.currentCourse?.certificateEntity {
            self.presenter.presentCertificate(response: .init(certificate: certificate))
        }
    }

    func doLeaveReviewPresentation(request: LessonFinishedStepsPanModal.LeaveReviewPresentation.Request) {
        self.moduleOutput?.handleLessonFinishedStepsPanModalLeaveReviewAction()
    }

    func doFindNewCoursePresentation(request: LessonFinishedStepsPanModal.FindNewCoursePresentation.Request) {
        self.moduleOutput?.handleLessonFinishedStepsPanModalFindNewCourseAction()
    }
}

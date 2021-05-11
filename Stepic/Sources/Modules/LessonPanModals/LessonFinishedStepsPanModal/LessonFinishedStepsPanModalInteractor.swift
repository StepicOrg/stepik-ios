import Foundation
import PromiseKit

protocol LessonFinishedStepsPanModalInteractorProtocol {
    func doModalLoad(request: LessonFinishedStepsPanModal.ModalLoad.Request)
}

final class LessonFinishedStepsPanModalInteractor: LessonFinishedStepsPanModalInteractorProtocol {
    weak var moduleOutput: LessonFinishedStepsPanModalOutputProtocol?

    private let presenter: LessonFinishedStepsPanModalPresenterProtocol
    private let provider: LessonFinishedStepsPanModalProviderProtocol

    private let courseID: Course.IdType

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
                if let courseReview = courseReviewOrNil {
                    courseReview.course = course
                    CoreDataHelper.shared.save()
                }

                print("LessonFinishedStepsPanModalInteractor :: did load data = \(course)")

                self.presenter.presentModal(response: .init(course: course, courseReview: courseReviewOrNil))
            }
            .catch { error in
                print("LessonFinishedStepsPanModalInteractor :: failed load data with error = \(error)")
            }
    }
}

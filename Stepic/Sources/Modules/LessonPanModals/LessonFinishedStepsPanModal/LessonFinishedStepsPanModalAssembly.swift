import UIKit

final class LessonFinishedStepsPanModalAssembly: Assembly {
    private let courseID: Course.IdType

    private weak var moduleOutput: LessonFinishedStepsPanModalOutputProtocol?

    init(
        courseID: Course.IdType,
        output: LessonFinishedStepsPanModalOutputProtocol? = nil
    ) {
        self.courseID = courseID
        self.moduleOutput = output
    }

    func makeModule() -> UIViewController {
        let provider = LessonFinishedStepsPanModalProvider(
            courseID: self.courseID,
            coursesPersistenceService: CoursesPersistenceService(),
            coursesNetworkService: CoursesNetworkService(coursesAPI: CoursesAPI()),
            progressesPersistenceService: ProgressesPersistenceService(),
            progressesNetworkService: ProgressesNetworkService(progressesAPI: ProgressesAPI()),
            certificatesPersistenceService: CertificatesPersistenceService(),
            certificatesNetworkService: CertificatesNetworkService(certificatesAPI: CertificatesAPI()),
            courseReviewsPersistenceService: CourseReviewsPersistenceService(),
            courseReviewsNetworkService: CourseReviewsNetworkService(courseReviewsAPI: CourseReviewsAPI()),
            userAccountService: UserAccountService()
        )
        let presenter = LessonFinishedStepsPanModalPresenter(urlFactory: StepikURLFactory())
        let interactor = LessonFinishedStepsPanModalInteractor(
            courseID: self.courseID,
            presenter: presenter,
            provider: provider,
            analytics: StepikAnalytics.shared
        )
        let viewController = LessonFinishedStepsPanModalViewController(interactor: interactor)

        presenter.viewController = viewController
        interactor.moduleOutput = self.moduleOutput

        return viewController
    }
}

import Foundation
import PromiseKit

protocol WriteCourseReviewInteractorProtocol {
    func doCourseReviewLoad(request: WriteCourseReview.CourseReviewLoad.Request)
    func doCourseReviewTextUpdate(request: WriteCourseReview.CourseReviewTextUpdate.Request)
    func doCourseReviewScoreUpdate(request: WriteCourseReview.CourseReviewScoreUpdate.Request)
    func doCourseReviewMainAction(request: WriteCourseReview.CourseReviewMainAction.Request)
}

final class WriteCourseReviewInteractor: WriteCourseReviewInteractorProtocol {
    weak var moduleOutput: WriteCourseReviewOutputProtocol?

    private let presenter: WriteCourseReviewPresenterProtocol
    private let provider: WriteCourseReviewProviderProtocol

    private let courseID: Course.IdType
    private let presentationContext: WriteCourseReview.PresentationContext

    private var currentCourseReview: CourseReview?
    private var currentText: String
    private var currentScore: Int

    init(
        courseID: Course.IdType,
        presentationContext: WriteCourseReview.PresentationContext,
        presenter: WriteCourseReviewPresenterProtocol,
        provider: WriteCourseReviewProviderProtocol
    ) {
        self.courseID = courseID
        self.presenter = presenter
        self.provider = provider
        self.presentationContext = presentationContext

        switch presentationContext {
        case .create(let courseReviewPlainObject):
            self.currentText = courseReviewPlainObject?.text ?? ""
            self.currentScore = courseReviewPlainObject?.score ?? 0
        case .update(let courseReview):
            self.currentCourseReview = courseReview
            self.currentText = courseReview.text
            self.currentScore = courseReview.score
        }
    }

    func doCourseReviewLoad(request: WriteCourseReview.CourseReviewLoad.Request) {
        self.presenter.presentCourseReview(
            response: WriteCourseReview.CourseReviewLoad.Response(
                result: WriteCourseReview.CourseReviewInfo(
                    text: self.currentText,
                    score: self.currentScore
                )
            )
        )
    }

    func doCourseReviewTextUpdate(request: WriteCourseReview.CourseReviewTextUpdate.Request) {
        self.currentText = request.text

        self.presenter.presentCourseReviewTextUpdate(
            response: WriteCourseReview.CourseReviewTextUpdate.Response(
                result: WriteCourseReview.CourseReviewInfo(
                    text: self.currentText,
                    score: self.currentScore
                )
            )
        )
    }

    func doCourseReviewScoreUpdate(request: WriteCourseReview.CourseReviewScoreUpdate.Request) {
        self.currentScore = request.score

        self.presenter.presentCourseReviewScoreUpdate(
            response: WriteCourseReview.CourseReviewScoreUpdate.Response(
                result: WriteCourseReview.CourseReviewInfo(
                    text: self.currentText,
                    score: self.currentScore
                )
            )
        )
    }

    func doCourseReviewMainAction(request: WriteCourseReview.CourseReviewMainAction.Request) {
        let trimmedText = self.currentText.trimmingCharacters(in: .whitespacesAndNewlines)

        self.presenter.presentWaitingState(response: .init(shouldDismiss: false))

        switch self.presentationContext {
        case .create:
            self.createCourseReview(score: self.currentScore, text: trimmedText)
        case .update:
            self.updateCourseReview(self.currentCourseReview.require(), score: self.currentScore, text: trimmedText)
        }
    }

    // MARK: - Private API

    private func createCourseReview(score: Int, text: String) {
        self.provider.create(courseID: self.courseID, score: score, text: text).done { createdCourseReview in
            self.currentCourseReview = createdCourseReview

            self.presenter.presentCourseReviewMainActionResult(
                response: WriteCourseReview.CourseReviewMainAction.Response(isSuccessful: true)
            )
            self.moduleOutput?.handleCourseReviewCreated(createdCourseReview)
        }.catch { _ in
            self.presenter.presentCourseReviewMainActionResult(
                response: WriteCourseReview.CourseReviewMainAction.Response(isSuccessful: false)
            )
        }
    }

    private func updateCourseReview(_ courseReview: CourseReview, score: Int, text: String) {
        courseReview.score = score
        courseReview.text = text

        self.provider.update(courseReview: courseReview).done { updatedCourseReview in
            self.currentCourseReview = updatedCourseReview

            self.presenter.presentCourseReviewMainActionResult(
                response: WriteCourseReview.CourseReviewMainAction.Response(isSuccessful: true)
            )
            self.moduleOutput?.handleCourseReviewUpdated(updatedCourseReview)
        }.catch { _ in
            self.presenter.presentCourseReviewMainActionResult(
                response: WriteCourseReview.CourseReviewMainAction.Response(isSuccessful: false)
            )
        }
    }
}

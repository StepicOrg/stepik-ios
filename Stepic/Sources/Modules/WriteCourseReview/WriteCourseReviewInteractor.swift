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
    private var courseReview: CourseReview?
    private var currentText: String
    private var currentScore: Int

    init(
        courseID: Course.IdType,
        courseReview: CourseReview?,
        presenter: WriteCourseReviewPresenterProtocol,
        provider: WriteCourseReviewProviderProtocol
    ) {
        self.courseID = courseID
        self.courseReview = courseReview
        self.currentText = courseReview?.text ?? ""
        self.currentScore = courseReview?.score ?? 0
        self.presenter = presenter
        self.provider = provider
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

        if let courseReview = self.courseReview {
            self.updateCourseReview(courseReview, score: self.currentScore, text: trimmedText)
        } else {
            self.createCourseReview(score: self.currentScore, text: trimmedText)
        }
    }

    // MARK: - Private API

    private func createCourseReview(score: Int, text: String) {
        self.provider.create(courseID: self.courseID, score: score, text: text).done { _ in
            self.presenter.presentCourseReviewMainActionResult(
                response: WriteCourseReview.CourseReviewMainAction.Response(isSuccessful: true)
            )
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
            self.courseReview = updatedCourseReview
            self.presenter.presentCourseReviewMainActionResult(
                response: WriteCourseReview.CourseReviewMainAction.Response(isSuccessful: true)
            )
        }.catch { _ in
            self.presenter.presentCourseReviewMainActionResult(
                response: WriteCourseReview.CourseReviewMainAction.Response(isSuccessful: false)
            )
        }
    }
}

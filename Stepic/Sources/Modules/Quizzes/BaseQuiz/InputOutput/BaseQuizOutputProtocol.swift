import Foundation

protocol BaseQuizOutputProtocol: AnyObject {
    func handleCorrectSubmission()
    func handleSubmissionEvaluated(submission: Submission)
    func handleNextStepNavigation()
    func handleQuizLoaded(attempt: Attempt, submission: Submission, submissionsCount: Int, source: DataSourceType)
    func handleReviewCreateSession()
    func handleReviewSelectDifferentSubmission()
}

extension BaseQuizOutputProtocol {
    func handleQuizLoaded(attempt: Attempt, submission: Submission, submissionsCount: Int, source: DataSourceType) {}

    func handleReviewCreateSession() {}

    func handleReviewSelectDifferentSubmission() {}
}

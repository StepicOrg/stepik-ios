import Foundation

protocol BaseQuizOutputProtocol: AnyObject {
    func handleCorrectSubmission()
    func handleSubmissionEvaluated()
    func handleNextStepNavigation()
    func handleQuizLoaded(attempt: Attempt, submission: Submission, submissionsCount: Int, source: DataSourceType)
}

extension BaseQuizOutputProtocol {
    func handleQuizLoaded(attempt: Attempt, submission: Submission, submissionsCount: Int, source: DataSourceType) {}
}

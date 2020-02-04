import Foundation

protocol BaseQuizOutputProtocol: AnyObject {
    func handleCorrectSubmission()
    func handleSubmissionEvaluated()
    func handleNextStepNavigation()
}

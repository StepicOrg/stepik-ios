import Foundation

protocol BaseQuizOutputProtocol: AnyObject {
    func handleCorrectSubmission()
    func handleNextStepNavigation()
}

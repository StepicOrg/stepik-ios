import Foundation

protocol StepInputProtocol: AnyObject {
    func updateStepNavigation(canNavigateToPreviousUnit: Bool, canNavigateToNextUnit: Bool, canNavigateToNextStep: Bool)
    func updateStepText(_ text: String)
    func autoplayStep()
}

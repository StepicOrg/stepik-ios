import Foundation

protocol NewStepInputProtocol: AnyObject {
    func updateStepNavigation(canNavigateToPreviousUnit: Bool, canNavigateToNextUnit: Bool, canNavigateToNextStep: Bool)
    func updateStepText(_ text: String)
    func play()
}

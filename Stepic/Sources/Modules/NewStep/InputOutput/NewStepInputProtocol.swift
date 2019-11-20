import Foundation

protocol NewStepInputProtocol: class {
    func updateStepNavigation(canNavigateToPreviousUnit: Bool, canNavigateToNextUnit: Bool, canNavigateToNextStep: Bool)
    func updateStepText(_ text: String)
}

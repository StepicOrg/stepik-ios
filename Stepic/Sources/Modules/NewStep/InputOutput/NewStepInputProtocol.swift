import Foundation

protocol NewStepInputProtocol: class {
    func updateStepNavigation(canNavigateToPreviousUnit: Bool, canNavigateNextUnit: Bool, canNavigateNextStep: Bool)
}

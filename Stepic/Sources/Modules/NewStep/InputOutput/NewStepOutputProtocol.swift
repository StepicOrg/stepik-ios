import Foundation

protocol NewStepOutputProtocol: class {
    func handleStepView(id: Step.IdType)
    func handlePreviousUnitNavigation()
    func handleNextUnitNavigation()
}

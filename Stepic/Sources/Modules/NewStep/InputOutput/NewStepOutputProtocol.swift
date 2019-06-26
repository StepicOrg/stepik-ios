import Foundation

protocol NewStepOutputProtocol: class {
    func handleStepView(id: Step.IdType)
    func handleStepDone(id: Step.IdType)
    func handlePreviousUnitNavigation()
    func handleNextUnitNavigation()
    func handleStepNavigation(to index: Int)
}

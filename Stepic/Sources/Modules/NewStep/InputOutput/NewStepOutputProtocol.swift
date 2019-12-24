import Foundation

protocol NewStepOutputProtocol: AnyObject {
    func handleStepView(id: Step.IdType)
    func handleStepDone(id: Step.IdType)
    func handlePreviousUnitNavigation()
    func handleNextUnitNavigation()
    func handleStepNavigation(to index: Int)
    func handleAutoplayNavigation(from index: Int)
}

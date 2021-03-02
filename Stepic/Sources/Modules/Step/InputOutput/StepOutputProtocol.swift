import Foundation

protocol StepOutputProtocol: AnyObject {
    func handleStepView(id: Step.IdType)
    func handleStepDone(id: Step.IdType)
    func handlePreviousUnitNavigation()
    func handleNextUnitNavigation()
    func handleLessonNavigation(lessonID: Int, stepIndex: Int, unitID: Int?)
    func handleStepNavigation(to index: Int)
    func handleAutoplayNavigation(from index: Int)
}

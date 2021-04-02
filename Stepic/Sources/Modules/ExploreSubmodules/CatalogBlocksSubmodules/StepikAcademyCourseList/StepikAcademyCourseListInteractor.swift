import Foundation
import PromiseKit

protocol StepikAcademyCourseListInteractorProtocol {
    func doSomeAction(request: StepikAcademyCourseList.SomeAction.Request)
}

final class StepikAcademyCourseListInteractor: StepikAcademyCourseListInteractorProtocol {
    weak var moduleOutput: StepikAcademyCourseListOutputProtocol?

    private let presenter: StepikAcademyCourseListPresenterProtocol
    private let provider: StepikAcademyCourseListProviderProtocol

    init(
        presenter: StepikAcademyCourseListPresenterProtocol,
        provider: StepikAcademyCourseListProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doSomeAction(request: StepikAcademyCourseList.SomeAction.Request) {}

    enum Error: Swift.Error {
        case something
    }
}

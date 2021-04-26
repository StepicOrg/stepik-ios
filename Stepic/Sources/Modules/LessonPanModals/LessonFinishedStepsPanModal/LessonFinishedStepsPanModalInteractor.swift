import Foundation
import PromiseKit

protocol LessonFinishedStepsPanModalInteractorProtocol {
    func doSomeAction(request: LessonFinishedStepsPanModal.SomeAction.Request)
}

final class LessonFinishedStepsPanModalInteractor: LessonFinishedStepsPanModalInteractorProtocol {
    weak var moduleOutput: LessonFinishedStepsPanModalOutputProtocol?

    private let presenter: LessonFinishedStepsPanModalPresenterProtocol
    private let provider: LessonFinishedStepsPanModalProviderProtocol

    init(
        presenter: LessonFinishedStepsPanModalPresenterProtocol,
        provider: LessonFinishedStepsPanModalProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doSomeAction(request: LessonFinishedStepsPanModal.SomeAction.Request) {}

    enum Error: Swift.Error {
        case something
    }
}

extension LessonFinishedStepsPanModalInteractor: LessonFinishedStepsPanModalInputProtocol {}

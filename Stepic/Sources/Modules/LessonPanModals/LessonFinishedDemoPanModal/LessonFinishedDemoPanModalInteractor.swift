import Foundation
import PromiseKit

protocol LessonFinishedDemoPanModalInteractorProtocol {
    func doSomeAction(request: LessonFinishedDemoPanModal.SomeAction.Request)
}

final class LessonFinishedDemoPanModalInteractor: LessonFinishedDemoPanModalInteractorProtocol {
    weak var moduleOutput: LessonFinishedDemoPanModalOutputProtocol?

    private let presenter: LessonFinishedDemoPanModalPresenterProtocol
    private let provider: LessonFinishedDemoPanModalProviderProtocol

    init(
        presenter: LessonFinishedDemoPanModalPresenterProtocol,
        provider: LessonFinishedDemoPanModalProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doSomeAction(request: LessonFinishedDemoPanModal.SomeAction.Request) {}
}

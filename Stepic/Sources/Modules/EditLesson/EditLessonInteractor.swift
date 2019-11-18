import Foundation
import PromiseKit

protocol EditLessonInteractorProtocol {
    func doSomeAction(request: EditLesson.SomeAction.Request)
}

final class EditLessonInteractor: EditLessonInteractorProtocol {
    weak var moduleOutput: EditLessonOutputProtocol?

    private let presenter: EditLessonPresenterProtocol
    private let provider: EditLessonProviderProtocol

    init(
        presenter: EditLessonPresenterProtocol,
        provider: EditLessonProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doSomeAction(request: EditLesson.SomeAction.Request) { }

    enum Error: Swift.Error {
        case something
    }
}

extension EditLessonInteractor: EditLessonInputProtocol { }
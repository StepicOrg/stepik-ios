import Foundation
import PromiseKit

protocol NewLessonInteractorProtocol {
    func doSomeAction(request: NewLesson.SomeAction.Request)
}

final class NewLessonInteractor: NewLessonInteractorProtocol {
    weak var moduleOutput: NewLessonOutputProtocol?

    private let presenter: NewLessonPresenterProtocol
    private let provider: NewLessonProviderProtocol

    init(
        presenter: NewLessonPresenterProtocol,
        provider: NewLessonProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doSomeAction(request: NewLesson.SomeAction.Request) { }

    enum Error: Swift.Error {
        case something
    }
}

extension NewLessonInteractor: NewLessonInputProtocol { }
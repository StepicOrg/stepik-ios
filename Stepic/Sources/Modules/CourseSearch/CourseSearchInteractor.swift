import Foundation
import PromiseKit

protocol CourseSearchInteractorProtocol {
    func doSomeAction(request: CourseSearch.SomeAction.Request)
}

final class CourseSearchInteractor: CourseSearchInteractorProtocol {
    weak var moduleOutput: CourseSearchOutputProtocol?

    private let presenter: CourseSearchPresenterProtocol
    private let provider: CourseSearchProviderProtocol

    init(
        presenter: CourseSearchPresenterProtocol,
        provider: CourseSearchProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doSomeAction(request: CourseSearch.SomeAction.Request) {}

    enum Error: Swift.Error {
        case something
    }
}

extension CourseSearchInteractor: CourseSearchInputProtocol {}

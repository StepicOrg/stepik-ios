import Foundation
import PromiseKit

protocol AuthorsCourseListInteractorProtocol {
    func doSomeAction(request: AuthorsCourseList.SomeAction.Request)
}

final class AuthorsCourseListInteractor: AuthorsCourseListInteractorProtocol {
    weak var moduleOutput: AuthorsCourseListOutputProtocol?

    private let presenter: AuthorsCourseListPresenterProtocol
    private let provider: AuthorsCourseListProviderProtocol

    init(
        presenter: AuthorsCourseListPresenterProtocol,
        provider: AuthorsCourseListProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doSomeAction(request: AuthorsCourseList.SomeAction.Request) {}

    enum Error: Swift.Error {
        case something
    }
}

extension AuthorsCourseListInteractor: AuthorsCourseListInputProtocol {}

import Foundation
import PromiseKit

protocol SimpleCourseListInteractorProtocol {
    func doSomeAction(request: SimpleCourseList.SomeAction.Request)
}

final class SimpleCourseListInteractor: SimpleCourseListInteractorProtocol {
    weak var moduleOutput: SimpleCourseListOutputProtocol?

    private let presenter: SimpleCourseListPresenterProtocol
    private let provider: SimpleCourseListProviderProtocol

    init(
        presenter: SimpleCourseListPresenterProtocol,
        provider: SimpleCourseListProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doSomeAction(request: SimpleCourseList.SomeAction.Request) {}

    enum Error: Swift.Error {
        case something
    }
}

extension SimpleCourseListInteractor: SimpleCourseListInputProtocol {}

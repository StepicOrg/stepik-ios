import Foundation
import PromiseKit

protocol NewDiscussionsInteractorProtocol {
    func doSomeAction(request: NewDiscussions.SomeAction.Request)
}

final class NewDiscussionsInteractor: NewDiscussionsInteractorProtocol {
    weak var moduleOutput: NewDiscussionsOutputProtocol?

    private let presenter: NewDiscussionsPresenterProtocol
    private let provider: NewDiscussionsProviderProtocol

    init(
        presenter: NewDiscussionsPresenterProtocol,
        provider: NewDiscussionsProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doSomeAction(request: NewDiscussions.SomeAction.Request) { }

    enum Error: Swift.Error {
        case something
    }
}

extension NewDiscussionsInteractor: NewDiscussionsInputProtocol { }
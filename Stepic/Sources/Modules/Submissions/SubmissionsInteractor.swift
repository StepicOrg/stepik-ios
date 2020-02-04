import Foundation
import PromiseKit

protocol SubmissionsInteractorProtocol {
    func doSomeAction(request: Submissions.SomeAction.Request)
}

final class SubmissionsInteractor: SubmissionsInteractorProtocol {
    weak var moduleOutput: SubmissionsOutputProtocol?

    private let presenter: SubmissionsPresenterProtocol
    private let provider: SubmissionsProviderProtocol

    init(
        presenter: SubmissionsPresenterProtocol,
        provider: SubmissionsProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doSomeAction(request: Submissions.SomeAction.Request) {}

    enum Error: Swift.Error {
        case something
    }
}

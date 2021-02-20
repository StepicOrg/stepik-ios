import Foundation
import PromiseKit

protocol SubmissionsFilterInteractorProtocol {
    func doSomeAction(request: SubmissionsFilter.SomeAction.Request)
}

final class SubmissionsFilterInteractor: SubmissionsFilterInteractorProtocol {
    weak var moduleOutput: SubmissionsFilterOutputProtocol?

    private let presenter: SubmissionsFilterPresenterProtocol

    init(
        presenter: SubmissionsFilterPresenterProtocol
    ) {
        self.presenter = presenter
    }

    func doSomeAction(request: SubmissionsFilter.SomeAction.Request) {}
}

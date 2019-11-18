import Foundation
import PromiseKit

protocol EditStepInteractorProtocol {
    func doSomeAction(request: EditStep.SomeAction.Request)
}

final class EditStepInteractor: EditStepInteractorProtocol {
    weak var moduleOutput: EditStepOutputProtocol?

    private let presenter: EditStepPresenterProtocol
    private let provider: EditStepProviderProtocol

    init(
        presenter: EditStepPresenterProtocol,
        provider: EditStepProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doSomeAction(request: EditStep.SomeAction.Request) { }

    enum Error: Swift.Error {
        case something
    }
}

extension EditStepInteractor: EditStepInputProtocol { }
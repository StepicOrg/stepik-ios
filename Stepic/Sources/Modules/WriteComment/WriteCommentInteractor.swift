import Foundation
import PromiseKit

protocol WriteCommentInteractorProtocol {
    func doSomeAction(request: WriteComment.SomeAction.Request)
}

final class WriteCommentInteractor: WriteCommentInteractorProtocol {
    weak var moduleOutput: WriteCommentOutputProtocol?

    private let presenter: WriteCommentPresenterProtocol
    private let provider: WriteCommentProviderProtocol

    init(
        presenter: WriteCommentPresenterProtocol,
        provider: WriteCommentProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doSomeAction(request: WriteComment.SomeAction.Request) { }

    enum Error: Swift.Error {
        case something
    }
}

extension WriteCommentInteractor: WriteCommentInputProtocol { }
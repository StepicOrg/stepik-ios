import Foundation
import PromiseKit

protocol CourseInfoPurchaseModalInteractorProtocol {
    func doSomeAction(request: CourseInfoPurchaseModal.SomeAction.Request)
}

final class CourseInfoPurchaseModalInteractor: CourseInfoPurchaseModalInteractorProtocol {
    weak var moduleOutput: CourseInfoPurchaseModalOutputProtocol?

    private let presenter: CourseInfoPurchaseModalPresenterProtocol
    private let provider: CourseInfoPurchaseModalProviderProtocol

    init(
        presenter: CourseInfoPurchaseModalPresenterProtocol,
        provider: CourseInfoPurchaseModalProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doSomeAction(request: CourseInfoPurchaseModal.SomeAction.Request) {}

    enum Error: Swift.Error {
        case something
    }
}

extension CourseInfoPurchaseModalInteractor: CourseInfoPurchaseModalInputProtocol {}

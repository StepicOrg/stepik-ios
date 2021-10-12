import Foundation
import PromiseKit

protocol CourseInfoPurchaseModalInteractorProtocol {
    func doModalLoad(request: CourseInfoPurchaseModal.ModalLoad.Request)
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

    func doModalLoad(request: CourseInfoPurchaseModal.ModalLoad.Request) {}

    enum Error: Swift.Error {
        case something
    }
}

extension CourseInfoPurchaseModalInteractor: CourseInfoPurchaseModalInputProtocol {}

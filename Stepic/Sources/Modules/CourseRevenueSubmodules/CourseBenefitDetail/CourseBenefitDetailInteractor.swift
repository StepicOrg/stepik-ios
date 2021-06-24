import Foundation
import PromiseKit

protocol CourseBenefitDetailInteractorProtocol {
    func doSomeAction(request: CourseBenefitDetail.SomeAction.Request)
}

final class CourseBenefitDetailInteractor: CourseBenefitDetailInteractorProtocol {
    weak var moduleOutput: CourseBenefitDetailOutputProtocol?

    private let presenter: CourseBenefitDetailPresenterProtocol
    private let provider: CourseBenefitDetailProviderProtocol

    init(
        presenter: CourseBenefitDetailPresenterProtocol,
        provider: CourseBenefitDetailProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doSomeAction(request: CourseBenefitDetail.SomeAction.Request) {}

    enum Error: Swift.Error {
        case something
    }
}

extension CourseBenefitDetailInteractor: CourseBenefitDetailInputProtocol {}

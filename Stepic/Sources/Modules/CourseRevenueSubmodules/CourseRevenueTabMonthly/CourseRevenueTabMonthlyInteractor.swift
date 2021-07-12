import Foundation
import PromiseKit

protocol CourseRevenueTabMonthlyInteractorProtocol {
    func doSomeAction(request: CourseRevenueTabMonthly.SomeAction.Request)
}

final class CourseRevenueTabMonthlyInteractor: CourseRevenueTabMonthlyInteractorProtocol {
    weak var moduleOutput: CourseRevenueTabMonthlyOutputProtocol?

    private let presenter: CourseRevenueTabMonthlyPresenterProtocol
    private let provider: CourseRevenueTabMonthlyProviderProtocol

    init(
        presenter: CourseRevenueTabMonthlyPresenterProtocol,
        provider: CourseRevenueTabMonthlyProviderProtocol
    ) {
        self.presenter = presenter
        self.provider = provider
    }

    func doSomeAction(request: CourseRevenueTabMonthly.SomeAction.Request) {}

    enum Error: Swift.Error {
        case something
    }
}

extension CourseRevenueTabMonthlyInteractor: CourseRevenueTabMonthlyInputProtocol {}

import UIKit

protocol CourseRevenueTabPurchasesPresenterProtocol {
    func presentPurchases(response: CourseRevenueTabPurchases.PurchasesLoad.Response)
}

final class CourseRevenueTabPurchasesPresenter: CourseRevenueTabPurchasesPresenterProtocol {
    weak var viewController: CourseRevenueTabPurchasesViewControllerProtocol?

    func presentPurchases(response: CourseRevenueTabPurchases.PurchasesLoad.Response) {
        switch response.result {
        case .success(let data):
            let viewModels = data.courseBenefits.map(self.makeViewModel(_:))
            let result = CourseRevenueTabPurchases.PurchasesResult(
                courseBenefits: viewModels,
                hasNextPage: data.hasNextPage
            )
            self.viewController?.displayPurchases(viewModel: .init(state: .result(data: result)))
        case .failure:
            self.viewController?.displayPurchases(viewModel: .init(state: .error))
        }
    }

    private func makeViewModel(_ courseBenefit: CourseBenefit) -> CourseRevenueTabPurchasesViewModel {
        CourseRevenueTabPurchasesViewModel(
            uniqueIdentifier: "\(courseBenefit.id)",
            title: FormatterHelper.price(courseBenefit.totalIncome, currencyCode: courseBenefit.currencyCode)
        )
    }
}

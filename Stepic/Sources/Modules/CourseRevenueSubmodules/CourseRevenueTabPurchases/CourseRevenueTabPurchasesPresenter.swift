import UIKit

protocol CourseRevenueTabPurchasesPresenterProtocol {
    func presentPurchases(response: CourseRevenueTabPurchases.PurchasesLoad.Response)
    func presentNextPurchases(response: CourseRevenueTabPurchases.NextPurchasesLoad.Response)
    func presentPurchaseDetails(response: CourseRevenueTabPurchases.PurchaseDetailsPresentation.Response)
}

final class CourseRevenueTabPurchasesPresenter: CourseRevenueTabPurchasesPresenterProtocol {
    weak var viewController: CourseRevenueTabPurchasesViewControllerProtocol?

    func presentPurchases(response: CourseRevenueTabPurchases.PurchasesLoad.Response) {
        switch response.result {
        case .success(let data):
            let viewModels = data.courseBenefits.map(self.makeViewModel(_:))
            let resultData = CourseRevenueTabPurchases.PurchasesResult(
                courseBenefits: viewModels,
                hasNextPage: data.hasNextPage
            )
            self.viewController?.displayPurchases(viewModel: .init(state: .result(data: resultData)))
        case .failure:
            self.viewController?.displayPurchases(viewModel: .init(state: .error))
        }
    }

    func presentNextPurchases(response: CourseRevenueTabPurchases.NextPurchasesLoad.Response) {
        switch response.result {
        case .success(let data):
            let viewModels = data.courseBenefits.map(self.makeViewModel(_:))
            let resultData = CourseRevenueTabPurchases.PurchasesResult(
                courseBenefits: viewModels,
                hasNextPage: data.hasNextPage
            )
            self.viewController?.displayNextPurchases(viewModel: .init(state: .result(data: resultData)))
        case .failure:
            self.viewController?.displayNextPurchases(viewModel: .init(state: .error))
        }
    }

    func presentPurchaseDetails(response: CourseRevenueTabPurchases.PurchaseDetailsPresentation.Response) {
        self.viewController?.displayPurchaseDetails(viewModel: .init(courseBenefitID: response.courseBenefitID))
    }

    private func makeViewModel(_ courseBenefit: CourseBenefit) -> CourseRevenueTabPurchasesViewModel {
        let formattedBuyerName: String = {
            if let buyer = courseBenefit.buyer {
                return FormatterHelper.username(buyer)
            }
            return "User \(courseBenefit.buyerID)"
        }()
        let formattedDate = FormatterHelper.dateStringWithFullMonthAndYear(courseBenefit.time ?? Date())

        let formattedPaymentAmount = FormatterHelper.price(
            courseBenefit.paymentAmount,
            currencyCode: courseBenefit.currencyCode
        )
        let formattedAmount = FormatterHelper.price(courseBenefit.amount, currencyCode: courseBenefit.currencyCode)

        return CourseRevenueTabPurchasesViewModel(
            uniqueIdentifier: "\(courseBenefit.id)",
            formattedDate: formattedDate,
            buyerName: formattedBuyerName,
            promoCodeName: courseBenefit.promoCode,
            formattedPaymentAmount: formattedPaymentAmount,
            formattedAmount: formattedAmount,
            isDebited: courseBenefit.status == .debited,
            isRefunded: courseBenefit.status == .refunded,
            isZLinkUsed: courseBenefit.isZLinkUsed
        )
    }
}

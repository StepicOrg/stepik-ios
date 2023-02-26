import UIKit

protocol CourseRevenueTabPurchasesPresenterProtocol {
    func presentPurchases(response: CourseRevenueTabPurchases.PurchasesLoad.Response)
    func presentNextPurchases(response: CourseRevenueTabPurchases.NextPurchasesLoad.Response)
    func presentPurchaseDetails(response: CourseRevenueTabPurchases.PurchaseDetailsPresentation.Response)
    func presentLoadingState(response: CourseRevenueTabPurchases.LoadingStatePresentation.Response)
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

    func presentLoadingState(response: CourseRevenueTabPurchases.LoadingStatePresentation.Response) {
        self.viewController?.displayLoadingState(viewModel: .init())
    }

    private func makeViewModel(_ courseBenefit: CourseBenefit) -> CourseRevenueTabPurchasesViewModel {
        let formattedBuyerName: String = {
            if let buyer = courseBenefit.buyer {
                return FormatterHelper.username(buyer)
            }
            return "User \(courseBenefit.buyerID ??? "n/a")"
        }()

        let formattedDate: String = {
            if let moscowDateInRegion = courseBenefit.time?.inEuropeMoscow {
                return FormatterHelper.dateStringWithFullMonthAndYear(moscowDateInRegion)
            }
            return FormatterHelper.dateStringWithFullMonthAndYear(courseBenefit.time ?? Date())
        }()

        let formattedPaymentAmount = FormatterHelper.priceCourseRevenue(
            courseBenefit.paymentAmount,
            currencyCode: courseBenefit.currencyCode
        )
        let formattedAmount: String = {
            let sign = courseBenefit.amount > 0 ? "+" : ""
            let price = FormatterHelper.priceCourseRevenue(
                courseBenefit.amount,
                currencyCode: courseBenefit.currencyCode
            )
            return "\(sign)\(price)"
        }()

        let formattedSeatsCount: String? = {
            if let seatsCount = courseBenefit.seatsCount {
                return FormatterHelper.seatsCount(seatsCount)
            }
            return nil
        }()

        let formattedManualBenefitDescription: String? = {
            guard courseBenefit.isManualBenefit else {
                return nil
            }

            return String(
                format: NSLocalizedString("CourseRevenueTabPurchasesManualBenefitTitle", comment: ""),
                arguments: [courseBenefit.descriptionString]
            ).trimmed()
        }()

        return CourseRevenueTabPurchasesViewModel(
            uniqueIdentifier: "\(courseBenefit.id)",
            formattedDate: formattedDate,
            buyerName: formattedBuyerName,
            promoCodeName: courseBenefit.promoCode,
            formattedPaymentAmount: formattedPaymentAmount,
            formattedAmount: formattedAmount,
            formattedSeatsCount: formattedSeatsCount,
            formattedManualBenefitDescription: formattedManualBenefitDescription,
            isDebited: courseBenefit.status == .debited,
            isRefunded: courseBenefit.status == .refunded,
            isAuthorLinkUsed: courseBenefit.isAuthorLinkUsed,
            isInvoicePayment: courseBenefit.isInvoicePayment,
            isManualBenefit: courseBenefit.isManualBenefit
        )
    }
}

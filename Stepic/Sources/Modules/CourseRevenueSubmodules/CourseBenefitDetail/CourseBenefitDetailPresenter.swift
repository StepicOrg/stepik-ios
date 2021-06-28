import UIKit

protocol CourseBenefitDetailPresenterProtocol {
    func presentCourseBenefit(response: CourseBenefitDetail.CourseBenefitLoad.Response)
}

final class CourseBenefitDetailPresenter: CourseBenefitDetailPresenterProtocol {
    weak var viewController: CourseBenefitDetailViewControllerProtocol?

    func presentCourseBenefit(response: CourseBenefitDetail.CourseBenefitLoad.Response) {
        switch response.result {
        case .success(let courseBenefit):
            let viewModel = self.makeViewModel(courseBenefit: courseBenefit)
            self.viewController?.displayCourseBenefit(viewModel: .init(state: .result(data: viewModel)))
        case .failure:
            self.viewController?.displayCourseBenefit(viewModel: .init(state: .loading))
        }
    }

    private func makeViewModel(courseBenefit: CourseBenefit) -> CourseBenefitDetailViewModel {
        let formattedDate = FormatterHelper.dateStringWithFullMonthAndYear(courseBenefit.time ?? Date())

        let courseTitle: String = {
            if let course = courseBenefit.course {
                return course.title
            }
            return "Course \(courseBenefit.courseID)"
        }()

        let formattedBuyerName: String = {
            if let buyer = courseBenefit.buyer {
                return FormatterHelper.username(buyer)
            }
            return "User \(courseBenefit.buyerID)"
        }()

        let channelName: String = {
            if courseBenefit.isZLinkUsed {
                return NSLocalizedString("CourseBenefitDetailChannelZLink", comment: "")
            } else if courseBenefit.status == .refunded {
                return NSLocalizedString("CourseBenefitDetailChannelRefund", comment: "")
            } else if courseBenefit.status == .debited {
                return NSLocalizedString("CourseBenefitDetailChannelStepikLink", comment: "")
            } else {
                return "n/a"
            }
        }()

        let formattedPaymentAmount = FormatterHelper.price(
            courseBenefit.paymentAmount,
            currencyCode: courseBenefit.currencyCode
        )

        let formattedAmountPercent = String(
            format: NSLocalizedString("CourseBenefitDetailAmountPercent", comment: ""),
            arguments: [FormatterHelper.integerPercent(courseBenefit.amountPercent)]
        )
        let formattedAmount = FormatterHelper.price(courseBenefit.amount, currencyCode: courseBenefit.currencyCode)

        return CourseBenefitDetailViewModel(
            title: NSLocalizedString("CourseBenefitDetailTitle", comment: ""),
            formattedDate: formattedDate,
            courseTitle: courseTitle,
            buyerName: formattedBuyerName,
            formattedPaymentAmount: formattedPaymentAmount,
            promoCodeName: courseBenefit.promoCode,
            channelName: channelName,
            formattedAmountPercent: formattedAmountPercent,
            formattedAmount: formattedAmount
        )
    }
}

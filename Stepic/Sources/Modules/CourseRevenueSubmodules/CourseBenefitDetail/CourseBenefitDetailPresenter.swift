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
        let title = courseBenefit.status == .refunded
            ? NSLocalizedString("CourseBenefitDetailTitleRefund", comment: "")
            : NSLocalizedString("CourseBenefitDetailTitle", comment: "")

        let formattedDate: String = {
            if let moscowDateInRegion = courseBenefit.time?.inEuropeMoscow {
                return FormatterHelper.dateStringWithFullMonthAndYear(moscowDateInRegion)
            }
            return FormatterHelper.dateStringWithFullMonthAndYear(courseBenefit.time ?? Date())
        }()

        let courseTitle: String = {
            if let course = courseBenefit.course {
                return course.title
            }
            return "Course \(courseBenefit.courseID)"
        }()

        let formattedBuyerName: String? = {
            if let buyer = courseBenefit.buyer {
                return FormatterHelper.username(buyer)
            } else if let buyerID = courseBenefit.buyerID {
                return "User \(buyerID)"
            }
            return nil
        }()

        let formattedSeatsCount: String? = {
            if let seatsCount = courseBenefit.seatsCount {
                return FormatterHelper.seatsCount(seatsCount)
            }
            return nil
        }()

        let channelName: String = {
            if courseBenefit.isZLinkUsed {
                return NSLocalizedString("CourseBenefitDetailChannelZLink", comment: "")
            } else if courseBenefit.isInvoicePayment {
                return NSLocalizedString("CourseBenefitDetailChannelInvoicePayment", comment: "")
            } else if courseBenefit.isManualBenefit {
                return String(
                    format: NSLocalizedString("CourseRevenueTabPurchasesManualBenefitTitle", comment: ""),
                    arguments: [courseBenefit.descriptionString]
                ).trimmed()
            } else if courseBenefit.status == .refunded {
                return NSLocalizedString("CourseBenefitDetailChannelRefund", comment: "")
            } else if courseBenefit.status == .debited {
                return NSLocalizedString("CourseBenefitDetailChannelStepikLink", comment: "")
            } else {
                return "n/a"
            }
        }()

        let formattedPaymentAmount = FormatterHelper.priceCourseRevenue(
            courseBenefit.paymentAmount,
            currencyCode: courseBenefit.currencyCode
        )

        let formattedUserSharePercent: String = {
            if let userSharePercent = courseBenefit.userSharePercent {
                return FormatterHelper.integerPercent(userSharePercent / 100)
            }
            return "n/a"
        }()
        let formattedAmountPercent = String(
            format: NSLocalizedString("CourseBenefitDetailAmountPercent", comment: ""),
            arguments: [formattedUserSharePercent]
        )
        let formattedAmount: String = {
            let sign = courseBenefit.amount > 0 ? "+" : ""
            let price = FormatterHelper.priceCourseRevenue(
                courseBenefit.amount,
                currencyCode: courseBenefit.currencyCode
            )
            return "\(sign)\(price)"
        }()

        return CourseBenefitDetailViewModel(
            title: title,
            formattedDate: formattedDate,
            courseTitle: courseTitle,
            buyerName: formattedBuyerName,
            formattedSeatsCount: formattedSeatsCount,
            formattedPaymentAmount: formattedPaymentAmount,
            promoCodeName: courseBenefit.promoCode,
            channelName: channelName,
            formattedAmountPercent: formattedAmountPercent,
            formattedAmount: formattedAmount,
            isRefunded: courseBenefit.status == .refunded,
            isInvoicePayment: courseBenefit.isInvoicePayment,
            isManualBenefit: courseBenefit.isManualBenefit
        )
    }
}

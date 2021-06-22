import SwiftDate
import UIKit

protocol CourseRevenuePresenterProtocol {
    func presentCourseRevenue(response: CourseRevenue.CourseRevenueLoad.Response)
}

final class CourseRevenuePresenter: CourseRevenuePresenterProtocol {
    weak var viewController: CourseRevenueViewControllerProtocol?

    func presentCourseRevenue(response: CourseRevenue.CourseRevenueLoad.Response) {
        guard let viewController = self.viewController else {
            return
        }

        switch response.result {
        case .success(let data):
            guard let courseBenefitSummary = data.courseBenefitSummary else {
                return viewController.displayCourseRevenue(viewModel: .init(state: .empty))
            }

            if courseBenefitSummary.isEmpty {
                viewController.displayCourseRevenue(viewModel: .init(state: .empty))
            } else {
                let headerViewModel = self.makeHeaderViewModel(benefitSummary: courseBenefitSummary)
                viewController.displayCourseRevenue(viewModel: .init(state: .result(data: headerViewModel)))
            }
        case .failure:
            viewController.displayCourseRevenue(viewModel: .init(state: .error))
        }
    }

    private func makeHeaderViewModel(benefitSummary: CourseBenefitSummary) -> CourseRevenueHeaderViewModel {
        let currentDate = benefitSummary.currentDate ?? Date()
        let formattedCurrentDate = "\(currentDate.monthName(.defaultStandalone).capitalized) \(currentDate.year)"

        let beginPaymentDate = benefitSummary.beginPaymentDate ?? Date()
        let formattedBeginPaymentDate = "\(beginPaymentDate.monthName(.default).capitalized) \(beginPaymentDate.year)"

        let monthIncomeDateString = String(
            format: NSLocalizedString("CourseRevenueMonthIncomeDate", comment: ""),
            arguments: [formattedCurrentDate]
        )
        let monthIncomeValueString = FormatterHelper.price(
            benefitSummary.monthUserIncome,
            currencyCode: benefitSummary.currencyCode
        )

        let monthTurnoverDateString = String(
            format: NSLocalizedString("CourseRevenueMonthTurnoverDate", comment: ""),
            arguments: [formattedCurrentDate]
        )
        let monthTurnoverValueString = FormatterHelper.price(
            benefitSummary.monthTurnover,
            currencyCode: benefitSummary.currencyCode
        )

        let totalIncomeDateString = String(
            format: NSLocalizedString("CourseRevenueTotalIncomeDate", comment: ""),
            arguments: [formattedBeginPaymentDate]
        )
        let totalIncomeValueString = FormatterHelper.price(
            benefitSummary.totalUserIncome,
            currencyCode: benefitSummary.currencyCode
        )

        let totalTurnoverDateString = String(
            format: NSLocalizedString("CourseRevenueTotalTurnoverDate", comment: ""),
            arguments: [formattedBeginPaymentDate]
        )
        let totalTurnoverValueString = FormatterHelper.price(
            benefitSummary.totalTurnover,
            currencyCode: benefitSummary.currencyCode
        )

        return CourseRevenueHeaderViewModel(
            monthIncomeDate: monthIncomeDateString,
            monthIncomeValue: monthIncomeValueString,
            monthTurnoverDate: monthTurnoverDateString,
            monthTurnoverValue: monthTurnoverValueString,
            totalIncomeDate: totalIncomeDateString,
            totalIncomeValue: totalIncomeValueString,
            totalTurnoverDate: totalTurnoverDateString,
            totalTurnoverValue: totalTurnoverValueString
        )
    }
}

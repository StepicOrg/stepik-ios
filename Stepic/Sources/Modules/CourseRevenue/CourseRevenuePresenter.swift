import SwiftDate
import UIKit

protocol CourseRevenuePresenterProtocol {
    func presentCourseRevenue(response: CourseRevenue.CourseRevenueLoad.Response)
    func presentCourseInfo(response: CourseRevenue.CourseInfoPresentation.Response)
    func presentProfile(response: CourseRevenue.ProfilePresentation.Response)
}

final class CourseRevenuePresenter: CourseRevenuePresenterProtocol {
    weak var viewController: CourseRevenueViewControllerProtocol?

    func presentCourseRevenue(response: CourseRevenue.CourseRevenueLoad.Response) {
        guard let viewController = self.viewController else {
            return
        }

        switch response.result {
        case .success(let courseBenefitSummary):
            if courseBenefitSummary.isEmpty {
                let emptyHeaderViewModel = CourseRevenueEmptyHeaderViewModel(
                    title: NSLocalizedString("CourseRevenueEmptyMessage", comment: ""),
                    disclaimerText: NSLocalizedString("CourseRevenueDisclaimer", comment: "")
                )
                viewController.displayCourseRevenue(viewModel: .init(state: .empty(data: emptyHeaderViewModel)))
            } else {
                let headerViewModel = self.makeHeaderViewModel(benefitSummary: courseBenefitSummary)
                viewController.displayCourseRevenue(viewModel: .init(state: .result(data: headerViewModel)))
            }
        case .failure:
            viewController.displayCourseRevenue(viewModel: .init(state: .error))
        }
    }

    func presentCourseInfo(response: CourseRevenue.CourseInfoPresentation.Response) {
        self.viewController?.displayCourseInfo(viewModel: .init(courseID: response.courseID))
    }

    func presentProfile(response: CourseRevenue.ProfilePresentation.Response) {
        self.viewController?.displayProfile(viewModel: .init(userID: response.userID))
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
        let monthIncomeValueString = FormatterHelper.priceCourseRevenue(
            benefitSummary.monthUserIncome,
            currencyCode: benefitSummary.currencyCode
        )

        let monthTurnoverDateString = String(
            format: NSLocalizedString("CourseRevenueMonthTurnoverDate", comment: ""),
            arguments: [formattedCurrentDate]
        )
        let monthTurnoverValueString = FormatterHelper.priceCourseRevenue(
            benefitSummary.monthTurnover,
            currencyCode: benefitSummary.currencyCode
        )

        let totalIncomeDateString = String(
            format: NSLocalizedString("CourseRevenueTotalIncomeDate", comment: ""),
            arguments: [formattedBeginPaymentDate]
        )
        let totalIncomeValueString = FormatterHelper.priceCourseRevenue(
            benefitSummary.totalUserIncome,
            currencyCode: benefitSummary.currencyCode
        )

        let totalTurnoverDateString = String(
            format: NSLocalizedString("CourseRevenueTotalTurnoverDate", comment: ""),
            arguments: [formattedBeginPaymentDate]
        )
        let totalTurnoverValueString = FormatterHelper.priceCourseRevenue(
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
            totalTurnoverValue: totalTurnoverValueString,
            disclaimerText: NSLocalizedString("CourseRevenueDisclaimer", comment: "")
        )
    }
}

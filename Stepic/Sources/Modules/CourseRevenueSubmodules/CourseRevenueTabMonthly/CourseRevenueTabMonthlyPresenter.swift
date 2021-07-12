import UIKit

protocol CourseRevenueTabMonthlyPresenterProtocol {
    func presentCourseBenefitByMonths(response: CourseRevenueTabMonthly.CourseBenefitByMonthsLoad.Response)
    func presentNextCourseBenefitByMonths(response: CourseRevenueTabMonthly.NextCourseBenefitByMonthsLoad.Response)
    func presentLoadingState(response: CourseRevenueTabMonthly.LoadingStatePresentation.Response)
}

final class CourseRevenueTabMonthlyPresenter: CourseRevenueTabMonthlyPresenterProtocol {
    weak var viewController: CourseRevenueTabMonthlyViewControllerProtocol?

    func presentCourseBenefitByMonths(response: CourseRevenueTabMonthly.CourseBenefitByMonthsLoad.Response) {
        switch response.result {
        case .success(let data):
            let viewModels = data.courseBenefitByMonths.map(self.makeViewModel(_:))
            let resultData = CourseRevenueTabMonthly.CourseBenefitByMonthsResult(
                courseBenefitByMonths: viewModels,
                hasNextPage: data.hasNextPage
            )
            self.viewController?.displayCourseBenefitByMonths(viewModel: .init(state: .result(data: resultData)))
        case .failure:
            self.viewController?.displayCourseBenefitByMonths(viewModel: .init(state: .error))
        }
    }

    func presentNextCourseBenefitByMonths(response: CourseRevenueTabMonthly.NextCourseBenefitByMonthsLoad.Response) {
        switch response.result {
        case .success(let data):
            let viewModels = data.courseBenefitByMonths.map(self.makeViewModel(_:))
            let resultData = CourseRevenueTabMonthly.CourseBenefitByMonthsResult(
                courseBenefitByMonths: viewModels,
                hasNextPage: data.hasNextPage
            )
            self.viewController?.displayNextCourseBenefitByMonths(viewModel: .init(state: .result(data: resultData)))
        case .failure:
            self.viewController?.displayCourseBenefitByMonths(viewModel: .init(state: .error))
        }
    }

    func presentLoadingState(response: CourseRevenueTabMonthly.LoadingStatePresentation.Response) {
        self.viewController?.displayLoadingState(viewModel: .init())
    }

    private func makeViewModel(_ courseBenefitByMonth: CourseBenefitByMonth) -> CourseRevenueTabMonthlyViewModel {
        let formattedDate: String = {
            if let date = courseBenefitByMonth.date {
                return "\(date.monthName(.defaultStandalone).capitalized) \(date.year)"
            }
            return "\(courseBenefitByMonth.monthNumber) \(courseBenefitByMonth.yearNumber)"
        }()

        let formattedTotalIncome: String = {
            let sign = courseBenefitByMonth.totalUserIncome > 0
                ? "+"
                : (courseBenefitByMonth.totalUserIncome < 0 ? "-" : "")
            let price = FormatterHelper.price(
                courseBenefitByMonth.totalUserIncome,
                currencyCode: courseBenefitByMonth.currencyCode
            )
            return "\(sign)\(price)"
        }()
        let formattedTotalTurnover = FormatterHelper.price(
            courseBenefitByMonth.totalTurnover,
            currencyCode: courseBenefitByMonth.currencyCode
        )
        let formattedTotalRefunds = FormatterHelper.price(
            courseBenefitByMonth.totalRefunds,
            currencyCode: courseBenefitByMonth.currencyCode
        )

        return CourseRevenueTabMonthlyViewModel(
            uniqueIdentifier: courseBenefitByMonth.id,
            formattedDate: formattedDate,
            formattedTotalIncome: formattedTotalIncome,
            formattedTotalTurnover: formattedTotalTurnover,
            formattedTotalRefunds: formattedTotalRefunds,
            totalIncome: courseBenefitByMonth.totalUserIncome,
            totalRefunds: courseBenefitByMonth.totalRefunds,
            countPayments: courseBenefitByMonth.countPayments,
            countNonZPayments: courseBenefitByMonth.countNonZPayments,
            countZPayments: courseBenefitByMonth.countZPayments
        )
    }
}

import Foundation

enum CourseRevenueTabMonthly {
    struct CourseBenefitByMonthsData {
        let courseBenefitByMonths: [CourseBenefitByMonth]
        let hasNextPage: Bool
    }

    struct CourseBenefitByMonthsResult {
        let courseBenefitByMonths: [CourseRevenueTabMonthlyViewModel]
        let hasNextPage: Bool
    }

    enum CourseBenefitByMonthsLoad {
        struct Request {}

        struct Response {
            let result: StepikResult<CourseBenefitByMonthsData>
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    enum NextCourseBenefitByMonthsLoad {
        struct Request {}

        struct Response {
            let result: StepikResult<CourseBenefitByMonthsData>
        }

        struct ViewModel {
            let state: PaginationState
        }
    }

    enum LoadingStatePresentation {
        struct Response {}

        struct ViewModel {}
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case error
        case result(data: CourseBenefitByMonthsResult)
    }

    enum PaginationState {
        case error
        case result(data: CourseBenefitByMonthsResult)
    }
}

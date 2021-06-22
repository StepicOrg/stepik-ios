import Foundation

enum CourseRevenue {
    /// Load & show course revenue
    enum CourseRevenueLoad {
        struct Request {}

        struct Response {
            struct Data {
                let courseBenefitSummary: CourseBenefitSummary?
            }

            let result: StepikResult<Data>
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case error
        case empty
        case result(data: CourseRevenueHeaderViewModel)
    }
}

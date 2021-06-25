import Foundation

enum CourseRevenue {
    enum Tab: CaseIterable {
        case purchasesAndRefunds
        case payments

        var title: String {
            switch self {
            case .purchasesAndRefunds:
                return NSLocalizedString("CourseRevenueTabPurchasesAndRefunds", comment: "")
            case .payments:
                return NSLocalizedString("CourseRevenueTabPayments", comment: "")
            }
        }
    }

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

    /// Register submodules
    enum SubmoduleRegistration {
        struct Request {
            var submodules: [Int: CourseRevenueSubmoduleProtocol]
        }
    }

    /// Send Course benefits summary clicked event
    enum CourseSummaryClickAction {
        struct Request {
            let expanded: Bool
        }
    }

    enum CourseInfoPresentation {
        struct Response {
            let courseID: Course.IdType
        }

        struct ViewModel {
            let courseID: Course.IdType
        }
    }

    enum ProfilePresentation {
        struct Response {
            let userID: User.IdType
        }

        struct ViewModel {
            let userID: User.IdType
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

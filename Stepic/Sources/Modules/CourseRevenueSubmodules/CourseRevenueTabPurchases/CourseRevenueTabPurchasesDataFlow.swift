import Foundation

enum CourseRevenueTabPurchases {
    struct PurchasesResult {
        let courseBenefits: [CourseRevenueTabPurchasesViewModel]
        let hasNextPage: Bool
    }

    enum PurchasesLoad {
        struct Request {}

        struct Data {
            let courseBenefits: [CourseBenefit]
            let hasNextPage: Bool
        }

        struct Response {
            let result: StepikResult<Data>
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    /// Load next part purchases
    enum NextPurchasesLoad {
        struct Request {}

        struct Response {
            let courseBenefits: [CourseBenefit]
            let hasNextPage: Bool
        }

        struct ViewModel {
            let state: PaginationState
        }
    }

    /// Present purchase details
    enum PurchasePresentation {
        struct Request {
            let viewModelUniqueIdentifier: UniqueIdentifierType
        }
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case error
        case result(data: PurchasesResult)
    }

    enum PaginationState {
        case error
        case result(data: PurchasesResult)
    }
}

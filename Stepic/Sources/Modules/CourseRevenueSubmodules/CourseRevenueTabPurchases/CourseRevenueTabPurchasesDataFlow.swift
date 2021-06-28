import Foundation

enum CourseRevenueTabPurchases {
    struct PurchasesData {
        let courseBenefits: [CourseBenefit]
        let hasNextPage: Bool
    }

    struct PurchasesResult {
        let courseBenefits: [CourseRevenueTabPurchasesViewModel]
        let hasNextPage: Bool
    }

    enum PurchasesLoad {
        struct Request {}

        struct Response {
            let result: StepikResult<PurchasesData>
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    /// Load next part purchases
    enum NextPurchasesLoad {
        struct Request {}

        struct Response {
            let result: StepikResult<PurchasesData>
        }

        struct ViewModel {
            let state: PaginationState
        }
    }

    /// Present purchase details
    enum PurchaseDetailsPresentation {
        struct Request {
            let viewModelUniqueIdentifier: UniqueIdentifierType
        }

        struct Response {
            let courseBenefitID: CourseBenefit.IdType
        }

        struct ViewModel {
            let courseBenefitID: CourseBenefit.IdType
        }
    }

    enum CourseInfoPresentation {
        struct Request {
            let courseID: Course.IdType
        }
    }

    enum ProfilePresentation {
        struct Request {
            let userID: User.IdType
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
        case result(data: PurchasesResult)
    }

    enum PaginationState {
        case error
        case result(data: PurchasesResult)
    }
}

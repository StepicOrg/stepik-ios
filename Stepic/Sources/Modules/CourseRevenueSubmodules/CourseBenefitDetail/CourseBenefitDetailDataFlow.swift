import Foundation

enum CourseBenefitDetail {
    enum CourseBenefitLoad {
        struct Request {}

        struct Response {
            let result: StepikResult<CourseBenefit>
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    enum CourseInfoPresentation {
        struct Request {}
    }

    enum BuyerProfilePresentation {
        struct Request {}
    }

    enum ViewControllerState {
        case loading
        case result(data: CourseBenefitDetailViewModel)
    }
}

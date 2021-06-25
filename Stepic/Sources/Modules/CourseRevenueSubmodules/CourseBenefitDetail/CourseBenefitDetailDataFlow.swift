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

    enum ViewControllerState {
        case loading
        case result(data: CourseBenefitDetailViewModel)
    }
}

import Foundation

enum CertificateDetail {
    enum CertificateLoad {
        struct Data {
            let certificate: Certificate
            let currentUserID: User.IdType?
        }

        struct Request {}

        struct Response {
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
        case result(data: CertificateDetailViewModel)
    }
}

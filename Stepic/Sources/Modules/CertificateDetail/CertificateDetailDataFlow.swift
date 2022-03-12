import Foundation

enum CertificateDetail {
    /// Show certificate
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

    /// Show certificate PDF in the web
    enum CertificatePDFPresentation {
        struct Request {}

        struct Response {
            let url: URL
        }

        struct ViewModel {
            let url: URL
        }
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case error
        case result(data: CertificateDetailViewModel)
    }
}

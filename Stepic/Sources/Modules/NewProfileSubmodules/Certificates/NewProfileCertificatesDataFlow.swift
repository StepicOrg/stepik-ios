import Foundation

enum NewProfileCertificates {
    /// Show certificates
    enum CertificatesLoad {
        struct Request {}

        struct Response {
            let result: Result<[Certificate], Error>
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    // MARK: - States

    enum ViewControllerState {
        case loading
        case error
        case result(data: NewProfileCertificatesViewModel)
    }
}

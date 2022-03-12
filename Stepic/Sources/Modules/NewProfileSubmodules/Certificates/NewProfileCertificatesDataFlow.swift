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

    /// Show CertificateDetail module
    enum CertificateDetailPresentation {
        struct Request {
            let viewModelUniqueIdentifier: UniqueIdentifierType
        }

        struct Response {
            let certificateID: Certificate.IdType
        }

        struct ViewModel {
            let certificateID: Certificate.IdType
        }
    }

    // MARK: - States

    enum ViewControllerState {
        case loading
        case error
        case result(data: NewProfileCertificatesViewModel)
    }
}

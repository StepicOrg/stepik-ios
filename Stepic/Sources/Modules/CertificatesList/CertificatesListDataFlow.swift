import Foundation

enum CertificatesList {
    /// Show certificates list
    enum CertificatesLoad {
        struct Request {}

        struct Response {
            let result: StepikResult<CertificatesData>
        }

        struct ViewModel {
            let state: ViewControllerState
        }
    }

    /// Load next part/page of the certificates
    enum NextCertificatesLoad {
        struct Request {}

        struct Response {
            let result: StepikResult<CertificatesData>
        }

        struct ViewModel {
            let state: PaginationState
        }
    }

    /// Show certificate detail module
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

    // MARK: Types

    struct CertificatesData {
        let certificates: [Certificate]
        let hasNextPage: Bool
    }

    struct CertificatesResult {
        let certificates: [CertificatesListItemViewModel]
        let hasNextPage: Bool
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case error
        case result(data: CertificatesResult)
    }

    enum PaginationState {
        case error
        case result(data: CertificatesResult)
    }
}

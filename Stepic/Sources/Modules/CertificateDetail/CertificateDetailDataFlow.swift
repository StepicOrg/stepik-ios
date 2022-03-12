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

    /// Share certificate
    enum CertificateSharePresentation {
        struct Request {}

        struct Response {
            let certificateID: Certificate.IdType
        }

        struct ViewModel {
            let url: URL
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

    /// Show course info module
    enum CoursePresentation {
        struct Request {}

        struct Response {
            let courseID: Course.IdType
            let certificateID: Certificate.IdType
        }

        struct ViewModel {
            let courseID: Course.IdType
            let certificateID: Certificate.IdType
        }
    }

    /// Show user profile module
    enum RecipientPresentation {
        struct Request {}

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
        case result(data: CertificateDetailViewModel)
    }
}

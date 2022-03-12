import Foundation

enum CertificateDetail {
    struct CertificateData {
        let certificate: Certificate
        let currentUserID: User.IdType?
    }

    /// Show certificate
    enum CertificateLoad {
        struct Request {}

        struct Response {
            let result: StepikResult<CertificateData>
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

    /// Input new recipient name
    enum PromptForChangeCertificateNameInput {
        struct Request {
            var predefinedNewFullName: String?
        }

        struct Response {
            let certificate: Certificate
            let predefinedNewFullName: String?
        }

        struct ViewModel {
            let editsCount: Int
            let allowedEditsCount: Int
            let savedFullName: String
            let predefinedNewFullName: String?
        }
    }

    /// Perform recipient name update
    enum UpdateCertificateRecipientName {
        struct Request {
            let newFullName: String
        }

        struct Response {
            var predefinedNewFullName: String?
            let result: StepikResult<CertificateData>
        }

        struct ViewModel {
            let state: UpdateCertificateRecipientNameState
        }
    }

    // MARK: States

    enum ViewControllerState {
        case loading
        case error
        case result(data: CertificateDetailViewModel)
    }

    enum UpdateCertificateRecipientNameState {
        case failure(predefinedNewFullName: String?)
        case success(data: CertificateDetailViewModel)
    }
}

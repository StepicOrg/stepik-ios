import Foundation

enum NewProfileCertificates {
    /// Show certificates
    enum CertificatesLoad {
        struct Request {}

        struct Response {
            let result: Result<[Certificate], Error>
        }

        struct ViewModel {}
    }
}

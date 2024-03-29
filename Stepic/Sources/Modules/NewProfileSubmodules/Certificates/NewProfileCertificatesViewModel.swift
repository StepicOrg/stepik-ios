import Foundation

struct NewProfileCertificatesCertificateViewModel: UniqueIdentifiable {
    let uniqueIdentifier: UniqueIdentifierType
    let courseTitle: String
    let courseImageURL: URL?
    let certificateGrade: Int?
    let certificateURL: URL?
    let certificateType: CertificateType
}

struct NewProfileCertificatesViewModel {
    let certificates: [NewProfileCertificatesCertificateViewModel]
}

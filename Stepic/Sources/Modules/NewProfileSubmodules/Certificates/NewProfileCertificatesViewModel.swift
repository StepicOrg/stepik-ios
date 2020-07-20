import Foundation

struct NewProfileCertificatesCertificateViewModel {
    let courseTitle: String
    let courseImageURL: URL?
    let certificateGrade: Int?
    let certificateType: Certificate.CertificateType
}

struct NewProfileCertificatesViewModel {
    let certificates: [NewProfileCertificatesCertificateViewModel]
}

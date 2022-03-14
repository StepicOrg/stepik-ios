import Foundation

struct CertificatesListItemViewModel: UniqueIdentifiable {
    let uniqueIdentifier: UniqueIdentifierType

    let courseTitle: String
    let courseCoverURL: URL?

    let formattedIssueDate: String?
    let formattedGrade: String

    let certificateType: CertificateType
}

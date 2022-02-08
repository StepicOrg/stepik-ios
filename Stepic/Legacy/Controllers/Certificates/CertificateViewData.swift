import Foundation

struct CertificateViewData: UniqueIdentifiable {
    let uniqueIdentifier: UniqueIdentifierType

    let courseName: String?
    let courseImageURL: URL?
    let grade: Int
    let certificateURL: URL?
    let certificateDescription: String?

    let isEditAvailable: Bool
    let editsCount: Int
    let allowedEditsCount: Int
    let savedFullName: String
}

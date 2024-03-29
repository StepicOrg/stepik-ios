import Foundation

struct CertificateDetailViewModel {
    let formattedIssueDate: String?
    let formattedGrade: String

    let courseTitle: String
    let userFullName: String

    let formattedUserRank: String?

    let previewURL: URL?
    let shareURL: URL?

    let isEditAvailable: Bool
    let isEditAllowed: Bool

    let isWithDistinction: Bool
}

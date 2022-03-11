import Foundation

struct CertificateDetailViewModel {
    let formattedIssueDate: String?
    let formattedGrade: String

    let courseTitle: String
    let userFullName: String

    let formattedUserRank: String?

    let previewURL: URL?

    let isEditAvailable: Bool
    let isWithDistinction: Bool
}

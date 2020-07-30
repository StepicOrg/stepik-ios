import Foundation

struct NewProfileHeaderViewModel {
    let avatarURL: URL?
    let coverURL: URL?
    let username: String
    let shortBio: String
    let reputationCount: Int
    let knowledgeCount: Int
    let issuedCertificatesCount: Int
    let createdCoursesCount: Int
    let isOrganization: Bool

    var isStretchyHeaderAvailable: Bool {
        self.isOrganization && self.coverURL != nil
    }
}

struct NewProfileViewModel {
    let headerViewModel: NewProfileHeaderViewModel

    let userID: User.IdType
    let userDetails: String
    let isCurrentUserProfile: Bool
    let socialProfilesCount: Int
}

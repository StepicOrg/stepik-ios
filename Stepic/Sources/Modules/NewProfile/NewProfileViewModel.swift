import Foundation

struct NewProfileHeaderViewModel {
    let avatarURL: URL?
    let username: String
    let shortBio: String
    let reputationCount: Int?
    let knowledgeCount: Int?
}

struct NewProfileViewModel {
    let headerViewModel: NewProfileHeaderViewModel

    let userID: User.IdType
    let userDetails: String
    let isCurrentUserProfile: Bool
}

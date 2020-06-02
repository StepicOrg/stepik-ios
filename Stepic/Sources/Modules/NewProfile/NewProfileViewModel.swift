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

    let userDetails: String
    let formattedUserID: String
}

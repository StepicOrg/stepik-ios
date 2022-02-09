import UIKit

struct CourseInfoTabInfoAuthorViewModel {
    let id: User.IdType
    let name: String
    let avatarImageURL: URL?
}

struct CourseInfoTabInfoInstructorViewModel {
    let id: User.IdType
    let avatarImageURL: URL?
    let title: String
    let description: String
}

struct CourseInfoTabInfoViewModel {
    let authors: [CourseInfoTabInfoAuthorViewModel]

    let acquiredSkills: [String]

    let introVideoURL: URL?
    let introVideoThumbnailURL: URL?

    let summaryText: String
    let aboutText: String
    let requirementsText: String
    let targetAudienceText: String

    let timeToCompleteText: String
    let languageText: String
    let certificateText: String
    let certificateDetailsText: String?

    let instructors: [CourseInfoTabInfoInstructorViewModel]
}

import UIKit

struct CourseInfoTabInfoViewModel {
    let author: String

    let introVideoURL: URL?
    let introVideoThumbnailURL: URL?

    let aboutText: String
    let requirementsText: String
    let targetAudienceText: String

    let timeToCompleteText: String
    let languageText: String
    let certificateText: String?
    let certificateDetailsText: String?

    let instructors: [CourseInfoTabInfoInstructorViewModel]
}

struct CourseInfoTabInfoInstructorViewModel {
    let avatarImageURL: URL?
    let title: String
    let description: String
}

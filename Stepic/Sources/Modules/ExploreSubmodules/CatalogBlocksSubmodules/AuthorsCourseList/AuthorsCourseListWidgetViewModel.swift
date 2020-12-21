import Foundation

struct AuthorsCourseListWidgetViewModel: UniqueIdentifiable {
    let uniqueIdentifier: UniqueIdentifierType
    let title: String
    let avatarURLString: String
    let formattedCreatedCoursesCountString: String
    let formattedFollowersCountString: String

    var avatarURL: URL? {
        URL(string: self.avatarURLString)
    }
}

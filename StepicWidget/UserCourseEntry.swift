import WidgetKit

struct UserCourseEntry: Codable, TimelineEntry {
    var date: Date = Date()
    let title: String
    let subtitle: String
    let progress: Float
    let thumbnailData: Data?
}

extension UserCourseEntry {
    static let snapshotEntry = UserCourseEntry(
        title: "Creating a course on Stepik",
        subtitle: "by Stepik Team",
        progress: 76.0,
        thumbnailData: nil
    )
}
